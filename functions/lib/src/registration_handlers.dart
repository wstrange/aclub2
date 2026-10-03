import 'package:firebase_functions/firebase_functions.dart';
import 'package:shared_models/shared_models.dart';
import 'package:firebase_functions/logger.dart' as logger;
import 'event_handlers.dart';
import 'notification_dispatcher.dart';

/// Helper to fetch registration data from Firestore if not provided.
Future<Map<String, dynamic>> fetchRegistrationData(
  Firebase firebase,
  String sectionId,
  String eventId,
  String registrationId,
) async {
  try {
    final doc = await firebase.adminApp
        .firestore()
        .doc('sections/$sectionId/events/$eventId/registrations/$registrationId')
        .get();
    return doc.data() ?? <String, dynamic>{};
  } catch (error) {
    logger.info('Failed to fetch registration $registrationId in event $eventId: $error');
    return <String, dynamic>{};
  }
}

/// Core logic for handling a created registration (used by emulator trigger & HTTPS endpoints).
///
/// * When status is [RegistrationStatus.pending], notifies the trip leaders and
///   creator of the event that a member has requested to join.
/// * When status is [RegistrationStatus.approved] and was added by a leader
///   (authId != userId), notifies the member that they have been added.
/// * When status is [RegistrationStatus.waitlisted], notifies the member that
///   they are on the waitlist.
Future<void> handleRegistrationCreated({
  required Firebase firebase,
  required String sectionId,
  required String eventId,
  required String registrationId,
  String? userId,
  String? status,
  String? authId,
  Map<String, dynamic>? regData,
}) async {
  if (sectionId.isEmpty || eventId.isEmpty || registrationId.isEmpty) return;

  if (userId == null || status == null) {
    final fetched = await fetchRegistrationData(firebase, sectionId, eventId, registrationId);
    userId ??= fetched['userId']?.toString();
    status ??= fetched['status']?.toString();
  }

  userId ??= registrationId;
  if (userId.isEmpty) return;

  final eventData = await fetchEventData(firebase, sectionId, eventId);
  final eventTitle = eventData['title']?.toString() ?? 'Event';

  if (status == RegistrationStatus.pending.name) {
    logger.info('Pending registration created for $userId on event $eventId. Notifying leaders.');
    await notifyTripLeadersOfPendingRegistration(
      firebase: firebase,
      sectionId: sectionId,
      eventId: eventId,
      eventTitle: eventTitle,
      eventData: eventData,
      applicantUserId: userId,
    );
  } else if (status == RegistrationStatus.approved.name) {
    // If added by a leader or manager (not self-registered)
    if (authId != null && authId != userId) {
      logger.info('User $userId added to event $eventId by leader $authId.');
      await sendNotificationToUser(
        firebase: firebase,
        userId: userId,
        title: 'Added to Event: $eventTitle',
        message: 'You have been added to "$eventTitle".',
        link: '/events/$eventId',
        type: 'registration_added',
        sectionId: sectionId,
        eventId: eventId,
      );
    }
  } else if (status == RegistrationStatus.waitlisted.name) {
    logger.info('User $userId added to waitlist for event $eventId.');
    await sendNotificationToUser(
      firebase: firebase,
      userId: userId,
      title: 'Waitlist: $eventTitle',
      message: 'You are on the waitlist for "$eventTitle".',
      link: '/events/$eventId',
      type: 'registration_waitlisted',
      sectionId: sectionId,
      eventId: eventId,
    );
  }
}

/// Core logic for handling an updated registration (used by emulator trigger & HTTPS endpoints).
///
/// * When transitioning to [RegistrationStatus.approved], notifies the member
///   that their registration was approved.
/// * When transitioning to [RegistrationStatus.waitlisted], notifies the member
///   that they have been moved to the waitlist.
/// * When transitioning to [RegistrationStatus.rejected], notifies the member
///   that their registration was not approved.
Future<void> handleRegistrationUpdated({
  required Firebase firebase,
  required String sectionId,
  required String eventId,
  required String registrationId,
  String? userId,
  String? beforeStatus,
  String? afterStatus,
  Map<String, dynamic>? beforeData,
  Map<String, dynamic>? afterData,
}) async {
  if (sectionId.isEmpty || eventId.isEmpty || registrationId.isEmpty) return;

  if (userId == null || afterStatus == null) {
    final fetched = await fetchRegistrationData(firebase, sectionId, eventId, registrationId);
    userId ??= fetched['userId']?.toString();
    afterStatus ??= fetched['status']?.toString();
  }

  userId ??= registrationId;
  if (userId.isEmpty) return;
  if (beforeStatus == afterStatus) return;

  final eventData = await fetchEventData(firebase, sectionId, eventId);
  final eventTitle = eventData['title']?.toString() ?? 'Event';

  if (beforeStatus != RegistrationStatus.approved.name && afterStatus == RegistrationStatus.approved.name) {
    logger.info('User $userId approved for event $eventId ($eventTitle)');
    await sendNotificationToUser(
      firebase: firebase,
      userId: userId,
      title: 'Registration Approved: $eventTitle',
      message: 'You have been approved for "$eventTitle".',
      link: '/events/$eventId',
      type: 'registration_approved',
      sectionId: sectionId,
      eventId: eventId,
    );
  } else if (beforeStatus != RegistrationStatus.waitlisted.name && afterStatus == RegistrationStatus.waitlisted.name) {
    logger.info('User $userId moved to waitlist for event $eventId ($eventTitle)');
    await sendNotificationToUser(
      firebase: firebase,
      userId: userId,
      title: 'Waitlist Update: $eventTitle',
      message: 'You have been moved to the waitlist for "$eventTitle".',
      link: '/events/$eventId',
      type: 'registration_waitlisted',
      sectionId: sectionId,
      eventId: eventId,
    );
  } else if (beforeStatus != RegistrationStatus.rejected.name && afterStatus == RegistrationStatus.rejected.name) {
    logger.info('User $userId registration rejected for event $eventId ($eventTitle)');
    await sendNotificationToUser(
      firebase: firebase,
      userId: userId,
      title: 'Registration Update: $eventTitle',
      message: 'Your registration for "$eventTitle" was not approved.',
      link: '/events/$eventId',
      type: 'registration_rejected',
      sectionId: sectionId,
      eventId: eventId,
    );
  }
}

/// Core logic for handling a deleted registration (used by emulator trigger & HTTPS endpoints).
///
/// Only sends a notification when a leader/manager removes the user.
/// If the member withdrew themselves (authId == userId), notification is skipped.
Future<void> handleRegistrationDeleted({
  required Firebase firebase,
  required String sectionId,
  required String eventId,
  required String registrationId,
  String? userId,
  String? status,
  String? authId,
  Map<String, dynamic>? regData,
}) async {
  if (sectionId.isEmpty || eventId.isEmpty || registrationId.isEmpty) return;

  userId ??= regData?['userId']?.toString() ?? registrationId;
  status ??= regData?['status']?.toString();

  if (userId.isEmpty) return;

  // Requirement: only when a leader removes them.
  // If the user removed themselves (withdrew), authId matches userId.
  if (authId != null && authId == userId) {
    logger.info('User $userId withdrew themselves from event $eventId. Skipping notification.');
    return;
  }

  // Only notify if they held an active or waitlisted status prior to deletion
  if (status == RegistrationStatus.approved.name ||
      status == RegistrationStatus.pending.name ||
      status == RegistrationStatus.waitlisted.name) {
    final eventData = await fetchEventData(firebase, sectionId, eventId);
    final eventTitle = eventData['title']?.toString() ?? 'Event';

    logger.info('User $userId was removed from event $eventId by leader (authId: $authId). Notifying user.');

    await sendNotificationToUser(
      firebase: firebase,
      userId: userId,
      title: 'Event Update: $eventTitle',
      message: 'You have been removed from "$eventTitle".',
      link: '/events/$eventId',
      type: 'registration_removed',
      sectionId: sectionId,
      eventId: eventId,
    );
  }
}

/// Firestore trigger that fires when a registration is created at
/// `/sections/{sectionId}/events/{eventId}/registrations/{registrationId}` (Emulator).
Future<void> onRegistrationCreated(FirestoreAuthEvent<EmulatorDocumentSnapshot?> event, Firebase firebase) async {
  final regData = event.data?.data() ?? <String, dynamic>{};
  final sectionId = event.params['sectionId'] ?? '';
  final eventId = event.params['eventId'] ?? '';
  final registrationId = event.params['registrationId'] ?? '';
  final userId = regData['userId']?.toString() ?? registrationId;
  final status = regData['status']?.toString();
  final authId = event.authId;

  await handleRegistrationCreated(
    firebase: firebase,
    sectionId: sectionId,
    eventId: eventId,
    registrationId: registrationId,
    userId: userId,
    status: status,
    authId: authId,
    regData: regData,
  );
}

/// Firestore trigger that fires when a registration is updated at
/// `/sections/{sectionId}/events/{eventId}/registrations/{registrationId}` (Emulator).
Future<void> onRegistrationUpdated(
  FirestoreAuthEvent<Change<EmulatorDocumentSnapshot>?> event,
  Firebase firebase,
) async {
  final beforeData = event.data?.before?.data() ?? <String, dynamic>{};
  final afterData = event.data?.after?.data() ?? <String, dynamic>{};
  final sectionId = event.params['sectionId'] ?? '';
  final eventId = event.params['eventId'] ?? '';
  final registrationId = event.params['registrationId'] ?? '';
  final userId = afterData['userId']?.toString() ?? registrationId;

  final beforeStatus = beforeData['status']?.toString();
  final afterStatus = afterData['status']?.toString();

  await handleRegistrationUpdated(
    firebase: firebase,
    sectionId: sectionId,
    eventId: eventId,
    registrationId: registrationId,
    userId: userId,
    beforeStatus: beforeStatus,
    afterStatus: afterStatus,
    beforeData: beforeData,
    afterData: afterData,
  );
}

/// Firestore trigger that fires when a registration is deleted from
/// `/sections/{sectionId}/events/{eventId}/registrations/{registrationId}` (Emulator).
Future<void> onRegistrationDeleted(FirestoreAuthEvent<EmulatorDocumentSnapshot?> event, Firebase firebase) async {
  final regData = event.data?.data() ?? <String, dynamic>{};
  final sectionId = event.params['sectionId'] ?? '';
  final eventId = event.params['eventId'] ?? '';
  final registrationId = event.params['registrationId'] ?? '';
  final userId = regData['userId']?.toString() ?? registrationId;
  final status = regData['status']?.toString();
  final authId = event.authId;

  await handleRegistrationDeleted(
    firebase: firebase,
    sectionId: sectionId,
    eventId: eventId,
    registrationId: registrationId,
    userId: userId,
    status: status,
    authId: authId,
    regData: regData,
  );
}
