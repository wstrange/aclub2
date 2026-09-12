// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Template _$TemplateFromJson(Map<String, dynamic> json) => _Template(
  id: json['id'] as String,
  language: json['language'] as String,
  title: json['title'] as String,
  markdownText: json['markdownText'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt'] as Object),
);

Map<String, dynamic> _$TemplateToJson(_Template instance) => <String, dynamic>{
  'id': instance.id,
  'language': instance.language,
  'title': instance.title,
  'markdownText': instance.markdownText,
  'createdBy': instance.createdBy,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
