import 'package:shared_models/shared_models.dart';

import 'event_details_state.dart';

/// A single derived view of an event's registration state.
///
/// The event detail page used to recompute capacity, waitlist position and
/// "can register" in several builders. Deriving them once here keeps the
/// register button, the leader actions and the status label consistent, and
/// makes the rules unit-testable.
class const RegistrationView({
  required this.myRegistration,
  required this.approvedCount,
  required this.hasSpace,
  required this.hasEnded,
  required this.waitlist,
  required this.pending,
  required this.approved,
  required this.myWaitlistPosition,
  required this.statusLabel,
  required this.canRegister,
  required this.manageable,
}) {
  factory RegistrationView.from({
    required Event event,
    required EventDetailsState details,
    required String? currentUid,
    DateTime? now,
  }) {
    final registrations = details.registrations;
    final myRegistration = currentUid == null
        ? null
        : registrations.where((registration) => registration.userId == currentUid).firstOrNull;

    // Only approved registrations count towards the event's capacity.
    final approvedCount = registrations.where((r) => r.status == RegistrationStatus.approved).length;
    final hasSpace = approvedCount < event.maxParticipants;

    // Registering is impossible once the event has passed. Managers can still
    // manage existing registrations (e.g. recording attendance).
    final hasEnded = event.endDate.isBefore(now ?? DateTime.now());

    final waitlist = details.waitlist;
    final pending = details.pendingRegistrations;
    final approved = details.approvedRegistrations;

    final myWaitlistIndex = currentUid != null && myRegistration?.status == RegistrationStatus.waitlisted
        ? waitlist.indexWhere((registration) => registration.userId == currentUid)
        : -1;
    final myWaitlistPosition = myWaitlistIndex >= 0 ? myWaitlistIndex + 1 : null;

    final statusLabel = switch (myRegistration?.status) {
      null => 'Not registered',
      RegistrationStatus.approved => 'Approved',
      RegistrationStatus.pending => 'Pending approval',
      RegistrationStatus.waitlisted =>
        myWaitlistPosition != null ? 'On waitlist (#$myWaitlistPosition of ${waitlist.length})' : 'On waitlist',
      RegistrationStatus.rejected => 'Rejected',
      RegistrationStatus.attended => 'Attended',
      RegistrationStatus.absent => 'Absent',
      RegistrationStatus.withdrawn => 'Withdrawn',
    };

    final canRegister =
        currentUid != null &&
        !hasEnded &&
        (myRegistration == null || myRegistration.status == RegistrationStatus.withdrawn) &&
        (hasSpace || event.requiresApproval);

    // Registrations a leader/manager can act on: pending, waitlisted, approved.
    final manageable = [...approved, ...pending, ...waitlist];

    return RegistrationView(
      myRegistration: myRegistration,
      approvedCount: approvedCount,
      hasSpace: hasSpace,
      hasEnded: hasEnded,
      waitlist: waitlist,
      pending: pending,
      approved: approved,
      myWaitlistPosition: myWaitlistPosition,
      statusLabel: statusLabel,
      canRegister: canRegister,
      manageable: manageable,
    );
  }

  /// The signed-in member's registration, if any.
  final Registration? myRegistration;

  /// Number of approved registrations; only these consume capacity.
  final int approvedCount;

  /// Whether the event still has room for another approved participant.
  final bool hasSpace;

  /// Whether the event has already ended.
  final bool hasEnded;

  /// Waitlisted registrations, earliest first.
  final List<Registration> waitlist;

  /// Registrations awaiting approval, earliest first.
  final List<Registration> pending;

  /// Approved registrations, earliest first.
  final List<Registration> approved;

  /// 1-based position on the waitlist, or `null` when not waitlisted.
  final int? myWaitlistPosition;

  /// Human-readable status for the signed-in member.
  final String statusLabel;

  /// Whether the signed-in member may register now.
  final bool canRegister;

  /// Registrations a leader/manager can act on (approved, pending, waitlisted).
  final List<Registration> manageable;
}
