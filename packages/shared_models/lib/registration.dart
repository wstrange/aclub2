
import 'package:firestore_odm/firestore_odm.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';
import 'firestore_converter.dart';

part 'registration.freezed.dart';
part 'registration.g.dart';

/// Firestore path: `/sections/{sectionId}/events/{eventId}/registrations/{registrationId}`
///
/// Records a member's registration for an event.
/// - For direct-registration events, status starts at [RegistrationStatus.approved].
/// - For approval-required events, status starts at [RegistrationStatus.pending]
///   or [RegistrationStatus.waitlisted] once capacity is reached.
/// - A member can add a guest by setting [guestName].
@freezed
@firestoreOdm
abstract class Registration with _$Registration {
  const factory Registration({
    /// Firestore document ID.
    required String id,

    /// The user who registered (or on whose behalf this registration exists).
    required String userId,

    /// Non-null when a member has registered a guest. Guests have no user
    /// account but are tracked via the registering member's record.
    String? guestName,

    @Default(RegistrationStatus.pending) RegistrationStatus status,

    // ── Carpool preference ────────────────────────────────────────────────
    /// True if this member is willing to drive others.
    bool? isDriver,

    /// True if this member needs a ride.
    bool? needsRide,

    // ── Timestamps ────────────────────────────────────────────────────────
    @TimestampConverter() required DateTime registeredAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Registration;

  factory Registration.fromJson(Map<String, dynamic> json) =>
      _$RegistrationFromJson(json);
}
