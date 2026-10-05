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
        json['registeredAt'] as Object,
      ),
      updatedAt: const TimestampConverter().fromJson(
        json['updatedAt'] as Object,
      ),
      withdrawnByUserId: json['withdrawnByUserId'] as String?,
      withdrawnAt: _$JsonConverterFromJson<Object, DateTime>(
        json['withdrawnAt'],
        const TimestampConverter().fromJson,
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
      'withdrawnByUserId': instance.withdrawnByUserId,
      'withdrawnAt': _$JsonConverterToJson<Object, DateTime>(
        instance.withdrawnAt,
        const TimestampConverter().toJson,
      ),
    };

const _$RegistrationStatusEnumMap = {
  RegistrationStatus.pending: 'pending',
  RegistrationStatus.approved: 'approved',
  RegistrationStatus.waitlisted: 'waitlisted',
  RegistrationStatus.rejected: 'rejected',
  RegistrationStatus.attended: 'attended',
  RegistrationStatus.absent: 'absent',
  RegistrationStatus.withdrawn: 'withdrawn',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
