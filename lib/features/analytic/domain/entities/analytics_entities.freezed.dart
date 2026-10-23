// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PeriodSummaryEntity {

 double get income; double get expense; int get count;
/// Create a copy of PeriodSummaryEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodSummaryEntityCopyWith<PeriodSummaryEntity> get copyWith => _$PeriodSummaryEntityCopyWithImpl<PeriodSummaryEntity>(this as PeriodSummaryEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodSummaryEntity&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,income,expense,count);

@override
String toString() {
  return 'PeriodSummaryEntity(income: $income, expense: $expense, count: $count)';
}


}

/// @nodoc
abstract mixin class $PeriodSummaryEntityCopyWith<$Res>  {
  factory $PeriodSummaryEntityCopyWith(PeriodSummaryEntity value, $Res Function(PeriodSummaryEntity) _then) = _$PeriodSummaryEntityCopyWithImpl;
@useResult
$Res call({
 double income, double expense, int count
});




}
/// @nodoc
class _$PeriodSummaryEntityCopyWithImpl<$Res>
    implements $PeriodSummaryEntityCopyWith<$Res> {
  _$PeriodSummaryEntityCopyWithImpl(this._self, this._then);

  final PeriodSummaryEntity _self;
  final $Res Function(PeriodSummaryEntity) _then;

/// Create a copy of PeriodSummaryEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? income = null,Object? expense = null,Object? count = null,}) {
  return _then(_self.copyWith(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PeriodSummaryEntity].
extension PeriodSummaryEntityPatterns on PeriodSummaryEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodSummaryEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodSummaryEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodSummaryEntity value)  $default,){
final _that = this;
switch (_that) {
case _PeriodSummaryEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodSummaryEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodSummaryEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double income,  double expense,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodSummaryEntity() when $default != null:
return $default(_that.income,_that.expense,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double income,  double expense,  int count)  $default,) {final _that = this;
switch (_that) {
case _PeriodSummaryEntity():
return $default(_that.income,_that.expense,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double income,  double expense,  int count)?  $default,) {final _that = this;
switch (_that) {
case _PeriodSummaryEntity() when $default != null:
return $default(_that.income,_that.expense,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _PeriodSummaryEntity implements PeriodSummaryEntity {
  const _PeriodSummaryEntity({this.income = 0, this.expense = 0, this.count = 0});
  

@override@JsonKey() final  double income;
@override@JsonKey() final  double expense;
@override@JsonKey() final  int count;

/// Create a copy of PeriodSummaryEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodSummaryEntityCopyWith<_PeriodSummaryEntity> get copyWith => __$PeriodSummaryEntityCopyWithImpl<_PeriodSummaryEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodSummaryEntity&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,income,expense,count);

@override
String toString() {
  return 'PeriodSummaryEntity(income: $income, expense: $expense, count: $count)';
}


}

/// @nodoc
abstract mixin class _$PeriodSummaryEntityCopyWith<$Res> implements $PeriodSummaryEntityCopyWith<$Res> {
  factory _$PeriodSummaryEntityCopyWith(_PeriodSummaryEntity value, $Res Function(_PeriodSummaryEntity) _then) = __$PeriodSummaryEntityCopyWithImpl;
@override @useResult
$Res call({
 double income, double expense, int count
});




}
/// @nodoc
class __$PeriodSummaryEntityCopyWithImpl<$Res>
    implements _$PeriodSummaryEntityCopyWith<$Res> {
  __$PeriodSummaryEntityCopyWithImpl(this._self, this._then);

  final _PeriodSummaryEntity _self;
  final $Res Function(_PeriodSummaryEntity) _then;

/// Create a copy of PeriodSummaryEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? income = null,Object? expense = null,Object? count = null,}) {
  return _then(_PeriodSummaryEntity(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CategoryTotalEntity {

 String get name; double get total; String? get categoryId; String? get icon; int get count;
/// Create a copy of CategoryTotalEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryTotalEntityCopyWith<CategoryTotalEntity> get copyWith => _$CategoryTotalEntityCopyWithImpl<CategoryTotalEntity>(this as CategoryTotalEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryTotalEntity&&(identical(other.name, name) || other.name == name)&&(identical(other.total, total) || other.total == total)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,name,total,categoryId,icon,count);

@override
String toString() {
  return 'CategoryTotalEntity(name: $name, total: $total, categoryId: $categoryId, icon: $icon, count: $count)';
}


}

/// @nodoc
abstract mixin class $CategoryTotalEntityCopyWith<$Res>  {
  factory $CategoryTotalEntityCopyWith(CategoryTotalEntity value, $Res Function(CategoryTotalEntity) _then) = _$CategoryTotalEntityCopyWithImpl;
@useResult
$Res call({
 String name, double total, String? categoryId, String? icon, int count
});




}
/// @nodoc
class _$CategoryTotalEntityCopyWithImpl<$Res>
    implements $CategoryTotalEntityCopyWith<$Res> {
  _$CategoryTotalEntityCopyWithImpl(this._self, this._then);

  final CategoryTotalEntity _self;
  final $Res Function(CategoryTotalEntity) _then;

/// Create a copy of CategoryTotalEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? total = null,Object? categoryId = freezed,Object? icon = freezed,Object? count = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryTotalEntity].
extension CategoryTotalEntityPatterns on CategoryTotalEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryTotalEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryTotalEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryTotalEntity value)  $default,){
final _that = this;
switch (_that) {
case _CategoryTotalEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryTotalEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryTotalEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double total,  String? categoryId,  String? icon,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryTotalEntity() when $default != null:
return $default(_that.name,_that.total,_that.categoryId,_that.icon,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double total,  String? categoryId,  String? icon,  int count)  $default,) {final _that = this;
switch (_that) {
case _CategoryTotalEntity():
return $default(_that.name,_that.total,_that.categoryId,_that.icon,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double total,  String? categoryId,  String? icon,  int count)?  $default,) {final _that = this;
switch (_that) {
case _CategoryTotalEntity() when $default != null:
return $default(_that.name,_that.total,_that.categoryId,_that.icon,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryTotalEntity implements CategoryTotalEntity {
  const _CategoryTotalEntity({required this.name, required this.total, this.categoryId, this.icon, this.count = 0});
  

@override final  String name;
@override final  double total;
@override final  String? categoryId;
@override final  String? icon;
@override@JsonKey() final  int count;

/// Create a copy of CategoryTotalEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryTotalEntityCopyWith<_CategoryTotalEntity> get copyWith => __$CategoryTotalEntityCopyWithImpl<_CategoryTotalEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryTotalEntity&&(identical(other.name, name) || other.name == name)&&(identical(other.total, total) || other.total == total)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,name,total,categoryId,icon,count);

@override
String toString() {
  return 'CategoryTotalEntity(name: $name, total: $total, categoryId: $categoryId, icon: $icon, count: $count)';
}


}

/// @nodoc
abstract mixin class _$CategoryTotalEntityCopyWith<$Res> implements $CategoryTotalEntityCopyWith<$Res> {
  factory _$CategoryTotalEntityCopyWith(_CategoryTotalEntity value, $Res Function(_CategoryTotalEntity) _then) = __$CategoryTotalEntityCopyWithImpl;
@override @useResult
$Res call({
 String name, double total, String? categoryId, String? icon, int count
});




}
/// @nodoc
class __$CategoryTotalEntityCopyWithImpl<$Res>
    implements _$CategoryTotalEntityCopyWith<$Res> {
  __$CategoryTotalEntityCopyWithImpl(this._self, this._then);

  final _CategoryTotalEntity _self;
  final $Res Function(_CategoryTotalEntity) _then;

/// Create a copy of CategoryTotalEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? total = null,Object? categoryId = freezed,Object? icon = freezed,Object? count = null,}) {
  return _then(_CategoryTotalEntity(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DailyTotalEntity {

 DateTime get date; double get income; double get expense;
/// Create a copy of DailyTotalEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyTotalEntityCopyWith<DailyTotalEntity> get copyWith => _$DailyTotalEntityCopyWithImpl<DailyTotalEntity>(this as DailyTotalEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyTotalEntity&&(identical(other.date, date) || other.date == date)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,date,income,expense);

@override
String toString() {
  return 'DailyTotalEntity(date: $date, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class $DailyTotalEntityCopyWith<$Res>  {
  factory $DailyTotalEntityCopyWith(DailyTotalEntity value, $Res Function(DailyTotalEntity) _then) = _$DailyTotalEntityCopyWithImpl;
@useResult
$Res call({
 DateTime date, double income, double expense
});




}
/// @nodoc
class _$DailyTotalEntityCopyWithImpl<$Res>
    implements $DailyTotalEntityCopyWith<$Res> {
  _$DailyTotalEntityCopyWithImpl(this._self, this._then);

  final DailyTotalEntity _self;
  final $Res Function(DailyTotalEntity) _then;

/// Create a copy of DailyTotalEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? income = null,Object? expense = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyTotalEntity].
extension DailyTotalEntityPatterns on DailyTotalEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyTotalEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyTotalEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyTotalEntity value)  $default,){
final _that = this;
switch (_that) {
case _DailyTotalEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyTotalEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DailyTotalEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double income,  double expense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyTotalEntity() when $default != null:
return $default(_that.date,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double income,  double expense)  $default,) {final _that = this;
switch (_that) {
case _DailyTotalEntity():
return $default(_that.date,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double income,  double expense)?  $default,) {final _that = this;
switch (_that) {
case _DailyTotalEntity() when $default != null:
return $default(_that.date,_that.income,_that.expense);case _:
  return null;

}
}

}

/// @nodoc


class _DailyTotalEntity implements DailyTotalEntity {
  const _DailyTotalEntity({required this.date, required this.income, required this.expense});
  

@override final  DateTime date;
@override final  double income;
@override final  double expense;

/// Create a copy of DailyTotalEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyTotalEntityCopyWith<_DailyTotalEntity> get copyWith => __$DailyTotalEntityCopyWithImpl<_DailyTotalEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyTotalEntity&&(identical(other.date, date) || other.date == date)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,date,income,expense);

@override
String toString() {
  return 'DailyTotalEntity(date: $date, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class _$DailyTotalEntityCopyWith<$Res> implements $DailyTotalEntityCopyWith<$Res> {
  factory _$DailyTotalEntityCopyWith(_DailyTotalEntity value, $Res Function(_DailyTotalEntity) _then) = __$DailyTotalEntityCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double income, double expense
});




}
/// @nodoc
class __$DailyTotalEntityCopyWithImpl<$Res>
    implements _$DailyTotalEntityCopyWith<$Res> {
  __$DailyTotalEntityCopyWithImpl(this._self, this._then);

  final _DailyTotalEntity _self;
  final $Res Function(_DailyTotalEntity) _then;

/// Create a copy of DailyTotalEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? income = null,Object? expense = null,}) {
  return _then(_DailyTotalEntity(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
