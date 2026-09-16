import 'package:json_annotation/json_annotation.dart';

/// Converts between Dart [DateTime] and Firestore [Timestamp] or ISO-8601 string / int.
///
/// Annotate required [DateTime] fields with `@TimestampConverter()`.
/// This converter ensures Firestore [Timestamp] objects, ISO-8601 strings, and
/// epoch milliseconds are transparently mapped to [DateTime] across both
/// client (`cloud_firestore`), admin (`dart_firebase_admin`), and HTTP/JSON environments.
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is DateTime) return json;
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    try {
      dynamic d = json;
      if (d.toDate != null) return d.toDate() as DateTime;
    } catch (_) {}
    try {
      dynamic d = json;
      if (d.millisecondsSinceEpoch != null) {
        return DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch as int);
      }
    } catch (_) {}
    throw ArgumentError.value(json, 'json', 'Cannot convert to DateTime');
  }

  /// Passes the [DateTime] through so Firestore SDKs (`cloud_firestore`,
  /// `google_cloud_firestore`) serialize it into a native Firestore
  /// [Timestamp] on write. Do not return an ISO-8601 string here — doing so
  /// would make Firestore store a string instead of a timestamp.
  @override
  Object toJson(DateTime dateTime) => dateTime;
}

/// Same as [TimestampConverter] but for nullable [DateTime] fields.
  /// [toJson] passes the [DateTime] through (non-null) so Firestore SDKs store
  /// native timestamps; null values are preserved.
  class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
    const NullableTimestampConverter();

    @override
    DateTime? fromJson(Object? value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      try {
        dynamic d = value;
        if (d.toDate != null) return d.toDate() as DateTime;
      } catch (_) {}
      try {
        dynamic d = value;
        if (d.millisecondsSinceEpoch != null) {
          return DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch as int);
        }
      } catch (_) {}
      return null;
    }

    @override
    Object? toJson(DateTime? dateTime) => dateTime;
  }
