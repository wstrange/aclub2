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
    sections: {'national': SectionRole.member},
  ),
];

List<Section> get defaultSampleSections => const [
  Section(
    id: 'national',
    name: 'National',
    description:
        'National section coordinating alpine activities across Canada.',
  ),
  Section(
    id: 'calgary',
    name: 'Calgary',
    description:
        'Calgary section exploring the Canadian Rockies and foothills.',
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

const List<
  ({
    String title,
    String description,
    EventType type,
    Difficulty difficulty,
    Duration duration,
    bool evening,
  })
>
_eventBlueprints = [
  (
    title: 'Intro to Mountaineering',
    description: 'A beginner-friendly mountaineering weekend in the Rockies.',
    type: EventType.climb,
    difficulty: Difficulty.moderate,
    duration: Duration(hours: 32),
    evening: false,
  ),
  (
    title: 'Annual General Meeting',
    description: 'Section AGM and club social.',
    type: EventType.social,
    difficulty: Difficulty.easy,
    duration: Duration(hours: 3),
    evening: true,
  ),
  (
    title: 'Yamnuska Ridge Scramble',
    description: 'Classic Mount Yamnuska traverse and ridge scramble.',
    type: EventType.hike,
    difficulty: Difficulty.hard,
    duration: Duration(hours: 8),
    evening: false,
  ),
  (
    title: 'Avalanche Safety AST 1',
    description: 'Classroom and field training for avalanche awareness.',
    type: EventType.skiMountaineering,
    difficulty: Difficulty.moderate,
    duration: Duration(hours: 24),
    evening: false,
  ),
  (
    title: 'Rock Climbing Clinic',
    description: 'Learn to belay and build anchors at a local crag.',
    type: EventType.rock,
    difficulty: Difficulty.moderate,
    duration: Duration(hours: 8),
    evening: false,
  ),
  (
    title: 'Glacier Travel Course',
    description: 'Rope team travel, crevasse rescue, and ice axe arrest.',
    type: EventType.climb,
    difficulty: Difficulty.hard,
    duration: Duration(hours: 32),
    evening: false,
  ),
  (
    title: 'Winter Snowshoe Social Hike',
    description: 'Easy snowshoe outing followed by hot chocolate in town.',
    type: EventType.snowshoe,
    difficulty: Difficulty.easy,
    duration: Duration(hours: 6),
    evening: false,
  ),
  (
    title: 'Guest Speaker: Backcountry Navigation',
    description: 'Evening presentation on trip planning and route finding.',
    type: EventType.presentation,
    difficulty: Difficulty.easy,
    duration: Duration(hours: 2),
    evening: true,
  ),
  (
    title: 'Rocky Mountain Trail Run',
    description: 'Social trail run on valley trails, all paces welcome.',
    type: EventType.trailRun,
    difficulty: Difficulty.moderate,
    duration: Duration(hours: 4),
    evening: false,
  ),
  (
    title: 'Bow Valley Alpine Ski Day',
    description: 'Club ski day — meet at the base lodge at opening.',
    type: EventType.alpineSki,
    difficulty: Difficulty.moderate,
    duration: Duration(hours: 8),
    evening: false,
  ),
];

// First/last names used to fabricate members for every section.
const _firstNames = [
  'Alice',
  'Ben',
  'Chloe',
  'Dave',
  'Emma',
  'Farid',
  'Grace',
  'Hugo',
  'Isla',
  'Jonas',
  'Kira',
  'Liam',
  'Mara',
  'Noah',
  'Olivia',
  'Pierre',
  'Quinn',
  'Rosa',
  'Sam',
  'Tara',
  'Uma',
  'Victor',
  'Wren',
  'Yuri',
  'Zoe',
];

const _lastNames = [
  'Parker',
  'Carter',
  'Nguyen',
  'Simmons',
  'Wilson',
  'Ahmed',
  'Brooks',
  'Chen',
  'Dubois',
  'Evans',
  'Foley',
  'Garcia',
  'Hussein',
  'Ito',
  'Jensen',
  'Kowalski',
  'Lam',
  'Moreau',
  'Nakamura',
  'Oduya',
  'Patel',
  'Rossi',
  'Singh',
  'Tanaka',
  'Verda',
];

/// Generates [perSection] sample users for every section in [sections]: each
/// section gets a manager, a trip leader, and (remaining) regular members,
/// for exactly [perSection] members per section in total.
List<SampleUser> generateSampleUsers(
  int perSection, {
  List<Section>? sections,
}) {
  final sectionList = sections ?? defaultSampleSections;
  if (sectionList.isEmpty || perSection <= 0) return const [];

  final users = <SampleUser>[];
  var index = 1;
  for (var s = 0; s < sectionList.length; s++) {
    for (var j = 0; j < perSection; j++, index++) {
      final section = sectionList[s];
      final firstName = _firstNames[(index - 1) % _firstNames.length];
      final lastName = _lastNames[(index - 1) % _lastNames.length];
      final role = switch (j) {
        0 => SectionRole.sectionManager,
        1 => SectionRole.tripLeader,
        _ => SectionRole.member,
      };
      final memberships = <String, SectionRole>{section.id: role};

      users.add(
        SampleUser(
          uid: 'user-$index',
          email:
              '${firstName.toLowerCase()}$index.${lastName.toLowerCase()}@example.com',
          displayName: '$firstName $lastName',
          firstName: firstName,
          lastName: lastName,
          sections: memberships,
        ),
      );
    }
  }
  return users;
}

/// Generates [count] sample events spread evenly from today through one year
/// out, cycling event blueprints across the supplied [sections].
List<Event> generateSampleEvents(int count, {List<Section>? sections}) {
  final sectionList = sections ?? defaultSampleSections;
  if (sectionList.isEmpty || count <= 0) return const [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return List.generate(count, (i) {
    final blueprint = _eventBlueprints[i % _eventBlueprints.length];

    // Spread start dates evenly across the next 365 days.
    final dayOffset = (365 * i / count).floor();
    final day = today.add(Duration(days: dayOffset));
    final hour = blueprint.evening ? 19 : 8 + (i % 3) * 2;
    final start = DateTime(
      day.year,
      day.month,
      day.day,
      hour,
      blueprint.evening ? 0 : 30,
    );
    final end = start.add(blueprint.duration);

    final cycle = i ~/ _eventBlueprints.length;
    final title = cycle >= 2 ? '${blueprint.title} #$cycle' : blueprint.title;

    return Event(
      id: 'event-${i + 1}',
      sectionId: sectionList[i % sectionList.length].id,
      title: title,
      description: blueprint.description,
      type: blueprint.type,
      status: EventStatus.published,
      startDate: start,
      endDate: end,
      maxParticipants: switch (blueprint.type) {
        EventType.social => 100,
        EventType.presentation => 60,
        _ => 12,
      },
      difficulty: blueprint.difficulty,
      creatorId: 'admin',
      createdAt: now,
      updatedAt: now,
    );
  });
}

/// The template content that ships with the app lives in `content/templates`
/// (see `lib/src/template_source.dart`); it is no longer hardcoded here.
