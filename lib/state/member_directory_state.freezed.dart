// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_directory_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MemberDirectoryState {

 String get sectionId; List<MemberDirectoryEntry> get entries; bool get isLoading; Object? get error; String get searchQuery; SectionRole? get selectedRole;
/// Create a copy of MemberDirectoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberDirectoryStateCopyWith<MemberDirectoryState> get copyWith => _$MemberDirectoryStateCopyWithImpl<MemberDirectoryState>(this as MemberDirectoryState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MemberDirectoryState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberDirectoryState&&(identical(other.sectionId, _this.sectionId) || other.sectionId == _this.sectionId)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&const DeepCollectionEquality().equals(other.error, _this.error)&&(identical(other.searchQuery, _this.searchQuery) || other.searchQuery == _this.searchQuery)&&(identical(other.selectedRole, _this.selectedRole) || other.selectedRole == _this.selectedRole));
}


@override
int get hashCode {
  final _this = this as MemberDirectoryState;
  return Object.hash(runtimeType,_this.sectionId,const DeepCollectionEquality().hash(_this.entries),_this.isLoading,const DeepCollectionEquality().hash(_this.error),_this.searchQuery,_this.selectedRole);
}

@override
String toString() {
  final _this = this as MemberDirectoryState;
  return 'MemberDirectoryState(sectionId: ${_this.sectionId}, entries: ${_this.entries}, isLoading: ${_this.isLoading}, error: ${_this.error}, searchQuery: ${_this.searchQuery}, selectedRole: ${_this.selectedRole})';
}


}

/// @nodoc
abstract mixin class $MemberDirectoryStateCopyWith<$Res>  {
  factory $MemberDirectoryStateCopyWith(MemberDirectoryState value, $Res Function(MemberDirectoryState) _then) = _$MemberDirectoryStateCopyWithImpl;
@useResult
$Res call({
 String sectionId, List<MemberDirectoryEntry> entries, bool isLoading, Object? error, String searchQuery, SectionRole? selectedRole
});




}
/// @nodoc
class _$MemberDirectoryStateCopyWithImpl<$Res>
    implements $MemberDirectoryStateCopyWith<$Res> {
  _$MemberDirectoryStateCopyWithImpl(this._self, this._then);

  final MemberDirectoryState _self;
  final $Res Function(MemberDirectoryState) _then;

/// Create a copy of MemberDirectoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sectionId = null,Object? entries = null,Object? isLoading = null,Object? error = freezed,Object? searchQuery = null,Object? selectedRole = freezed,}) {
  return _then(MemberDirectoryState(
sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<MemberDirectoryEntry>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedRole: freezed == selectedRole ? _self.selectedRole : selectedRole // ignore: cast_nullable_to_non_nullable
as SectionRole?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberDirectoryState].
extension MemberDirectoryStatePatterns on MemberDirectoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberDirectoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberDirectoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberDirectoryState value)  $default,){
final _that = this;
switch (_that) {
case _MemberDirectoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberDirectoryState value)?  $default,){
final _that = this;
switch (_that) {
case _MemberDirectoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sectionId,  List<MemberDirectoryEntry> entries,  bool isLoading,  Object? error,  String searchQuery,  SectionRole? selectedRole)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberDirectoryState() when $default != null:
return $default(_that.sectionId,_that.entries,_that.isLoading,_that.error,_that.searchQuery,_that.selectedRole);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sectionId,  List<MemberDirectoryEntry> entries,  bool isLoading,  Object? error,  String searchQuery,  SectionRole? selectedRole)  $default,) {final _that = this;
switch (_that) {
case _MemberDirectoryState():
return $default(_that.sectionId,_that.entries,_that.isLoading,_that.error,_that.searchQuery,_that.selectedRole);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sectionId,  List<MemberDirectoryEntry> entries,  bool isLoading,  Object? error,  String searchQuery,  SectionRole? selectedRole)?  $default,) {final _that = this;
switch (_that) {
case _MemberDirectoryState() when $default != null:
return $default(_that.sectionId,_that.entries,_that.isLoading,_that.error,_that.searchQuery,_that.selectedRole);case _:
  return null;

}
}

}

/// @nodoc


class _MemberDirectoryState extends MemberDirectoryState {
  const _MemberDirectoryState({required this.sectionId,  List<MemberDirectoryEntry> entries = const <MemberDirectoryEntry>[], this.isLoading = true, this.error, this.searchQuery = '', this.selectedRole}): _entries = entries,super._();
  

@override final  String sectionId;
 final  List<MemberDirectoryEntry> _entries;
@override@JsonKey() List<MemberDirectoryEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override@JsonKey() final  bool isLoading;
@override final  Object? error;
@override@JsonKey() final  String searchQuery;
@override final  SectionRole? selectedRole;

/// Create a copy of MemberDirectoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberDirectoryStateCopyWith<_MemberDirectoryState> get copyWith => __$MemberDirectoryStateCopyWithImpl<_MemberDirectoryState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberDirectoryState&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.selectedRole, selectedRole) || other.selectedRole == selectedRole));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sectionId,const DeepCollectionEquality().hash(_entries),isLoading,const DeepCollectionEquality().hash(error),searchQuery,selectedRole);
}

@override
String toString() {
    return 'MemberDirectoryState(sectionId: $sectionId, entries: $entries, isLoading: $isLoading, error: $error, searchQuery: $searchQuery, selectedRole: $selectedRole)';
}


}

/// @nodoc
abstract mixin class _$MemberDirectoryStateCopyWith<$Res> implements $MemberDirectoryStateCopyWith<$Res> {
  factory _$MemberDirectoryStateCopyWith(_MemberDirectoryState value, $Res Function(_MemberDirectoryState) _then) = __$MemberDirectoryStateCopyWithImpl;
@override @useResult
$Res call({
 String sectionId, List<MemberDirectoryEntry> entries, bool isLoading, Object? error, String searchQuery, SectionRole? selectedRole
});




}
/// @nodoc
class __$MemberDirectoryStateCopyWithImpl<$Res>
    implements _$MemberDirectoryStateCopyWith<$Res> {
  __$MemberDirectoryStateCopyWithImpl(this._self, this._then);

  final _MemberDirectoryState _self;
  final $Res Function(_MemberDirectoryState) _then;

/// Create a copy of MemberDirectoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sectionId = null,Object? entries = null,Object? isLoading = null,Object? error = freezed,Object? searchQuery = null,Object? selectedRole = freezed,}) {
  return _then(_MemberDirectoryState(
sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<MemberDirectoryEntry>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedRole: freezed == selectedRole ? _self.selectedRole : selectedRole // ignore: cast_nullable_to_non_nullable
as SectionRole?,
  ));
}


}

// dart format on
