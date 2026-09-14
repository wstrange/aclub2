// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_details_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventDetailsState {

 String get sectionId; String get eventId; Event? get event; List<Registration> get registrations; bool get isEventLoading; bool get isRegistrationsLoading; Object? get error;
/// Create a copy of EventDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventDetailsStateCopyWith<EventDetailsState> get copyWith => _$EventDetailsStateCopyWithImpl<EventDetailsState>(this as EventDetailsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventDetailsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventDetailsState&&(identical(other.sectionId, _this.sectionId) || other.sectionId == _this.sectionId)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.event, _this.event) || other.event == _this.event)&&const DeepCollectionEquality().equals(other.registrations, _this.registrations)&&(identical(other.isEventLoading, _this.isEventLoading) || other.isEventLoading == _this.isEventLoading)&&(identical(other.isRegistrationsLoading, _this.isRegistrationsLoading) || other.isRegistrationsLoading == _this.isRegistrationsLoading)&&const DeepCollectionEquality().equals(other.error, _this.error));
}


@override
int get hashCode {
  final _this = this as EventDetailsState;
  return Object.hash(runtimeType,_this.sectionId,_this.eventId,_this.event,const DeepCollectionEquality().hash(_this.registrations),_this.isEventLoading,_this.isRegistrationsLoading,const DeepCollectionEquality().hash(_this.error));
}

@override
String toString() {
  final _this = this as EventDetailsState;
  return 'EventDetailsState(sectionId: ${_this.sectionId}, eventId: ${_this.eventId}, event: ${_this.event}, registrations: ${_this.registrations}, isEventLoading: ${_this.isEventLoading}, isRegistrationsLoading: ${_this.isRegistrationsLoading}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $EventDetailsStateCopyWith<$Res>  {
  factory $EventDetailsStateCopyWith(EventDetailsState value, $Res Function(EventDetailsState) _then) = _$EventDetailsStateCopyWithImpl;
@useResult
$Res call({
 String sectionId, String eventId, Event? event, List<Registration> registrations, bool isEventLoading, bool isRegistrationsLoading, Object? error
});


$EventCopyWith<$Res>? get event;

}
/// @nodoc
class _$EventDetailsStateCopyWithImpl<$Res>
    implements $EventDetailsStateCopyWith<$Res> {
  _$EventDetailsStateCopyWithImpl(this._self, this._then);

  final EventDetailsState _self;
  final $Res Function(EventDetailsState) _then;

/// Create a copy of EventDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sectionId = null,Object? eventId = null,Object? event = freezed,Object? registrations = null,Object? isEventLoading = null,Object? isRegistrationsLoading = null,Object? error = freezed,}) {
  return _then(EventDetailsState(
sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as Event?,registrations: null == registrations ? _self.registrations : registrations // ignore: cast_nullable_to_non_nullable
as List<Registration>,isEventLoading: null == isEventLoading ? _self.isEventLoading : isEventLoading // ignore: cast_nullable_to_non_nullable
as bool,isRegistrationsLoading: null == isRegistrationsLoading ? _self.isRegistrationsLoading : isRegistrationsLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,
  ));
}
/// Create a copy of EventDetailsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventCopyWith<$Res>? get event {
    if (_self.event == null) {
    return null;
  }

  return $EventCopyWith<$Res>(_self.event!, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventDetailsState].
extension EventDetailsStatePatterns on EventDetailsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventDetailsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventDetailsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventDetailsState value)  $default,){
final _that = this;
switch (_that) {
case _EventDetailsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventDetailsState value)?  $default,){
final _that = this;
switch (_that) {
case _EventDetailsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sectionId,  String eventId,  Event? event,  List<Registration> registrations,  bool isEventLoading,  bool isRegistrationsLoading,  Object? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventDetailsState() when $default != null:
return $default(_that.sectionId,_that.eventId,_that.event,_that.registrations,_that.isEventLoading,_that.isRegistrationsLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sectionId,  String eventId,  Event? event,  List<Registration> registrations,  bool isEventLoading,  bool isRegistrationsLoading,  Object? error)  $default,) {final _that = this;
switch (_that) {
case _EventDetailsState():
return $default(_that.sectionId,_that.eventId,_that.event,_that.registrations,_that.isEventLoading,_that.isRegistrationsLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sectionId,  String eventId,  Event? event,  List<Registration> registrations,  bool isEventLoading,  bool isRegistrationsLoading,  Object? error)?  $default,) {final _that = this;
switch (_that) {
case _EventDetailsState() when $default != null:
return $default(_that.sectionId,_that.eventId,_that.event,_that.registrations,_that.isEventLoading,_that.isRegistrationsLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _EventDetailsState implements EventDetailsState {
  const _EventDetailsState({required this.sectionId, required this.eventId, this.event,  List<Registration> registrations = const <Registration>[], this.isEventLoading = true, this.isRegistrationsLoading = true, this.error}): _registrations = registrations;
  

@override final  String sectionId;
@override final  String eventId;
@override final  Event? event;
 final  List<Registration> _registrations;
@override@JsonKey() List<Registration> get registrations {
  if (_registrations is EqualUnmodifiableListView) return _registrations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_registrations);
}

@override@JsonKey() final  bool isEventLoading;
@override@JsonKey() final  bool isRegistrationsLoading;
@override final  Object? error;

/// Create a copy of EventDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventDetailsStateCopyWith<_EventDetailsState> get copyWith => __$EventDetailsStateCopyWithImpl<_EventDetailsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventDetailsState&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.event, event) || other.event == event)&&const DeepCollectionEquality().equals(other.registrations, _registrations)&&(identical(other.isEventLoading, isEventLoading) || other.isEventLoading == isEventLoading)&&(identical(other.isRegistrationsLoading, isRegistrationsLoading) || other.isRegistrationsLoading == isRegistrationsLoading)&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sectionId,eventId,event,const DeepCollectionEquality().hash(_registrations),isEventLoading,isRegistrationsLoading,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'EventDetailsState(sectionId: $sectionId, eventId: $eventId, event: $event, registrations: $registrations, isEventLoading: $isEventLoading, isRegistrationsLoading: $isRegistrationsLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$EventDetailsStateCopyWith<$Res> implements $EventDetailsStateCopyWith<$Res> {
  factory _$EventDetailsStateCopyWith(_EventDetailsState value, $Res Function(_EventDetailsState) _then) = __$EventDetailsStateCopyWithImpl;
@override @useResult
$Res call({
 String sectionId, String eventId, Event? event, List<Registration> registrations, bool isEventLoading, bool isRegistrationsLoading, Object? error
});


@override $EventCopyWith<$Res>? get event;

}
/// @nodoc
class __$EventDetailsStateCopyWithImpl<$Res>
    implements _$EventDetailsStateCopyWith<$Res> {
  __$EventDetailsStateCopyWithImpl(this._self, this._then);

  final _EventDetailsState _self;
  final $Res Function(_EventDetailsState) _then;

/// Create a copy of EventDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sectionId = null,Object? eventId = null,Object? event = freezed,Object? registrations = null,Object? isEventLoading = null,Object? isRegistrationsLoading = null,Object? error = freezed,}) {
  return _then(_EventDetailsState(
sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as Event?,registrations: null == registrations ? _self._registrations : registrations // ignore: cast_nullable_to_non_nullable
as List<Registration>,isEventLoading: null == isEventLoading ? _self.isEventLoading : isEventLoading // ignore: cast_nullable_to_non_nullable
as bool,isRegistrationsLoading: null == isRegistrationsLoading ? _self.isRegistrationsLoading : isRegistrationsLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,
  ));
}

/// Create a copy of EventDetailsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventCopyWith<$Res>? get event {
    if (_self.event == null) {
    return null;
  }

  return $EventCopyWith<$Res>(_self.event!, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}

// dart format on
