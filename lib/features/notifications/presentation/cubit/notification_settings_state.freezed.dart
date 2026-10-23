// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationSettingsState {

 bool get captureEnabled; List<NotificationSourceEntity> get sources; String? get errorMessage;
/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsStateCopyWith<NotificationSettingsState> get copyWith => _$NotificationSettingsStateCopyWithImpl<NotificationSettingsState>(this as NotificationSettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettingsState&&(identical(other.captureEnabled, captureEnabled) || other.captureEnabled == captureEnabled)&&const DeepCollectionEquality().equals(other.sources, sources)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,captureEnabled,const DeepCollectionEquality().hash(sources),errorMessage);

@override
String toString() {
  return 'NotificationSettingsState(captureEnabled: $captureEnabled, sources: $sources, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsStateCopyWith<$Res>  {
  factory $NotificationSettingsStateCopyWith(NotificationSettingsState value, $Res Function(NotificationSettingsState) _then) = _$NotificationSettingsStateCopyWithImpl;
@useResult
$Res call({
 bool captureEnabled, List<NotificationSourceEntity> sources, String? errorMessage
});




}
/// @nodoc
class _$NotificationSettingsStateCopyWithImpl<$Res>
    implements $NotificationSettingsStateCopyWith<$Res> {
  _$NotificationSettingsStateCopyWithImpl(this._self, this._then);

  final NotificationSettingsState _self;
  final $Res Function(NotificationSettingsState) _then;

/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? captureEnabled = null,Object? sources = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
captureEnabled: null == captureEnabled ? _self.captureEnabled : captureEnabled // ignore: cast_nullable_to_non_nullable
as bool,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<NotificationSourceEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettingsState].
extension NotificationSettingsStatePatterns on NotificationSettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettingsState value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool captureEnabled,  List<NotificationSourceEntity> sources,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
return $default(_that.captureEnabled,_that.sources,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool captureEnabled,  List<NotificationSourceEntity> sources,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsState():
return $default(_that.captureEnabled,_that.sources,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool captureEnabled,  List<NotificationSourceEntity> sources,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
return $default(_that.captureEnabled,_that.sources,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationSettingsState implements NotificationSettingsState {
  const _NotificationSettingsState({this.captureEnabled = false, final  List<NotificationSourceEntity> sources = const <NotificationSourceEntity>[], this.errorMessage}): _sources = sources;
  

@override@JsonKey() final  bool captureEnabled;
 final  List<NotificationSourceEntity> _sources;
@override@JsonKey() List<NotificationSourceEntity> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

@override final  String? errorMessage;

/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsStateCopyWith<_NotificationSettingsState> get copyWith => __$NotificationSettingsStateCopyWithImpl<_NotificationSettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettingsState&&(identical(other.captureEnabled, captureEnabled) || other.captureEnabled == captureEnabled)&&const DeepCollectionEquality().equals(other._sources, _sources)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,captureEnabled,const DeepCollectionEquality().hash(_sources),errorMessage);

@override
String toString() {
  return 'NotificationSettingsState(captureEnabled: $captureEnabled, sources: $sources, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsStateCopyWith<$Res> implements $NotificationSettingsStateCopyWith<$Res> {
  factory _$NotificationSettingsStateCopyWith(_NotificationSettingsState value, $Res Function(_NotificationSettingsState) _then) = __$NotificationSettingsStateCopyWithImpl;
@override @useResult
$Res call({
 bool captureEnabled, List<NotificationSourceEntity> sources, String? errorMessage
});




}
/// @nodoc
class __$NotificationSettingsStateCopyWithImpl<$Res>
    implements _$NotificationSettingsStateCopyWith<$Res> {
  __$NotificationSettingsStateCopyWithImpl(this._self, this._then);

  final _NotificationSettingsState _self;
  final $Res Function(_NotificationSettingsState) _then;

/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? captureEnabled = null,Object? sources = null,Object? errorMessage = freezed,}) {
  return _then(_NotificationSettingsState(
captureEnabled: null == captureEnabled ? _self.captureEnabled : captureEnabled // ignore: cast_nullable_to_non_nullable
as bool,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<NotificationSourceEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
