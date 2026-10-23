// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allocation_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AllocationEntity {

 String get id; String get targetWalletId; double? get percent; double? get fixedAmount;
/// Create a copy of AllocationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllocationEntityCopyWith<AllocationEntity> get copyWith => _$AllocationEntityCopyWithImpl<AllocationEntity>(this as AllocationEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllocationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.targetWalletId, targetWalletId) || other.targetWalletId == targetWalletId)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.fixedAmount, fixedAmount) || other.fixedAmount == fixedAmount));
}


@override
int get hashCode => Object.hash(runtimeType,id,targetWalletId,percent,fixedAmount);

@override
String toString() {
  return 'AllocationEntity(id: $id, targetWalletId: $targetWalletId, percent: $percent, fixedAmount: $fixedAmount)';
}


}

/// @nodoc
abstract mixin class $AllocationEntityCopyWith<$Res>  {
  factory $AllocationEntityCopyWith(AllocationEntity value, $Res Function(AllocationEntity) _then) = _$AllocationEntityCopyWithImpl;
@useResult
$Res call({
 String id, String targetWalletId, double? percent, double? fixedAmount
});




}
/// @nodoc
class _$AllocationEntityCopyWithImpl<$Res>
    implements $AllocationEntityCopyWith<$Res> {
  _$AllocationEntityCopyWithImpl(this._self, this._then);

  final AllocationEntity _self;
  final $Res Function(AllocationEntity) _then;

/// Create a copy of AllocationEntity
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


/// Adds pattern-matching-related methods to [AllocationEntity].
extension AllocationEntityPatterns on AllocationEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllocationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllocationEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllocationEntity value)  $default,){
final _that = this;
switch (_that) {
case _AllocationEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllocationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AllocationEntity() when $default != null:
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
case _AllocationEntity() when $default != null:
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
case _AllocationEntity():
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
case _AllocationEntity() when $default != null:
return $default(_that.id,_that.targetWalletId,_that.percent,_that.fixedAmount);case _:
  return null;

}
}

}

/// @nodoc


class _AllocationEntity implements AllocationEntity {
  const _AllocationEntity({required this.id, required this.targetWalletId, this.percent, this.fixedAmount});
  

@override final  String id;
@override final  String targetWalletId;
@override final  double? percent;
@override final  double? fixedAmount;

/// Create a copy of AllocationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllocationEntityCopyWith<_AllocationEntity> get copyWith => __$AllocationEntityCopyWithImpl<_AllocationEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllocationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.targetWalletId, targetWalletId) || other.targetWalletId == targetWalletId)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.fixedAmount, fixedAmount) || other.fixedAmount == fixedAmount));
}


@override
int get hashCode => Object.hash(runtimeType,id,targetWalletId,percent,fixedAmount);

@override
String toString() {
  return 'AllocationEntity(id: $id, targetWalletId: $targetWalletId, percent: $percent, fixedAmount: $fixedAmount)';
}


}

/// @nodoc
abstract mixin class _$AllocationEntityCopyWith<$Res> implements $AllocationEntityCopyWith<$Res> {
  factory _$AllocationEntityCopyWith(_AllocationEntity value, $Res Function(_AllocationEntity) _then) = __$AllocationEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String targetWalletId, double? percent, double? fixedAmount
});




}
/// @nodoc
class __$AllocationEntityCopyWithImpl<$Res>
    implements _$AllocationEntityCopyWith<$Res> {
  __$AllocationEntityCopyWithImpl(this._self, this._then);

  final _AllocationEntity _self;
  final $Res Function(_AllocationEntity) _then;

/// Create a copy of AllocationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? targetWalletId = null,Object? percent = freezed,Object? fixedAmount = freezed,}) {
  return _then(_AllocationEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetWalletId: null == targetWalletId ? _self.targetWalletId : targetWalletId // ignore: cast_nullable_to_non_nullable
as String,percent: freezed == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double?,fixedAmount: freezed == fixedAmount ? _self.fixedAmount : fixedAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
