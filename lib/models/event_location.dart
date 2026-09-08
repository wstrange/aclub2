import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_location.freezed.dart';
part 'event_location.g.dart';

/// Embedded location object for an [Event].
///
/// At least one of [description], GPS ([latitude] + [longitude]), or [mapUrl]
/// should be provided. All fields are nullable to support flexible location
/// descriptions.
@freezed
abstract class EventLocation with _$EventLocation {
  const factory EventLocation({
    /// Free-text description, e.g. "Meet at the base of the north face".
    String? description,

    /// GPS latitude in decimal degrees.
    double? latitude,

    /// GPS longitude in decimal degrees.
    double? longitude,

    /// HTTP link to an external map (e.g. Google Maps, CalTopo).
    String? mapUrl,
  }) = _EventLocation;

  factory EventLocation.fromJson(Map<String, dynamic> json) =>
      _$EventLocationFromJson(json);
}
