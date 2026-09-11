
import 'package:firestore_odm/firestore_odm.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'firestore_converter.dart';

part 'section_member.freezed.dart';
part 'section_member.g.dart';

/// Firestore path: `/sections/{sectionId}/members/{userId}`
///
/// Join record linking a user to a section. Supports syncing membership from
/// an external system via [externalSystemId].
@freezed
@firestoreOdm
abstract class SectionMember with _$SectionMember {
  const factory SectionMember({
    /// Firestore document ID — matches the Firebase Auth UID.
    @DocumentIdField() required String id,

    /// The section this record belongs to.
    required String sectionId,

    required SectionRole sectionRole,

    /// Optional ID from an external membership management system.
    String? externalSystemId,

    /// When the user joined this section.
    @TimestampConverter() required DateTime joinedAt,
  }) = _SectionMember;

  factory SectionMember.fromJson(Map<String, dynamic> json) => _$SectionMemberFromJson(json);
}
