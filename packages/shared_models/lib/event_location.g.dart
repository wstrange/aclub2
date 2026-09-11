// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventLocation _$EventLocationFromJson(Map<String, dynamic> json) =>
    _EventLocation(
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      mapUrl: json['mapUrl'] as String?,
    );

Map<String, dynamic> _$EventLocationToJson(_EventLocation instance) =>
    <String, dynamic>{
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'mapUrl': instance.mapUrl,
    };
