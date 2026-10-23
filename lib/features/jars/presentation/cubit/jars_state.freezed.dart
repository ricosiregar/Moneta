// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jars_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JarsState {

 JarsStatus get status; List<JarEntity> get jars; String? get errorMessage;
/// Create a copy of JarsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JarsStateCopyWith<JarsState> get copyWith => _$JarsStateCopyWithImpl<JarsState>(this as JarsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JarsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.jars, jars)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(jars),errorMessage);

@override
String toString() {
  return 'JarsState(status: $status, jars: $jars, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $JarsStateCopyWith<$Res>  {
  factory $JarsStateCopyWith(JarsState value, $Res Function(JarsState) _then) = _$JarsStateCopyWithImpl;
@useResult
$Res call({
 JarsStatus status, List<JarEntity> jars, String? errorMessage
});




}
/// @nodoc
class _$JarsStateCopyWithImpl<$Res>
    implements $JarsStateCopyWith<$Res> {
  _$JarsStateCopyWithImpl(this._self, this._then);

  final JarsState _self;
  final $Res Function(JarsState) _then;

/// Create a copy of JarsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? jars = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JarsStatus,jars: null == jars ? _self.jars : jars // ignore: cast_nullable_to_non_nullable
as List<JarEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [JarsState].
extension JarsStatePatterns on JarsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JarsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JarsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JarsState value)  $default,){
final _that = this;
switch (_that) {
case _JarsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JarsState value)?  $default,){
final _that = this;
switch (_that) {
case _JarsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( JarsStatus status,  List<JarEntity> jars,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JarsState() when $default != null:
return $default(_that.status,_that.jars,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( JarsStatus status,  List<JarEntity> jars,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _JarsState():
return $default(_that.status,_that.jars,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( JarsStatus status,  List<JarEntity> jars,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _JarsState() when $default != null:
return $default(_that.status,_that.jars,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _JarsState implements JarsState {
  const _JarsState({this.status = JarsStatus.initial, final  List<JarEntity> jars = const <JarEntity>[], this.errorMessage}): _jars = jars;
  

@override@JsonKey() final  JarsStatus status;
 final  List<JarEntity> _jars;
@override@JsonKey() List<JarEntity> get jars {
  if (_jars is EqualUnmodifiableListView) return _jars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_jars);
}

@override final  String? errorMessage;

/// Create a copy of JarsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JarsStateCopyWith<_JarsState> get copyWith => __$JarsStateCopyWithImpl<_JarsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JarsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._jars, _jars)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_jars),errorMessage);

@override
String toString() {
  return 'JarsState(status: $status, jars: $jars, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$JarsStateCopyWith<$Res> implements $JarsStateCopyWith<$Res> {
  factory _$JarsStateCopyWith(_JarsState value, $Res Function(_JarsState) _then) = __$JarsStateCopyWithImpl;
@override @useResult
$Res call({
 JarsStatus status, List<JarEntity> jars, String? errorMessage
});




}
/// @nodoc
class __$JarsStateCopyWithImpl<$Res>
    implements _$JarsStateCopyWith<$Res> {
  __$JarsStateCopyWithImpl(this._self, this._then);

  final _JarsState _self;
  final $Res Function(_JarsState) _then;

/// Create a copy of JarsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? jars = null,Object? errorMessage = freezed,}) {
  return _then(_JarsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JarsStatus,jars: null == jars ? _self._jars : jars // ignore: cast_nullable_to_non_nullable
as List<JarEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
