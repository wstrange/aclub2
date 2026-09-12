// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(
  Map<String, dynamic> json,
) => _NotificationModel(
  id: json['id'] as String,
  recipientId: json['recipientId'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  link: json['link'] as String?,
  channels:
      (json['channels'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isRead: json['isRead'] as bool? ?? false,
  relatedEventId: json['relatedEventId'] as String?,
  relatedSectionId: json['relatedSectionId'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
);

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientId': instance.recipientId,
      'title': instance.title,
      'message': instance.message,
      'link': instance.link,
      'channels': instance.channels,
      'isRead': instance.isRead,
      'relatedEventId': instance.relatedEventId,
      'relatedSectionId': instance.relatedSectionId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
