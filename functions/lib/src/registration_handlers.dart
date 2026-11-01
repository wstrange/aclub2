import 'package:firebase_functions/firebase_functions.dart';
import 'package:shared_models/shared_models.dart';
import 'package:firebase_functions/logger.dart' as logger;
import 'event_handlers.dart';
import 'notification_dispatcher.dart';
import 'registration_transitions.dart';

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

  final notification = notificationForCreatedRegistration(status: status, userId: userId, authId: authId);
  if (notification == RegistrationNotification.none) return;

  final eventData = await fetchEventData(firebase, sectionId, eventId);
  final eventTitle = eventData['title']?.toString() ?? 'Event';

  switch (notification) {
    case RegistrationNotification.pendingRequested:
      logger.info('Pending registration created for $userId on event $eventId. Notifying leaders.');
      await notifyTripLeadersOfPendingRegistration(
        firebase: firebase,
        sectionId: sectionId,
        eventId: eventId,
        eventTitle: eventTitle,
        eventData: eventData,
        applicantUserId: userId,
      );
    case RegistrationNotification.addedByLeader:
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
    case RegistrationNotification.waitlisted:
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
    case RegistrationNotification.none:
    case RegistrationNotification.approved:
    case RegistrationNotification.rejected:
    case RegistrationNotification.selfWithdrawn:
    case RegistrationNotification.removedByLeader:
      break;
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
  String? authId,
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

  final notification = notificationForUpdatedRegistration(
    beforeStatus: beforeStatus,
    afterStatus: afterStatus,
    userId: userId,
    authId: authId,
    afterData: afterData,
  );
  if (notification == RegistrationNotification.none) return;

  final eventData = await fetchEventData(firebase, sectionId, eventId);
  final eventTitle = eventData['title']?.toString() ?? 'Event';

  switch (notification) {
    case RegistrationNotification.approved:
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
    case RegistrationNotification.waitlisted:
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
    case RegistrationNotification.rejected:
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
    case RegistrationNotification.pendingRequested:
      logger.info('User $userId pending registration for event $eventId ($eventTitle)');
      await notifyTripLeadersOfPendingRegistration(
        firebase: firebase,
        sectionId: sectionId,
        eventId: eventId,
        eventTitle: eventTitle,
        eventData: eventData,
        applicantUserId: userId,
      );
    case RegistrationNotification.selfWithdrawn:
      logger.info('User $userId withdrew from event $eventId ($eventTitle)');
      await notifyTripLeadersOfWithdrawal(
        firebase: firebase,
        sectionId: sectionId,
        eventId: eventId,
        eventTitle: eventTitle,
        eventData: eventData,
        withdrawingUserId: userId,
      );
    case RegistrationNotification.removedByLeader:
      logger.info('User $userId removed from event $eventId by leader. Notifying user.');
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
    case RegistrationNotification.none:
    case RegistrationNotification.addedByLeader:
      break;
  }
}
/// Core logic for handling a deleted registration (used by emulator trigger & HTTPS endpoints).
///
/// * When a member withdraws themselves (`deletedByUserId == userId` from the
///   doc, or `authId == userId` for HTTPS-triggered calls), notifies the trip
///   leaders and creator of the event.
/// * When a leader/manager removes a member, notifies the member that they
///   have been removed.
///
/// > **Why `deletedByUserId` instead of `authId`?**
/// > `FirestoreAuthEvent.authId` identifies the Cloud IAM principal (service
/// > account) that made the write, *not* the Firebase Auth UID of the
/// > end-user. The client stamps `deletedByUserId` on the document before
/// > deleting it so the trigger can reliably detect self-withdrawal.
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

  final notification = notificationForDeletedRegistration(
    status: status,
    userId: userId,
    authId: authId,
    regData: regData,
  );
  if (notification == RegistrationNotification.none) return;

  final eventData = await fetchEventData(firebase, sectionId, eventId);
  final eventTitle = eventData['title']?.toString() ?? 'Event';

  switch (notification) {
    // Self-withdrawal: notify trip leaders and creator.
    case RegistrationNotification.selfWithdrawn:
      logger.info('User $userId withdrew from event $eventId. Notifying trip leaders.');
      await notifyTripLeadersOfWithdrawal(
        firebase: firebase,
        sectionId: sectionId,
        eventId: eventId,
        eventTitle: eventTitle,
        eventData: eventData,
        withdrawingUserId: userId,
      );
    // Leader removal: the registration held an active or waitlisted status.
    case RegistrationNotification.removedByLeader:
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
    case RegistrationNotification.none:
    case RegistrationNotification.pendingRequested:
    case RegistrationNotification.addedByLeader:
    case RegistrationNotification.approved:
    case RegistrationNotification.waitlisted:
    case RegistrationNotification.rejected:
      break;
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
  final authId = event.authId;

  await handleRegistrationUpdated(
    firebase: firebase,
    sectionId: sectionId,
    eventId: eventId,
    registrationId: registrationId,
    userId: userId,
    beforeStatus: beforeStatus,
    afterStatus: afterStatus,
    authId: authId,
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
