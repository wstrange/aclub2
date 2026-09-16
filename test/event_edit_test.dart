import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

void main() {
  group('Event Model and Editing Logic', () {
    test('copyWith updates event fields accurately', () {
      final now = DateTime(2026, 9, 10, 10, 0);
      final original = Event(
        id: 'event-101',
        sectionId: 'calgary',
        title: 'Original Title',
        description: 'Original Description',
        type: EventType.hike,
        difficulty: Difficulty.moderate,
        status: EventStatus.draft,
        startDate: DateTime(2026, 9, 15, 8, 0),
        endDate: DateTime(2026, 9, 15, 16, 0),
        maxParticipants: 10,
        creatorId: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      final updatedTime = DateTime(2026, 9, 10, 12, 0);
      final updated = original.copyWith(
        title: 'Updated Mountain Summit Hike',
        description: 'Updated route details and gear check.',
        type: EventType.climb,
        difficulty: Difficulty.hard,
        status: EventStatus.published,
        maxParticipants: 15,
        location: const EventLocation(description: 'Trailhead A', mapUrl: 'https://maps.example.com'),
        carpoolOption: CarpoolOption(meetTime: DateTime(2026, 9, 15, 6, 30), meetPlace: 'Calgary P&R'),
        updatedAt: updatedTime,
      );

      expect(updated.id, equals('event-101'));
      expect(updated.sectionId, equals('calgary'));
      expect(updated.title, equals('Updated Mountain Summit Hike'));
      expect(updated.type, equals(EventType.climb));
      expect(updated.difficulty, equals(Difficulty.hard));
      expect(updated.status, equals(EventStatus.published));
      expect(updated.maxParticipants, equals(15));
      expect(updated.location?.description, equals('Trailhead A'));
      expect(updated.carpoolOption?.meetPlace, equals('Calgary P&R'));
      expect(updated.updatedAt, equals(updatedTime));
    });

    test('validates start and end date ordering', () {
      final start = DateTime(2026, 9, 20, 10, 0);
      final validEnd = DateTime(2026, 9, 20, 16, 0);
      final invalidEnd = DateTime(2026, 9, 19, 16, 0);

      expect(validEnd.isBefore(start), isFalse);
      expect(invalidEnd.isBefore(start), isTrue);
    });

    test('creates new event with default fields', () {
      final now = DateTime(2026, 9, 10);
      final newEvent = Event(
        id: '',
        sectionId: 'national',
        title: 'New Event Title',
        type: EventType.hike,
        difficulty: Difficulty.moderate,
        status: EventStatus.published,
        startDate: DateTime(2026, 9, 25, 9, 0),
        endDate: DateTime(2026, 9, 25, 17, 0),
        maxParticipants: 12,
        creatorId: 'user-2',
        createdAt: now,
        updatedAt: now,
      );

      expect(newEvent.id, isEmpty);
      expect(newEvent.sectionId, equals('national'));
      expect(newEvent.title, equals('New Event Title'));
      expect(newEvent.status, equals(EventStatus.published));
      expect(newEvent.maxParticipants, equals(12));
    });

    group('copyForDuplicate', () {
      Event buildEvent({
        String id = 'event-101',
        String title = 'Original Hike',
        DateTime? start,
        DateTime? end,
        List<String> tripLeaders = const ['leader-1'],
        CarpoolOption? carpool,
      }) {
        return Event(
          id: id,
          sectionId: 'calgary',
          title: title,
          type: EventType.hike,
          difficulty: Difficulty.moderate,
          status: EventStatus.published,
          startDate: start ?? DateTime(2026, 9, 10, 8, 0),
          endDate: end ?? DateTime(2026, 9, 10, 16, 0),
          maxParticipants: 10,
          creatorId: 'user-1',
          tripLeaderIds: tripLeaders,
          carpoolOption: carpool,
          createdAt: DateTime(2026, 9, 1),
          updatedAt: DateTime(2026, 9, 1),
        );
      }

      test('advances a past event to the next available current date, preserving times and duration', () {
        final event = buildEvent(start: DateTime(2026, 9, 10, 8, 0), end: DateTime(2026, 9, 10, 16, 0));
        final now = DateTime(2026, 9, 15, 10, 30);

        final copy = event.copyForDuplicate(
          now: now,
          copyParticipantsAndLeaders: false,
          creatorId: 'user-2',
        );

        expect(copy.id, isEmpty);
        expect(copy.title, equals('COPY: Original Hike'));
        expect(copy.creatorId, equals('user-2'));
        // 8:00 today already passed by now (10:30) -> advance to tomorrow 8:00-16:00.
        expect(copy.startDate, equals(DateTime(2026, 9, 16, 8, 0)));
        expect(copy.endDate, equals(DateTime(2026, 9, 16, 16, 0)));
      });

      test('keeps today when the original start time is still in the future', () {
        final event = buildEvent(start: DateTime(2026, 9, 10, 14, 0), end: DateTime(2026, 9, 10, 20, 0));
        final now = DateTime(2026, 9, 15, 10, 30);

        final copy = event.copyForDuplicate(now: now, copyParticipantsAndLeaders: false, creatorId: 'user-2');

        expect(copy.startDate, equals(DateTime(2026, 9, 15, 14, 0)));
        expect(copy.endDate, equals(DateTime(2026, 9, 15, 20, 0)));
      });

      test('leaves a future event on its original dates', () {
        final event = buildEvent(start: DateTime(2026, 9, 25, 9, 0), end: DateTime(2026, 9, 25, 17, 0));
        final now = DateTime(2026, 9, 15, 10, 30);

        final copy = event.copyForDuplicate(now: now, copyParticipantsAndLeaders: false, creatorId: 'user-2');

        expect(copy.startDate, equals(DateTime(2026, 9, 25, 9, 0)));
        expect(copy.endDate, equals(DateTime(2026, 9, 25, 17, 0)));
      });

      test('copies trip leaders only when requested', () {
        final event = buildEvent(tripLeaders: ['leader-1', 'leader-2']);
        final now = DateTime(2026, 9, 15, 10, 30);

        final withLeaders = event.copyForDuplicate(now: now, copyParticipantsAndLeaders: true, creatorId: 'user-2');
        expect(withLeaders.tripLeaderIds, equals(['leader-1', 'leader-2']));

        final withoutLeaders =
            event.copyForDuplicate(now: now, copyParticipantsAndLeaders: false, creatorId: 'user-2');
        expect(withoutLeaders.tripLeaderIds, equals(['user-2']));
      });

      test('shifts the carpool meet time by the same advance, unchanged for future events', () {
        final carpool = CarpoolOption(meetTime: DateTime(2026, 9, 10, 6, 30), meetPlace: 'Park & Ride');
        final pastEvent = buildEvent(start: DateTime(2026, 9, 10, 8, 0), end: DateTime(2026, 9, 10, 16, 0), carpool: carpool);
        final now = DateTime(2026, 9, 15, 10, 30);

        final copy = pastEvent.copyForDuplicate(now: now, copyParticipantsAndLeaders: false, creatorId: 'user-2');
        expect(copy.carpoolOption?.meetTime, equals(DateTime(2026, 9, 16, 6, 30)));

        final futureEvent = buildEvent(
          start: DateTime(2026, 9, 25, 9, 0),
          end: DateTime(2026, 9, 25, 17, 0),
          carpool: CarpoolOption(meetTime: DateTime(2026, 9, 25, 6, 30), meetPlace: 'Park & Ride'),
        );
        final futureCopy = futureEvent.copyForDuplicate(now: now, copyParticipantsAndLeaders: false, creatorId: 'user-2');
        expect(futureCopy.carpoolOption?.meetTime, equals(DateTime(2026, 9, 25, 6, 30)));
      });

      test('does not mutate the source event', () {
        final event = buildEvent(start: DateTime(2026, 9, 10, 8, 0), end: DateTime(2026, 9, 10, 16, 0));
        final now = DateTime(2026, 9, 15, 10, 30);

        event.copyForDuplicate(now: now, copyParticipantsAndLeaders: false, creatorId: 'user-2');

        expect(event.title, equals('Original Hike'));
        expect(event.id, equals('event-101'));
        expect(event.startDate, equals(DateTime(2026, 9, 10, 8, 0)));
        expect(event.endDate, equals(DateTime(2026, 9, 10, 16, 0)));
      });
    });
  });
}
