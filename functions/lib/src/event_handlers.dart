import 'package:firebase_functions/firebase_functions.dart';
import 'package:shared_models/shared_models.dart';
import 'package:firebase_functions/logger.dart' as logger;
import 'notification_dispatcher.dart';

/// Firestore trigger that fires when a new event document is added to
/// `/sections/{sectionId}/events/{eventId}`.
///
/// If the event is in [EventStatus.draft] mode, no notifications are sent.
/// When created directly in [EventStatus.published] mode, interested section
/// members are notified.
Future<void> onNewEventCreated(FirestoreEvent<EmulatorDocumentSnapshot?> event, Firebase firebase) async {
  final eventData = event.data?.data() ?? <String, dynamic>{};
  final sectionId = event.params['sectionId'] ?? '';
  final eventId = event.data?.id ?? '';
  final title = eventData['title']?.toString() ?? 'Untitled event';
  final status = eventData['status']?.toString();

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

/// Firestore trigger that fires when an event document is updated at
/// `/sections/{sectionId}/events/{eventId}`.
///
/// When an event transitions from draft to published, triggers sending
/// notifications to interested section members.
Future<void> onEventUpdated(FirestoreEvent<Change<EmulatorDocumentSnapshot>?> event, Firebase firebase) async {
  final beforeData = event.data?.before?.data() ?? <String, dynamic>{};
  final afterData = event.data?.after?.data() ?? <String, dynamic>{};
  final sectionId = event.params['sectionId'] ?? '';
  final eventId = event.data?.after?.id ?? event.params['eventId'] ?? '';
  final title = afterData['title']?.toString() ?? 'Untitled event';

  final beforeStatus = beforeData['status']?.toString();
  final afterStatus = afterData['status']?.toString();

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
