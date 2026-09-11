// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferences(
  pushEnabled: json['pushEnabled'] as bool? ?? true,
  emailEnabled: json['emailEnabled'] as bool? ?? true,
  inAppEnabled: json['inAppEnabled'] as bool? ?? true,
  frequency:
      $enumDecodeNullable(_$NotificationFrequencyEnumMap, json['frequency']) ??
      NotificationFrequency.immediate,
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'pushEnabled': instance.pushEnabled,
  'emailEnabled': instance.emailEnabled,
  'inAppEnabled': instance.inAppEnabled,
  'frequency': _$NotificationFrequencyEnumMap[instance.frequency]!,
};

const _$NotificationFrequencyEnumMap = {
  NotificationFrequency.immediate: 'immediate',
  NotificationFrequency.daily: 'daily',
  NotificationFrequency.weekly: 'weekly',
};
