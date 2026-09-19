import 'package:aclub2/state/member_directory_cubit.dart';
import 'package:aclub2/state/member_directory_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

void main() {
  group('MemberDirectoryEntry', () {
    final now = DateTime(2026, 9, 1);

    test('resolves full name and initials when profile has first and last name', () {
      final member = SectionMember(
        id: 'user-1',
        sectionId: 'calgary',
        sectionRole: SectionRole.sectionManager,
        joinedAt: now,
      );
      final profile = UserProfile(
        id: 'user-1',
        firstName: 'Alice',
        lastName: 'Smith',
        email: 'alice@example.com',
        phone: '403-555-0100',
        emergencyContactName: 'Bob',
        emergencyContactPhone: '403-555-0101',
        notificationPreferences: NotificationPreferences(),
        createdAt: now,
        updatedAt: now,
      );

      final entry = MemberDirectoryEntry(member: member, profile: profile);

      expect(entry.displayName, equals('Alice Smith'));
      expect(entry.initials, equals('AS'));
      expect(entry.roleDisplayName, equals('Section Manager'));
      expect(entry.email, equals('alice@example.com'));
      expect(entry.phone, equals('403-555-0100'));
    });

    test('falls back to email or user id when names are missing', () {
      final member = SectionMember(
        id: 'u-123456789',
        sectionId: 'calgary',
        sectionRole: SectionRole.member,
        joinedAt: now,
      );
      final profileWithEmailOnly = UserProfile(
        id: 'u-123456789',
        firstName: '',
        lastName: '',
        email: 'climber@mountain.org',
        emergencyContactName: 'E',
        emergencyContactPhone: 'P',
        notificationPreferences: NotificationPreferences(),
        createdAt: now,
        updatedAt: now,
      );

      final entryWithEmail = MemberDirectoryEntry(member: member, profile: profileWithEmailOnly);
      expect(entryWithEmail.displayName, equals('climber@mountain.org'));
      expect(entryWithEmail.initials, equals('CL'));

      final entryWithoutProfile = MemberDirectoryEntry(member: member);
      expect(entryWithoutProfile.displayName, equals('Member (u-1234)'));
      expect(entryWithoutProfile.initials, equals('ME'));
    });
  });

  group('MemberDirectoryState filtering and sorting', () {
    final now = DateTime(2026, 9, 1);

    final manager = MemberDirectoryEntry(
      member: SectionMember(id: 'm1', sectionId: 'sec-1', sectionRole: SectionRole.sectionManager, joinedAt: now),
      profile: UserProfile(
        id: 'm1',
        firstName: 'Zachary',
        lastName: 'Manager',
        email: 'zach@club.org',
        certifications: ['AST 2', 'First Aid'],
        emergencyContactName: 'E',
        emergencyContactPhone: 'P',
        notificationPreferences: NotificationPreferences(),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final leaderA = MemberDirectoryEntry(
      member: SectionMember(id: 'l1', sectionId: 'sec-1', sectionRole: SectionRole.tripLeader, joinedAt: now),
      profile: UserProfile(
        id: 'l1',
        firstName: 'Bob',
        lastName: 'Leader',
        email: 'bob@club.org',
        certifications: ['First Aid'],
        emergencyContactName: 'E',
        emergencyContactPhone: 'P',
        notificationPreferences: NotificationPreferences(),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final leaderB = MemberDirectoryEntry(
      member: SectionMember(id: 'l2', sectionId: 'sec-1', sectionRole: SectionRole.tripLeader, joinedAt: now),
      profile: UserProfile(
        id: 'l2',
        firstName: 'Alice',
        lastName: 'Leader',
        email: 'alice@club.org',
        certifications: ['AST 1'],
        emergencyContactName: 'E',
        emergencyContactPhone: 'P',
        notificationPreferences: NotificationPreferences(),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final regularMember = MemberDirectoryEntry(
      member: SectionMember(id: 'mem1', sectionId: 'sec-1', sectionRole: SectionRole.member, joinedAt: now),
      profile: UserProfile(
        id: 'mem1',
        firstName: 'Charlie',
        lastName: 'Climber',
        email: 'charlie@gmail.com',
        emergencyContactName: 'E',
        emergencyContactPhone: 'P',
        notificationPreferences: NotificationPreferences(),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final allEntries = [regularMember, leaderA, manager, leaderB];

    test('counts members by role correctly', () {
      final state = MemberDirectoryState(
        sectionId: 'sec-1',
        entries: allEntries,
        isLoading: false,
      );

      expect(state.totalCount, equals(4));
      expect(state.managerCount, equals(1));
      expect(state.tripLeaderCount, equals(2));
      expect(state.memberCount, equals(1));
    });

    test('sorts by role hierarchy (Managers -> Leaders -> Members) and then alphabetically', () {
      final state = MemberDirectoryState(
        sectionId: 'sec-1',
        entries: allEntries,
        isLoading: false,
      );

      final sorted = state.filteredEntries;
      expect(sorted.length, equals(4));
      // Manager first (even though name is Zachary)
      expect(sorted[0].displayName, equals('Zachary Manager'));
      // Trip Leaders next, sorted alphabetically: Alice Leader then Bob Leader
      expect(sorted[1].displayName, equals('Alice Leader'));
      expect(sorted[2].displayName, equals('Bob Leader'));
      // Regular member last
      expect(sorted[3].displayName, equals('Charlie Climber'));
    });

    test('filters entries by role', () {
      final state = MemberDirectoryState(
        sectionId: 'sec-1',
        entries: allEntries,
        isLoading: false,
        selectedRole: SectionRole.tripLeader,
      );

      final filtered = state.filteredEntries;
      expect(filtered.length, equals(2));
      expect(filtered.map((e) => e.displayName), containsAll(['Alice Leader', 'Bob Leader']));
    });

    test('filters entries by search query on name', () {
      final state = MemberDirectoryState(
        sectionId: 'sec-1',
        entries: allEntries,
        isLoading: false,
        searchQuery: 'charlie',
      );

      final filtered = state.filteredEntries;
      expect(filtered.length, equals(1));
      expect(filtered.first.displayName, equals('Charlie Climber'));
    });

    test('filters entries by search query on email', () {
      final state = MemberDirectoryState(
        sectionId: 'sec-1',
        entries: allEntries,
        isLoading: false,
        searchQuery: 'gmail.com',
      );

      final filtered = state.filteredEntries;
      expect(filtered.length, equals(1));
      expect(filtered.first.displayName, equals('Charlie Climber'));
    });

    test('filters entries by search query on certification', () {
      final state = MemberDirectoryState(
        sectionId: 'sec-1',
        entries: allEntries,
        isLoading: false,
        searchQuery: 'AST 2',
      );

      final filtered = state.filteredEntries;
      expect(filtered.length, equals(1));
      expect(filtered.first.displayName, equals('Zachary Manager'));
    });
  });

  group('MemberDirectoryCubit', () {
    test('updates search query and role filter synchronously', () async {
      final cubit = MemberDirectoryCubit(sectionId: 'test-section');
      addTearDown(cubit.close);

      expect(cubit.value.searchQuery, isEmpty);
      expect(cubit.value.selectedRole, isNull);

      cubit.setSearchQuery('alpine');
      expect(cubit.value.searchQuery, equals('alpine'));

      cubit.setRoleFilter(SectionRole.sectionManager);
      expect(cubit.value.selectedRole, equals(SectionRole.sectionManager));

      cubit.setRoleFilter(null);
      expect(cubit.value.selectedRole, isNull);
    });
  });
}
