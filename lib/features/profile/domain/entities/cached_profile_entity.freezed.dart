// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cached_profile_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CachedProfileEntity {

 String get name; String get email;
/// Create a copy of CachedProfileEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CachedProfileEntityCopyWith<CachedProfileEntity> get copyWith => _$CachedProfileEntityCopyWithImpl<CachedProfileEntity>(this as CachedProfileEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CachedProfileEntity&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,name,email);

@override
String toString() {
  return 'CachedProfileEntity(name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class $CachedProfileEntityCopyWith<$Res>  {
  factory $CachedProfileEntityCopyWith(CachedProfileEntity value, $Res Function(CachedProfileEntity) _then) = _$CachedProfileEntityCopyWithImpl;
@useResult
$Res call({
 String name, String email
});




}
/// @nodoc
class _$CachedProfileEntityCopyWithImpl<$Res>
    implements $CachedProfileEntityCopyWith<$Res> {
  _$CachedProfileEntityCopyWithImpl(this._self, this._then);

  final CachedProfileEntity _self;
  final $Res Function(CachedProfileEntity) _then;

/// Create a copy of CachedProfileEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CachedProfileEntity].
extension CachedProfileEntityPatterns on CachedProfileEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CachedProfileEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CachedProfileEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CachedProfileEntity value)  $default,){
final _that = this;
switch (_that) {
case _CachedProfileEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CachedProfileEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CachedProfileEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CachedProfileEntity() when $default != null:
return $default(_that.name,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String email)  $default,) {final _that = this;
switch (_that) {
case _CachedProfileEntity():
return $default(_that.name,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String email)?  $default,) {final _that = this;
switch (_that) {
case _CachedProfileEntity() when $default != null:
return $default(_that.name,_that.email);case _:
  return null;

}
}

}

/// @nodoc


class _CachedProfileEntity implements CachedProfileEntity {
  const _CachedProfileEntity({this.name = '', this.email = ''});
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String email;

/// Create a copy of CachedProfileEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CachedProfileEntityCopyWith<_CachedProfileEntity> get copyWith => __$CachedProfileEntityCopyWithImpl<_CachedProfileEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CachedProfileEntity&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,name,email);

@override
String toString() {
  return 'CachedProfileEntity(name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class _$CachedProfileEntityCopyWith<$Res> implements $CachedProfileEntityCopyWith<$Res> {
  factory _$CachedProfileEntityCopyWith(_CachedProfileEntity value, $Res Function(_CachedProfileEntity) _then) = __$CachedProfileEntityCopyWithImpl;
@override @useResult
$Res call({
 String name, String email
});




}
/// @nodoc
class __$CachedProfileEntityCopyWithImpl<$Res>
    implements _$CachedProfileEntityCopyWith<$Res> {
  __$CachedProfileEntityCopyWithImpl(this._self, this._then);

  final _CachedProfileEntity _self;
  final $Res Function(_CachedProfileEntity) _then;

/// Create a copy of CachedProfileEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,}) {
  return _then(_CachedProfileEntity(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
