// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detected_transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DetectedTransactionModel {

 String get id; String? get walletId; String? get walletName; String? get sourcePackage; double get amount; String get type; String? get merchant; DateTime get detectedAt;
/// Create a copy of DetectedTransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetectedTransactionModelCopyWith<DetectedTransactionModel> get copyWith => _$DetectedTransactionModelCopyWithImpl<DetectedTransactionModel>(this as DetectedTransactionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetectedTransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.walletName, walletName) || other.walletName == walletName)&&(identical(other.sourcePackage, sourcePackage) || other.sourcePackage == sourcePackage)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,walletId,walletName,sourcePackage,amount,type,merchant,detectedAt);

@override
String toString() {
  return 'DetectedTransactionModel(id: $id, walletId: $walletId, walletName: $walletName, sourcePackage: $sourcePackage, amount: $amount, type: $type, merchant: $merchant, detectedAt: $detectedAt)';
}


}

/// @nodoc
abstract mixin class $DetectedTransactionModelCopyWith<$Res>  {
  factory $DetectedTransactionModelCopyWith(DetectedTransactionModel value, $Res Function(DetectedTransactionModel) _then) = _$DetectedTransactionModelCopyWithImpl;
@useResult
$Res call({
 String id, String? walletId, String? walletName, String? sourcePackage, double amount, String type, String? merchant, DateTime detectedAt
});




}
/// @nodoc
class _$DetectedTransactionModelCopyWithImpl<$Res>
    implements $DetectedTransactionModelCopyWith<$Res> {
  _$DetectedTransactionModelCopyWithImpl(this._self, this._then);

  final DetectedTransactionModel _self;
  final $Res Function(DetectedTransactionModel) _then;

/// Create a copy of DetectedTransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? walletId = freezed,Object? walletName = freezed,Object? sourcePackage = freezed,Object? amount = null,Object? type = null,Object? merchant = freezed,Object? detectedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,walletName: freezed == walletName ? _self.walletName : walletName // ignore: cast_nullable_to_non_nullable
as String?,sourcePackage: freezed == sourcePackage ? _self.sourcePackage : sourcePackage // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DetectedTransactionModel].
extension DetectedTransactionModelPatterns on DetectedTransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetectedTransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetectedTransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetectedTransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _DetectedTransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetectedTransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _DetectedTransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? walletId,  String? walletName,  String? sourcePackage,  double amount,  String type,  String? merchant,  DateTime detectedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetectedTransactionModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? walletId,  String? walletName,  String? sourcePackage,  double amount,  String type,  String? merchant,  DateTime detectedAt)  $default,) {final _that = this;
switch (_that) {
case _DetectedTransactionModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? walletId,  String? walletName,  String? sourcePackage,  double amount,  String type,  String? merchant,  DateTime detectedAt)?  $default,) {final _that = this;
switch (_that) {
case _DetectedTransactionModel() when $default != null:
return $default(_that.id,_that.walletId,_that.walletName,_that.sourcePackage,_that.amount,_that.type,_that.merchant,_that.detectedAt);case _:
  return null;

}
}

}

/// @nodoc


class _DetectedTransactionModel extends DetectedTransactionModel {
  const _DetectedTransactionModel({required this.id, this.walletId, this.walletName, this.sourcePackage, required this.amount, required this.type, this.merchant, required this.detectedAt}): super._();
  

@override final  String id;
@override final  String? walletId;
@override final  String? walletName;
@override final  String? sourcePackage;
@override final  double amount;
@override final  String type;
@override final  String? merchant;
@override final  DateTime detectedAt;

/// Create a copy of DetectedTransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetectedTransactionModelCopyWith<_DetectedTransactionModel> get copyWith => __$DetectedTransactionModelCopyWithImpl<_DetectedTransactionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetectedTransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.walletName, walletName) || other.walletName == walletName)&&(identical(other.sourcePackage, sourcePackage) || other.sourcePackage == sourcePackage)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,walletId,walletName,sourcePackage,amount,type,merchant,detectedAt);

@override
String toString() {
  return 'DetectedTransactionModel(id: $id, walletId: $walletId, walletName: $walletName, sourcePackage: $sourcePackage, amount: $amount, type: $type, merchant: $merchant, detectedAt: $detectedAt)';
}


}

/// @nodoc
abstract mixin class _$DetectedTransactionModelCopyWith<$Res> implements $DetectedTransactionModelCopyWith<$Res> {
  factory _$DetectedTransactionModelCopyWith(_DetectedTransactionModel value, $Res Function(_DetectedTransactionModel) _then) = __$DetectedTransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? walletId, String? walletName, String? sourcePackage, double amount, String type, String? merchant, DateTime detectedAt
});




}
/// @nodoc
class __$DetectedTransactionModelCopyWithImpl<$Res>
    implements _$DetectedTransactionModelCopyWith<$Res> {
  __$DetectedTransactionModelCopyWithImpl(this._self, this._then);

  final _DetectedTransactionModel _self;
  final $Res Function(_DetectedTransactionModel) _then;

/// Create a copy of DetectedTransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? walletId = freezed,Object? walletName = freezed,Object? sourcePackage = freezed,Object? amount = null,Object? type = null,Object? merchant = freezed,Object? detectedAt = null,}) {
  return _then(_DetectedTransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,walletName: freezed == walletName ? _self.walletName : walletName // ignore: cast_nullable_to_non_nullable
as String?,sourcePackage: freezed == sourcePackage ? _self.sourcePackage : sourcePackage // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
