// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationPreferences {

/// Whether the member receives push notifications.
 bool get pushEnabled;/// Whether the member receives email notifications.
 bool get emailEnabled;/// Whether the member receives in-app notifications.
 bool get inAppEnabled;/// How often notifications are batched / delivered.
 NotificationFrequency get frequency;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationPreferences;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.pushEnabled, _this.pushEnabled) || other.pushEnabled == _this.pushEnabled)&&(identical(other.emailEnabled, _this.emailEnabled) || other.emailEnabled == _this.emailEnabled)&&(identical(other.inAppEnabled, _this.inAppEnabled) || other.inAppEnabled == _this.inAppEnabled)&&(identical(other.frequency, _this.frequency) || other.frequency == _this.frequency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationPreferences;
  return Object.hash(runtimeType,_this.pushEnabled,_this.emailEnabled,_this.inAppEnabled,_this.frequency);
}

@override
String toString() {
  final _this = this as NotificationPreferences;
  return 'NotificationPreferences(pushEnabled: ${_this.pushEnabled}, emailEnabled: ${_this.emailEnabled}, inAppEnabled: ${_this.inAppEnabled}, frequency: ${_this.frequency})';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
 bool pushEnabled, bool emailEnabled, bool inAppEnabled, NotificationFrequency frequency
});




}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pushEnabled = null,Object? emailEnabled = null,Object? inAppEnabled = null,Object? frequency = null,}) {
  return _then(NotificationPreferences(
pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,inAppEnabled: null == inAppEnabled ? _self.inAppEnabled : inAppEnabled // ignore: cast_nullable_to_non_nullable
as bool,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as NotificationFrequency,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool pushEnabled,  bool emailEnabled,  bool inAppEnabled,  NotificationFrequency frequency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.pushEnabled,_that.emailEnabled,_that.inAppEnabled,_that.frequency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool pushEnabled,  bool emailEnabled,  bool inAppEnabled,  NotificationFrequency frequency)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.pushEnabled,_that.emailEnabled,_that.inAppEnabled,_that.frequency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool pushEnabled,  bool emailEnabled,  bool inAppEnabled,  NotificationFrequency frequency)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.pushEnabled,_that.emailEnabled,_that.inAppEnabled,_that.frequency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferences implements NotificationPreferences {
  const _NotificationPreferences({this.pushEnabled = true, this.emailEnabled = true, this.inAppEnabled = true, this.frequency = NotificationFrequency.immediate});
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

/// Whether the member receives push notifications.
@override@JsonKey() final  bool pushEnabled;
/// Whether the member receives email notifications.
@override@JsonKey() final  bool emailEnabled;
/// Whether the member receives in-app notifications.
@override@JsonKey() final  bool inAppEnabled;
/// How often notifications are batched / delivered.
@override@JsonKey() final  NotificationFrequency frequency;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith => __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.inAppEnabled, inAppEnabled) || other.inAppEnabled == inAppEnabled)&&(identical(other.frequency, frequency) || other.frequency == frequency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pushEnabled,emailEnabled,inAppEnabled,frequency);
}

@override
String toString() {
    return 'NotificationPreferences(pushEnabled: $pushEnabled, emailEnabled: $emailEnabled, inAppEnabled: $inAppEnabled, frequency: $frequency)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool pushEnabled, bool emailEnabled, bool inAppEnabled, NotificationFrequency frequency
});




}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pushEnabled = null,Object? emailEnabled = null,Object? inAppEnabled = null,Object? frequency = null,}) {
  return _then(_NotificationPreferences(
pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,inAppEnabled: null == inAppEnabled ? _self.inAppEnabled : inAppEnabled // ignore: cast_nullable_to_non_nullable
as bool,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as NotificationFrequency,
  ));
}


}

// dart format on
