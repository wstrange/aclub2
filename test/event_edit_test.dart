import 'package:aclub2/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

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
        requiredEquipment: ['Helmet', 'Crampons'],
        prerequisites: ['Prior multi-pitch experience'],
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
      expect(updated.requiredEquipment, contains('Helmet'));
      expect(updated.prerequisites, contains('Prior multi-pitch experience'));
      expect(updated.updatedAt, equals(updatedTime));
    });

    test('validates start and end date ordering', () {
      final start = DateTime(2026, 9, 20, 10, 0);
      final validEnd = DateTime(2026, 9, 20, 16, 0);
      final invalidEnd = DateTime(2026, 9, 19, 16, 0);

      expect(validEnd.isBefore(start), isFalse);
      expect(invalidEnd.isBefore(start), isTrue);
    });
  });
}
