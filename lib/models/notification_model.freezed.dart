// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationModel {

/// Firestore document ID.
 String get id;/// The user this notification is addressed to.
 String get recipientId; String get title; String get message;/// Optional deep-link or in-app route, e.g. "/events/abc123".
 String? get link;/// Which channels were used to deliver this notification.
/// Valid values: `push`, `email`, `inApp` (see [NotificationChannel]).
/// Stored as strings because the ODM builder does not support List<Enum>.
 List<String> get channels;/// Whether the recipient has marked this notification as read.
 bool get isRead; String? get relatedEventId; String? get relatedSectionId;@TimestampConverter() DateTime get createdAt;
/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<NotificationModel> get copyWith => _$NotificationModelCopyWithImpl<NotificationModel>(this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.recipientId, _this.recipientId) || other.recipientId == _this.recipientId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.link, _this.link) || other.link == _this.link)&&const DeepCollectionEquality().equals(other.channels, _this.channels)&&(identical(other.isRead, _this.isRead) || other.isRead == _this.isRead)&&(identical(other.relatedEventId, _this.relatedEventId) || other.relatedEventId == _this.relatedEventId)&&(identical(other.relatedSectionId, _this.relatedSectionId) || other.relatedSectionId == _this.relatedSectionId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationModel;
  return Object.hash(runtimeType,_this.id,_this.recipientId,_this.title,_this.message,_this.link,const DeepCollectionEquality().hash(_this.channels),_this.isRead,_this.relatedEventId,_this.relatedSectionId,_this.createdAt);
}

@override
String toString() {
  final _this = this as NotificationModel;
  return 'NotificationModel(id: ${_this.id}, recipientId: ${_this.recipientId}, title: ${_this.title}, message: ${_this.message}, link: ${_this.link}, channels: ${_this.channels}, isRead: ${_this.isRead}, relatedEventId: ${_this.relatedEventId}, relatedSectionId: ${_this.relatedSectionId}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res>  {
  factory $NotificationModelCopyWith(NotificationModel value, $Res Function(NotificationModel) _then) = _$NotificationModelCopyWithImpl;
@useResult
$Res call({
 String id, String recipientId, String title, String message, String? link, List<String> channels, bool isRead, String? relatedEventId, String? relatedSectionId,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? recipientId = null,Object? title = null,Object? message = null,Object? link = freezed,Object? channels = null,Object? isRead = null,Object? relatedEventId = freezed,Object? relatedSectionId = freezed,Object? createdAt = null,}) {
  return _then(NotificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipientId: null == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,channels: null == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as List<String>,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,relatedEventId: freezed == relatedEventId ? _self.relatedEventId : relatedEventId // ignore: cast_nullable_to_non_nullable
as String?,relatedSectionId: freezed == relatedSectionId ? _self.relatedSectionId : relatedSectionId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationModel].
extension NotificationModelPatterns on NotificationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String recipientId,  String title,  String message,  String? link,  List<String> channels,  bool isRead,  String? relatedEventId,  String? relatedSectionId, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.recipientId,_that.title,_that.message,_that.link,_that.channels,_that.isRead,_that.relatedEventId,_that.relatedSectionId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String recipientId,  String title,  String message,  String? link,  List<String> channels,  bool isRead,  String? relatedEventId,  String? relatedSectionId, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationModel():
return $default(_that.id,_that.recipientId,_that.title,_that.message,_that.link,_that.channels,_that.isRead,_that.relatedEventId,_that.relatedSectionId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String recipientId,  String title,  String message,  String? link,  List<String> channels,  bool isRead,  String? relatedEventId,  String? relatedSectionId, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.recipientId,_that.title,_that.message,_that.link,_that.channels,_that.isRead,_that.relatedEventId,_that.relatedSectionId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationModel implements NotificationModel {
  const _NotificationModel({required this.id, required this.recipientId, required this.title, required this.message, this.link,  List<String> channels = const [], this.isRead = false, this.relatedEventId, this.relatedSectionId, @TimestampConverter() required this.createdAt}): _channels = channels;
  factory _NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

/// Firestore document ID.
@override final  String id;
/// The user this notification is addressed to.
@override final  String recipientId;
@override final  String title;
@override final  String message;
/// Optional deep-link or in-app route, e.g. "/events/abc123".
@override final  String? link;
/// Which channels were used to deliver this notification.
/// Valid values: `push`, `email`, `inApp` (see [NotificationChannel]).
/// Stored as strings because the ODM builder does not support List<Enum>.
 final  List<String> _channels;
/// Which channels were used to deliver this notification.
/// Valid values: `push`, `email`, `inApp` (see [NotificationChannel]).
/// Stored as strings because the ODM builder does not support List<Enum>.
@override@JsonKey() List<String> get channels {
  if (_channels is EqualUnmodifiableListView) return _channels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_channels);
}

/// Whether the recipient has marked this notification as read.
@override@JsonKey() final  bool isRead;
@override final  String? relatedEventId;
@override final  String? relatedSectionId;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationModelCopyWith<_NotificationModel> get copyWith => __$NotificationModelCopyWithImpl<_NotificationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.link, link) || other.link == link)&&const DeepCollectionEquality().equals(other.channels, _channels)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.relatedEventId, relatedEventId) || other.relatedEventId == relatedEventId)&&(identical(other.relatedSectionId, relatedSectionId) || other.relatedSectionId == relatedSectionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,recipientId,title,message,link,const DeepCollectionEquality().hash(_channels),isRead,relatedEventId,relatedSectionId,createdAt);
}

@override
String toString() {
    return 'NotificationModel(id: $id, recipientId: $recipientId, title: $title, message: $message, link: $link, channels: $channels, isRead: $isRead, relatedEventId: $relatedEventId, relatedSectionId: $relatedSectionId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationModelCopyWith<$Res> implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationModelCopyWith(_NotificationModel value, $Res Function(_NotificationModel) _then) = __$NotificationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String recipientId, String title, String message, String? link, List<String> channels, bool isRead, String? relatedEventId, String? relatedSectionId,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$NotificationModelCopyWithImpl<$Res>
    implements _$NotificationModelCopyWith<$Res> {
  __$NotificationModelCopyWithImpl(this._self, this._then);

  final _NotificationModel _self;
  final $Res Function(_NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? recipientId = null,Object? title = null,Object? message = null,Object? link = freezed,Object? channels = null,Object? isRead = null,Object? relatedEventId = freezed,Object? relatedSectionId = freezed,Object? createdAt = null,}) {
  return _then(_NotificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipientId: null == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,channels: null == channels ? _self._channels : channels // ignore: cast_nullable_to_non_nullable
as List<String>,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,relatedEventId: freezed == relatedEventId ? _self.relatedEventId : relatedEventId // ignore: cast_nullable_to_non_nullable
as String?,relatedSectionId: freezed == relatedSectionId ? _self.relatedSectionId : relatedSectionId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
