import 'package:shared_models/shared_models.dart';

/// The notification side effect of a registration lifecycle transition.
///
/// Keeping this mapping in one pure place makes the transition table explicit
/// and testable; the handlers only translate the result into notification
/// payloads.
enum RegistrationNotification {
  /// No notification is sent for this transition.
  none,

  /// A registration was created as `pending`; notify the event leaders.
  pendingRequested,

  /// A leader added another member as `approved`; notify that member.
  addedByLeader,

  /// The registration moved to `approved`; notify the member.
  approved,

  /// The registration moved to (or was created as) `waitlisted`.
  waitlisted,

  /// The registration moved to `rejected`; notify the member.
  rejected,

  /// The member withdrew themselves; notify the event leaders.
  selfWithdrawn,

  /// A leader removed an active registration; notify the member.
  removedByLeader,
}

final _activeStatuses = {
  RegistrationStatus.pending.name,
  RegistrationStatus.approved.name,
  RegistrationStatus.waitlisted.name,
};

/// Notification for a newly created registration.
///
/// A self-registration as `approved` is silent (the member already knows); an
/// `approved` registration created by a leader for someone else notifies the
/// added member.
RegistrationNotification notificationForCreatedRegistration({
  required String? status,
  required String userId,
  String? authId,
}) {
  switch (status) {
    case 'pending':
      return RegistrationNotification.pendingRequested;
    case 'approved':
      return authId != null && authId != userId ? RegistrationNotification.addedByLeader : RegistrationNotification.none;
    case 'waitlisted':
      return RegistrationNotification.waitlisted;
    default:
      return RegistrationNotification.none;
  }
}

/// Notification for a registration update.
///
/// Withdrawal is classified using the client-stamped `withdrawnByUserId` (or
/// the legacy `deletedByUserId`), falling back to [authId] for HTTPS callers.
RegistrationNotification notificationForUpdatedRegistration({
  required String? beforeStatus,
  required String? afterStatus,
  required String userId,
  String? authId,
  Map<String, dynamic>? afterData,
}) {
  if (afterStatus == null || beforeStatus == afterStatus) {
    return RegistrationNotification.none;
  }

  switch (afterStatus) {
    case 'approved':
      return RegistrationNotification.approved;
    case 'waitlisted':
      return RegistrationNotification.waitlisted;
    case 'rejected':
      return RegistrationNotification.rejected;
    case 'pending':
      return RegistrationNotification.pendingRequested;
    case 'withdrawn':
      final withdrawnBy =
          afterData?['withdrawnByUserId']?.toString() ??
          afterData?['deletedByUserId']?.toString() ??
          authId;
      if (withdrawnBy != null && withdrawnBy == userId) {
        return RegistrationNotification.selfWithdrawn;
      }
      if (beforeStatus == null || _activeStatuses.contains(beforeStatus)) {
        return RegistrationNotification.removedByLeader;
      }
      return RegistrationNotification.none;
    default:
      return RegistrationNotification.none;
  }
}

/// Notification for a hard-deleted registration.
RegistrationNotification notificationForDeletedRegistration({
  required String? status,
  required String userId,
  String? authId,
  Map<String, dynamic>? regData,
}) {
  final deletedBy =
      regData?['withdrawnByUserId']?.toString() ??
      regData?['deletedByUserId']?.toString() ??
      authId;
  if (deletedBy != null && deletedBy == userId) {
    return RegistrationNotification.selfWithdrawn;
  }
  if (status != null && _activeStatuses.contains(status)) {
    return RegistrationNotification.removedByLeader;
  }
  return RegistrationNotification.none;
}
