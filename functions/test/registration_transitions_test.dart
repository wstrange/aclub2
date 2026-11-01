import 'package:aclub_functions/src/registration_transitions.dart';
import 'package:test/test.dart';

void main() {
  group('created registration notifications', () {
    test('pending notifies the leaders', () {
      expect(
        notificationForCreatedRegistration(status: 'pending', userId: 'u1'),
        RegistrationNotification.pendingRequested,
      );
    });

    test('self-approved registration is silent', () {
      expect(
        notificationForCreatedRegistration(status: 'approved', userId: 'u1'),
        RegistrationNotification.none,
      );
      expect(
        notificationForCreatedRegistration(status: 'approved', userId: 'u1', authId: 'u1'),
        RegistrationNotification.none,
      );
    });

    test('approved added by a leader notifies the member', () {
      expect(
        notificationForCreatedRegistration(status: 'approved', userId: 'u1', authId: 'leader'),
        RegistrationNotification.addedByLeader,
      );
    });

    test('waitlisted notifies the member', () {
      expect(
        notificationForCreatedRegistration(status: 'waitlisted', userId: 'u1'),
        RegistrationNotification.waitlisted,
      );
    });

    test('other statuses are silent', () {
      for (final status in ['rejected', 'attended', 'absent', 'withdrawn', null]) {
        expect(
          notificationForCreatedRegistration(status: status, userId: 'u1'),
          RegistrationNotification.none,
          reason: 'status=$status',
        );
      }
    });
  });

  group('updated registration notifications', () {
    RegistrationNotification update(
      String? before,
      String? after, {
      String userId = 'u1',
      String? authId,
      Map<String, dynamic>? afterData,
    }) => notificationForUpdatedRegistration(
      beforeStatus: before,
      afterStatus: after,
      userId: userId,
      authId: authId,
      afterData: afterData,
    );

    test('approval notifies the member', () {
      expect(update('pending', 'approved'), RegistrationNotification.approved);
      expect(update('waitlisted', 'approved'), RegistrationNotification.approved);
    });

    test('moving to waitlist notifies the member', () {
      expect(update('pending', 'waitlisted'), RegistrationNotification.waitlisted);
      expect(update('approved', 'waitlisted'), RegistrationNotification.waitlisted);
    });

    test('rejection notifies the member', () {
      expect(update('pending', 'rejected'), RegistrationNotification.rejected);
    });

    test('moving back to pending notifies the leaders', () {
      expect(update('approved', 'pending'), RegistrationNotification.pendingRequested);
    });

    test('self-withdrawal is detected from withdrawnByUserId', () {
      expect(
        update(
          'approved',
          'withdrawn',
          afterData: {'withdrawnByUserId': 'u1'},
        ),
        RegistrationNotification.selfWithdrawn,
      );
    });

    test('self-withdrawal falls back to deletedByUserId and authId', () {
      expect(
        update('pending', 'withdrawn', afterData: {'deletedByUserId': 'u1'}),
        RegistrationNotification.selfWithdrawn,
      );
      expect(update('waitlisted', 'withdrawn', authId: 'u1'), RegistrationNotification.selfWithdrawn);
    });

    test('leader removal notifies the member for active statuses', () {
      for (final before in ['approved', 'pending', 'waitlisted']) {
        expect(
          update(
            before,
            'withdrawn',
            afterData: {'withdrawnByUserId': 'leader'},
          ),
          RegistrationNotification.removedByLeader,
          reason: 'before=$before',
        );
      }
    });

    test('a withdrawal with no prior active status is silent', () {
      for (final before in ['rejected', 'withdrawn', 'attended', 'absent']) {
        expect(
          update(
            before,
            'withdrawn',
            afterData: {'withdrawnByUserId': 'leader'},
          ),
          RegistrationNotification.none,
          reason: 'before=$before',
        );
      }
    });

    test('same-status and unknown-status updates are silent', () {
      expect(update('approved', 'approved'), RegistrationNotification.none);
      expect(update('pending', null), RegistrationNotification.none);
      expect(update('approved', 'attended'), RegistrationNotification.none);
    });
  });

  group('deleted registration notifications', () {
    test('self-withdrawal is detected from the stored actor fields', () {
      expect(
        notificationForDeletedRegistration(
          status: 'approved',
          userId: 'u1',
          regData: {'withdrawnByUserId': 'u1'},
        ),
        RegistrationNotification.selfWithdrawn,
      );
      expect(
        notificationForDeletedRegistration(
          status: 'approved',
          userId: 'u1',
          regData: {'deletedByUserId': 'u1'},
        ),
        RegistrationNotification.selfWithdrawn,
      );
      expect(
        notificationForDeletedRegistration(status: 'approved', userId: 'u1', authId: 'u1'),
        RegistrationNotification.selfWithdrawn,
      );
    });

    test('leader removal notifies the member for active statuses', () {
      for (final status in ['approved', 'pending', 'waitlisted']) {
        expect(
          notificationForDeletedRegistration(
            status: status,
            userId: 'u1',
            regData: {'withdrawnByUserId': 'leader'},
          ),
          RegistrationNotification.removedByLeader,
          reason: 'status=$status',
        );
      }
    });

    test('deleting an inactive registration is silent', () {
      for (final status in ['rejected', 'withdrawn', 'attended', 'absent', null]) {
        expect(
          notificationForDeletedRegistration(
            status: status,
            userId: 'u1',
            regData: {'withdrawnByUserId': 'leader'},
          ),
          RegistrationNotification.none,
          reason: 'status=$status',
        );
      }
    });
  });
}
