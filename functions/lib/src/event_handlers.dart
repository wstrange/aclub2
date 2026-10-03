import 'package:firebase_functions/firebase_functions.dart';
import 'package:shared_models/shared_models.dart';
import 'package:firebase_functions/logger.dart' as logger;
import 'notification_dispatcher.dart';

/// Helper to fetch event title and data from Firestore.
Future<Map<String, dynamic>> fetchEventData(Firebase firebase, String sectionId, String eventId) async {
  try {
    final doc = await firebase.adminApp.firestore().doc('sections/$sectionId/events/$eventId').get();
    return doc.data() ?? <String, dynamic>{};
  } catch (error) {
    logger.info('Failed to fetch event $eventId in section $sectionId: $error');
    return <String, dynamic>{};
  }
}

/// Core logic for handling newly created events (used by emulator trigger & HTTPS endpoints).
///
/// If the event is in [EventStatus.draft] mode, no notifications are sent.
/// When created directly in [EventStatus.published] mode, interested section
/// members are notified.
Future<void> handleNewEventCreated({
  required Firebase firebase,
  required String sectionId,
  required String eventId,
  String? title,
  String? status,
  Map<String, dynamic>? eventData,
}) async {
  if (sectionId.isEmpty || eventId.isEmpty) {
    logger.info('handleNewEventCreated: missing sectionId or eventId');
    return;
  }

  // If status is not provided, fetch from Firestore
  if (status == null || title == null) {
    final fetched = await fetchEventData(firebase, sectionId, eventId);
    status ??= fetched['status']?.toString();
    title ??= fetched['title']?.toString();
  }

  title ??= 'Untitled event';

  // Do not send notifications for drafts
  if (status != EventStatus.published.name) {
    logger.info(
      'Event created in draft or non-published mode, skipping notifications: '
      'eventId=$eventId, sectionId=$sectionId, status=$status',
    );
    return;
  }

  logger.info('New published event created: eventId=$eventId, sectionId=$sectionId, title=$title');

  await notifySectionMembersOfEvent(
    firebase: firebase,
    sectionId: sectionId,
    eventId: eventId,
    title: title,
    message: 'A new event has been added to the calendar.',
    type: 'new_event',
  );
}

/// Core logic for handling updated events (used by emulator trigger & HTTPS endpoints).
///
/// When an event transitions from draft to published, triggers sending
/// notifications to interested section members.
Future<void> handleEventUpdated({
  required Firebase firebase,
  required String sectionId,
  required String eventId,
  String? beforeStatus,
  String? afterStatus,
  String? title,
  Map<String, dynamic>? beforeData,
  Map<String, dynamic>? afterData,
}) async {
  if (sectionId.isEmpty || eventId.isEmpty) {
    logger.info('handleEventUpdated: missing sectionId or eventId');
    return;
  }

  if (afterStatus == null || title == null) {
    final fetched = await fetchEventData(firebase, sectionId, eventId);
    afterStatus ??= fetched['status']?.toString();
    title ??= fetched['title']?.toString();
  }

  title ??= 'Untitled event';

  // Only trigger when transitioning from non-published (e.g. draft) to published
  if (beforeStatus != EventStatus.published.name && afterStatus == EventStatus.published.name) {
    logger.info('Event published: eventId=$eventId, sectionId=$sectionId, title=$title');

    await notifySectionMembersOfEvent(
      firebase: firebase,
      sectionId: sectionId,
      eventId: eventId,
      title: title,
      message: 'A new event has been published to the calendar.',
      type: 'event_published',
    );
  }
}

/// Firestore trigger that fires when a new event document is added to
/// `/sections/{sectionId}/events/{eventId}` (Emulator).
Future<void> onNewEventCreated(FirestoreEvent<EmulatorDocumentSnapshot?> event, Firebase firebase) async {
  final eventData = event.data?.data() ?? <String, dynamic>{};
  final sectionId = event.params['sectionId'] ?? '';
  final eventId = event.data?.id ?? event.params['eventId'] ?? '';
  final title = eventData['title']?.toString();
  final status = eventData['status']?.toString();

  await handleNewEventCreated(
    firebase: firebase,
    sectionId: sectionId,
    eventId: eventId,
    title: title,
    status: status,
    eventData: eventData,
  );
}

/// Firestore trigger that fires when an event document is updated at
/// `/sections/{sectionId}/events/{eventId}` (Emulator).
Future<void> onEventUpdated(FirestoreEvent<Change<EmulatorDocumentSnapshot>?> event, Firebase firebase) async {
  final beforeData = event.data?.before?.data() ?? <String, dynamic>{};
  final afterData = event.data?.after?.data() ?? <String, dynamic>{};
  final sectionId = event.params['sectionId'] ?? '';
  final eventId = event.data?.after?.id ?? event.params['eventId'] ?? '';
  final title = afterData['title']?.toString();

  final beforeStatus = beforeData['status']?.toString();
  final afterStatus = afterData['status']?.toString();

  await handleEventUpdated(
    firebase: firebase,
    sectionId: sectionId,
    eventId: eventId,
    beforeStatus: beforeStatus,
    afterStatus: afterStatus,
    title: title,
    beforeData: beforeData,
    afterData: afterData,
  );
}
