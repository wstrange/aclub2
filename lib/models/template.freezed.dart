// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Template {

/// Firestore document ID.
@DocumentIdField() String get id;/// ISO language code — "en" or "fr".
 String get language;/// Short admin-visible name for this template.
 String get title;/// The full markdown body of the template.
 String get markdownText;/// User ID of the admin who created the template.
 String get createdBy;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of Template
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateCopyWith<Template> get copyWith => _$TemplateCopyWithImpl<Template>(this as Template, _$identity);

  /// Serializes this Template to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Template;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Template&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.markdownText, _this.markdownText) || other.markdownText == _this.markdownText)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Template;
  return Object.hash(runtimeType,_this.id,_this.language,_this.title,_this.markdownText,_this.createdBy,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Template;
  return 'Template(id: ${_this.id}, language: ${_this.language}, title: ${_this.title}, markdownText: ${_this.markdownText}, createdBy: ${_this.createdBy}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $TemplateCopyWith<$Res>  {
  factory $TemplateCopyWith(Template value, $Res Function(Template) _then) = _$TemplateCopyWithImpl;
@useResult
$Res call({
@DocumentIdField() String id, String language, String title, String markdownText, String createdBy,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$TemplateCopyWithImpl<$Res>
    implements $TemplateCopyWith<$Res> {
  _$TemplateCopyWithImpl(this._self, this._then);

  final Template _self;
  final $Res Function(Template) _then;

/// Create a copy of Template
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? language = null,Object? title = null,Object? markdownText = null,Object? createdBy = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Template(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,markdownText: null == markdownText ? _self.markdownText : markdownText // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Template].
extension TemplatePatterns on Template {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Template value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Template() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Template value)  $default,){
final _that = this;
switch (_that) {
case _Template():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Template value)?  $default,){
final _that = this;
switch (_that) {
case _Template() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DocumentIdField()  String id,  String language,  String title,  String markdownText,  String createdBy, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Template() when $default != null:
return $default(_that.id,_that.language,_that.title,_that.markdownText,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DocumentIdField()  String id,  String language,  String title,  String markdownText,  String createdBy, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Template():
return $default(_that.id,_that.language,_that.title,_that.markdownText,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DocumentIdField()  String id,  String language,  String title,  String markdownText,  String createdBy, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Template() when $default != null:
return $default(_that.id,_that.language,_that.title,_that.markdownText,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Template extends Template {
  const _Template({@DocumentIdField() required this.id, required this.language, required this.title, required this.markdownText, required this.createdBy, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt}): super._();
  factory _Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);

/// Firestore document ID.
@override@DocumentIdField() final  String id;
/// ISO language code — "en" or "fr".
@override final  String language;
/// Short admin-visible name for this template.
@override final  String title;
/// The full markdown body of the template.
@override final  String markdownText;
/// User ID of the admin who created the template.
@override final  String createdBy;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of Template
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateCopyWith<_Template> get copyWith => __$TemplateCopyWithImpl<_Template>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Template&&(identical(other.id, id) || other.id == id)&&(identical(other.language, language) || other.language == language)&&(identical(other.title, title) || other.title == title)&&(identical(other.markdownText, markdownText) || other.markdownText == markdownText)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,language,title,markdownText,createdBy,createdAt,updatedAt);
}

@override
String toString() {
    return 'Template(id: $id, language: $language, title: $title, markdownText: $markdownText, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TemplateCopyWith<$Res> implements $TemplateCopyWith<$Res> {
  factory _$TemplateCopyWith(_Template value, $Res Function(_Template) _then) = __$TemplateCopyWithImpl;
@override @useResult
$Res call({
@DocumentIdField() String id, String language, String title, String markdownText, String createdBy,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$TemplateCopyWithImpl<$Res>
    implements _$TemplateCopyWith<$Res> {
  __$TemplateCopyWithImpl(this._self, this._then);

  final _Template _self;
  final $Res Function(_Template) _then;

/// Create a copy of Template
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? language = null,Object? title = null,Object? markdownText = null,Object? createdBy = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Template(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,markdownText: null == markdownText ? _self.markdownText : markdownText // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
