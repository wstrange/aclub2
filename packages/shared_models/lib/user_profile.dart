import 'package:firestore_odm_annotation/firestore_odm_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'firestore_converter.dart';
import 'notification_preferences.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Firestore path: `/users/{userId}`
///
/// The document ID matches the Firebase Auth UID. Stores profile and
/// preference data beyond what Firebase Auth provides in the `User` class.
///
/// Note: a user's role within a specific section (i.e. section manager) is
/// NOT stored here. It is tracked via [Section.managerIds] on the relevant
/// section documents.
///
/// /// TODO: replace with isAdmin: bool
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    /// Firebase Auth UID — used as the Firestore document ID.
    @DocumentIdField() required String id,

    required String firstName,
    required String lastName,

    /// Firebase Auth email. Denormalised here so other clients can display
    /// a user's email without needing Auth admin access.
    String? email,

    String? phone,

    // ── Emergency contact (mandatory) ─────────────────────────────────────
    required String emergencyContactName,
    required String emergencyContactPhone,
    String? emergencyContactRelation,

    // ── Health ────────────────────────────────────────────────────────────
    String? medicalConditions,

    /// Free-text certifications, e.g. ["First Aid", "AST 2", "ACMG Ski Guide"].
    @Default([]) List<String> certifications,

    // ── Memberships & roles ───────────────────────────────────────────────
    /// Membership is NOT stored on the profile. The source of truth is the
    /// `sections/{sectionId}/members/{userId}` subcollection. This field was
    /// removed so section membership can't be accidentally read from here.

    // The default section to login as
    String? defaultSectionId,

    /// Whether this user has global admin access.
    /// All other roles (section manager, trip leader, member) are per-section
    /// and are stored on each [SectionMember] document.
    @Default(false) bool isAdmin,

    @Default(false) bool complatedProfile,

    @Default(false) bool signedWaiver,

    /// FCM registration tokens for this user's devices.
    ///
    /// Populated by the mobile app (via `firebase_messaging`) when the user
    /// grants notification permission. Used by server-side functions to send
    /// push notifications for events the user is registered for or has
    /// expressed interest in.
    @Default([]) List<String> fcmTokens,

    // ── Preferences ───────────────────────────────────────────────────────
    @JsonKey(toJson: _notificationPreferencesToJson, fromJson: _notificationPreferencesFromJson)
    required NotificationPreferences notificationPreferences,

    // ── Timestamps ────────────────────────────────────────────────────────
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

Map<String, dynamic>? _notificationPreferencesToJson(NotificationPreferences? value) => value?.toJson();
NotificationPreferences _notificationPreferencesFromJson(Object? json) =>
    NotificationPreferences.fromJson(json as Map<String, dynamic>);
