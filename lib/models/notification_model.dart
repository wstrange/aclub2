import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';
import 'firestore_converter.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Firestore path: `/notifications/{notificationId}`
///
/// Represents a notification delivered to a specific member. Notifications can
/// be sent via multiple channels (push, email, in-app) and can be marked as
/// read or unread.
@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    /// Firestore document ID.
    required String id,

    /// The user this notification is addressed to.
    required String recipientId,

    required String title,
    required String message,

    /// Optional deep-link or in-app route, e.g. "/events/abc123".
    String? link,

    /// Which channels were used to deliver this notification.
    @Default([]) List<NotificationChannel> channels,

    /// Whether the recipient has marked this notification as read.
    @Default(false) bool isRead,

    // ── Optional references ───────────────────────────────────────────────
    String? relatedEventId,
    String? relatedSectionId,

    @TimestampConverter() required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
