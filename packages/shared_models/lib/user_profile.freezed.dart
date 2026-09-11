// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

/// Firebase Auth UID — used as the Firestore document ID.
@DocumentIdField() String get id; String get firstName; String get lastName; String? get phone; String get emergencyContactName; String get emergencyContactPhone; String? get emergencyContactRelation; String? get medicalConditions;/// Free-text certifications, e.g. ["First Aid", "AST 2", "ACMG Ski Guide"].
 List<String> get certifications;/// IDs of the sections this user belongs to.
 List<String> get sectionIds; String? get defaultSectionId;/// Whether this user has global admin access.
/// All other roles (section manager, trip leader, member) are per-section
/// and are stored on each [SectionMember] document.
 bool get isAdmin; bool get complatedProfile; bool get signedWaiver; NotificationPreferences get notificationPreferences;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.emergencyContactName, _this.emergencyContactName) || other.emergencyContactName == _this.emergencyContactName)&&(identical(other.emergencyContactPhone, _this.emergencyContactPhone) || other.emergencyContactPhone == _this.emergencyContactPhone)&&(identical(other.emergencyContactRelation, _this.emergencyContactRelation) || other.emergencyContactRelation == _this.emergencyContactRelation)&&(identical(other.medicalConditions, _this.medicalConditions) || other.medicalConditions == _this.medicalConditions)&&const DeepCollectionEquality().equals(other.certifications, _this.certifications)&&const DeepCollectionEquality().equals(other.sectionIds, _this.sectionIds)&&(identical(other.defaultSectionId, _this.defaultSectionId) || other.defaultSectionId == _this.defaultSectionId)&&(identical(other.isAdmin, _this.isAdmin) || other.isAdmin == _this.isAdmin)&&(identical(other.complatedProfile, _this.complatedProfile) || other.complatedProfile == _this.complatedProfile)&&(identical(other.signedWaiver, _this.signedWaiver) || other.signedWaiver == _this.signedWaiver)&&(identical(other.notificationPreferences, _this.notificationPreferences) || other.notificationPreferences == _this.notificationPreferences)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserProfile;
  return Object.hash(runtimeType,_this.id,_this.firstName,_this.lastName,_this.phone,_this.emergencyContactName,_this.emergencyContactPhone,_this.emergencyContactRelation,_this.medicalConditions,const DeepCollectionEquality().hash(_this.certifications),const DeepCollectionEquality().hash(_this.sectionIds),_this.defaultSectionId,_this.isAdmin,_this.complatedProfile,_this.signedWaiver,_this.notificationPreferences,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as UserProfile;
  return 'UserProfile(id: ${_this.id}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, phone: ${_this.phone}, emergencyContactName: ${_this.emergencyContactName}, emergencyContactPhone: ${_this.emergencyContactPhone}, emergencyContactRelation: ${_this.emergencyContactRelation}, medicalConditions: ${_this.medicalConditions}, certifications: ${_this.certifications}, sectionIds: ${_this.sectionIds}, defaultSectionId: ${_this.defaultSectionId}, isAdmin: ${_this.isAdmin}, complatedProfile: ${_this.complatedProfile}, signedWaiver: ${_this.signedWaiver}, notificationPreferences: ${_this.notificationPreferences}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
@DocumentIdField() String id, String firstName, String lastName, String? phone, String emergencyContactName, String emergencyContactPhone, String? emergencyContactRelation, String? medicalConditions, List<String> certifications, List<String> sectionIds, String? defaultSectionId, bool isAdmin, bool complatedProfile, bool signedWaiver, NotificationPreferences notificationPreferences,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});


$NotificationPreferencesCopyWith<$Res> get notificationPreferences;

}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? phone = freezed,Object? emergencyContactName = null,Object? emergencyContactPhone = null,Object? emergencyContactRelation = freezed,Object? medicalConditions = freezed,Object? certifications = null,Object? sectionIds = null,Object? defaultSectionId = freezed,Object? isAdmin = null,Object? complatedProfile = null,Object? signedWaiver = null,Object? notificationPreferences = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactName: null == emergencyContactName ? _self.emergencyContactName : emergencyContactName // ignore: cast_nullable_to_non_nullable
as String,emergencyContactPhone: null == emergencyContactPhone ? _self.emergencyContactPhone : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
as String,emergencyContactRelation: freezed == emergencyContactRelation ? _self.emergencyContactRelation : emergencyContactRelation // ignore: cast_nullable_to_non_nullable
as String?,medicalConditions: freezed == medicalConditions ? _self.medicalConditions : medicalConditions // ignore: cast_nullable_to_non_nullable
as String?,certifications: null == certifications ? _self.certifications : certifications // ignore: cast_nullable_to_non_nullable
as List<String>,sectionIds: null == sectionIds ? _self.sectionIds : sectionIds // ignore: cast_nullable_to_non_nullable
as List<String>,defaultSectionId: freezed == defaultSectionId ? _self.defaultSectionId : defaultSectionId // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,complatedProfile: null == complatedProfile ? _self.complatedProfile : complatedProfile // ignore: cast_nullable_to_non_nullable
as bool,signedWaiver: null == signedWaiver ? _self.signedWaiver : signedWaiver // ignore: cast_nullable_to_non_nullable
as bool,notificationPreferences: null == notificationPreferences ? _self.notificationPreferences : notificationPreferences // ignore: cast_nullable_to_non_nullable
as NotificationPreferences,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<$Res> get notificationPreferences {
  
  return $NotificationPreferencesCopyWith<$Res>(_self.notificationPreferences, (value) {
    return _then(_self.copyWith(notificationPreferences: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DocumentIdField()  String id,  String firstName,  String lastName,  String? phone,  String emergencyContactName,  String emergencyContactPhone,  String? emergencyContactRelation,  String? medicalConditions,  List<String> certifications,  List<String> sectionIds,  String? defaultSectionId,  bool isAdmin,  bool complatedProfile,  bool signedWaiver,  NotificationPreferences notificationPreferences, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.phone,_that.emergencyContactName,_that.emergencyContactPhone,_that.emergencyContactRelation,_that.medicalConditions,_that.certifications,_that.sectionIds,_that.defaultSectionId,_that.isAdmin,_that.complatedProfile,_that.signedWaiver,_that.notificationPreferences,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DocumentIdField()  String id,  String firstName,  String lastName,  String? phone,  String emergencyContactName,  String emergencyContactPhone,  String? emergencyContactRelation,  String? medicalConditions,  List<String> certifications,  List<String> sectionIds,  String? defaultSectionId,  bool isAdmin,  bool complatedProfile,  bool signedWaiver,  NotificationPreferences notificationPreferences, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.firstName,_that.lastName,_that.phone,_that.emergencyContactName,_that.emergencyContactPhone,_that.emergencyContactRelation,_that.medicalConditions,_that.certifications,_that.sectionIds,_that.defaultSectionId,_that.isAdmin,_that.complatedProfile,_that.signedWaiver,_that.notificationPreferences,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DocumentIdField()  String id,  String firstName,  String lastName,  String? phone,  String emergencyContactName,  String emergencyContactPhone,  String? emergencyContactRelation,  String? medicalConditions,  List<String> certifications,  List<String> sectionIds,  String? defaultSectionId,  bool isAdmin,  bool complatedProfile,  bool signedWaiver,  NotificationPreferences notificationPreferences, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.phone,_that.emergencyContactName,_that.emergencyContactPhone,_that.emergencyContactRelation,_that.medicalConditions,_that.certifications,_that.sectionIds,_that.defaultSectionId,_that.isAdmin,_that.complatedProfile,_that.signedWaiver,_that.notificationPreferences,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({@DocumentIdField() required this.id, required this.firstName, required this.lastName, this.phone, required this.emergencyContactName, required this.emergencyContactPhone, this.emergencyContactRelation, this.medicalConditions,  List<String> certifications = const [],  List<String> sectionIds = const [], this.defaultSectionId, this.isAdmin = false, this.complatedProfile = false, this.signedWaiver = false, required this.notificationPreferences, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt}): _certifications = certifications,_sectionIds = sectionIds;
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

/// Firebase Auth UID — used as the Firestore document ID.
@override@DocumentIdField() final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String? phone;
@override final  String emergencyContactName;
@override final  String emergencyContactPhone;
@override final  String? emergencyContactRelation;
@override final  String? medicalConditions;
/// Free-text certifications, e.g. ["First Aid", "AST 2", "ACMG Ski Guide"].
 final  List<String> _certifications;
/// Free-text certifications, e.g. ["First Aid", "AST 2", "ACMG Ski Guide"].
@override@JsonKey() List<String> get certifications {
  if (_certifications is EqualUnmodifiableListView) return _certifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_certifications);
}

/// IDs of the sections this user belongs to.
 final  List<String> _sectionIds;
/// IDs of the sections this user belongs to.
@override@JsonKey() List<String> get sectionIds {
  if (_sectionIds is EqualUnmodifiableListView) return _sectionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sectionIds);
}

@override final  String? defaultSectionId;
/// Whether this user has global admin access.
/// All other roles (section manager, trip leader, member) are per-section
/// and are stored on each [SectionMember] document.
@override@JsonKey() final  bool isAdmin;
@override@JsonKey() final  bool complatedProfile;
@override@JsonKey() final  bool signedWaiver;
@override final  NotificationPreferences notificationPreferences;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&(identical(other.emergencyContactRelation, emergencyContactRelation) || other.emergencyContactRelation == emergencyContactRelation)&&(identical(other.medicalConditions, medicalConditions) || other.medicalConditions == medicalConditions)&&const DeepCollectionEquality().equals(other.certifications, _certifications)&&const DeepCollectionEquality().equals(other.sectionIds, _sectionIds)&&(identical(other.defaultSectionId, defaultSectionId) || other.defaultSectionId == defaultSectionId)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.complatedProfile, complatedProfile) || other.complatedProfile == complatedProfile)&&(identical(other.signedWaiver, signedWaiver) || other.signedWaiver == signedWaiver)&&(identical(other.notificationPreferences, notificationPreferences) || other.notificationPreferences == notificationPreferences)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,firstName,lastName,phone,emergencyContactName,emergencyContactPhone,emergencyContactRelation,medicalConditions,const DeepCollectionEquality().hash(_certifications),const DeepCollectionEquality().hash(_sectionIds),defaultSectionId,isAdmin,complatedProfile,signedWaiver,notificationPreferences,createdAt,updatedAt);
}

@override
String toString() {
    return 'UserProfile(id: $id, firstName: $firstName, lastName: $lastName, phone: $phone, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, emergencyContactRelation: $emergencyContactRelation, medicalConditions: $medicalConditions, certifications: $certifications, sectionIds: $sectionIds, defaultSectionId: $defaultSectionId, isAdmin: $isAdmin, complatedProfile: $complatedProfile, signedWaiver: $signedWaiver, notificationPreferences: $notificationPreferences, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
@DocumentIdField() String id, String firstName, String lastName, String? phone, String emergencyContactName, String emergencyContactPhone, String? emergencyContactRelation, String? medicalConditions, List<String> certifications, List<String> sectionIds, String? defaultSectionId, bool isAdmin, bool complatedProfile, bool signedWaiver, NotificationPreferences notificationPreferences,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});


@override $NotificationPreferencesCopyWith<$Res> get notificationPreferences;

}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? phone = freezed,Object? emergencyContactName = null,Object? emergencyContactPhone = null,Object? emergencyContactRelation = freezed,Object? medicalConditions = freezed,Object? certifications = null,Object? sectionIds = null,Object? defaultSectionId = freezed,Object? isAdmin = null,Object? complatedProfile = null,Object? signedWaiver = null,Object? notificationPreferences = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactName: null == emergencyContactName ? _self.emergencyContactName : emergencyContactName // ignore: cast_nullable_to_non_nullable
as String,emergencyContactPhone: null == emergencyContactPhone ? _self.emergencyContactPhone : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
as String,emergencyContactRelation: freezed == emergencyContactRelation ? _self.emergencyContactRelation : emergencyContactRelation // ignore: cast_nullable_to_non_nullable
as String?,medicalConditions: freezed == medicalConditions ? _self.medicalConditions : medicalConditions // ignore: cast_nullable_to_non_nullable
as String?,certifications: null == certifications ? _self._certifications : certifications // ignore: cast_nullable_to_non_nullable
as List<String>,sectionIds: null == sectionIds ? _self._sectionIds : sectionIds // ignore: cast_nullable_to_non_nullable
as List<String>,defaultSectionId: freezed == defaultSectionId ? _self.defaultSectionId : defaultSectionId // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,complatedProfile: null == complatedProfile ? _self.complatedProfile : complatedProfile // ignore: cast_nullable_to_non_nullable
as bool,signedWaiver: null == signedWaiver ? _self.signedWaiver : signedWaiver // ignore: cast_nullable_to_non_nullable
as bool,notificationPreferences: null == notificationPreferences ? _self.notificationPreferences : notificationPreferences // ignore: cast_nullable_to_non_nullable
as NotificationPreferences,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<$Res> get notificationPreferences {
  
  return $NotificationPreferencesCopyWith<$Res>(_self.notificationPreferences, (value) {
    return _then(_self.copyWith(notificationPreferences: value));
  });
}
}

// dart format on
