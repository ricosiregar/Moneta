// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allocation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AllocationModel {

 String get id; String get targetWalletId; double? get percent; double? get fixedAmount;
/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllocationModelCopyWith<AllocationModel> get copyWith => _$AllocationModelCopyWithImpl<AllocationModel>(this as AllocationModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllocationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.targetWalletId, targetWalletId) || other.targetWalletId == targetWalletId)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.fixedAmount, fixedAmount) || other.fixedAmount == fixedAmount));
}


@override
int get hashCode => Object.hash(runtimeType,id,targetWalletId,percent,fixedAmount);

@override
String toString() {
  return 'AllocationModel(id: $id, targetWalletId: $targetWalletId, percent: $percent, fixedAmount: $fixedAmount)';
}


}

/// @nodoc
abstract mixin class $AllocationModelCopyWith<$Res>  {
  factory $AllocationModelCopyWith(AllocationModel value, $Res Function(AllocationModel) _then) = _$AllocationModelCopyWithImpl;
@useResult
$Res call({
 String id, String targetWalletId, double? percent, double? fixedAmount
});




}
/// @nodoc
class _$AllocationModelCopyWithImpl<$Res>
    implements $AllocationModelCopyWith<$Res> {
  _$AllocationModelCopyWithImpl(this._self, this._then);

  final AllocationModel _self;
  final $Res Function(AllocationModel) _then;

/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? targetWalletId = null,Object? percent = freezed,Object? fixedAmount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetWalletId: null == targetWalletId ? _self.targetWalletId : targetWalletId // ignore: cast_nullable_to_non_nullable
as String,percent: freezed == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double?,fixedAmount: freezed == fixedAmount ? _self.fixedAmount : fixedAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AllocationModel].
extension AllocationModelPatterns on AllocationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllocationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllocationModel value)  $default,){
final _that = this;
switch (_that) {
case _AllocationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllocationModel value)?  $default,){
final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String targetWalletId,  double? percent,  double? fixedAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
return $default(_that.id,_that.targetWalletId,_that.percent,_that.fixedAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String targetWalletId,  double? percent,  double? fixedAmount)  $default,) {final _that = this;
switch (_that) {
case _AllocationModel():
return $default(_that.id,_that.targetWalletId,_that.percent,_that.fixedAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String targetWalletId,  double? percent,  double? fixedAmount)?  $default,) {final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
return $default(_that.id,_that.targetWalletId,_that.percent,_that.fixedAmount);case _:
  return null;

}
}

}

/// @nodoc


class _AllocationModel extends AllocationModel {
  const _AllocationModel({required this.id, required this.targetWalletId, this.percent, this.fixedAmount}): super._();
  

@override final  String id;
@override final  String targetWalletId;
@override final  double? percent;
@override final  double? fixedAmount;

/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllocationModelCopyWith<_AllocationModel> get copyWith => __$AllocationModelCopyWithImpl<_AllocationModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllocationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.targetWalletId, targetWalletId) || other.targetWalletId == targetWalletId)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.fixedAmount, fixedAmount) || other.fixedAmount == fixedAmount));
}


@override
int get hashCode => Object.hash(runtimeType,id,targetWalletId,percent,fixedAmount);

@override
String toString() {
  return 'AllocationModel(id: $id, targetWalletId: $targetWalletId, percent: $percent, fixedAmount: $fixedAmount)';
}


}

/// @nodoc
abstract mixin class _$AllocationModelCopyWith<$Res> implements $AllocationModelCopyWith<$Res> {
  factory _$AllocationModelCopyWith(_AllocationModel value, $Res Function(_AllocationModel) _then) = __$AllocationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String targetWalletId, double? percent, double? fixedAmount
});




}
/// @nodoc
class __$AllocationModelCopyWithImpl<$Res>
    implements _$AllocationModelCopyWith<$Res> {
  __$AllocationModelCopyWithImpl(this._self, this._then);

  final _AllocationModel _self;
  final $Res Function(_AllocationModel) _then;

/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? targetWalletId = null,Object? percent = freezed,Object? fixedAmount = freezed,}) {
  return _then(_AllocationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetWalletId: null == targetWalletId ? _self.targetWalletId : targetWalletId // ignore: cast_nullable_to_non_nullable
as String,percent: freezed == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double?,fixedAmount: freezed == fixedAmount ? _self.fixedAmount : fixedAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
