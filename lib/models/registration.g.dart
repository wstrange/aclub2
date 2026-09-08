// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Registration _$RegistrationFromJson(Map<String, dynamic> json) =>
    _Registration(
      id: json['id'] as String,
      userId: json['userId'] as String,
      guestName: json['guestName'] as String?,
      status:
          $enumDecodeNullable(_$RegistrationStatusEnumMap, json['status']) ??
          RegistrationStatus.pending,
      isDriver: json['isDriver'] as bool?,
      needsRide: json['needsRide'] as bool?,
      registeredAt: const TimestampConverter().fromJson(
        json['registeredAt'] as Timestamp,
      ),
      updatedAt: const TimestampConverter().fromJson(
        json['updatedAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$RegistrationToJson(_Registration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'guestName': instance.guestName,
      'status': _$RegistrationStatusEnumMap[instance.status]!,
      'isDriver': instance.isDriver,
      'needsRide': instance.needsRide,
      'registeredAt': const TimestampConverter().toJson(instance.registeredAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$RegistrationStatusEnumMap = {
  RegistrationStatus.pending: 'pending',
  RegistrationStatus.approved: 'approved',
  RegistrationStatus.waitlisted: 'waitlisted',
  RegistrationStatus.rejected: 'rejected',
  RegistrationStatus.attended: 'attended',
  RegistrationStatus.absent: 'absent',
};
