import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'firestore_converter.dart';

part 'section_member.freezed.dart';
part 'section_member.g.dart';

/// Firestore path: `/sections/{sectionId}/members/{userId}`
///
/// Join record linking a user to a section. Supports syncing membership from
/// an external system via [externalSystemId].
@freezed
abstract class SectionMember with _$SectionMember {
  const factory SectionMember({
    /// Firestore document ID — matches the Firebase Auth UID.
    required String userId,

    /// The section this record belongs to.
    required String sectionId,

    /// Optional ID from an external membership management system.
    String? externalSystemId,

    /// When the user joined this section.
    @TimestampConverter() required DateTime joinedAt,
  }) = _SectionMember;

  factory SectionMember.fromJson(Map<String, dynamic> json) =>
      _$SectionMemberFromJson(json);
}
