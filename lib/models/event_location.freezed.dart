// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventLocation {

/// Free-text description, e.g. "Meet at the base of the north face".
 String? get description;/// GPS latitude in decimal degrees.
 double? get latitude;/// GPS longitude in decimal degrees.
 double? get longitude;/// HTTP link to an external map (e.g. Google Maps, CalTopo).
 String? get mapUrl;
/// Create a copy of EventLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventLocationCopyWith<EventLocation> get copyWith => _$EventLocationCopyWithImpl<EventLocation>(this as EventLocation, _$identity);

  /// Serializes this EventLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EventLocation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventLocation&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.mapUrl, _this.mapUrl) || other.mapUrl == _this.mapUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EventLocation;
  return Object.hash(runtimeType,_this.description,_this.latitude,_this.longitude,_this.mapUrl);
}

@override
String toString() {
  final _this = this as EventLocation;
  return 'EventLocation(description: ${_this.description}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, mapUrl: ${_this.mapUrl})';
}


}

/// @nodoc
abstract mixin class $EventLocationCopyWith<$Res>  {
  factory $EventLocationCopyWith(EventLocation value, $Res Function(EventLocation) _then) = _$EventLocationCopyWithImpl;
@useResult
$Res call({
 String? description, double? latitude, double? longitude, String? mapUrl
});




}
/// @nodoc
class _$EventLocationCopyWithImpl<$Res>
    implements $EventLocationCopyWith<$Res> {
  _$EventLocationCopyWithImpl(this._self, this._then);

  final EventLocation _self;
  final $Res Function(EventLocation) _then;

/// Create a copy of EventLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? mapUrl = freezed,}) {
  return _then(EventLocation(
description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,mapUrl: freezed == mapUrl ? _self.mapUrl : mapUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventLocation].
extension EventLocationPatterns on EventLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventLocation value)  $default,){
final _that = this;
switch (_that) {
case _EventLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventLocation value)?  $default,){
final _that = this;
switch (_that) {
case _EventLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? description,  double? latitude,  double? longitude,  String? mapUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventLocation() when $default != null:
return $default(_that.description,_that.latitude,_that.longitude,_that.mapUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? description,  double? latitude,  double? longitude,  String? mapUrl)  $default,) {final _that = this;
switch (_that) {
case _EventLocation():
return $default(_that.description,_that.latitude,_that.longitude,_that.mapUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? description,  double? latitude,  double? longitude,  String? mapUrl)?  $default,) {final _that = this;
switch (_that) {
case _EventLocation() when $default != null:
return $default(_that.description,_that.latitude,_that.longitude,_that.mapUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventLocation implements EventLocation {
  const _EventLocation({this.description, this.latitude, this.longitude, this.mapUrl});
  factory _EventLocation.fromJson(Map<String, dynamic> json) => _$EventLocationFromJson(json);

/// Free-text description, e.g. "Meet at the base of the north face".
@override final  String? description;
/// GPS latitude in decimal degrees.
@override final  double? latitude;
/// GPS longitude in decimal degrees.
@override final  double? longitude;
/// HTTP link to an external map (e.g. Google Maps, CalTopo).
@override final  String? mapUrl;

/// Create a copy of EventLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventLocationCopyWith<_EventLocation> get copyWith => __$EventLocationCopyWithImpl<_EventLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventLocationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventLocation&&(identical(other.description, description) || other.description == description)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.mapUrl, mapUrl) || other.mapUrl == mapUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,description,latitude,longitude,mapUrl);
}

@override
String toString() {
    return 'EventLocation(description: $description, latitude: $latitude, longitude: $longitude, mapUrl: $mapUrl)';
}


}

/// @nodoc
abstract mixin class _$EventLocationCopyWith<$Res> implements $EventLocationCopyWith<$Res> {
  factory _$EventLocationCopyWith(_EventLocation value, $Res Function(_EventLocation) _then) = __$EventLocationCopyWithImpl;
@override @useResult
$Res call({
 String? description, double? latitude, double? longitude, String? mapUrl
});




}
/// @nodoc
class __$EventLocationCopyWithImpl<$Res>
    implements _$EventLocationCopyWith<$Res> {
  __$EventLocationCopyWithImpl(this._self, this._then);

  final _EventLocation _self;
  final $Res Function(_EventLocation) _then;

/// Create a copy of EventLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? mapUrl = freezed,}) {
  return _then(_EventLocation(
description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,mapUrl: freezed == mapUrl ? _self.mapUrl : mapUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
