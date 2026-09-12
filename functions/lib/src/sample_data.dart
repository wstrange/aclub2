import 'package:shared_models/shared_models.dart';

const samplePassword = 'foobar';

/// A sample Auth + Firestore user to seed alongside sections and events.
class SampleUser {
  const SampleUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.sections,
    this.isAdmin = false,
  });

  final String uid;
  final String email;
  final String displayName;
  final String firstName;
  final String lastName;
  final bool isAdmin;

  /// sectionId → role held within that section.
  final Map<String, SectionRole> sections;
}

List<SampleUser> get defaultSampleUsers => const [
      SampleUser(
        uid: 'user-1',
        email: 'alice@example.com',
        displayName: 'Alice Parker',
        firstName: 'Alice',
        lastName: 'Parker',
        sections: {
          'calgary': SectionRole.sectionManager,
          'national': SectionRole.tripLeader,
        },
      ),
      SampleUser(
        uid: 'user-2',
        email: 'ben@example.com',
        displayName: 'Ben Carter',
        firstName: 'Ben',
        lastName: 'Carter',
        sections: {
          'vancouver': SectionRole.sectionManager,
          'edmonton': SectionRole.member,
        },
      ),
      SampleUser(
        uid: 'user-3',
        email: 'chloe@example.com',
        displayName: 'Chloe Nguyen',
        firstName: 'Chloe',
        lastName: 'Nguyen',
        sections: {
          'calgary': SectionRole.tripLeader,
          'national': SectionRole.member,
        },
      ),
      SampleUser(
        uid: 'user-4',
        email: 'dave@example.com',
        displayName: 'Dave Simmons',
        firstName: 'Dave',
        lastName: 'Simmons',
        sections: {
          'calgary': SectionRole.member,
          'national': SectionRole.member,
          'vancouver': SectionRole.member,
        },
      ),
      SampleUser(
        uid: 'user-5',
        email: 'emma@example.com',
        displayName: 'Emma Wilson',
        firstName: 'Emma',
        lastName: 'Wilson',
        sections: {
          'national': SectionRole.member,
        },
      ),
    ];

List<Section> get defaultSampleSections => const [
      Section(
        id: 'national',
        name: 'National',
        description: 'National section coordinating alpine activities across Canada.',
      ),
      Section(
        id: 'calgary',
        name: 'Calgary',
        description: 'Calgary section exploring the Canadian Rockies and foothills.',
      ),
      Section(
        id: 'vancouver',
        name: 'Vancouver',
        description: 'Vancouver & Coastal British Columbia mountain club.',
      ),
      Section(
        id: 'edmonton',
        name: 'Edmonton',
        description: 'Edmonton section organizing trips to Jasper and Nordegg.',
      ),
    ];

List<Event> get defaultSampleEvents {
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;

  return [
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
}
