import 'package:aclub2/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}
