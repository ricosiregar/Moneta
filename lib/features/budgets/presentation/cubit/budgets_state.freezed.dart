// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budgets_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetsState {

 BudgetsStatus get status; List<BudgetEntity> get budgets; String? get errorMessage;
/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetsStateCopyWith<BudgetsState> get copyWith => _$BudgetsStateCopyWithImpl<BudgetsState>(this as BudgetsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.budgets, budgets)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(budgets),errorMessage);

@override
String toString() {
  return 'BudgetsState(status: $status, budgets: $budgets, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $BudgetsStateCopyWith<$Res>  {
  factory $BudgetsStateCopyWith(BudgetsState value, $Res Function(BudgetsState) _then) = _$BudgetsStateCopyWithImpl;
@useResult
$Res call({
 BudgetsStatus status, List<BudgetEntity> budgets, String? errorMessage
});




}
/// @nodoc
class _$BudgetsStateCopyWithImpl<$Res>
    implements $BudgetsStateCopyWith<$Res> {
  _$BudgetsStateCopyWithImpl(this._self, this._then);

  final BudgetsState _self;
  final $Res Function(BudgetsState) _then;

/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? budgets = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetsStatus,budgets: null == budgets ? _self.budgets : budgets // ignore: cast_nullable_to_non_nullable
as List<BudgetEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetsState].
extension BudgetsStatePatterns on BudgetsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetsState value)  $default,){
final _that = this;
switch (_that) {
case _BudgetsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetsState value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BudgetsStatus status,  List<BudgetEntity> budgets,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
return $default(_that.status,_that.budgets,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BudgetsStatus status,  List<BudgetEntity> budgets,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _BudgetsState():
return $default(_that.status,_that.budgets,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BudgetsStatus status,  List<BudgetEntity> budgets,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
return $default(_that.status,_that.budgets,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetsState implements BudgetsState {
  const _BudgetsState({this.status = BudgetsStatus.initial, final  List<BudgetEntity> budgets = const <BudgetEntity>[], this.errorMessage}): _budgets = budgets;
  

@override@JsonKey() final  BudgetsStatus status;
 final  List<BudgetEntity> _budgets;
@override@JsonKey() List<BudgetEntity> get budgets {
  if (_budgets is EqualUnmodifiableListView) return _budgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_budgets);
}

@override final  String? errorMessage;

/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetsStateCopyWith<_BudgetsState> get copyWith => __$BudgetsStateCopyWithImpl<_BudgetsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._budgets, _budgets)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_budgets),errorMessage);

@override
String toString() {
  return 'BudgetsState(status: $status, budgets: $budgets, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$BudgetsStateCopyWith<$Res> implements $BudgetsStateCopyWith<$Res> {
  factory _$BudgetsStateCopyWith(_BudgetsState value, $Res Function(_BudgetsState) _then) = __$BudgetsStateCopyWithImpl;
@override @useResult
$Res call({
 BudgetsStatus status, List<BudgetEntity> budgets, String? errorMessage
});




}
/// @nodoc
class __$BudgetsStateCopyWithImpl<$Res>
    implements _$BudgetsStateCopyWith<$Res> {
  __$BudgetsStateCopyWithImpl(this._self, this._then);

  final _BudgetsState _self;
  final $Res Function(_BudgetsState) _then;

/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? budgets = null,Object? errorMessage = freezed,}) {
  return _then(_BudgetsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetsStatus,budgets: null == budgets ? _self._budgets : budgets // ignore: cast_nullable_to_non_nullable
as List<BudgetEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
