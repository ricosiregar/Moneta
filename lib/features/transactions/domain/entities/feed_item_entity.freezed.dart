// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_item_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedItemEntity {

 String get id; FeedKind get kind; String get title; String get category; String? get iconKey; String get wallet; double get amount; DateTime get date; String? get walletId; String? get toWalletId; String? get categoryId;
/// Create a copy of FeedItemEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedItemEntityCopyWith<FeedItemEntity> get copyWith => _$FeedItemEntityCopyWithImpl<FeedItemEntity>(this as FeedItemEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,title,category,iconKey,wallet,amount,date,walletId,toWalletId,categoryId);

@override
String toString() {
  return 'FeedItemEntity(id: $id, kind: $kind, title: $title, category: $category, iconKey: $iconKey, wallet: $wallet, amount: $amount, date: $date, walletId: $walletId, toWalletId: $toWalletId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $FeedItemEntityCopyWith<$Res>  {
  factory $FeedItemEntityCopyWith(FeedItemEntity value, $Res Function(FeedItemEntity) _then) = _$FeedItemEntityCopyWithImpl;
@useResult
$Res call({
 String id, FeedKind kind, String title, String category, String? iconKey, String wallet, double amount, DateTime date, String? walletId, String? toWalletId, String? categoryId
});




}
/// @nodoc
class _$FeedItemEntityCopyWithImpl<$Res>
    implements $FeedItemEntityCopyWith<$Res> {
  _$FeedItemEntityCopyWithImpl(this._self, this._then);

  final FeedItemEntity _self;
  final $Res Function(FeedItemEntity) _then;

/// Create a copy of FeedItemEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? title = null,Object? category = null,Object? iconKey = freezed,Object? wallet = null,Object? amount = null,Object? date = null,Object? walletId = freezed,Object? toWalletId = freezed,Object? categoryId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FeedKind,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,iconKey: freezed == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String?,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,toWalletId: freezed == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedItemEntity].
extension FeedItemEntityPatterns on FeedItemEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedItemEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedItemEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedItemEntity value)  $default,){
final _that = this;
switch (_that) {
case _FeedItemEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedItemEntity value)?  $default,){
final _that = this;
switch (_that) {
case _FeedItemEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  FeedKind kind,  String title,  String category,  String? iconKey,  String wallet,  double amount,  DateTime date,  String? walletId,  String? toWalletId,  String? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedItemEntity() when $default != null:
return $default(_that.id,_that.kind,_that.title,_that.category,_that.iconKey,_that.wallet,_that.amount,_that.date,_that.walletId,_that.toWalletId,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  FeedKind kind,  String title,  String category,  String? iconKey,  String wallet,  double amount,  DateTime date,  String? walletId,  String? toWalletId,  String? categoryId)  $default,) {final _that = this;
switch (_that) {
case _FeedItemEntity():
return $default(_that.id,_that.kind,_that.title,_that.category,_that.iconKey,_that.wallet,_that.amount,_that.date,_that.walletId,_that.toWalletId,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  FeedKind kind,  String title,  String category,  String? iconKey,  String wallet,  double amount,  DateTime date,  String? walletId,  String? toWalletId,  String? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _FeedItemEntity() when $default != null:
return $default(_that.id,_that.kind,_that.title,_that.category,_that.iconKey,_that.wallet,_that.amount,_that.date,_that.walletId,_that.toWalletId,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _FeedItemEntity extends FeedItemEntity {
  const _FeedItemEntity({required this.id, required this.kind, required this.title, required this.category, this.iconKey, required this.wallet, required this.amount, required this.date, this.walletId, this.toWalletId, this.categoryId}): super._();
  

@override final  String id;
@override final  FeedKind kind;
@override final  String title;
@override final  String category;
@override final  String? iconKey;
@override final  String wallet;
@override final  double amount;
@override final  DateTime date;
@override final  String? walletId;
@override final  String? toWalletId;
@override final  String? categoryId;

/// Create a copy of FeedItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemEntityCopyWith<_FeedItemEntity> get copyWith => __$FeedItemEntityCopyWithImpl<_FeedItemEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,title,category,iconKey,wallet,amount,date,walletId,toWalletId,categoryId);

@override
String toString() {
  return 'FeedItemEntity(id: $id, kind: $kind, title: $title, category: $category, iconKey: $iconKey, wallet: $wallet, amount: $amount, date: $date, walletId: $walletId, toWalletId: $toWalletId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$FeedItemEntityCopyWith<$Res> implements $FeedItemEntityCopyWith<$Res> {
  factory _$FeedItemEntityCopyWith(_FeedItemEntity value, $Res Function(_FeedItemEntity) _then) = __$FeedItemEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, FeedKind kind, String title, String category, String? iconKey, String wallet, double amount, DateTime date, String? walletId, String? toWalletId, String? categoryId
});




}
/// @nodoc
class __$FeedItemEntityCopyWithImpl<$Res>
    implements _$FeedItemEntityCopyWith<$Res> {
  __$FeedItemEntityCopyWithImpl(this._self, this._then);

  final _FeedItemEntity _self;
  final $Res Function(_FeedItemEntity) _then;

/// Create a copy of FeedItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? title = null,Object? category = null,Object? iconKey = freezed,Object? wallet = null,Object? amount = null,Object? date = null,Object? walletId = freezed,Object? toWalletId = freezed,Object? categoryId = freezed,}) {
  return _then(_FeedItemEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FeedKind,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,iconKey: freezed == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String?,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,toWalletId: freezed == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
