import 'package:firestore_odm/firestore_odm.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'notification_preferences.freezed.dart';
part 'notification_preferences.g.dart';

/// Embedded object stored inside a [UserModel] document.
/// Controls which channels and how frequently a member receives notifications.
@freezed
@firestoreOdm
abstract class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    /// Whether the member receives push notifications.
    @Default(true) bool pushEnabled,

    /// Whether the member receives email notifications.
    @Default(true) bool emailEnabled,

    /// Whether the member receives in-app notifications.
    @Default(true) bool inAppEnabled,

    /// How often notifications are batched / delivered.
    @Default(NotificationFrequency.immediate) NotificationFrequency frequency,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);
}
