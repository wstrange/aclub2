import 'package:aclub2/repo.dart';

import '../models/models.dart';

final repo = AlpineRepository();

Future<void> createSections() async {
  await repo.createSection(const Section(id: 'national', name: 'National', description: 'National section description'));
  await repo.createSection(const Section(id: 'calgary', name: 'Calgary', description: 'Calgary section description'));
}

Future<void> createSampleEvents() async {
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;

  final sampleEvents = [
    Event(
      id: 'event-1',
      sectionId: 'national',
      title: 'Intro to Mountaineering',
      description: 'A beginner-friendly mountaineering weekend in the Rockies.',
      type: EventType.climb,
      status: EventStatus.published,
      startDate: DateTime(year, month, 5, 9, 0),
      endDate: DateTime(year, month, 6, 17, 0),
      maxParticipants: 12,
      difficulty: Difficulty.moderate,
      creatorId: 'admin',
      createdAt: now,
      updatedAt: now,
    ),
    Event(
      id: 'event-2',
      sectionId: 'national',
      title: 'Annual General Meeting',
      description: 'National section AGM and club social.',
      type: EventType.social,
      status: EventStatus.published,
      startDate: DateTime(year, month, 15, 18, 30),
      endDate: DateTime(year, month, 15, 21, 0),
      maxParticipants: 100,
      difficulty: Difficulty.easy,
      creatorId: 'admin',
      createdAt: now,
      updatedAt: now,
    ),
    Event(
      id: 'event-3',
      sectionId: 'calgary',
      title: 'Yamnuska Ridge Scramble',
      description: 'Classic Mount Yamnuska traverse and ridge scramble.',
      type: EventType.hike,
      status: EventStatus.published,
      startDate: DateTime(year, month, 12, 8, 0),
      endDate: DateTime(year, month, 12, 16, 0),
      maxParticipants: 8,
      difficulty: Difficulty.hard,
      creatorId: 'admin',
      createdAt: now,
      updatedAt: now,
    ),
    Event(
      id: 'event-4',
      sectionId: 'calgary',
      title: 'Avalanche Safety AST 1',
      description: 'Classroom and field training for avalanche awareness.',
      type: EventType.skiMountaineering,
      status: EventStatus.published,
      startDate: DateTime(year, month, 20, 9, 0),
      endDate: DateTime(year, month, 21, 16, 0),
      maxParticipants: 10,
      difficulty: Difficulty.moderate,
      creatorId: 'admin',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  for (final event in sampleEvents) {
    await repo.createEvent(event.sectionId, event);
  }
}

Future<void> doAdminSetup() async {
  await createSections();
  await createSampleEvents();
}
