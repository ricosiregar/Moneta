// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthStateEntity {

 UserEntity? get user; AuthEventType get event;
/// Create a copy of AuthStateEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateEntityCopyWith<AuthStateEntity> get copyWith => _$AuthStateEntityCopyWithImpl<AuthStateEntity>(this as AuthStateEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStateEntity&&(identical(other.user, user) || other.user == user)&&(identical(other.event, event) || other.event == event));
}


@override
int get hashCode => Object.hash(runtimeType,user,event);

@override
String toString() {
  return 'AuthStateEntity(user: $user, event: $event)';
}


}

/// @nodoc
abstract mixin class $AuthStateEntityCopyWith<$Res>  {
  factory $AuthStateEntityCopyWith(AuthStateEntity value, $Res Function(AuthStateEntity) _then) = _$AuthStateEntityCopyWithImpl;
@useResult
$Res call({
 UserEntity? user, AuthEventType event
});


$UserEntityCopyWith<$Res>? get user;

}
/// @nodoc
class _$AuthStateEntityCopyWithImpl<$Res>
    implements $AuthStateEntityCopyWith<$Res> {
  _$AuthStateEntityCopyWithImpl(this._self, this._then);

  final AuthStateEntity _self;
  final $Res Function(AuthStateEntity) _then;

/// Create a copy of AuthStateEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = freezed,Object? event = null,}) {
  return _then(_self.copyWith(
user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserEntity?,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as AuthEventType,
  ));
}
/// Create a copy of AuthStateEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserEntityCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserEntityCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthStateEntity].
extension AuthStateEntityPatterns on AuthStateEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthStateEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthStateEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthStateEntity value)  $default,){
final _that = this;
switch (_that) {
case _AuthStateEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthStateEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AuthStateEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserEntity? user,  AuthEventType event)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthStateEntity() when $default != null:
return $default(_that.user,_that.event);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserEntity? user,  AuthEventType event)  $default,) {final _that = this;
switch (_that) {
case _AuthStateEntity():
return $default(_that.user,_that.event);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserEntity? user,  AuthEventType event)?  $default,) {final _that = this;
switch (_that) {
case _AuthStateEntity() when $default != null:
return $default(_that.user,_that.event);case _:
  return null;

}
}

}

/// @nodoc


class _AuthStateEntity implements AuthStateEntity {
  const _AuthStateEntity({required this.user, required this.event});
  

@override final  UserEntity? user;
@override final  AuthEventType event;

/// Create a copy of AuthStateEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthStateEntityCopyWith<_AuthStateEntity> get copyWith => __$AuthStateEntityCopyWithImpl<_AuthStateEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthStateEntity&&(identical(other.user, user) || other.user == user)&&(identical(other.event, event) || other.event == event));
}


@override
int get hashCode => Object.hash(runtimeType,user,event);

@override
String toString() {
  return 'AuthStateEntity(user: $user, event: $event)';
}


}

/// @nodoc
abstract mixin class _$AuthStateEntityCopyWith<$Res> implements $AuthStateEntityCopyWith<$Res> {
  factory _$AuthStateEntityCopyWith(_AuthStateEntity value, $Res Function(_AuthStateEntity) _then) = __$AuthStateEntityCopyWithImpl;
@override @useResult
$Res call({
 UserEntity? user, AuthEventType event
});


@override $UserEntityCopyWith<$Res>? get user;

}
/// @nodoc
class __$AuthStateEntityCopyWithImpl<$Res>
    implements _$AuthStateEntityCopyWith<$Res> {
  __$AuthStateEntityCopyWithImpl(this._self, this._then);

  final _AuthStateEntity _self;
  final $Res Function(_AuthStateEntity) _then;

/// Create a copy of AuthStateEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = freezed,Object? event = null,}) {
  return _then(_AuthStateEntity(
user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserEntity?,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as AuthEventType,
  ));
}

/// Create a copy of AuthStateEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserEntityCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserEntityCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
