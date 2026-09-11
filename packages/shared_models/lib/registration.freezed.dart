// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Registration {

/// Firestore document ID.
 String get id;/// The user who registered (or on whose behalf this registration exists).
 String get userId;/// Non-null when a member has registered a guest. Guests have no user
/// account but are tracked via the registering member's record.
 String? get guestName; RegistrationStatus get status;/// True if this member is willing to drive others.
 bool? get isDriver;/// True if this member needs a ride.
 bool? get needsRide;@TimestampConverter() DateTime get registeredAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of Registration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationCopyWith<Registration> get copyWith => _$RegistrationCopyWithImpl<Registration>(this as Registration, _$identity);

  /// Serializes this Registration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Registration;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Registration&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.guestName, _this.guestName) || other.guestName == _this.guestName)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.isDriver, _this.isDriver) || other.isDriver == _this.isDriver)&&(identical(other.needsRide, _this.needsRide) || other.needsRide == _this.needsRide)&&(identical(other.registeredAt, _this.registeredAt) || other.registeredAt == _this.registeredAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Registration;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.guestName,_this.status,_this.isDriver,_this.needsRide,_this.registeredAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Registration;
  return 'Registration(id: ${_this.id}, userId: ${_this.userId}, guestName: ${_this.guestName}, status: ${_this.status}, isDriver: ${_this.isDriver}, needsRide: ${_this.needsRide}, registeredAt: ${_this.registeredAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $RegistrationCopyWith<$Res>  {
  factory $RegistrationCopyWith(Registration value, $Res Function(Registration) _then) = _$RegistrationCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? guestName, RegistrationStatus status, bool? isDriver, bool? needsRide,@TimestampConverter() DateTime registeredAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$RegistrationCopyWithImpl<$Res>
    implements $RegistrationCopyWith<$Res> {
  _$RegistrationCopyWithImpl(this._self, this._then);

  final Registration _self;
  final $Res Function(Registration) _then;

/// Create a copy of Registration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? guestName = freezed,Object? status = null,Object? isDriver = freezed,Object? needsRide = freezed,Object? registeredAt = null,Object? updatedAt = null,}) {
  return _then(Registration(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RegistrationStatus,isDriver: freezed == isDriver ? _self.isDriver : isDriver // ignore: cast_nullable_to_non_nullable
as bool?,needsRide: freezed == needsRide ? _self.needsRide : needsRide // ignore: cast_nullable_to_non_nullable
as bool?,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Registration].
extension RegistrationPatterns on Registration {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Registration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Registration() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Registration value)  $default,){
final _that = this;
switch (_that) {
case _Registration():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Registration value)?  $default,){
final _that = this;
switch (_that) {
case _Registration() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? guestName,  RegistrationStatus status,  bool? isDriver,  bool? needsRide, @TimestampConverter()  DateTime registeredAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Registration() when $default != null:
return $default(_that.id,_that.userId,_that.guestName,_that.status,_that.isDriver,_that.needsRide,_that.registeredAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? guestName,  RegistrationStatus status,  bool? isDriver,  bool? needsRide, @TimestampConverter()  DateTime registeredAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Registration():
return $default(_that.id,_that.userId,_that.guestName,_that.status,_that.isDriver,_that.needsRide,_that.registeredAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? guestName,  RegistrationStatus status,  bool? isDriver,  bool? needsRide, @TimestampConverter()  DateTime registeredAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Registration() when $default != null:
return $default(_that.id,_that.userId,_that.guestName,_that.status,_that.isDriver,_that.needsRide,_that.registeredAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Registration implements Registration {
  const _Registration({required this.id, required this.userId, this.guestName, this.status = RegistrationStatus.pending, this.isDriver, this.needsRide, @TimestampConverter() required this.registeredAt, @TimestampConverter() required this.updatedAt});
  factory _Registration.fromJson(Map<String, dynamic> json) => _$RegistrationFromJson(json);

/// Firestore document ID.
@override final  String id;
/// The user who registered (or on whose behalf this registration exists).
@override final  String userId;
/// Non-null when a member has registered a guest. Guests have no user
/// account but are tracked via the registering member's record.
@override final  String? guestName;
@override@JsonKey() final  RegistrationStatus status;
/// True if this member is willing to drive others.
@override final  bool? isDriver;
/// True if this member needs a ride.
@override final  bool? needsRide;
@override@TimestampConverter() final  DateTime registeredAt;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of Registration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrationCopyWith<_Registration> get copyWith => __$RegistrationCopyWithImpl<_Registration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegistrationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Registration&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.status, status) || other.status == status)&&(identical(other.isDriver, isDriver) || other.isDriver == isDriver)&&(identical(other.needsRide, needsRide) || other.needsRide == needsRide)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,guestName,status,isDriver,needsRide,registeredAt,updatedAt);
}

@override
String toString() {
    return 'Registration(id: $id, userId: $userId, guestName: $guestName, status: $status, isDriver: $isDriver, needsRide: $needsRide, registeredAt: $registeredAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RegistrationCopyWith<$Res> implements $RegistrationCopyWith<$Res> {
  factory _$RegistrationCopyWith(_Registration value, $Res Function(_Registration) _then) = __$RegistrationCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? guestName, RegistrationStatus status, bool? isDriver, bool? needsRide,@TimestampConverter() DateTime registeredAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$RegistrationCopyWithImpl<$Res>
    implements _$RegistrationCopyWith<$Res> {
  __$RegistrationCopyWithImpl(this._self, this._then);

  final _Registration _self;
  final $Res Function(_Registration) _then;

/// Create a copy of Registration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? guestName = freezed,Object? status = null,Object? isDriver = freezed,Object? needsRide = freezed,Object? registeredAt = null,Object? updatedAt = null,}) {
  return _then(_Registration(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RegistrationStatus,isDriver: freezed == isDriver ? _self.isDriver : isDriver // ignore: cast_nullable_to_non_nullable
as bool?,needsRide: freezed == needsRide ? _self.needsRide : needsRide // ignore: cast_nullable_to_non_nullable
as bool?,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
