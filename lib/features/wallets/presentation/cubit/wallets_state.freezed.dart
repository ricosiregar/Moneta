// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallets_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletsState {

 WalletsStatus get status; List<WalletEntity> get wallets; String? get errorMessage;
/// Create a copy of WalletsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletsStateCopyWith<WalletsState> get copyWith => _$WalletsStateCopyWithImpl<WalletsState>(this as WalletsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.wallets, wallets)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(wallets),errorMessage);

@override
String toString() {
  return 'WalletsState(status: $status, wallets: $wallets, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $WalletsStateCopyWith<$Res>  {
  factory $WalletsStateCopyWith(WalletsState value, $Res Function(WalletsState) _then) = _$WalletsStateCopyWithImpl;
@useResult
$Res call({
 WalletsStatus status, List<WalletEntity> wallets, String? errorMessage
});




}
/// @nodoc
class _$WalletsStateCopyWithImpl<$Res>
    implements $WalletsStateCopyWith<$Res> {
  _$WalletsStateCopyWithImpl(this._self, this._then);

  final WalletsState _self;
  final $Res Function(WalletsState) _then;

/// Create a copy of WalletsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? wallets = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WalletsStatus,wallets: null == wallets ? _self.wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<WalletEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletsState].
extension WalletsStatePatterns on WalletsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletsState value)  $default,){
final _that = this;
switch (_that) {
case _WalletsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletsState value)?  $default,){
final _that = this;
switch (_that) {
case _WalletsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WalletsStatus status,  List<WalletEntity> wallets,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletsState() when $default != null:
return $default(_that.status,_that.wallets,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WalletsStatus status,  List<WalletEntity> wallets,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _WalletsState():
return $default(_that.status,_that.wallets,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WalletsStatus status,  List<WalletEntity> wallets,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _WalletsState() when $default != null:
return $default(_that.status,_that.wallets,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _WalletsState implements WalletsState {
  const _WalletsState({this.status = WalletsStatus.initial, final  List<WalletEntity> wallets = const <WalletEntity>[], this.errorMessage}): _wallets = wallets;
  

@override@JsonKey() final  WalletsStatus status;
 final  List<WalletEntity> _wallets;
@override@JsonKey() List<WalletEntity> get wallets {
  if (_wallets is EqualUnmodifiableListView) return _wallets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wallets);
}

@override final  String? errorMessage;

/// Create a copy of WalletsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletsStateCopyWith<_WalletsState> get copyWith => __$WalletsStateCopyWithImpl<_WalletsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._wallets, _wallets)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_wallets),errorMessage);

@override
String toString() {
  return 'WalletsState(status: $status, wallets: $wallets, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$WalletsStateCopyWith<$Res> implements $WalletsStateCopyWith<$Res> {
  factory _$WalletsStateCopyWith(_WalletsState value, $Res Function(_WalletsState) _then) = __$WalletsStateCopyWithImpl;
@override @useResult
$Res call({
 WalletsStatus status, List<WalletEntity> wallets, String? errorMessage
});




}
/// @nodoc
class __$WalletsStateCopyWithImpl<$Res>
    implements _$WalletsStateCopyWith<$Res> {
  __$WalletsStateCopyWithImpl(this._self, this._then);

  final _WalletsState _self;
  final $Res Function(_WalletsState) _then;

/// Create a copy of WalletsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? wallets = null,Object? errorMessage = freezed,}) {
  return _then(_WalletsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WalletsStatus,wallets: null == wallets ? _self._wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<WalletEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
