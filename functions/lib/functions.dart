// ignore_for_file: experimental_member_use

import 'dart:io';

import 'package:firebase_admin_sdk/firestore.dart' as admin_firestore;
import 'package:firebase_admin_sdk/messaging.dart' as admin_messaging;
import 'package:firebase_functions/firebase_functions.dart';
import 'package:shared_models/shared_models.dart';

/// Registers all Cloud Functions (HTTP endpoints and background triggers).
///
/// Called from `bin/server.dart` at startup.
void registerFunctions(Firebase firebase) {
  firebase.https.onRequest(name: 'helloWorld', helloWorld);
  firebase.firestore.onDocumentCreated(
    document: 'sections/{sectionId}/events/{eventId}',
    (event) => onNewEventCreated(event, firebase),
  );
}

/// Health check Cloud Function: `/helloWorld`
Future<Response> helloWorld(Request request) async {
  return Response.ok('Hello from aclub Dart Functions!');
}

/// Firestore trigger that fires when a new event document is added to
/// `/sections/{sectionId}/events/{eventId}`.
///
/// Notifies interested members of the section (see
/// `NotificationPreferences.notifyForNewEvents`):
///   * pushes an FCM notification to each opted-in device token, and
///   * writes an in-app notification to `/notifications/{notificationId}`.
///
/// The Firebase emulator does not provide an FCM emulator, so push sends are
/// skipped there (logged instead). In-app notifications still work.
Future<void> onNewEventCreated(FirestoreEvent<EmulatorDocumentSnapshot?> event, Firebase firebase) async {
  final eventData = event.data?.data() ?? <String, dynamic>{};
  final sectionId = event.params['sectionId'] ?? '';
  final eventId = event.data?.id ?? '';
  final title = eventData['title']?.toString() ?? 'Untitled event';

  logger.info('New event created: eventId=$eventId, sectionId=$sectionId, title=$title');

  final message = 'A new event has been added to the calendar .';
  final data = <String, String>{
    'type': 'new_event',
    'sectionId': sectionId,
    'eventId': eventId,
    'link': '/events/$eventId',
  };

  // Admin Firestore talks to the local Firestore emulator via
  // FIRESTORE_EMULATOR_HOST (set by the Functions emulator), so reads/writes
  // work out of the box here.
  final firestore = admin_firestore.Firestore.internal(firebase.adminApp).getDatabase();

  try {
    final pushTokens = <String>[];
    final inAppRecipients = <String>[];

    // ── Find interested section members ──────────────────────────────────
    final membersQuery = await firestore.collection('sections/$sectionId/members').get();
    for (final member in membersQuery.docs) {
      final profileDoc = await firestore.doc('users/${member.id}').get();
      //logger.info('got profile: $profileDoc');
      if (!profileDoc.exists) continue;

      final UserProfile profile;
      try {
        profile = UserProfile.fromJson({...?profileDoc.data(), 'id': member.id});
      } on Object catch (error) {
        logger.warn('Skipping malformed profile for ${member.id}: $error');
        continue;
      }

      final prefs = profile.notificationPreferences;
      //logger.info('prefs for user $profile ${member.id}: $prefs');
      if (!prefs.notifyForNewEvents) continue;

      if (prefs.inAppEnabled) {
        //logger.info('Adding user ${member.id} to in-app recipients');
        inAppRecipients.add(member.id);
      }
      if (prefs.pushEnabled && profile.fcmTokens.isNotEmpty) {
        pushTokens.addAll(profile.fcmTokens);
      }
    }

    // ── Push channel ─────────────────────────────────────────────────────
    if (pushTokens.isNotEmpty) {
      if (Platform.environment['FUNCTIONS_EMULATOR'] == 'true') {
        logger.info(
          '[emulator] FCM push skipped (no FCM emulator). '
          'Would send to ${pushTokens.length} device token(s).',
        );
      } else {
        final messaging = admin_messaging.Messaging.internal(firebase.adminApp);
        final response = await messaging.sendEachForMulticast(
          admin_messaging.MulticastMessage(
            tokens: pushTokens,
            notification: admin_messaging.Notification(title: title, body: message),
            data: data,
          ),
        );
        logger.info(
          'FCM push sent: success=${response.successCount}, '
          'failure=${response.failureCount}.',
        );
      }
    }

    // ── In-app channel ───────────────────────────────────────────────────
    for (final userId in inAppRecipients) {
      final ref = firestore.collection('notifications').doc();
      final notification = NotificationModel(
        id: ref.id,
        recipientId: userId,
        title: title,
        message: message,
        link: data['link'],
        channels: const ['inApp'],
        isRead: false,
        relatedEventId: eventId,
        relatedSectionId: sectionId,
        createdAt: DateTime.now().toUtc(),
      );
      // NotificationModel.toJson() passes DateTime values through (see
      // TimestampConverter.toJson), so the Firestore serializer stores
      // createdAt as a native Timestamp.
      await ref.set(notification.toJson());
    }
    if (inAppRecipients.isNotEmpty) {
      logger.info('In-app notification written for ${inAppRecipients.length} member(s).');
    }
  } catch (error, stackTrace) {
    logger.error(
      'Failed to process notifications for event $eventId: '
      '$error\n$stackTrace',
    );
  }
}
