// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  email: json['email'] as String,
  photoUrl: json['photoUrl'] as String?,
  phone: json['phone'] as String?,
  emergencyContactName: json['emergencyContactName'] as String,
  emergencyContactPhone: json['emergencyContactPhone'] as String,
  emergencyContactRelation: json['emergencyContactRelation'] as String?,
  medicalConditions: json['medicalConditions'] as String?,
  certifications:
      (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  sectionIds:
      (json['sectionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isAdmin: json['isAdmin'] as bool? ?? false,
  notificationPreferences: NotificationPreferences.fromJson(
    json['notificationPreferences'] as Map<String, dynamic>,
  ),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'phone': instance.phone,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'emergencyContactRelation': instance.emergencyContactRelation,
      'medicalConditions': instance.medicalConditions,
      'certifications': instance.certifications,
      'sectionIds': instance.sectionIds,
      'isAdmin': instance.isAdmin,
      'notificationPreferences': instance.notificationPreferences,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
