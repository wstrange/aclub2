import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

void main() {
  group('Calendar Event Date Calculations', () {
    test('filters single-day and multi-day events correctly', () {
      final now = DateTime(2026, 9, 10);
      final singleDayEvent = Event(
        id: '1',
        sectionId: 'national',
        title: 'Day Hike',
        type: EventType.hike,
        startDate: DateTime(2026, 9, 15, 9, 0),
        endDate: DateTime(2026, 9, 15, 17, 0),
        maxParticipants: 10,
        creatorId: 'admin',
        createdAt: now,
        updatedAt: now,
      );

      final multiDayEvent = Event(
        id: '2',
        sectionId: 'national',
        title: 'Weekend Camp',
        type: EventType.climb,
        startDate: DateTime(2026, 9, 18, 16, 0),
        endDate: DateTime(2026, 9, 20, 18, 0),
        maxParticipants: 8,
        creatorId: 'admin',
        createdAt: now,
        updatedAt: now,
      );

      final events = [singleDayEvent, multiDayEvent];

      bool isEventOnDay(Event event, DateTime targetDay) {
        final target = DateTime(targetDay.year, targetDay.month, targetDay.day);
        final startNorm = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
        final endNorm = DateTime(event.endDate.year, event.endDate.month, event.endDate.day);
        return target.compareTo(startNorm) >= 0 && target.compareTo(endNorm) <= 0;
      }

      // Check single day event
      expect(isEventOnDay(singleDayEvent, DateTime(2026, 9, 14)), isFalse);
      expect(isEventOnDay(singleDayEvent, DateTime(2026, 9, 15)), isTrue);
      expect(isEventOnDay(singleDayEvent, DateTime(2026, 9, 16)), isFalse);

      // Check multi day event
      expect(isEventOnDay(multiDayEvent, DateTime(2026, 9, 17)), isFalse);
      expect(isEventOnDay(multiDayEvent, DateTime(2026, 9, 18)), isTrue);
      expect(isEventOnDay(multiDayEvent, DateTime(2026, 9, 19)), isTrue);
      expect(isEventOnDay(multiDayEvent, DateTime(2026, 9, 20)), isTrue);
      expect(isEventOnDay(multiDayEvent, DateTime(2026, 9, 21)), isFalse);

      final day19Events = events.where((e) => isEventOnDay(e, DateTime(2026, 9, 19))).toList();
      expect(day19Events.length, equals(1));
      expect(day19Events.first.title, equals('Weekend Camp'));
    });

    test('calculates month grid layout correctly', () {
      const year = 2026;
      const month = 9; // September 2026: starts on Tuesday (weekday 2)
      final firstDayOfMonth = DateTime(year, month, 1);
      final daysInMonth = DateTime(year, month + 1, 0).day; // 30 days
      final startWeekdayOffset = firstDayOfMonth.weekday % 7; // Tuesday -> 2 (Sun=0, Mon=1, Tue=2)

      expect(daysInMonth, equals(30));
      expect(startWeekdayOffset, equals(2));

      final totalGridCells = ((startWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;
      expect(totalGridCells, equals(35)); // 5 rows * 7 columns
    });

    test('filters "My events" correctly (registered, managed, or created)', () {
      final now = DateTime(2026, 9, 10);
      const currentUserId = 'user123';

      final createdEvent = Event(
        id: 'ev-created',
        sectionId: 'national',
        title: 'Created by Me',
        type: EventType.hike,
        startDate: DateTime(2026, 9, 15, 9, 0),
        endDate: DateTime(2026, 9, 15, 17, 0),
        maxParticipants: 10,
        creatorId: currentUserId,
        createdAt: now,
        updatedAt: now,
      );

      final managedEvent = Event(
        id: 'ev-managed',
        sectionId: 'national',
        title: 'Led by Me',
        type: EventType.climb,
        startDate: DateTime(2026, 9, 16, 9, 0),
        endDate: DateTime(2026, 9, 16, 17, 0),
        maxParticipants: 10,
        creatorId: 'other-user',
        tripLeaderIds: [currentUserId, 'leader2'],
        createdAt: now,
        updatedAt: now,
      );

      final registeredEvent = Event(
        id: 'ev-registered',
        sectionId: 'national',
        title: 'Registered Attendee',
        type: EventType.social,
        startDate: DateTime(2026, 9, 17, 9, 0),
        endDate: DateTime(2026, 9, 17, 17, 0),
        maxParticipants: 10,
        creatorId: 'other-user',
        createdAt: now,
        updatedAt: now,
      );

      final unassociatedEvent = Event(
        id: 'ev-unrelated',
        sectionId: 'national',
        title: 'Unrelated Event',
        type: EventType.alpineSki,
        startDate: DateTime(2026, 9, 18, 9, 0),
        endDate: DateTime(2026, 9, 18, 17, 0),
        maxParticipants: 10,
        creatorId: 'other-user',
        tripLeaderIds: ['leader3'],
        createdAt: now,
        updatedAt: now,
      );

      final allEvents = [createdEvent, managedEvent, registeredEvent, unassociatedEvent];
      final registeredEventIds = {'ev-registered'};

      List<Event> filterEvents(List<Event> events, {required bool myEventsOnly}) {
        if (!myEventsOnly) return events;
        return events.where((event) {
          final isCreator = event.creatorId == currentUserId;
          final isLeader = event.tripLeaderIds.contains(currentUserId);
          final isRegistered = registeredEventIds.contains(event.id);
          return isCreator || isLeader || isRegistered;
        }).toList();
      }

      // "All events" returns all 4 events
      final allFiltered = filterEvents(allEvents, myEventsOnly: false);
      expect(allFiltered.length, equals(4));

      // "My events" returns exactly 3 events (created, managed, registered), excluding unrelated
      final myFiltered = filterEvents(allEvents, myEventsOnly: true);
      expect(myFiltered.length, equals(3));
      expect(myFiltered.map((e) => e.id).toSet(), equals({'ev-created', 'ev-managed', 'ev-registered'}));
      expect(myFiltered.any((e) => e.id == 'ev-unrelated'), isFalse);
    });
  });
}
