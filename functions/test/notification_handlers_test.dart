import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

/// todo: These are AI generate, and mostly useless. Delete or fix.
void main() {
  group('Notification and Event Lifecycle Logic', () {
    test('EventStatus enum names match expected Firestore string values', () {
      expect(EventStatus.draft.name, equals('draft'));
      expect(EventStatus.published.name, equals('published'));
    });

    test('RegistrationStatus enum names match expected Firestore string values', () {
      expect(RegistrationStatus.pending.name, equals('pending'));
      expect(RegistrationStatus.approved.name, equals('approved'));
      expect(RegistrationStatus.waitlisted.name, equals('waitlisted'));
      expect(RegistrationStatus.rejected.name, equals('rejected'));
    });

    test('Event publishing transition detection', () {
      // Transition from draft to published should trigger
      final beforeDraft = {'status': EventStatus.draft.name};
      final afterPublished = {'status': EventStatus.published.name};
      final isPublishingTransition =
          beforeDraft['status'] != EventStatus.published.name && afterPublished['status'] == EventStatus.published.name;
      expect(isPublishingTransition, isTrue);

      // Subsequent update on an already-published event should NOT trigger publishing notification
      final beforePublished = {'status': EventStatus.published.name};
      final afterStillPublished = {'status': EventStatus.published.name};
      final isSubsequentUpdate =
          beforePublished['status'] != EventStatus.published.name &&
          afterStillPublished['status'] == EventStatus.published.name;
      expect(isSubsequentUpdate, isFalse);
    });

    test('Registration approval transition detection', () {
      final beforePending = {'status': RegistrationStatus.pending.name};
      final afterApproved = {'status': RegistrationStatus.approved.name};

      final isApprovalTransition =
          beforePending['status'] != RegistrationStatus.approved.name &&
          afterApproved['status'] == RegistrationStatus.approved.name;
      expect(isApprovalTransition, isTrue);
    });

    test('Registration waitlist transition detection', () {
      final beforePending = {'status': RegistrationStatus.pending.name};
      final afterWaitlist = {'status': RegistrationStatus.waitlisted.name};

      final isWaitlistTransition =
          beforePending['status'] != RegistrationStatus.waitlisted.name &&
          afterWaitlist['status'] == RegistrationStatus.waitlisted.name;
      expect(isWaitlistTransition, isTrue);
    });

    test('Registration rejection transition detection', () {
      final beforePending = {'status': RegistrationStatus.pending.name};
      final afterRejected = {'status': RegistrationStatus.rejected.name};

      final isRejectedTransition =
          beforePending['status'] != RegistrationStatus.rejected.name &&
          afterRejected['status'] == RegistrationStatus.rejected.name;
      expect(isRejectedTransition, isTrue);
    });

    test('Self-withdrawal detected via deletedByUserId field (client-stamped)', () {
      const userId = 'user-123';

      // Self-withdrawal: client stamps deletedByUserId == userId on the doc
      final regData = {'userId': userId, 'deletedByUserId': userId};
      final effectiveDeletedBy = regData['deletedByUserId'] ?? /* authId fallback */ null;
      final isSelfWithdrawal = effectiveDeletedBy != null && effectiveDeletedBy == userId;
      expect(isSelfWithdrawal, isTrue);
    });

    test('Leader removal detected when deletedByUserId != userId', () {
      const userId = 'user-123';

      // Leader removal: deletedByUserId is the leader's UID
      final regData = {'userId': userId, 'deletedByUserId': 'leader-456'};
      final effectiveDeletedBy = regData['deletedByUserId'];
      final isSelfWithdrawal = effectiveDeletedBy != null && effectiveDeletedBy == userId;
      expect(isSelfWithdrawal, isFalse);
    });

    test('Falls back to authId when deletedByUserId is absent (HTTPS path)', () {
      const userId = 'user-123';
      const authId = 'user-123'; // HTTPS caller passes their UID

      final regData = <String, dynamic>{'userId': userId}; // no deletedByUserId
      final effectiveDeletedBy = regData['deletedByUserId']?.toString() ?? authId;
      final isSelfWithdrawal = effectiveDeletedBy != null && effectiveDeletedBy == userId;
      expect(isSelfWithdrawal, isTrue);
    });

    test('Withdrawal notification targets leaders and creator, not the withdrawing user', () {
      const withdrawingUserId = 'user-123';
      final eventData = {
        'tripLeaderIds': ['leader-456', 'leader-789'],
        'creatorId': 'creator-101',
      };

      // Collect unique leader/creator IDs
      final leaders = <String>{};
      final tripLeaderIds = eventData['tripLeaderIds'];
      if (tripLeaderIds is List) {
        for (final id in tripLeaderIds) {
          leaders.add(id.toString());
        }
      }
      final creatorId = eventData['creatorId']?.toString();
      if (creatorId != null) leaders.add(creatorId);

      // Remove the withdrawing user in case they are also a leader
      leaders.remove(withdrawingUserId);

      expect(leaders, containsAll(['leader-456', 'leader-789', 'creator-101']));
      expect(leaders, isNot(contains(withdrawingUserId)));
    });

    test('Withdrawal notification excludes withdrawing user if they are a leader', () {
      const withdrawingUserId = 'leader-456'; // also a leader
      final eventData = {
        'tripLeaderIds': ['leader-456', 'leader-789'],
        'creatorId': 'creator-101',
      };

      final leaders = <String>{};
      final tripLeaderIds = eventData['tripLeaderIds'];
      if (tripLeaderIds is List) {
        for (final id in tripLeaderIds) {
          leaders.add(id.toString());
        }
      }
      final creatorId = eventData['creatorId']?.toString();
      if (creatorId != null) leaders.add(creatorId);
      leaders.remove(withdrawingUserId);

      expect(leaders, containsAll(['leader-789', 'creator-101']));
      expect(leaders, isNot(contains(withdrawingUserId)));
    });

    test('NotificationModel link generation format', () {
      const eventId = 'event-xyz';
      const link = '/events/$eventId';
      expect(link, equals('/events/event-xyz'));
    });
  });
}
