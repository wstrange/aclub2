// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Section _$SectionFromJson(Map<String, dynamic> json) => _Section(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  location: json['location'] as String?,
  contactEmail: json['contactEmail'] as String?,
  contactPhone: json['contactPhone'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SectionToJson(_Section instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'location': instance.location,
  'contactEmail': instance.contactEmail,
  'contactPhone': instance.contactPhone,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
