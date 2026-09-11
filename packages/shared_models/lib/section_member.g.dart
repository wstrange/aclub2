// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SectionMember _$SectionMemberFromJson(Map<String, dynamic> json) =>
    _SectionMember(
      id: json['id'] as String,
      sectionId: json['sectionId'] as String,
      sectionRole: $enumDecode(_$SectionRoleEnumMap, json['sectionRole']),
      externalSystemId: json['externalSystemId'] as String?,
      joinedAt: const TimestampConverter().fromJson(json['joinedAt'] as Object),
    );

Map<String, dynamic> _$SectionMemberToJson(_SectionMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sectionId': instance.sectionId,
      'sectionRole': _$SectionRoleEnumMap[instance.sectionRole]!,
      'externalSystemId': instance.externalSystemId,
      'joinedAt': const TimestampConverter().toJson(instance.joinedAt),
    };

const _$SectionRoleEnumMap = {
  SectionRole.sectionManager: 'sectionManager',
  SectionRole.tripLeader: 'tripLeader',
  SectionRole.member: 'member',
};
