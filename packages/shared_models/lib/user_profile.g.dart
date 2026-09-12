// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String?,
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
  defaultSectionId: json['defaultSectionId'] as String?,
  isAdmin: json['isAdmin'] as bool? ?? false,
  complatedProfile: json['complatedProfile'] as bool? ?? false,
  signedWaiver: json['signedWaiver'] as bool? ?? false,
  notificationPreferences: _notificationPreferencesFromJson(
    json['notificationPreferences'],
  ),
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt'] as Object),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'emergencyContactRelation': instance.emergencyContactRelation,
      'medicalConditions': instance.medicalConditions,
      'certifications': instance.certifications,
      'sectionIds': instance.sectionIds,
      'defaultSectionId': instance.defaultSectionId,
      'isAdmin': instance.isAdmin,
      'complatedProfile': instance.complatedProfile,
      'signedWaiver': instance.signedWaiver,
      'notificationPreferences': _notificationPreferencesToJson(
        instance.notificationPreferences,
      ),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
