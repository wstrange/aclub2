// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CarpoolOption _$CarpoolOptionFromJson(Map<String, dynamic> json) =>
    _CarpoolOption(
      meetTime: const TimestampConverter().fromJson(
        json['meetTime'] as Timestamp,
      ),
      meetPlace: json['meetPlace'] as String,
    );

Map<String, dynamic> _$CarpoolOptionToJson(_CarpoolOption instance) =>
    <String, dynamic>{
      'meetTime': const TimestampConverter().toJson(instance.meetTime),
      'meetPlace': instance.meetPlace,
    };
