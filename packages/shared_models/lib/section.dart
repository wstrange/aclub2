import 'package:firestore_odm_annotation/firestore_odm_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'section.freezed.dart';
part 'section.g.dart';

/// Firestore path: `/sections/{sectionId}`
///
/// Represents an alpine club section. A section can host multiple events and
/// have multiple members. Section managers are users listed in [managerIds];
/// their elevated permissions apply only within this section.
@freezed
@firestoreOdm
abstract class Section with _$Section {
  const factory Section({
    /// Firestore document ID.
    @DocumentIdField() required String id,

    required String name,

    String? description,

    /// Geographic location or region of the section, e.g. "Vancouver, BC".
    String? location,

    String? contactEmail,
    String? contactPhone,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Section;

  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);
}
