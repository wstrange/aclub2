// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carpool_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CarpoolOption {

/// Time and date to meet for carpooling.
@TimestampConverter() DateTime get meetTime;/// Description of the meeting point, e.g. "Park & Ride on Hwy 1".
 String get meetPlace;/// Optional URL to a map of the meeting point.
 String? get mapUrl;
/// Create a copy of CarpoolOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarpoolOptionCopyWith<CarpoolOption> get copyWith => _$CarpoolOptionCopyWithImpl<CarpoolOption>(this as CarpoolOption, _$identity);

  /// Serializes this CarpoolOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CarpoolOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarpoolOption&&(identical(other.meetTime, _this.meetTime) || other.meetTime == _this.meetTime)&&(identical(other.meetPlace, _this.meetPlace) || other.meetPlace == _this.meetPlace)&&(identical(other.mapUrl, _this.mapUrl) || other.mapUrl == _this.mapUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CarpoolOption;
  return Object.hash(runtimeType,_this.meetTime,_this.meetPlace,_this.mapUrl);
}

@override
String toString() {
  final _this = this as CarpoolOption;
  return 'CarpoolOption(meetTime: ${_this.meetTime}, meetPlace: ${_this.meetPlace}, mapUrl: ${_this.mapUrl})';
}


}

/// @nodoc
abstract mixin class $CarpoolOptionCopyWith<$Res>  {
  factory $CarpoolOptionCopyWith(CarpoolOption value, $Res Function(CarpoolOption) _then) = _$CarpoolOptionCopyWithImpl;
@useResult
$Res call({
@TimestampConverter() DateTime meetTime, String meetPlace, String? mapUrl
});




}
/// @nodoc
class _$CarpoolOptionCopyWithImpl<$Res>
    implements $CarpoolOptionCopyWith<$Res> {
  _$CarpoolOptionCopyWithImpl(this._self, this._then);

  final CarpoolOption _self;
  final $Res Function(CarpoolOption) _then;

/// Create a copy of CarpoolOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? meetTime = null,Object? meetPlace = null,Object? mapUrl = freezed,}) {
  return _then(CarpoolOption(
meetTime: null == meetTime ? _self.meetTime : meetTime // ignore: cast_nullable_to_non_nullable
as DateTime,meetPlace: null == meetPlace ? _self.meetPlace : meetPlace // ignore: cast_nullable_to_non_nullable
as String,mapUrl: freezed == mapUrl ? _self.mapUrl : mapUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CarpoolOption].
extension CarpoolOptionPatterns on CarpoolOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarpoolOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarpoolOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarpoolOption value)  $default,){
final _that = this;
switch (_that) {
case _CarpoolOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarpoolOption value)?  $default,){
final _that = this;
switch (_that) {
case _CarpoolOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@TimestampConverter()  DateTime meetTime,  String meetPlace,  String? mapUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarpoolOption() when $default != null:
return $default(_that.meetTime,_that.meetPlace,_that.mapUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@TimestampConverter()  DateTime meetTime,  String meetPlace,  String? mapUrl)  $default,) {final _that = this;
switch (_that) {
case _CarpoolOption():
return $default(_that.meetTime,_that.meetPlace,_that.mapUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@TimestampConverter()  DateTime meetTime,  String meetPlace,  String? mapUrl)?  $default,) {final _that = this;
switch (_that) {
case _CarpoolOption() when $default != null:
return $default(_that.meetTime,_that.meetPlace,_that.mapUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CarpoolOption implements CarpoolOption {
  const _CarpoolOption({@TimestampConverter() required this.meetTime, required this.meetPlace, this.mapUrl});
  factory _CarpoolOption.fromJson(Map<String, dynamic> json) => _$CarpoolOptionFromJson(json);

/// Time and date to meet for carpooling.
@override@TimestampConverter() final  DateTime meetTime;
/// Description of the meeting point, e.g. "Park & Ride on Hwy 1".
@override final  String meetPlace;
/// Optional URL to a map of the meeting point.
@override final  String? mapUrl;

/// Create a copy of CarpoolOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarpoolOptionCopyWith<_CarpoolOption> get copyWith => __$CarpoolOptionCopyWithImpl<_CarpoolOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarpoolOptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarpoolOption&&(identical(other.meetTime, meetTime) || other.meetTime == meetTime)&&(identical(other.meetPlace, meetPlace) || other.meetPlace == meetPlace)&&(identical(other.mapUrl, mapUrl) || other.mapUrl == mapUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,meetTime,meetPlace,mapUrl);
}

@override
String toString() {
    return 'CarpoolOption(meetTime: $meetTime, meetPlace: $meetPlace, mapUrl: $mapUrl)';
}


}

/// @nodoc
abstract mixin class _$CarpoolOptionCopyWith<$Res> implements $CarpoolOptionCopyWith<$Res> {
  factory _$CarpoolOptionCopyWith(_CarpoolOption value, $Res Function(_CarpoolOption) _then) = __$CarpoolOptionCopyWithImpl;
@override @useResult
$Res call({
@TimestampConverter() DateTime meetTime, String meetPlace, String? mapUrl
});




}
/// @nodoc
class __$CarpoolOptionCopyWithImpl<$Res>
    implements _$CarpoolOptionCopyWith<$Res> {
  __$CarpoolOptionCopyWithImpl(this._self, this._then);

  final _CarpoolOption _self;
  final $Res Function(_CarpoolOption) _then;

/// Create a copy of CarpoolOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meetTime = null,Object? meetPlace = null,Object? mapUrl = freezed,}) {
  return _then(_CarpoolOption(
meetTime: null == meetTime ? _self.meetTime : meetTime // ignore: cast_nullable_to_non_nullable
as DateTime,meetPlace: null == meetPlace ? _self.meetPlace : meetPlace // ignore: cast_nullable_to_non_nullable
as String,mapUrl: freezed == mapUrl ? _self.mapUrl : mapUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
