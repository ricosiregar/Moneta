// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_schedule_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AutoScheduleEntity {

 String get id; String get title; String get kind;// 'expense' | 'transfer'
 double get amount; int get dayOfMonth;// 1..31
 String get walletId; String get walletName; String? get toWalletId; String? get toWalletName; String? get categoryId; String? get categoryName; String? get categoryIcon; String? get budgetId; String? get note; bool get isEnabled; String? get lastExecutedPeriod;// 'YYYY-MM' atau 'SKIP:YYYY-MM'
 DateTime? get lastExecutedAt;
/// Create a copy of AutoScheduleEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoScheduleEntityCopyWith<AutoScheduleEntity> get copyWith => _$AutoScheduleEntityCopyWithImpl<AutoScheduleEntity>(this as AutoScheduleEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoScheduleEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.walletName, walletName) || other.walletName == walletName)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.toWalletName, toWalletName) || other.toWalletName == toWalletName)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIcon, categoryIcon) || other.categoryIcon == categoryIcon)&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId)&&(identical(other.note, note) || other.note == note)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.lastExecutedPeriod, lastExecutedPeriod) || other.lastExecutedPeriod == lastExecutedPeriod)&&(identical(other.lastExecutedAt, lastExecutedAt) || other.lastExecutedAt == lastExecutedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,kind,amount,dayOfMonth,walletId,walletName,toWalletId,toWalletName,categoryId,categoryName,categoryIcon,budgetId,note,isEnabled,lastExecutedPeriod,lastExecutedAt);

@override
String toString() {
  return 'AutoScheduleEntity(id: $id, title: $title, kind: $kind, amount: $amount, dayOfMonth: $dayOfMonth, walletId: $walletId, walletName: $walletName, toWalletId: $toWalletId, toWalletName: $toWalletName, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, budgetId: $budgetId, note: $note, isEnabled: $isEnabled, lastExecutedPeriod: $lastExecutedPeriod, lastExecutedAt: $lastExecutedAt)';
}


}

/// @nodoc
abstract mixin class $AutoScheduleEntityCopyWith<$Res>  {
  factory $AutoScheduleEntityCopyWith(AutoScheduleEntity value, $Res Function(AutoScheduleEntity) _then) = _$AutoScheduleEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String kind, double amount, int dayOfMonth, String walletId, String walletName, String? toWalletId, String? toWalletName, String? categoryId, String? categoryName, String? categoryIcon, String? budgetId, String? note, bool isEnabled, String? lastExecutedPeriod, DateTime? lastExecutedAt
});




}
/// @nodoc
class _$AutoScheduleEntityCopyWithImpl<$Res>
    implements $AutoScheduleEntityCopyWith<$Res> {
  _$AutoScheduleEntityCopyWithImpl(this._self, this._then);

  final AutoScheduleEntity _self;
  final $Res Function(AutoScheduleEntity) _then;

/// Create a copy of AutoScheduleEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? kind = null,Object? amount = null,Object? dayOfMonth = null,Object? walletId = null,Object? walletName = null,Object? toWalletId = freezed,Object? toWalletName = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? categoryIcon = freezed,Object? budgetId = freezed,Object? note = freezed,Object? isEnabled = null,Object? lastExecutedPeriod = freezed,Object? lastExecutedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,walletName: null == walletName ? _self.walletName : walletName // ignore: cast_nullable_to_non_nullable
as String,toWalletId: freezed == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as String?,toWalletName: freezed == toWalletName ? _self.toWalletName : toWalletName // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,categoryIcon: freezed == categoryIcon ? _self.categoryIcon : categoryIcon // ignore: cast_nullable_to_non_nullable
as String?,budgetId: freezed == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,lastExecutedPeriod: freezed == lastExecutedPeriod ? _self.lastExecutedPeriod : lastExecutedPeriod // ignore: cast_nullable_to_non_nullable
as String?,lastExecutedAt: freezed == lastExecutedAt ? _self.lastExecutedAt : lastExecutedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoScheduleEntity].
extension AutoScheduleEntityPatterns on AutoScheduleEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutoScheduleEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutoScheduleEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutoScheduleEntity value)  $default,){
final _that = this;
switch (_that) {
case _AutoScheduleEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutoScheduleEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AutoScheduleEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String kind,  double amount,  int dayOfMonth,  String walletId,  String walletName,  String? toWalletId,  String? toWalletName,  String? categoryId,  String? categoryName,  String? categoryIcon,  String? budgetId,  String? note,  bool isEnabled,  String? lastExecutedPeriod,  DateTime? lastExecutedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutoScheduleEntity() when $default != null:
return $default(_that.id,_that.title,_that.kind,_that.amount,_that.dayOfMonth,_that.walletId,_that.walletName,_that.toWalletId,_that.toWalletName,_that.categoryId,_that.categoryName,_that.categoryIcon,_that.budgetId,_that.note,_that.isEnabled,_that.lastExecutedPeriod,_that.lastExecutedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String kind,  double amount,  int dayOfMonth,  String walletId,  String walletName,  String? toWalletId,  String? toWalletName,  String? categoryId,  String? categoryName,  String? categoryIcon,  String? budgetId,  String? note,  bool isEnabled,  String? lastExecutedPeriod,  DateTime? lastExecutedAt)  $default,) {final _that = this;
switch (_that) {
case _AutoScheduleEntity():
return $default(_that.id,_that.title,_that.kind,_that.amount,_that.dayOfMonth,_that.walletId,_that.walletName,_that.toWalletId,_that.toWalletName,_that.categoryId,_that.categoryName,_that.categoryIcon,_that.budgetId,_that.note,_that.isEnabled,_that.lastExecutedPeriod,_that.lastExecutedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String kind,  double amount,  int dayOfMonth,  String walletId,  String walletName,  String? toWalletId,  String? toWalletName,  String? categoryId,  String? categoryName,  String? categoryIcon,  String? budgetId,  String? note,  bool isEnabled,  String? lastExecutedPeriod,  DateTime? lastExecutedAt)?  $default,) {final _that = this;
switch (_that) {
case _AutoScheduleEntity() when $default != null:
return $default(_that.id,_that.title,_that.kind,_that.amount,_that.dayOfMonth,_that.walletId,_that.walletName,_that.toWalletId,_that.toWalletName,_that.categoryId,_that.categoryName,_that.categoryIcon,_that.budgetId,_that.note,_that.isEnabled,_that.lastExecutedPeriod,_that.lastExecutedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AutoScheduleEntity extends AutoScheduleEntity {
  const _AutoScheduleEntity({required this.id, required this.title, required this.kind, required this.amount, required this.dayOfMonth, required this.walletId, required this.walletName, this.toWalletId, this.toWalletName, this.categoryId, this.categoryName, this.categoryIcon, this.budgetId, this.note, required this.isEnabled, this.lastExecutedPeriod, this.lastExecutedAt}): super._();
  

@override final  String id;
@override final  String title;
@override final  String kind;
// 'expense' | 'transfer'
@override final  double amount;
@override final  int dayOfMonth;
// 1..31
@override final  String walletId;
@override final  String walletName;
@override final  String? toWalletId;
@override final  String? toWalletName;
@override final  String? categoryId;
@override final  String? categoryName;
@override final  String? categoryIcon;
@override final  String? budgetId;
@override final  String? note;
@override final  bool isEnabled;
@override final  String? lastExecutedPeriod;
// 'YYYY-MM' atau 'SKIP:YYYY-MM'
@override final  DateTime? lastExecutedAt;

/// Create a copy of AutoScheduleEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutoScheduleEntityCopyWith<_AutoScheduleEntity> get copyWith => __$AutoScheduleEntityCopyWithImpl<_AutoScheduleEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutoScheduleEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.walletName, walletName) || other.walletName == walletName)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.toWalletName, toWalletName) || other.toWalletName == toWalletName)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIcon, categoryIcon) || other.categoryIcon == categoryIcon)&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId)&&(identical(other.note, note) || other.note == note)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.lastExecutedPeriod, lastExecutedPeriod) || other.lastExecutedPeriod == lastExecutedPeriod)&&(identical(other.lastExecutedAt, lastExecutedAt) || other.lastExecutedAt == lastExecutedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,kind,amount,dayOfMonth,walletId,walletName,toWalletId,toWalletName,categoryId,categoryName,categoryIcon,budgetId,note,isEnabled,lastExecutedPeriod,lastExecutedAt);

@override
String toString() {
  return 'AutoScheduleEntity(id: $id, title: $title, kind: $kind, amount: $amount, dayOfMonth: $dayOfMonth, walletId: $walletId, walletName: $walletName, toWalletId: $toWalletId, toWalletName: $toWalletName, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, budgetId: $budgetId, note: $note, isEnabled: $isEnabled, lastExecutedPeriod: $lastExecutedPeriod, lastExecutedAt: $lastExecutedAt)';
}


}

/// @nodoc
abstract mixin class _$AutoScheduleEntityCopyWith<$Res> implements $AutoScheduleEntityCopyWith<$Res> {
  factory _$AutoScheduleEntityCopyWith(_AutoScheduleEntity value, $Res Function(_AutoScheduleEntity) _then) = __$AutoScheduleEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String kind, double amount, int dayOfMonth, String walletId, String walletName, String? toWalletId, String? toWalletName, String? categoryId, String? categoryName, String? categoryIcon, String? budgetId, String? note, bool isEnabled, String? lastExecutedPeriod, DateTime? lastExecutedAt
});




}
/// @nodoc
class __$AutoScheduleEntityCopyWithImpl<$Res>
    implements _$AutoScheduleEntityCopyWith<$Res> {
  __$AutoScheduleEntityCopyWithImpl(this._self, this._then);

  final _AutoScheduleEntity _self;
  final $Res Function(_AutoScheduleEntity) _then;

/// Create a copy of AutoScheduleEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? kind = null,Object? amount = null,Object? dayOfMonth = null,Object? walletId = null,Object? walletName = null,Object? toWalletId = freezed,Object? toWalletName = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? categoryIcon = freezed,Object? budgetId = freezed,Object? note = freezed,Object? isEnabled = null,Object? lastExecutedPeriod = freezed,Object? lastExecutedAt = freezed,}) {
  return _then(_AutoScheduleEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,walletName: null == walletName ? _self.walletName : walletName // ignore: cast_nullable_to_non_nullable
as String,toWalletId: freezed == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as String?,toWalletName: freezed == toWalletName ? _self.toWalletName : toWalletName // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,categoryIcon: freezed == categoryIcon ? _self.categoryIcon : categoryIcon // ignore: cast_nullable_to_non_nullable
as String?,budgetId: freezed == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,lastExecutedPeriod: freezed == lastExecutedPeriod ? _self.lastExecutedPeriod : lastExecutedPeriod // ignore: cast_nullable_to_non_nullable
as String?,lastExecutedAt: freezed == lastExecutedAt ? _self.lastExecutedAt : lastExecutedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
