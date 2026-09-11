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

  @override
  Object toJson(DateTime dateTime) => dateTime.toIso8601String();
}

/// Same as [TimestampConverter] but for nullable [DateTime] fields.
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
  Object? toJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toIso8601String();
  }
}
