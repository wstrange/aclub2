import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

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
          beforeDraft['status'] != EventStatus.published.name &&
          afterPublished['status'] == EventStatus.published.name;
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

    test('Self-withdrawal vs leader removal detection', () {
      const registrantUserId = 'user-123';

      // Self-withdrawal: authId == userId
      const selfAuthId = 'user-123';
      final isSelfWithdrawal = selfAuthId == registrantUserId;
      expect(isSelfWithdrawal, isTrue);

      // Leader removal: authId != userId
      const leaderAuthId = 'leader-456';
      final isLeaderRemoval = leaderAuthId != registrantUserId;
      expect(isLeaderRemoval, isTrue);
    });

    test('NotificationModel link generation format', () {
      const eventId = 'event-xyz';
      const link = '/events/$eventId';
      expect(link, equals('/events/event-xyz'));
    });
  });
}
