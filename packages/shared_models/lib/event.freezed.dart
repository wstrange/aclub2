// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Event {

/// Firestore document ID.
 String get id;/// Denormalised section ID for cross-collection queries.
 String get sectionId; String get title;/// Markdown-formatted description. A template can be inserted here.
 String? get description; EventType get type;/// Events start as [EventStatus.draft]. Only published events appear in
/// public listings; draft events are visible only to the creator and trip
/// leaders.
 EventStatus get status;@TimestampConverter() DateTime get startDate;@TimestampConverter() DateTime get endDate;@JsonKey(toJson: _eventLocationToJson, fromJson: _eventLocationFromJson) EventLocation? get location;@JsonKey(toJson: _carpoolOptionToJson, fromJson: _carpoolOptionFromJson) CarpoolOption? get carpoolOption; int get minParticipants; int get maxParticipants; Difficulty get difficulty;/// When true, registrations go to a waitlist and require approval from a
/// trip leader or section manager before being confirmed.
 bool get requiresApproval;/// List of required equipment items (free text or markdown).
 List<String> get requiredEquipment;/// List of prerequisites for participation (free text or markdown).
 List<String> get prerequisites; String get creatorId;/// User IDs of members leading this event. Trip leaders can update event
/// details and communicate with participants.
 List<String> get tripLeaderIds;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Event;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sectionId, _this.sectionId) || other.sectionId == _this.sectionId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.carpoolOption, _this.carpoolOption) || other.carpoolOption == _this.carpoolOption)&&(identical(other.minParticipants, _this.minParticipants) || other.minParticipants == _this.minParticipants)&&(identical(other.maxParticipants, _this.maxParticipants) || other.maxParticipants == _this.maxParticipants)&&(identical(other.difficulty, _this.difficulty) || other.difficulty == _this.difficulty)&&(identical(other.requiresApproval, _this.requiresApproval) || other.requiresApproval == _this.requiresApproval)&&const DeepCollectionEquality().equals(other.requiredEquipment, _this.requiredEquipment)&&const DeepCollectionEquality().equals(other.prerequisites, _this.prerequisites)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&const DeepCollectionEquality().equals(other.tripLeaderIds, _this.tripLeaderIds)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Event;
  return Object.hashAll([runtimeType,_this.id,_this.sectionId,_this.title,_this.description,_this.type,_this.status,_this.startDate,_this.endDate,_this.location,_this.carpoolOption,_this.minParticipants,_this.maxParticipants,_this.difficulty,_this.requiresApproval,const DeepCollectionEquality().hash(_this.requiredEquipment),const DeepCollectionEquality().hash(_this.prerequisites),_this.creatorId,const DeepCollectionEquality().hash(_this.tripLeaderIds),_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as Event;
  return 'Event(id: ${_this.id}, sectionId: ${_this.sectionId}, title: ${_this.title}, description: ${_this.description}, type: ${_this.type}, status: ${_this.status}, startDate: ${_this.startDate}, endDate: ${_this.endDate}, location: ${_this.location}, carpoolOption: ${_this.carpoolOption}, minParticipants: ${_this.minParticipants}, maxParticipants: ${_this.maxParticipants}, difficulty: ${_this.difficulty}, requiresApproval: ${_this.requiresApproval}, requiredEquipment: ${_this.requiredEquipment}, prerequisites: ${_this.prerequisites}, creatorId: ${_this.creatorId}, tripLeaderIds: ${_this.tripLeaderIds}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
 String id, String sectionId, String title, String? description, EventType type, EventStatus status,@TimestampConverter() DateTime startDate,@TimestampConverter() DateTime endDate,@JsonKey(toJson: _eventLocationToJson, fromJson: _eventLocationFromJson) EventLocation? location,@JsonKey(toJson: _carpoolOptionToJson, fromJson: _carpoolOptionFromJson) CarpoolOption? carpoolOption, int minParticipants, int maxParticipants, Difficulty difficulty, bool requiresApproval, List<String> requiredEquipment, List<String> prerequisites, String creatorId, List<String> tripLeaderIds,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});


$EventLocationCopyWith<$Res>? get location;$CarpoolOptionCopyWith<$Res>? get carpoolOption;

}
/// @nodoc
class _$EventCopyWithImpl<$Res>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sectionId = null,Object? title = null,Object? description = freezed,Object? type = null,Object? status = null,Object? startDate = null,Object? endDate = null,Object? location = freezed,Object? carpoolOption = freezed,Object? minParticipants = null,Object? maxParticipants = null,Object? difficulty = null,Object? requiresApproval = null,Object? requiredEquipment = null,Object? prerequisites = null,Object? creatorId = null,Object? tripLeaderIds = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EventType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as EventLocation?,carpoolOption: freezed == carpoolOption ? _self.carpoolOption : carpoolOption // ignore: cast_nullable_to_non_nullable
as CarpoolOption?,minParticipants: null == minParticipants ? _self.minParticipants : minParticipants // ignore: cast_nullable_to_non_nullable
as int,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,requiredEquipment: null == requiredEquipment ? _self.requiredEquipment : requiredEquipment // ignore: cast_nullable_to_non_nullable
as List<String>,prerequisites: null == prerequisites ? _self.prerequisites : prerequisites // ignore: cast_nullable_to_non_nullable
as List<String>,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,tripLeaderIds: null == tripLeaderIds ? _self.tripLeaderIds : tripLeaderIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $EventLocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarpoolOptionCopyWith<$Res>? get carpoolOption {
    if (_self.carpoolOption == null) {
    return null;
  }

  return $CarpoolOptionCopyWith<$Res>(_self.carpoolOption!, (value) {
    return _then(_self.copyWith(carpoolOption: value));
  });
}
}


/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Event value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Event value)  $default,){
final _that = this;
switch (_that) {
case _Event():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Event value)?  $default,){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sectionId,  String title,  String? description,  EventType type,  EventStatus status, @TimestampConverter()  DateTime startDate, @TimestampConverter()  DateTime endDate, @JsonKey(toJson: _eventLocationToJson, fromJson: _eventLocationFromJson)  EventLocation? location, @JsonKey(toJson: _carpoolOptionToJson, fromJson: _carpoolOptionFromJson)  CarpoolOption? carpoolOption,  int minParticipants,  int maxParticipants,  Difficulty difficulty,  bool requiresApproval,  List<String> requiredEquipment,  List<String> prerequisites,  String creatorId,  List<String> tripLeaderIds, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.sectionId,_that.title,_that.description,_that.type,_that.status,_that.startDate,_that.endDate,_that.location,_that.carpoolOption,_that.minParticipants,_that.maxParticipants,_that.difficulty,_that.requiresApproval,_that.requiredEquipment,_that.prerequisites,_that.creatorId,_that.tripLeaderIds,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sectionId,  String title,  String? description,  EventType type,  EventStatus status, @TimestampConverter()  DateTime startDate, @TimestampConverter()  DateTime endDate, @JsonKey(toJson: _eventLocationToJson, fromJson: _eventLocationFromJson)  EventLocation? location, @JsonKey(toJson: _carpoolOptionToJson, fromJson: _carpoolOptionFromJson)  CarpoolOption? carpoolOption,  int minParticipants,  int maxParticipants,  Difficulty difficulty,  bool requiresApproval,  List<String> requiredEquipment,  List<String> prerequisites,  String creatorId,  List<String> tripLeaderIds, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.sectionId,_that.title,_that.description,_that.type,_that.status,_that.startDate,_that.endDate,_that.location,_that.carpoolOption,_that.minParticipants,_that.maxParticipants,_that.difficulty,_that.requiresApproval,_that.requiredEquipment,_that.prerequisites,_that.creatorId,_that.tripLeaderIds,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sectionId,  String title,  String? description,  EventType type,  EventStatus status, @TimestampConverter()  DateTime startDate, @TimestampConverter()  DateTime endDate, @JsonKey(toJson: _eventLocationToJson, fromJson: _eventLocationFromJson)  EventLocation? location, @JsonKey(toJson: _carpoolOptionToJson, fromJson: _carpoolOptionFromJson)  CarpoolOption? carpoolOption,  int minParticipants,  int maxParticipants,  Difficulty difficulty,  bool requiresApproval,  List<String> requiredEquipment,  List<String> prerequisites,  String creatorId,  List<String> tripLeaderIds, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.sectionId,_that.title,_that.description,_that.type,_that.status,_that.startDate,_that.endDate,_that.location,_that.carpoolOption,_that.minParticipants,_that.maxParticipants,_that.difficulty,_that.requiresApproval,_that.requiredEquipment,_that.prerequisites,_that.creatorId,_that.tripLeaderIds,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Event implements Event {
  const _Event({required this.id, required this.sectionId, required this.title, this.description, required this.type, this.status = EventStatus.draft, @TimestampConverter() required this.startDate, @TimestampConverter() required this.endDate, @JsonKey(toJson: _eventLocationToJson, fromJson: _eventLocationFromJson) this.location, @JsonKey(toJson: _carpoolOptionToJson, fromJson: _carpoolOptionFromJson) this.carpoolOption, this.minParticipants = 0, required this.maxParticipants, this.difficulty = Difficulty.moderate, this.requiresApproval = false,  List<String> requiredEquipment = const [],  List<String> prerequisites = const [], required this.creatorId,  List<String> tripLeaderIds = const [], @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt}): _requiredEquipment = requiredEquipment,_prerequisites = prerequisites,_tripLeaderIds = tripLeaderIds;
  factory _Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

/// Firestore document ID.
@override final  String id;
/// Denormalised section ID for cross-collection queries.
@override final  String sectionId;
@override final  String title;
/// Markdown-formatted description. A template can be inserted here.
@override final  String? description;
@override final  EventType type;
/// Events start as [EventStatus.draft]. Only published events appear in
/// public listings; draft events are visible only to the creator and trip
/// leaders.
@override@JsonKey() final  EventStatus status;
@override@TimestampConverter() final  DateTime startDate;
@override@TimestampConverter() final  DateTime endDate;
@override@JsonKey(toJson: _eventLocationToJson, fromJson: _eventLocationFromJson) final  EventLocation? location;
@override@JsonKey(toJson: _carpoolOptionToJson, fromJson: _carpoolOptionFromJson) final  CarpoolOption? carpoolOption;
@override@JsonKey() final  int minParticipants;
@override final  int maxParticipants;
@override@JsonKey() final  Difficulty difficulty;
/// When true, registrations go to a waitlist and require approval from a
/// trip leader or section manager before being confirmed.
@override@JsonKey() final  bool requiresApproval;
/// List of required equipment items (free text or markdown).
 final  List<String> _requiredEquipment;
/// List of required equipment items (free text or markdown).
@override@JsonKey() List<String> get requiredEquipment {
  if (_requiredEquipment is EqualUnmodifiableListView) return _requiredEquipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requiredEquipment);
}

/// List of prerequisites for participation (free text or markdown).
 final  List<String> _prerequisites;
/// List of prerequisites for participation (free text or markdown).
@override@JsonKey() List<String> get prerequisites {
  if (_prerequisites is EqualUnmodifiableListView) return _prerequisites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prerequisites);
}

@override final  String creatorId;
/// User IDs of members leading this event. Trip leaders can update event
/// details and communicate with participants.
 final  List<String> _tripLeaderIds;
/// User IDs of members leading this event. Trip leaders can update event
/// details and communicate with participants.
@override@JsonKey() List<String> get tripLeaderIds {
  if (_tripLeaderIds is EqualUnmodifiableListView) return _tripLeaderIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tripLeaderIds);
}

@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCopyWith<_Event> get copyWith => __$EventCopyWithImpl<_Event>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.carpoolOption, carpoolOption) || other.carpoolOption == carpoolOption)&&(identical(other.minParticipants, minParticipants) || other.minParticipants == minParticipants)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&const DeepCollectionEquality().equals(other.requiredEquipment, _requiredEquipment)&&const DeepCollectionEquality().equals(other.prerequisites, _prerequisites)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&const DeepCollectionEquality().equals(other.tripLeaderIds, _tripLeaderIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,sectionId,title,description,type,status,startDate,endDate,location,carpoolOption,minParticipants,maxParticipants,difficulty,requiresApproval,const DeepCollectionEquality().hash(_requiredEquipment),const DeepCollectionEquality().hash(_prerequisites),creatorId,const DeepCollectionEquality().hash(_tripLeaderIds),createdAt,updatedAt]);
}

@override
String toString() {
    return 'Event(id: $id, sectionId: $sectionId, title: $title, description: $description, type: $type, status: $status, startDate: $startDate, endDate: $endDate, location: $location, carpoolOption: $carpoolOption, minParticipants: $minParticipants, maxParticipants: $maxParticipants, difficulty: $difficulty, requiresApproval: $requiresApproval, requiredEquipment: $requiredEquipment, prerequisites: $prerequisites, creatorId: $creatorId, tripLeaderIds: $tripLeaderIds, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
 String id, String sectionId, String title, String? description, EventType type, EventStatus status,@TimestampConverter() DateTime startDate,@TimestampConverter() DateTime endDate,@JsonKey(toJson: _eventLocationToJson, fromJson: _eventLocationFromJson) EventLocation? location,@JsonKey(toJson: _carpoolOptionToJson, fromJson: _carpoolOptionFromJson) CarpoolOption? carpoolOption, int minParticipants, int maxParticipants, Difficulty difficulty, bool requiresApproval, List<String> requiredEquipment, List<String> prerequisites, String creatorId, List<String> tripLeaderIds,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});


@override $EventLocationCopyWith<$Res>? get location;@override $CarpoolOptionCopyWith<$Res>? get carpoolOption;

}
/// @nodoc
class __$EventCopyWithImpl<$Res>
    implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sectionId = null,Object? title = null,Object? description = freezed,Object? type = null,Object? status = null,Object? startDate = null,Object? endDate = null,Object? location = freezed,Object? carpoolOption = freezed,Object? minParticipants = null,Object? maxParticipants = null,Object? difficulty = null,Object? requiresApproval = null,Object? requiredEquipment = null,Object? prerequisites = null,Object? creatorId = null,Object? tripLeaderIds = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EventType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as EventLocation?,carpoolOption: freezed == carpoolOption ? _self.carpoolOption : carpoolOption // ignore: cast_nullable_to_non_nullable
as CarpoolOption?,minParticipants: null == minParticipants ? _self.minParticipants : minParticipants // ignore: cast_nullable_to_non_nullable
as int,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,requiredEquipment: null == requiredEquipment ? _self._requiredEquipment : requiredEquipment // ignore: cast_nullable_to_non_nullable
as List<String>,prerequisites: null == prerequisites ? _self._prerequisites : prerequisites // ignore: cast_nullable_to_non_nullable
as List<String>,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,tripLeaderIds: null == tripLeaderIds ? _self._tripLeaderIds : tripLeaderIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $EventLocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarpoolOptionCopyWith<$Res>? get carpoolOption {
    if (_self.carpoolOption == null) {
    return null;
  }

  return $CarpoolOptionCopyWith<$Res>(_self.carpoolOption!, (value) {
    return _then(_self.copyWith(carpoolOption: value));
  });
}
}

// dart format on
