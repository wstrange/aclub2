import 'package:aclub2/widgets/calendar_common.dart';
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

      // Check single day event using shared isEventOnDay
      expect(isEventOnDay(singleDayEvent, DateTime(2026, 9, 14)), isFalse);
      expect(isEventOnDay(singleDayEvent, DateTime(2026, 9, 15)), isTrue);
      expect(isEventOnDay(singleDayEvent, DateTime(2026, 9, 16)), isFalse);

      // Check multi day event using shared isEventOnDay
      expect(isEventOnDay(multiDayEvent, DateTime(2026, 9, 17)), isFalse);
      expect(isEventOnDay(multiDayEvent, DateTime(2026, 9, 18)), isTrue);
      expect(isEventOnDay(multiDayEvent, DateTime(2026, 9, 19)), isTrue);
      expect(isEventOnDay(multiDayEvent, DateTime(2026, 9, 20)), isTrue);
      expect(isEventOnDay(multiDayEvent, DateTime(2026, 9, 21)), isFalse);

      final day19Events = getEventsForDay(events, DateTime(2026, 9, 19));
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

      // "All events" returns all 4 events using shared filterCalendarEvents
      final allFiltered = filterCalendarEvents(
        events: allEvents,
        filter: CalendarEventFilter.all,
        userId: currentUserId,
        registeredEventIds: registeredEventIds,
      );
      expect(allFiltered.length, equals(4));

      // "My events" returns exactly 3 events (created, managed, registered), excluding unrelated
      final myFiltered = filterCalendarEvents(
        events: allEvents,
        filter: CalendarEventFilter.mine,
        userId: currentUserId,
        registeredEventIds: registeredEventIds,
      );
      expect(myFiltered.length, equals(3));
      expect(myFiltered.map((e) => e.id).toSet(), equals({'ev-created', 'ev-managed', 'ev-registered'}));
      expect(myFiltered.any((e) => e.id == 'ev-unrelated'), isFalse);
    });

    test('groups agenda entries by date with multi-day spans and chronological ordering', () {
      final now = DateTime(2026, 9, 1);
      final morningHike = Event(
        id: '1',
        sectionId: 'national',
        title: 'Morning Hike',
        type: EventType.hike,
        startDate: DateTime(2026, 9, 15, 8, 0),
        endDate: DateTime(2026, 9, 15, 11, 0),
        maxParticipants: 10,
        creatorId: 'user1',
        createdAt: now,
        updatedAt: now,
      );

      final eveningSocial = Event(
        id: '2',
        sectionId: 'national',
        title: 'Evening Social',
        type: EventType.social,
        startDate: DateTime(2026, 9, 15, 18, 0),
        endDate: DateTime(2026, 9, 15, 20, 0),
        maxParticipants: 20,
        creatorId: 'user1',
        createdAt: now,
        updatedAt: now,
      );

      final weekendCamp = Event(
        id: '3',
        sectionId: 'national',
        title: 'Weekend Camp',
        type: EventType.climb,
        startDate: DateTime(2026, 9, 15, 14, 0),
        endDate: DateTime(2026, 9, 17, 12, 0),
        maxParticipants: 8,
        creatorId: 'user1',
        createdAt: now,
        updatedAt: now,
      );

      final events = [eveningSocial, morningHike, weekendCamp];

      const year = 2026;
      const month = 9;
      final daysInMonth = DateTime(year, month + 1, 0).day;

      final dayEntries = <DateTime, List<Event>>{};
      for (var d = 1; d <= daysInMonth; d++) {
        final date = DateTime(year, month, d);
        final dayEvents = getEventsForDay(events, date);

        if (dayEvents.isNotEmpty) {
          dayEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
          dayEntries[date] = dayEvents;
        }
      }

      // Only days with events are present: Sept 15, 16, 17
      expect(dayEntries.keys.map((d) => d.day).toList(), equals([15, 16, 17]));

      // On Sept 15: Morning Hike (8am), Weekend Camp (2pm), Evening Social (6pm)
      final day15 = dayEntries[DateTime(2026, 9, 15)]!;
      expect(day15.length, equals(3));
      expect(day15[0].title, equals('Morning Hike'));
      expect(day15[1].title, equals('Weekend Camp'));
      expect(day15[2].title, equals('Evening Social'));

      // On Sept 16: Weekend Camp only
      final day16 = dayEntries[DateTime(2026, 9, 16)]!;
      expect(day16.length, equals(1));
      expect(day16[0].title, equals('Weekend Camp'));

      // On Sept 17: Weekend Camp only
      final day17 = dayEntries[DateTime(2026, 9, 17)]!;
      expect(day17.length, equals(1));
      expect(day17[0].title, equals('Weekend Camp'));
    });
  });
}
