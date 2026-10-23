// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletEntity {

 String get id; String get name;/// cash | bank | e_wallet
 String get type; String? get parentId; String? get purpose; bool get isIncomeSource; double get openingBalance; double get balance;
/// Create a copy of WalletEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletEntityCopyWith<WalletEntity> get copyWith => _$WalletEntityCopyWithImpl<WalletEntity>(this as WalletEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.isIncomeSource, isIncomeSource) || other.isIncomeSource == isIncomeSource)&&(identical(other.openingBalance, openingBalance) || other.openingBalance == openingBalance)&&(identical(other.balance, balance) || other.balance == balance));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,parentId,purpose,isIncomeSource,openingBalance,balance);

@override
String toString() {
  return 'WalletEntity(id: $id, name: $name, type: $type, parentId: $parentId, purpose: $purpose, isIncomeSource: $isIncomeSource, openingBalance: $openingBalance, balance: $balance)';
}


}

/// @nodoc
abstract mixin class $WalletEntityCopyWith<$Res>  {
  factory $WalletEntityCopyWith(WalletEntity value, $Res Function(WalletEntity) _then) = _$WalletEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, String? parentId, String? purpose, bool isIncomeSource, double openingBalance, double balance
});




}
/// @nodoc
class _$WalletEntityCopyWithImpl<$Res>
    implements $WalletEntityCopyWith<$Res> {
  _$WalletEntityCopyWithImpl(this._self, this._then);

  final WalletEntity _self;
  final $Res Function(WalletEntity) _then;

/// Create a copy of WalletEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? parentId = freezed,Object? purpose = freezed,Object? isIncomeSource = null,Object? openingBalance = null,Object? balance = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,isIncomeSource: null == isIncomeSource ? _self.isIncomeSource : isIncomeSource // ignore: cast_nullable_to_non_nullable
as bool,openingBalance: null == openingBalance ? _self.openingBalance : openingBalance // ignore: cast_nullable_to_non_nullable
as double,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletEntity].
extension WalletEntityPatterns on WalletEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletEntity value)  $default,){
final _that = this;
switch (_that) {
case _WalletEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletEntity value)?  $default,){
final _that = this;
switch (_that) {
case _WalletEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  String? parentId,  String? purpose,  bool isIncomeSource,  double openingBalance,  double balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletEntity() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.parentId,_that.purpose,_that.isIncomeSource,_that.openingBalance,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  String? parentId,  String? purpose,  bool isIncomeSource,  double openingBalance,  double balance)  $default,) {final _that = this;
switch (_that) {
case _WalletEntity():
return $default(_that.id,_that.name,_that.type,_that.parentId,_that.purpose,_that.isIncomeSource,_that.openingBalance,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  String? parentId,  String? purpose,  bool isIncomeSource,  double openingBalance,  double balance)?  $default,) {final _that = this;
switch (_that) {
case _WalletEntity() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.parentId,_that.purpose,_that.isIncomeSource,_that.openingBalance,_that.balance);case _:
  return null;

}
}

}

/// @nodoc


class _WalletEntity implements WalletEntity {
  const _WalletEntity({required this.id, required this.name, required this.type, this.parentId, this.purpose, required this.isIncomeSource, required this.openingBalance, required this.balance});
  

@override final  String id;
@override final  String name;
/// cash | bank | e_wallet
@override final  String type;
@override final  String? parentId;
@override final  String? purpose;
@override final  bool isIncomeSource;
@override final  double openingBalance;
@override final  double balance;

/// Create a copy of WalletEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletEntityCopyWith<_WalletEntity> get copyWith => __$WalletEntityCopyWithImpl<_WalletEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.isIncomeSource, isIncomeSource) || other.isIncomeSource == isIncomeSource)&&(identical(other.openingBalance, openingBalance) || other.openingBalance == openingBalance)&&(identical(other.balance, balance) || other.balance == balance));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,parentId,purpose,isIncomeSource,openingBalance,balance);

@override
String toString() {
  return 'WalletEntity(id: $id, name: $name, type: $type, parentId: $parentId, purpose: $purpose, isIncomeSource: $isIncomeSource, openingBalance: $openingBalance, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$WalletEntityCopyWith<$Res> implements $WalletEntityCopyWith<$Res> {
  factory _$WalletEntityCopyWith(_WalletEntity value, $Res Function(_WalletEntity) _then) = __$WalletEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, String? parentId, String? purpose, bool isIncomeSource, double openingBalance, double balance
});




}
/// @nodoc
class __$WalletEntityCopyWithImpl<$Res>
    implements _$WalletEntityCopyWith<$Res> {
  __$WalletEntityCopyWithImpl(this._self, this._then);

  final _WalletEntity _self;
  final $Res Function(_WalletEntity) _then;

/// Create a copy of WalletEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? parentId = freezed,Object? purpose = freezed,Object? isIncomeSource = null,Object? openingBalance = null,Object? balance = null,}) {
  return _then(_WalletEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,isIncomeSource: null == isIncomeSource ? _self.isIncomeSource : isIncomeSource // ignore: cast_nullable_to_non_nullable
as bool,openingBalance: null == openingBalance ? _self.openingBalance : openingBalance // ignore: cast_nullable_to_non_nullable
as double,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
