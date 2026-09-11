// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserState {

 UserProfile get userProfile; User get user; List<Section> get userSections; Section get currentSection;
/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStateCopyWith<UserState> get copyWith => _$UserStateCopyWithImpl<UserState>(this as UserState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserState&&(identical(other.userProfile, _this.userProfile) || other.userProfile == _this.userProfile)&&(identical(other.user, _this.user) || other.user == _this.user)&&const DeepCollectionEquality().equals(other.userSections, _this.userSections)&&(identical(other.currentSection, _this.currentSection) || other.currentSection == _this.currentSection));
}


@override
int get hashCode {
  final _this = this as UserState;
  return Object.hash(runtimeType,_this.userProfile,_this.user,const DeepCollectionEquality().hash(_this.userSections),_this.currentSection);
}

@override
String toString() {
  final _this = this as UserState;
  return 'UserState(userProfile: ${_this.userProfile}, user: ${_this.user}, userSections: ${_this.userSections}, currentSection: ${_this.currentSection})';
}


}

/// @nodoc
abstract mixin class $UserStateCopyWith<$Res>  {
  factory $UserStateCopyWith(UserState value, $Res Function(UserState) _then) = _$UserStateCopyWithImpl;
@useResult
$Res call({
 UserProfile userProfile, User user, List<Section> userSections, Section currentSection
});


$UserProfileCopyWith<$Res> get userProfile;$SectionCopyWith<$Res> get currentSection;

}
/// @nodoc
class _$UserStateCopyWithImpl<$Res>
    implements $UserStateCopyWith<$Res> {
  _$UserStateCopyWithImpl(this._self, this._then);

  final UserState _self;
  final $Res Function(UserState) _then;

/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProfile = null,Object? user = null,Object? userSections = null,Object? currentSection = null,}) {
  return _then(UserState(
userProfile: null == userProfile ? _self.userProfile : userProfile // ignore: cast_nullable_to_non_nullable
as UserProfile,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,userSections: null == userSections ? _self.userSections : userSections // ignore: cast_nullable_to_non_nullable
as List<Section>,currentSection: null == currentSection ? _self.currentSection : currentSection // ignore: cast_nullable_to_non_nullable
as Section,
  ));
}
/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get userProfile {
  
  return $UserProfileCopyWith<$Res>(_self.userProfile, (value) {
    return _then(_self.copyWith(userProfile: value));
  });
}/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SectionCopyWith<$Res> get currentSection {
  
  return $SectionCopyWith<$Res>(_self.currentSection, (value) {
    return _then(_self.copyWith(currentSection: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserState].
extension UserStatePatterns on UserState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserState value)  $default,){
final _that = this;
switch (_that) {
case _UserState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserState value)?  $default,){
final _that = this;
switch (_that) {
case _UserState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserProfile userProfile,  User user,  List<Section> userSections,  Section currentSection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserState() when $default != null:
return $default(_that.userProfile,_that.user,_that.userSections,_that.currentSection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserProfile userProfile,  User user,  List<Section> userSections,  Section currentSection)  $default,) {final _that = this;
switch (_that) {
case _UserState():
return $default(_that.userProfile,_that.user,_that.userSections,_that.currentSection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserProfile userProfile,  User user,  List<Section> userSections,  Section currentSection)?  $default,) {final _that = this;
switch (_that) {
case _UserState() when $default != null:
return $default(_that.userProfile,_that.user,_that.userSections,_that.currentSection);case _:
  return null;

}
}

}

/// @nodoc


class _UserState implements UserState {
  const _UserState({required this.userProfile, required this.user, required  List<Section> userSections, required this.currentSection}): _userSections = userSections;
  

@override final  UserProfile userProfile;
@override final  User user;
 final  List<Section> _userSections;
@override List<Section> get userSections {
  if (_userSections is EqualUnmodifiableListView) return _userSections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userSections);
}

@override final  Section currentSection;

/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStateCopyWith<_UserState> get copyWith => __$UserStateCopyWithImpl<_UserState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserState&&(identical(other.userProfile, userProfile) || other.userProfile == userProfile)&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other.userSections, _userSections)&&(identical(other.currentSection, currentSection) || other.currentSection == currentSection));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userProfile,user,const DeepCollectionEquality().hash(_userSections),currentSection);
}

@override
String toString() {
    return 'UserState(userProfile: $userProfile, user: $user, userSections: $userSections, currentSection: $currentSection)';
}


}

/// @nodoc
abstract mixin class _$UserStateCopyWith<$Res> implements $UserStateCopyWith<$Res> {
  factory _$UserStateCopyWith(_UserState value, $Res Function(_UserState) _then) = __$UserStateCopyWithImpl;
@override @useResult
$Res call({
 UserProfile userProfile, User user, List<Section> userSections, Section currentSection
});


@override $UserProfileCopyWith<$Res> get userProfile;@override $SectionCopyWith<$Res> get currentSection;

}
/// @nodoc
class __$UserStateCopyWithImpl<$Res>
    implements _$UserStateCopyWith<$Res> {
  __$UserStateCopyWithImpl(this._self, this._then);

  final _UserState _self;
  final $Res Function(_UserState) _then;

/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProfile = null,Object? user = null,Object? userSections = null,Object? currentSection = null,}) {
  return _then(_UserState(
userProfile: null == userProfile ? _self.userProfile : userProfile // ignore: cast_nullable_to_non_nullable
as UserProfile,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,userSections: null == userSections ? _self._userSections : userSections // ignore: cast_nullable_to_non_nullable
as List<Section>,currentSection: null == currentSection ? _self.currentSection : currentSection // ignore: cast_nullable_to_non_nullable
as Section,
  ));
}

/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get userProfile {
  
  return $UserProfileCopyWith<$Res>(_self.userProfile, (value) {
    return _then(_self.copyWith(userProfile: value));
  });
}/// Create a copy of UserState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SectionCopyWith<$Res> get currentSection {
  
  return $SectionCopyWith<$Res>(_self.currentSection, (value) {
    return _then(_self.copyWith(currentSection: value));
  });
}
}

// dart format on
