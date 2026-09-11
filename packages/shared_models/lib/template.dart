
import 'package:firestore_odm_annotation/firestore_odm_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'firestore_converter.dart';

part 'template.freezed.dart';
part 'template.g.dart';

/// Firestore path: `/templates/{templateId}`
///
/// Admin-managed markdown templates that can be inserted into event
/// description fields (or any other markdown-accepting field). Supports
/// bilingual content via [language].
@freezed
@firestoreOdm
abstract class Template with _$Template {
  const Template._();

  const factory Template({
    /// Firestore document ID.
    @DocumentIdField() required String id,

    /// ISO language code — "en" or "fr".
    required String language,

    /// Short admin-visible name for this template.
    required String title,

    /// The full markdown body of the template.
    required String markdownText,

    /// User ID of the admin who created the template.
    required String createdBy,

    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Template;

  factory Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);
}
