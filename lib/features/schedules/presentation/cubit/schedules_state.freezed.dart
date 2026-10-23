// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedules_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SchedulesState {

 SchedulesStatus get status; List<AutoScheduleEntity> get schedules; String? get errorMessage;
/// Create a copy of SchedulesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchedulesStateCopyWith<SchedulesState> get copyWith => _$SchedulesStateCopyWithImpl<SchedulesState>(this as SchedulesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchedulesState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.schedules, schedules)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(schedules),errorMessage);

@override
String toString() {
  return 'SchedulesState(status: $status, schedules: $schedules, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $SchedulesStateCopyWith<$Res>  {
  factory $SchedulesStateCopyWith(SchedulesState value, $Res Function(SchedulesState) _then) = _$SchedulesStateCopyWithImpl;
@useResult
$Res call({
 SchedulesStatus status, List<AutoScheduleEntity> schedules, String? errorMessage
});




}
/// @nodoc
class _$SchedulesStateCopyWithImpl<$Res>
    implements $SchedulesStateCopyWith<$Res> {
  _$SchedulesStateCopyWithImpl(this._self, this._then);

  final SchedulesState _self;
  final $Res Function(SchedulesState) _then;

/// Create a copy of SchedulesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? schedules = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SchedulesStatus,schedules: null == schedules ? _self.schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<AutoScheduleEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SchedulesState].
extension SchedulesStatePatterns on SchedulesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchedulesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchedulesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchedulesState value)  $default,){
final _that = this;
switch (_that) {
case _SchedulesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchedulesState value)?  $default,){
final _that = this;
switch (_that) {
case _SchedulesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SchedulesStatus status,  List<AutoScheduleEntity> schedules,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchedulesState() when $default != null:
return $default(_that.status,_that.schedules,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SchedulesStatus status,  List<AutoScheduleEntity> schedules,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SchedulesState():
return $default(_that.status,_that.schedules,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SchedulesStatus status,  List<AutoScheduleEntity> schedules,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SchedulesState() when $default != null:
return $default(_that.status,_that.schedules,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SchedulesState implements SchedulesState {
  const _SchedulesState({this.status = SchedulesStatus.initial, final  List<AutoScheduleEntity> schedules = const <AutoScheduleEntity>[], this.errorMessage}): _schedules = schedules;
  

@override@JsonKey() final  SchedulesStatus status;
 final  List<AutoScheduleEntity> _schedules;
@override@JsonKey() List<AutoScheduleEntity> get schedules {
  if (_schedules is EqualUnmodifiableListView) return _schedules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schedules);
}

@override final  String? errorMessage;

/// Create a copy of SchedulesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchedulesStateCopyWith<_SchedulesState> get copyWith => __$SchedulesStateCopyWithImpl<_SchedulesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchedulesState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._schedules, _schedules)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_schedules),errorMessage);

@override
String toString() {
  return 'SchedulesState(status: $status, schedules: $schedules, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SchedulesStateCopyWith<$Res> implements $SchedulesStateCopyWith<$Res> {
  factory _$SchedulesStateCopyWith(_SchedulesState value, $Res Function(_SchedulesState) _then) = __$SchedulesStateCopyWithImpl;
@override @useResult
$Res call({
 SchedulesStatus status, List<AutoScheduleEntity> schedules, String? errorMessage
});




}
/// @nodoc
class __$SchedulesStateCopyWithImpl<$Res>
    implements _$SchedulesStateCopyWith<$Res> {
  __$SchedulesStateCopyWithImpl(this._self, this._then);

  final _SchedulesState _self;
  final $Res Function(_SchedulesState) _then;

/// Create a copy of SchedulesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? schedules = null,Object? errorMessage = freezed,}) {
  return _then(_SchedulesState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SchedulesStatus,schedules: null == schedules ? _self._schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<AutoScheduleEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
