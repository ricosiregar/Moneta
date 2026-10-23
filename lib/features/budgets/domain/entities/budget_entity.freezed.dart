// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetEntity {

 String get id; String? get categoryId; String get categoryName; double get limit; double get spent;
/// Create a copy of BudgetEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetEntityCopyWith<BudgetEntity> get copyWith => _$BudgetEntityCopyWithImpl<BudgetEntity>(this as BudgetEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.spent, spent) || other.spent == spent));
}


@override
int get hashCode => Object.hash(runtimeType,id,categoryId,categoryName,limit,spent);

@override
String toString() {
  return 'BudgetEntity(id: $id, categoryId: $categoryId, categoryName: $categoryName, limit: $limit, spent: $spent)';
}


}

/// @nodoc
abstract mixin class $BudgetEntityCopyWith<$Res>  {
  factory $BudgetEntityCopyWith(BudgetEntity value, $Res Function(BudgetEntity) _then) = _$BudgetEntityCopyWithImpl;
@useResult
$Res call({
 String id, String? categoryId, String categoryName, double limit, double spent
});




}
/// @nodoc
class _$BudgetEntityCopyWithImpl<$Res>
    implements $BudgetEntityCopyWith<$Res> {
  _$BudgetEntityCopyWithImpl(this._self, this._then);

  final BudgetEntity _self;
  final $Res Function(BudgetEntity) _then;

/// Create a copy of BudgetEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = freezed,Object? categoryName = null,Object? limit = null,Object? spent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as double,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetEntity].
extension BudgetEntityPatterns on BudgetEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetEntity value)  $default,){
final _that = this;
switch (_that) {
case _BudgetEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetEntity value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? categoryId,  String categoryName,  double limit,  double spent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetEntity() when $default != null:
return $default(_that.id,_that.categoryId,_that.categoryName,_that.limit,_that.spent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? categoryId,  String categoryName,  double limit,  double spent)  $default,) {final _that = this;
switch (_that) {
case _BudgetEntity():
return $default(_that.id,_that.categoryId,_that.categoryName,_that.limit,_that.spent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? categoryId,  String categoryName,  double limit,  double spent)?  $default,) {final _that = this;
switch (_that) {
case _BudgetEntity() when $default != null:
return $default(_that.id,_that.categoryId,_that.categoryName,_that.limit,_that.spent);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetEntity implements BudgetEntity {
  const _BudgetEntity({required this.id, this.categoryId, required this.categoryName, required this.limit, required this.spent});
  

@override final  String id;
@override final  String? categoryId;
@override final  String categoryName;
@override final  double limit;
@override final  double spent;

/// Create a copy of BudgetEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetEntityCopyWith<_BudgetEntity> get copyWith => __$BudgetEntityCopyWithImpl<_BudgetEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.spent, spent) || other.spent == spent));
}


@override
int get hashCode => Object.hash(runtimeType,id,categoryId,categoryName,limit,spent);

@override
String toString() {
  return 'BudgetEntity(id: $id, categoryId: $categoryId, categoryName: $categoryName, limit: $limit, spent: $spent)';
}


}

/// @nodoc
abstract mixin class _$BudgetEntityCopyWith<$Res> implements $BudgetEntityCopyWith<$Res> {
  factory _$BudgetEntityCopyWith(_BudgetEntity value, $Res Function(_BudgetEntity) _then) = __$BudgetEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String? categoryId, String categoryName, double limit, double spent
});




}
/// @nodoc
class __$BudgetEntityCopyWithImpl<$Res>
    implements _$BudgetEntityCopyWith<$Res> {
  __$BudgetEntityCopyWithImpl(this._self, this._then);

  final _BudgetEntity _self;
  final $Res Function(_BudgetEntity) _then;

/// Create a copy of BudgetEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = freezed,Object? categoryName = null,Object? limit = null,Object? spent = null,}) {
  return _then(_BudgetEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as double,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
