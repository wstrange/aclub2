// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SectionMember _$SectionMemberFromJson(Map<String, dynamic> json) =>
    _SectionMember(
      userId: json['userId'] as String,
      sectionId: json['sectionId'] as String,
      sectionRole: $enumDecode(_$SectionRoleEnumMap, json['sectionRole']),
      externalSystemId: json['externalSystemId'] as String?,
      joinedAt: const TimestampConverter().fromJson(
        json['joinedAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$SectionMemberToJson(_SectionMember instance) =>
    <String, dynamic>{
      'userId': instance.userId,
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
