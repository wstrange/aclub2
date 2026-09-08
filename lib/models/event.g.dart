// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  sectionId: json['sectionId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  status:
      $enumDecodeNullable(_$EventStatusEnumMap, json['status']) ??
      EventStatus.draft,
  startDate: const TimestampConverter().fromJson(
    json['startDate'] as Timestamp,
  ),
  endDate: const TimestampConverter().fromJson(json['endDate'] as Timestamp),
  location: json['location'] == null
      ? null
      : EventLocation.fromJson(json['location'] as Map<String, dynamic>),
  carpoolOption: json['carpoolOption'] == null
      ? null
      : CarpoolOption.fromJson(json['carpoolOption'] as Map<String, dynamic>),
  minParticipants: (json['minParticipants'] as num?)?.toInt() ?? 0,
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  difficulty:
      $enumDecodeNullable(_$DifficultyEnumMap, json['difficulty']) ??
      Difficulty.moderate,
  requiresApproval: json['requiresApproval'] as bool? ?? false,
  requiredEquipment:
      (json['requiredEquipment'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  prerequisites:
      (json['prerequisites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  creatorId: json['creatorId'] as String,
  tripLeaderIds:
      (json['tripLeaderIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'sectionId': instance.sectionId,
  'title': instance.title,
  'description': instance.description,
  'type': _$EventTypeEnumMap[instance.type]!,
  'status': _$EventStatusEnumMap[instance.status]!,
  'startDate': const TimestampConverter().toJson(instance.startDate),
  'endDate': const TimestampConverter().toJson(instance.endDate),
  'location': instance.location,
  'carpoolOption': instance.carpoolOption,
  'minParticipants': instance.minParticipants,
  'maxParticipants': instance.maxParticipants,
  'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
  'requiresApproval': instance.requiresApproval,
  'requiredEquipment': instance.requiredEquipment,
  'prerequisites': instance.prerequisites,
  'creatorId': instance.creatorId,
  'tripLeaderIds': instance.tripLeaderIds,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$EventTypeEnumMap = {
  EventType.hike: 'hike',
  EventType.climb: 'climb',
  EventType.alpineSki: 'alpineSki',
  EventType.skiMountaineering: 'skiMountaineering',
  EventType.snowshoe: 'snowshoe',
  EventType.social: 'social',
  EventType.presentation: 'presentation',
};

const _$EventStatusEnumMap = {
  EventStatus.draft: 'draft',
  EventStatus.published: 'published',
};

const _$DifficultyEnumMap = {
  Difficulty.easy: 'easy',
  Difficulty.moderate: 'moderate',
  Difficulty.hard: 'hard',
};
