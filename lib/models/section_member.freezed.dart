// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'section_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SectionMember {

/// Firestore document ID — matches the Firebase Auth UID.
 String get userId;/// The section this record belongs to.
 String get sectionId; SectionRole get sectionRole;/// Optional ID from an external membership management system.
 String? get externalSystemId;/// When the user joined this section.
@TimestampConverter() DateTime get joinedAt;
/// Create a copy of SectionMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SectionMemberCopyWith<SectionMember> get copyWith => _$SectionMemberCopyWithImpl<SectionMember>(this as SectionMember, _$identity);

  /// Serializes this SectionMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SectionMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SectionMember&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.sectionId, _this.sectionId) || other.sectionId == _this.sectionId)&&(identical(other.sectionRole, _this.sectionRole) || other.sectionRole == _this.sectionRole)&&(identical(other.externalSystemId, _this.externalSystemId) || other.externalSystemId == _this.externalSystemId)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SectionMember;
  return Object.hash(runtimeType,_this.userId,_this.sectionId,_this.sectionRole,_this.externalSystemId,_this.joinedAt);
}

@override
String toString() {
  final _this = this as SectionMember;
  return 'SectionMember(userId: ${_this.userId}, sectionId: ${_this.sectionId}, sectionRole: ${_this.sectionRole}, externalSystemId: ${_this.externalSystemId}, joinedAt: ${_this.joinedAt})';
}


}

/// @nodoc
abstract mixin class $SectionMemberCopyWith<$Res>  {
  factory $SectionMemberCopyWith(SectionMember value, $Res Function(SectionMember) _then) = _$SectionMemberCopyWithImpl;
@useResult
$Res call({
 String userId, String sectionId, SectionRole sectionRole, String? externalSystemId,@TimestampConverter() DateTime joinedAt
});




}
/// @nodoc
class _$SectionMemberCopyWithImpl<$Res>
    implements $SectionMemberCopyWith<$Res> {
  _$SectionMemberCopyWithImpl(this._self, this._then);

  final SectionMember _self;
  final $Res Function(SectionMember) _then;

/// Create a copy of SectionMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? sectionId = null,Object? sectionRole = null,Object? externalSystemId = freezed,Object? joinedAt = null,}) {
  return _then(SectionMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,sectionRole: null == sectionRole ? _self.sectionRole : sectionRole // ignore: cast_nullable_to_non_nullable
as SectionRole,externalSystemId: freezed == externalSystemId ? _self.externalSystemId : externalSystemId // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SectionMember].
extension SectionMemberPatterns on SectionMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SectionMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SectionMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SectionMember value)  $default,){
final _that = this;
switch (_that) {
case _SectionMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SectionMember value)?  $default,){
final _that = this;
switch (_that) {
case _SectionMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String sectionId,  SectionRole sectionRole,  String? externalSystemId, @TimestampConverter()  DateTime joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SectionMember() when $default != null:
return $default(_that.userId,_that.sectionId,_that.sectionRole,_that.externalSystemId,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String sectionId,  SectionRole sectionRole,  String? externalSystemId, @TimestampConverter()  DateTime joinedAt)  $default,) {final _that = this;
switch (_that) {
case _SectionMember():
return $default(_that.userId,_that.sectionId,_that.sectionRole,_that.externalSystemId,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String sectionId,  SectionRole sectionRole,  String? externalSystemId, @TimestampConverter()  DateTime joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _SectionMember() when $default != null:
return $default(_that.userId,_that.sectionId,_that.sectionRole,_that.externalSystemId,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SectionMember implements SectionMember {
  const _SectionMember({required this.userId, required this.sectionId, required this.sectionRole, this.externalSystemId, @TimestampConverter() required this.joinedAt});
  factory _SectionMember.fromJson(Map<String, dynamic> json) => _$SectionMemberFromJson(json);

/// Firestore document ID — matches the Firebase Auth UID.
@override final  String userId;
/// The section this record belongs to.
@override final  String sectionId;
@override final  SectionRole sectionRole;
/// Optional ID from an external membership management system.
@override final  String? externalSystemId;
/// When the user joined this section.
@override@TimestampConverter() final  DateTime joinedAt;

/// Create a copy of SectionMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SectionMemberCopyWith<_SectionMember> get copyWith => __$SectionMemberCopyWithImpl<_SectionMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SectionMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SectionMember&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.sectionRole, sectionRole) || other.sectionRole == sectionRole)&&(identical(other.externalSystemId, externalSystemId) || other.externalSystemId == externalSystemId)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,sectionId,sectionRole,externalSystemId,joinedAt);
}

@override
String toString() {
    return 'SectionMember(userId: $userId, sectionId: $sectionId, sectionRole: $sectionRole, externalSystemId: $externalSystemId, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$SectionMemberCopyWith<$Res> implements $SectionMemberCopyWith<$Res> {
  factory _$SectionMemberCopyWith(_SectionMember value, $Res Function(_SectionMember) _then) = __$SectionMemberCopyWithImpl;
@override @useResult
$Res call({
 String userId, String sectionId, SectionRole sectionRole, String? externalSystemId,@TimestampConverter() DateTime joinedAt
});




}
/// @nodoc
class __$SectionMemberCopyWithImpl<$Res>
    implements _$SectionMemberCopyWith<$Res> {
  __$SectionMemberCopyWithImpl(this._self, this._then);

  final _SectionMember _self;
  final $Res Function(_SectionMember) _then;

/// Create a copy of SectionMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? sectionId = null,Object? sectionRole = null,Object? externalSystemId = freezed,Object? joinedAt = null,}) {
  return _then(_SectionMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,sectionRole: null == sectionRole ? _self.sectionRole : sectionRole // ignore: cast_nullable_to_non_nullable
as SectionRole,externalSystemId: freezed == externalSystemId ? _self.externalSystemId : externalSystemId // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
