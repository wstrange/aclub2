import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'firestore_converter.dart';
import 'notification_preferences.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Firestore path: `/users/{userId}`
///
/// The document ID matches the Firebase Auth UID. Stores profile and
/// preference data beyond what Firebase Auth provides.
///
/// Note: a user's role within a specific section (i.e. section manager) is
/// NOT stored here. It is tracked via [Section.managerIds] on the relevant
/// section documents.
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    /// Firebase Auth UID — used as the Firestore document ID.
    required String id,

    required String displayName,
    required String email,

    /// URL to the member's profile picture.
    String? photoUrl,

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
    /// IDs of the sections this user belongs to.
    @Default([]) List<String> sectionIds,

    /// Whether this user has global admin access.
    /// All other roles (section manager, trip leader, member) are per-section
    /// and are stored on each [SectionMember] document.
    @Default(false) bool isAdmin,

    // ── Preferences ───────────────────────────────────────────────────────
    required NotificationPreferences notificationPreferences,

    // ── Timestamps ────────────────────────────────────────────────────────
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
