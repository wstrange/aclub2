import 'dart:io';

import 'package:firebase_admin_sdk/messaging.dart' as admin_messaging;
import 'package:firebase_functions/firebase_functions.dart';
import 'package:shared_models/shared_models.dart';
import 'package:firebase_functions/logger.dart' as logger;

/// Sends a notification to a single user via in-app and FCM push channels,
/// respecting the user's [NotificationPreferences].
Future<void> sendNotificationToUser({
  required Firebase firebase,
  required String userId,
  required String title,
  required String message,
  required String link,
  required String type,
  required String sectionId,
  required String eventId,
}) async {
  final firestore = firebase.adminApp.firestore();

  final userDoc = await firestore.doc('users/$userId').get();
  if (!userDoc.exists) return;

  final UserProfile profile;
  try {
    profile = UserProfile.fromJson({...?userDoc.data(), 'id': userId});
  } on Object catch (error) {
    logger.info('Skipping malformed profile for $userId: $error');
    return;
  }

  final prefs = profile.notificationPreferences;
  final channels = <String>[];

  if (prefs.inAppEnabled) {
    channels.add('inApp');
    final ref = firestore.collection('notifications').doc();
    final notification = NotificationModel(
      id: ref.id,
      recipientId: userId,
      title: title,
      message: message,
      link: link,
      channels: const ['inApp'],
      isRead: false,
      relatedEventId: eventId,
      relatedSectionId: sectionId,
      createdAt: DateTime.now().toUtc(),
    );
    await ref.set(notification.toJson());
    logger.info('In-app notification written for user $userId (type=$type)');
  }

  if (prefs.pushEnabled && profile.fcmTokens.isNotEmpty) {
    channels.add('push');
    final data = <String, String>{'type': type, 'sectionId': sectionId, 'eventId': eventId, 'link': link};

    if (Platform.environment['FUNCTIONS_EMULATOR'] == 'true') {
      logger.info(
        '[emulator] FCM push skipped (no FCM emulator). '
        'Would send to ${profile.fcmTokens.length} device token(s) for user $userId.',
      );
    } else {
      final messaging = firebase.adminApp.messaging();
      final response = await messaging.sendEachForMulticast(
        admin_messaging.MulticastMessage(
          tokens: profile.fcmTokens,
          notification: admin_messaging.Notification(title: title, body: message),
          data: data,
        ),
      );
      logger.info('FCM push sent to $userId: success=${response.successCount}, failure=${response.failureCount}.');
    }
  }
}

/// Notifies all interested members of [sectionId] that a new event is available.
/// Respects [NotificationPreferences.notifyForNewEvents].
Future<void> notifySectionMembersOfEvent({
  required Firebase firebase,
  required String sectionId,
  required String eventId,
  required String title,
  required String message,
  required String type,
}) async {
  final firestore = firebase.adminApp.firestore();
  final link = '/events/$eventId';
  final data = <String, String>{'type': type, 'sectionId': sectionId, 'eventId': eventId, 'link': link};

  try {
    final pushTokens = <String>[];
    final inAppRecipients = <String>[];

    final membersQuery = await firestore.collection('sections/$sectionId/members').get();
    for (final member in membersQuery.docs) {
      final profileDoc = await firestore.doc('users/${member.id}').get();
      if (!profileDoc.exists) continue;

      final UserProfile profile;
      try {
        profile = UserProfile.fromJson({...?profileDoc.data(), 'id': member.id});
      } on Object catch (error) {
        logger.info('Skipping malformed profile for ${member.id}: $error');
        continue;
      }

      final prefs = profile.notificationPreferences;
      if (!prefs.notifyForNewEvents) continue;

      if (prefs.inAppEnabled) {
        inAppRecipients.add(member.id);
      }
      if (prefs.pushEnabled && profile.fcmTokens.isNotEmpty) {
        pushTokens.addAll(profile.fcmTokens);
      }
    }

    // FCM Push
    if (pushTokens.isNotEmpty) {
      if (Platform.environment['FUNCTIONS_EMULATOR'] == 'true') {
        logger.info(
          '[emulator] FCM push skipped (no FCM emulator). '
          'Would send to ${pushTokens.length} device token(s).',
        );
      } else {
        final messaging = firebase.adminApp.messaging();
        final response = await messaging.sendEachForMulticast(
          admin_messaging.MulticastMessage(
            tokens: pushTokens,
            notification: admin_messaging.Notification(title: title, body: message),
            data: data,
          ),
        );
        logger.info('FCM push sent: success=${response.successCount}, failure=${response.failureCount}.');
      }
    }

    // In-app notifications
    for (final userId in inAppRecipients) {
      final ref = firestore.collection('notifications').doc();
      final notification = NotificationModel(
        id: ref.id,
        recipientId: userId,
        title: title,
        message: message,
        link: link,
        channels: const ['inApp'],
        isRead: false,
        relatedEventId: eventId,
        relatedSectionId: sectionId,
        createdAt: DateTime.now().toUtc(),
      );
      await ref.set(notification.toJson());
    }
    if (inAppRecipients.isNotEmpty) {
      logger.info('In-app notifications written for ${inAppRecipients.length} member(s).');
    }
  } catch (error, stackTrace) {
    logger.error('Failed to notify section members for event $eventId: $error\n$stackTrace');
  }
}

/// Notifies trip leaders and creator of an event that a member has withdrawn
/// their registration.
///
Future<void> notifyTripLeadersOfWithdrawal({
  required Firebase firebase,
  required String sectionId,
  required String eventId,
  required String eventTitle,
  required Map<String, dynamic> eventData,
  required String withdrawingUserId,
}) async {
  final firestore = firebase.adminApp.firestore();

  // Find withdrawing member's name
  String memberName = 'A member';
  final memberDoc = await firestore.doc('users/$withdrawingUserId').get();
  if (memberDoc.exists) {
    final data = memberDoc.data();
    final first = data?['firstName']?.toString() ?? '';
    final last = data?['lastName']?.toString() ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) {
      memberName = full;
    }
  }

  // Collect unique leader IDs (tripLeaderIds + creatorId)
  final leaders = <String>{};
  final tripLeaderIds = eventData['tripLeaderIds'];
  if (tripLeaderIds is List) {
    for (final id in tripLeaderIds) {
      if (id != null && id.toString().isNotEmpty) {
        leaders.add(id.toString());
      }
    }
  }
  final creatorId = eventData['creatorId']?.toString();
  if (creatorId != null && creatorId.isNotEmpty) {
    leaders.add(creatorId);
  }

  // Don't notify the withdrawing member themselves if they are listed as a leader
  leaders.remove(withdrawingUserId);

  for (final leaderId in leaders) {
    await sendNotificationToUser(
      firebase: firebase,
      userId: leaderId,
      title: 'Withdrawal: $eventTitle',
      message: '$memberName has withdrawn from "$eventTitle".',
      link: '/events/$eventId',
      type: 'registration_withdrawn',
      sectionId: sectionId,
      eventId: eventId,
    );
  }
}

/// Notifies trip leaders and creator of an event that an applicant submitted a
/// pending registration request.
Future<void> notifyTripLeadersOfPendingRegistration({
  required Firebase firebase,
  required String sectionId,
  required String eventId,
  required String eventTitle,
  required Map<String, dynamic> eventData,
  required String applicantUserId,
}) async {
  final firestore = firebase.adminApp.firestore();

  // Find applicant name
  String applicantName = 'A member';
  final applicantDoc = await firestore.doc('users/$applicantUserId').get();
  if (applicantDoc.exists) {
    final data = applicantDoc.data();
    final first = data?['firstName']?.toString() ?? '';
    final last = data?['lastName']?.toString() ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) {
      applicantName = full;
    }
  }

  // Collect unique leader IDs (tripLeaderIds + creatorId)
  final leaders = <String>{};
  final tripLeaderIds = eventData['tripLeaderIds'];
  if (tripLeaderIds is List) {
    for (final id in tripLeaderIds) {
      if (id != null && id.toString().isNotEmpty) {
        leaders.add(id.toString());
      }
    }
  }
  final creatorId = eventData['creatorId']?.toString();
  if (creatorId != null && creatorId.isNotEmpty) {
    leaders.add(creatorId);
  }

  // Don't notify the applicant themselves if they are listed as leader
  leaders.remove(applicantUserId);

  for (final leaderId in leaders) {
    await sendNotificationToUser(
      firebase: firebase,
      userId: leaderId,
      title: 'New Registration: $eventTitle',
      message: '$applicantName requested to join "$eventTitle".',
      link: '/events/$eventId',
      type: 'registration_pending',
      sectionId: sectionId,
      eventId: eventId,
    );
  }
}
