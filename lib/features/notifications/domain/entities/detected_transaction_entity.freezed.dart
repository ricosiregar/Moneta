// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detected_transaction_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DetectedTransactionEntity {

 String get id; String? get walletId; String? get walletName; String? get sourcePackage; double get amount; DetectedType get type; String? get merchant; DateTime get detectedAt;
/// Create a copy of DetectedTransactionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetectedTransactionEntityCopyWith<DetectedTransactionEntity> get copyWith => _$DetectedTransactionEntityCopyWithImpl<DetectedTransactionEntity>(this as DetectedTransactionEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetectedTransactionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.walletName, walletName) || other.walletName == walletName)&&(identical(other.sourcePackage, sourcePackage) || other.sourcePackage == sourcePackage)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,walletId,walletName,sourcePackage,amount,type,merchant,detectedAt);

@override
String toString() {
  return 'DetectedTransactionEntity(id: $id, walletId: $walletId, walletName: $walletName, sourcePackage: $sourcePackage, amount: $amount, type: $type, merchant: $merchant, detectedAt: $detectedAt)';
}


}

/// @nodoc
abstract mixin class $DetectedTransactionEntityCopyWith<$Res>  {
  factory $DetectedTransactionEntityCopyWith(DetectedTransactionEntity value, $Res Function(DetectedTransactionEntity) _then) = _$DetectedTransactionEntityCopyWithImpl;
@useResult
$Res call({
 String id, String? walletId, String? walletName, String? sourcePackage, double amount, DetectedType type, String? merchant, DateTime detectedAt
});




}
/// @nodoc
class _$DetectedTransactionEntityCopyWithImpl<$Res>
    implements $DetectedTransactionEntityCopyWith<$Res> {
  _$DetectedTransactionEntityCopyWithImpl(this._self, this._then);

  final DetectedTransactionEntity _self;
  final $Res Function(DetectedTransactionEntity) _then;

/// Create a copy of DetectedTransactionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? walletId = freezed,Object? walletName = freezed,Object? sourcePackage = freezed,Object? amount = null,Object? type = null,Object? merchant = freezed,Object? detectedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,walletName: freezed == walletName ? _self.walletName : walletName // ignore: cast_nullable_to_non_nullable
as String?,sourcePackage: freezed == sourcePackage ? _self.sourcePackage : sourcePackage // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DetectedType,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DetectedTransactionEntity].
extension DetectedTransactionEntityPatterns on DetectedTransactionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetectedTransactionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetectedTransactionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetectedTransactionEntity value)  $default,){
final _that = this;
switch (_that) {
case _DetectedTransactionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetectedTransactionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DetectedTransactionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? walletId,  String? walletName,  String? sourcePackage,  double amount,  DetectedType type,  String? merchant,  DateTime detectedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetectedTransactionEntity() when $default != null:
return $default(_that.id,_that.walletId,_that.walletName,_that.sourcePackage,_that.amount,_that.type,_that.merchant,_that.detectedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? walletId,  String? walletName,  String? sourcePackage,  double amount,  DetectedType type,  String? merchant,  DateTime detectedAt)  $default,) {final _that = this;
switch (_that) {
case _DetectedTransactionEntity():
return $default(_that.id,_that.walletId,_that.walletName,_that.sourcePackage,_that.amount,_that.type,_that.merchant,_that.detectedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? walletId,  String? walletName,  String? sourcePackage,  double amount,  DetectedType type,  String? merchant,  DateTime detectedAt)?  $default,) {final _that = this;
switch (_that) {
case _DetectedTransactionEntity() when $default != null:
return $default(_that.id,_that.walletId,_that.walletName,_that.sourcePackage,_that.amount,_that.type,_that.merchant,_that.detectedAt);case _:
  return null;

}
}

}

/// @nodoc


class _DetectedTransactionEntity implements DetectedTransactionEntity {
  const _DetectedTransactionEntity({required this.id, this.walletId, this.walletName, this.sourcePackage, required this.amount, required this.type, this.merchant, required this.detectedAt});
  

@override final  String id;
@override final  String? walletId;
@override final  String? walletName;
@override final  String? sourcePackage;
@override final  double amount;
@override final  DetectedType type;
@override final  String? merchant;
@override final  DateTime detectedAt;

/// Create a copy of DetectedTransactionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetectedTransactionEntityCopyWith<_DetectedTransactionEntity> get copyWith => __$DetectedTransactionEntityCopyWithImpl<_DetectedTransactionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetectedTransactionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.walletName, walletName) || other.walletName == walletName)&&(identical(other.sourcePackage, sourcePackage) || other.sourcePackage == sourcePackage)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,walletId,walletName,sourcePackage,amount,type,merchant,detectedAt);

@override
String toString() {
  return 'DetectedTransactionEntity(id: $id, walletId: $walletId, walletName: $walletName, sourcePackage: $sourcePackage, amount: $amount, type: $type, merchant: $merchant, detectedAt: $detectedAt)';
}


}

/// @nodoc
abstract mixin class _$DetectedTransactionEntityCopyWith<$Res> implements $DetectedTransactionEntityCopyWith<$Res> {
  factory _$DetectedTransactionEntityCopyWith(_DetectedTransactionEntity value, $Res Function(_DetectedTransactionEntity) _then) = __$DetectedTransactionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String? walletId, String? walletName, String? sourcePackage, double amount, DetectedType type, String? merchant, DateTime detectedAt
});




}
/// @nodoc
class __$DetectedTransactionEntityCopyWithImpl<$Res>
    implements _$DetectedTransactionEntityCopyWith<$Res> {
  __$DetectedTransactionEntityCopyWithImpl(this._self, this._then);

  final _DetectedTransactionEntity _self;
  final $Res Function(_DetectedTransactionEntity) _then;

/// Create a copy of DetectedTransactionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? walletId = freezed,Object? walletName = freezed,Object? sourcePackage = freezed,Object? amount = null,Object? type = null,Object? merchant = freezed,Object? detectedAt = null,}) {
  return _then(_DetectedTransactionEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,walletName: freezed == walletName ? _self.walletName : walletName // ignore: cast_nullable_to_non_nullable
as String?,sourcePackage: freezed == sourcePackage ? _self.sourcePackage : sourcePackage // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DetectedType,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
