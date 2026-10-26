import 'package:aclub2/state/event_details_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

void main() {
  group('EventDetailsStateX waitlist sorting and first-come first-served logic', () {
    final t1 = DateTime(2026, 9, 10, 9, 0);
    final t2 = DateTime(2026, 9, 10, 9, 30);
    final t3 = DateTime(2026, 9, 10, 10, 0);
    final t4 = DateTime(2026, 9, 10, 10, 15);
    final t5 = DateTime(2026, 9, 10, 11, 0);

    test('waitlist getter filters only waitlisted and sorts by registeredAt ascending', () {
      final regUser1 = Registration(
        id: 'u1',
        userId: 'u1',
        status: RegistrationStatus.waitlisted,
        registeredAt: t3, // 10:00
        updatedAt: t3,
      );
      final regUser2 = Registration(
        id: 'u2',
        userId: 'u2',
        status: RegistrationStatus.waitlisted,
        registeredAt: t1, // 09:00 (earliest)
        updatedAt: t1,
      );
      final regUser3 = Registration(
        id: 'u3',
        userId: 'u3',
        status: RegistrationStatus.waitlisted,
        registeredAt: t4, // 10:15
        updatedAt: t4,
      );
      final regUser4 = Registration(
        id: 'u4',
        userId: 'u4',
        status: RegistrationStatus.waitlisted,
        registeredAt: t2, // 09:30
        updatedAt: t2,
      );
      final approvedUser = Registration(
        id: 'uApproved',
        userId: 'uApproved',
        status: RegistrationStatus.approved,
        registeredAt: t1,
        updatedAt: t1,
      );
      final pendingUser = Registration(
        id: 'uPending',
        userId: 'uPending',
        status: RegistrationStatus.pending,
        registeredAt: t2,
        updatedAt: t2,
      );
      final withdrawnUser = Registration(
        id: 'uWithdrawn',
        userId: 'uWithdrawn',
        status: RegistrationStatus.withdrawn,
        registeredAt: t1,
        updatedAt: t5,
      );

      // Supplied in arbitrary / non-chronological order
      final state = EventDetailsState(
        sectionId: 'sec-1',
        eventId: 'ev-1',
        registrations: [
          regUser1,
          approvedUser,
          regUser3,
          pendingUser,
          withdrawnUser,
          regUser2,
          regUser4,
        ],
      );

      final waitlist = state.waitlist;

      expect(waitlist.length, equals(4));
      // First come, first served: earliest registeredAt first
      expect(waitlist[0].userId, equals('u2')); // 09:00 (#1)
      expect(waitlist[1].userId, equals('u4')); // 09:30 (#2)
      expect(waitlist[2].userId, equals('u1')); // 10:00 (#3)
      expect(waitlist[3].userId, equals('u3')); // 10:15 (#4)

      expect(waitlist[0].registeredAt, equals(t1));
      expect(waitlist[1].registeredAt, equals(t2));
      expect(waitlist[2].registeredAt, equals(t3));
      expect(waitlist[3].registeredAt, equals(t4));
    });

    test('calculates correct 1-based position for waitlisted user', () {
      final regA = Registration(
        id: 'alice',
        userId: 'alice',
        status: RegistrationStatus.waitlisted,
        registeredAt: t1,
        updatedAt: t1,
      );
      final regB = Registration(
        id: 'bob',
        userId: 'bob',
        status: RegistrationStatus.waitlisted,
        registeredAt: t2,
        updatedAt: t2,
      );
      final regC = Registration(
        id: 'charlie',
        userId: 'charlie',
        status: RegistrationStatus.waitlisted,
        registeredAt: t3,
        updatedAt: t3,
      );

      final state = EventDetailsState(
        sectionId: 'sec-1',
        eventId: 'ev-1',
        registrations: [regC, regA, regB],
      );

      final waitlist = state.waitlist;

      int positionFor(String userId) {
        final idx = waitlist.indexWhere((r) => r.userId == userId);
        return idx >= 0 ? idx + 1 : -1;
      }

      expect(positionFor('alice'), equals(1));
      expect(positionFor('bob'), equals(2));
      expect(positionFor('charlie'), equals(3));
      expect(positionFor('david'), equals(-1));
    });

    test('when leader approves #1 waitlisted user, next in line becomes #1', () {
      final reg1 = Registration(
        id: 'u1',
        userId: 'u1',
        status: RegistrationStatus.waitlisted,
        registeredAt: t1,
        updatedAt: t1,
      );
      final reg2 = Registration(
        id: 'u2',
        userId: 'u2',
        status: RegistrationStatus.waitlisted,
        registeredAt: t2,
        updatedAt: t2,
      );

      final initial = EventDetailsState(
        sectionId: 'sec-1',
        eventId: 'ev-1',
        registrations: [reg2, reg1],
      );

      expect(initial.waitlist.first.userId, equals('u1'));

      // Trip leader approves u1
      final afterApproval = initial.copyWith(
        registrations: [
          reg1.copyWith(status: RegistrationStatus.approved),
          reg2,
        ],
      );

      expect(afterApproval.waitlist.length, equals(1));
      expect(afterApproval.waitlist.first.userId, equals('u2'));
      expect(afterApproval.approvedRegistrations.map((r) => r.userId), contains('u1'));
    });

    test('trip leader may approve out of order without breaking chronological sorting of remaining waitlist', () {
      final reg1 = Registration(
        id: 'u1',
        userId: 'u1',
        status: RegistrationStatus.waitlisted,
        registeredAt: t1,
        updatedAt: t1,
      );
      final reg2 = Registration(
        id: 'u2',
        userId: 'u2',
        status: RegistrationStatus.waitlisted,
        registeredAt: t2,
        updatedAt: t2,
      );
      final reg3 = Registration(
        id: 'u3',
        userId: 'u3',
        status: RegistrationStatus.waitlisted,
        registeredAt: t3,
        updatedAt: t3,
      );

      final initial = EventDetailsState(
        sectionId: 'sec-1',
        eventId: 'ev-1',
        registrations: [reg3, reg1, reg2],
      );

      expect(initial.waitlist.map((r) => r.userId).toList(), equals(['u1', 'u2', 'u3']));

      // Leader chooses to approve u2 (out of order, e.g. for carpool/skills)
      final afterApproval = initial.copyWith(
        registrations: [
          reg1,
          reg2.copyWith(status: RegistrationStatus.approved),
          reg3,
        ],
      );

      // Remaining waitlist stays chronologically sorted: u1 is still #1, u3 becomes #2
      expect(afterApproval.waitlist.map((r) => r.userId).toList(), equals(['u1', 'u3']));
      expect(afterApproval.approvedRegistrations.map((r) => r.userId), contains('u2'));
    });
  });
}
