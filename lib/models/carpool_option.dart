import 'package:firestore_odm/firestore_odm.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import 'firestore_converter.dart';

part 'carpool_option.freezed.dart';
part 'carpool_option.g.dart';

/// Embedded carpool details for an [Event].
///
/// When an event offers carpooling, this object captures the meeting time and
/// place. Individual members indicate their driving preference in
/// [Registration.isDriver] / [Registration.needsRide].
@freezed
@firestoreOdm
abstract class CarpoolOption with _$CarpoolOption {
  const factory CarpoolOption({
    /// Time and date to meet for carpooling.
    @TimestampConverter() required DateTime meetTime,

    /// Description of the meeting point, e.g. "Park & Ride on Hwy 1".
    required String meetPlace,
  }) = _CarpoolOption;

  factory CarpoolOption.fromJson(Map<String, dynamic> json) => _$CarpoolOptionFromJson(json);
}
