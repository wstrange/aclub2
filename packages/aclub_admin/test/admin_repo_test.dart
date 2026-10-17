import 'package:test/test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:aclub_admin/admin_repo.dart';

void main() {
  group('Admin Models & Sample Data', () {
    test('defaultSampleSections contains valid section data', () {
      final sections = defaultSampleSections;
      expect(sections.isNotEmpty, isTrue);
      expect(sections.any((s) => s.id == 'national'), isTrue);
      expect(sections.any((s) => s.id == 'calgary'), isTrue);
    });

    test('defaultSampleEvents contains valid Freezed event models', () {
      final events = defaultSampleEvents;
      expect(events.isNotEmpty, isTrue);
      for (final event in events) {
        expect(event.id.isNotEmpty, isTrue);
        expect(event.sectionId.isNotEmpty, isTrue);
        expect(event.title.isNotEmpty, isTrue);
        expect(
          event.startDate.isBefore(event.endDate) ||
              event.startDate.isAtSameMomentAs(event.endDate),
          isTrue,
        );

        final json = event.toJson();
        final reconstructed = Event.fromJson(json);
        expect(reconstructed.id, equals(event.id));
        expect(reconstructed.title, equals(event.title));
      }
    });
    test('defaultSampleUsers contains valid user data', () {
      final users = defaultSampleUsers;
      expect(users.isNotEmpty, isTrue);
      expect(users.every((u) => u.uid.isNotEmpty), isTrue);
      expect(users.every((u) => u.email.contains('@')), isTrue);
      expect(users.every((u) => u.sections.isNotEmpty), isTrue);
      expect(
        users.any((u) => u.sections.containsValue(SectionRole.sectionManager)),
        isTrue,
      );
      expect(
        users.any((u) => u.sections.containsValue(SectionRole.tripLeader)),
        isTrue,
      );
    });

    test(
      'generateSampleUsers seeds the requested number of users per section',
      () {
        final sections = defaultSampleSections;
        final users = generateSampleUsers(3);

        expect(users.length, equals(sections.length * 3));
        // Every section gets exactly the requested number of users, each with a
        // distinct uid/email.
        for (final section in sections) {
          final members = users
              .where((u) => u.sections[section.id] != null)
              .toList();
          expect(members.length, equals(3), reason: 'section ${section.id}');
          // First member per section manages it.
          expect(
            members.first.sections[section.id],
            equals(SectionRole.sectionManager),
          );
        }
        final uids = users.map((u) => u.uid).toSet();
        final emails = users.map((u) => u.email).toSet();
        expect(uids.length, equals(users.length));
        expect(emails.length, equals(users.length));
        expect(users.every((u) => u.sections.isNotEmpty), isTrue);
      },
    );

    test('generateSampleEvents spreads events from today to one year out', () {
      const count = 12;
      final now = DateTime.now();
      final events = generateSampleEvents(count);
      final yearFromNow = now.add(const Duration(days: 365));

      expect(events.length, equals(count));
      for (final event in events) {
        expect(
          event.startDate.isBefore(now.subtract(const Duration(days: 1))),
          isFalse,
          reason: '${event.title} must not start before today',
        );
        expect(
          event.startDate.isBefore(yearFromNow),
          isTrue,
          reason: '${event.title} must start within a year',
        );
        expect(event.startDate.isBefore(event.endDate), isTrue);
        expect(event.status, equals(EventStatus.published));
      }

      // The last event should reach close to the one-year mark.
      final maxStart = events
          .map((e) => e.startDate)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      expect(maxStart.difference(now).inDays, greaterThan(300));
    });

    test('generateSampleEvents with zero/empty inputs yields empty lists', () {
      expect(generateSampleEvents(0), isEmpty);
      expect(generateSampleUsers(0), isEmpty);
    });
  });
}
