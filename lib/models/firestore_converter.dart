import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts between Dart [DateTime] and Firestore [Timestamp].
///
/// Annotate required [DateTime] fields with `@TimestampConverter()`.
/// The repository layer passes Firestore document data directly to
/// `ModelClass.fromJson(doc.data()!)`, so this converter ensures the
/// Firestore [Timestamp] objects are transparently mapped to [DateTime].
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}

/// Same as [TimestampConverter] but for nullable [DateTime] fields.
class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }

  @override
  Object? toJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}
