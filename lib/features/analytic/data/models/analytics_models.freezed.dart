// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PeriodSummaryModel {

 double get income; double get expense; int get count;
/// Create a copy of PeriodSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodSummaryModelCopyWith<PeriodSummaryModel> get copyWith => _$PeriodSummaryModelCopyWithImpl<PeriodSummaryModel>(this as PeriodSummaryModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodSummaryModel&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,income,expense,count);

@override
String toString() {
  return 'PeriodSummaryModel(income: $income, expense: $expense, count: $count)';
}


}

/// @nodoc
abstract mixin class $PeriodSummaryModelCopyWith<$Res>  {
  factory $PeriodSummaryModelCopyWith(PeriodSummaryModel value, $Res Function(PeriodSummaryModel) _then) = _$PeriodSummaryModelCopyWithImpl;
@useResult
$Res call({
 double income, double expense, int count
});




}
/// @nodoc
class _$PeriodSummaryModelCopyWithImpl<$Res>
    implements $PeriodSummaryModelCopyWith<$Res> {
  _$PeriodSummaryModelCopyWithImpl(this._self, this._then);

  final PeriodSummaryModel _self;
  final $Res Function(PeriodSummaryModel) _then;

/// Create a copy of PeriodSummaryModel
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


/// Adds pattern-matching-related methods to [PeriodSummaryModel].
extension PeriodSummaryModelPatterns on PeriodSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _PeriodSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodSummaryModel() when $default != null:
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
case _PeriodSummaryModel() when $default != null:
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
case _PeriodSummaryModel():
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
case _PeriodSummaryModel() when $default != null:
return $default(_that.income,_that.expense,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _PeriodSummaryModel extends PeriodSummaryModel {
  const _PeriodSummaryModel({required this.income, required this.expense, required this.count}): super._();
  

@override final  double income;
@override final  double expense;
@override final  int count;

/// Create a copy of PeriodSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodSummaryModelCopyWith<_PeriodSummaryModel> get copyWith => __$PeriodSummaryModelCopyWithImpl<_PeriodSummaryModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodSummaryModel&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,income,expense,count);

@override
String toString() {
  return 'PeriodSummaryModel(income: $income, expense: $expense, count: $count)';
}


}

/// @nodoc
abstract mixin class _$PeriodSummaryModelCopyWith<$Res> implements $PeriodSummaryModelCopyWith<$Res> {
  factory _$PeriodSummaryModelCopyWith(_PeriodSummaryModel value, $Res Function(_PeriodSummaryModel) _then) = __$PeriodSummaryModelCopyWithImpl;
@override @useResult
$Res call({
 double income, double expense, int count
});




}
/// @nodoc
class __$PeriodSummaryModelCopyWithImpl<$Res>
    implements _$PeriodSummaryModelCopyWith<$Res> {
  __$PeriodSummaryModelCopyWithImpl(this._self, this._then);

  final _PeriodSummaryModel _self;
  final $Res Function(_PeriodSummaryModel) _then;

/// Create a copy of PeriodSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? income = null,Object? expense = null,Object? count = null,}) {
  return _then(_PeriodSummaryModel(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CategoryTotalModel {

 String get name; double get total; String? get categoryId; String? get icon; int get count;
/// Create a copy of CategoryTotalModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryTotalModelCopyWith<CategoryTotalModel> get copyWith => _$CategoryTotalModelCopyWithImpl<CategoryTotalModel>(this as CategoryTotalModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryTotalModel&&(identical(other.name, name) || other.name == name)&&(identical(other.total, total) || other.total == total)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,name,total,categoryId,icon,count);

@override
String toString() {
  return 'CategoryTotalModel(name: $name, total: $total, categoryId: $categoryId, icon: $icon, count: $count)';
}


}

/// @nodoc
abstract mixin class $CategoryTotalModelCopyWith<$Res>  {
  factory $CategoryTotalModelCopyWith(CategoryTotalModel value, $Res Function(CategoryTotalModel) _then) = _$CategoryTotalModelCopyWithImpl;
@useResult
$Res call({
 String name, double total, String? categoryId, String? icon, int count
});




}
/// @nodoc
class _$CategoryTotalModelCopyWithImpl<$Res>
    implements $CategoryTotalModelCopyWith<$Res> {
  _$CategoryTotalModelCopyWithImpl(this._self, this._then);

  final CategoryTotalModel _self;
  final $Res Function(CategoryTotalModel) _then;

/// Create a copy of CategoryTotalModel
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


/// Adds pattern-matching-related methods to [CategoryTotalModel].
extension CategoryTotalModelPatterns on CategoryTotalModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryTotalModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryTotalModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryTotalModel value)  $default,){
final _that = this;
switch (_that) {
case _CategoryTotalModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryTotalModel value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryTotalModel() when $default != null:
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
case _CategoryTotalModel() when $default != null:
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
case _CategoryTotalModel():
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
case _CategoryTotalModel() when $default != null:
return $default(_that.name,_that.total,_that.categoryId,_that.icon,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryTotalModel extends CategoryTotalModel {
  const _CategoryTotalModel({required this.name, required this.total, this.categoryId, this.icon, required this.count}): super._();
  

@override final  String name;
@override final  double total;
@override final  String? categoryId;
@override final  String? icon;
@override final  int count;

/// Create a copy of CategoryTotalModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryTotalModelCopyWith<_CategoryTotalModel> get copyWith => __$CategoryTotalModelCopyWithImpl<_CategoryTotalModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryTotalModel&&(identical(other.name, name) || other.name == name)&&(identical(other.total, total) || other.total == total)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,name,total,categoryId,icon,count);

@override
String toString() {
  return 'CategoryTotalModel(name: $name, total: $total, categoryId: $categoryId, icon: $icon, count: $count)';
}


}

/// @nodoc
abstract mixin class _$CategoryTotalModelCopyWith<$Res> implements $CategoryTotalModelCopyWith<$Res> {
  factory _$CategoryTotalModelCopyWith(_CategoryTotalModel value, $Res Function(_CategoryTotalModel) _then) = __$CategoryTotalModelCopyWithImpl;
@override @useResult
$Res call({
 String name, double total, String? categoryId, String? icon, int count
});




}
/// @nodoc
class __$CategoryTotalModelCopyWithImpl<$Res>
    implements _$CategoryTotalModelCopyWith<$Res> {
  __$CategoryTotalModelCopyWithImpl(this._self, this._then);

  final _CategoryTotalModel _self;
  final $Res Function(_CategoryTotalModel) _then;

/// Create a copy of CategoryTotalModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? total = null,Object? categoryId = freezed,Object? icon = freezed,Object? count = null,}) {
  return _then(_CategoryTotalModel(
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
mixin _$DailyTotalModel {

 DateTime get date; double get income; double get expense;
/// Create a copy of DailyTotalModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyTotalModelCopyWith<DailyTotalModel> get copyWith => _$DailyTotalModelCopyWithImpl<DailyTotalModel>(this as DailyTotalModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyTotalModel&&(identical(other.date, date) || other.date == date)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,date,income,expense);

@override
String toString() {
  return 'DailyTotalModel(date: $date, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class $DailyTotalModelCopyWith<$Res>  {
  factory $DailyTotalModelCopyWith(DailyTotalModel value, $Res Function(DailyTotalModel) _then) = _$DailyTotalModelCopyWithImpl;
@useResult
$Res call({
 DateTime date, double income, double expense
});




}
/// @nodoc
class _$DailyTotalModelCopyWithImpl<$Res>
    implements $DailyTotalModelCopyWith<$Res> {
  _$DailyTotalModelCopyWithImpl(this._self, this._then);

  final DailyTotalModel _self;
  final $Res Function(DailyTotalModel) _then;

/// Create a copy of DailyTotalModel
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


/// Adds pattern-matching-related methods to [DailyTotalModel].
extension DailyTotalModelPatterns on DailyTotalModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyTotalModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyTotalModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyTotalModel value)  $default,){
final _that = this;
switch (_that) {
case _DailyTotalModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyTotalModel value)?  $default,){
final _that = this;
switch (_that) {
case _DailyTotalModel() when $default != null:
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
case _DailyTotalModel() when $default != null:
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
case _DailyTotalModel():
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
case _DailyTotalModel() when $default != null:
return $default(_that.date,_that.income,_that.expense);case _:
  return null;

}
}

}

/// @nodoc


class _DailyTotalModel extends DailyTotalModel {
  const _DailyTotalModel({required this.date, required this.income, required this.expense}): super._();
  

@override final  DateTime date;
@override final  double income;
@override final  double expense;

/// Create a copy of DailyTotalModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyTotalModelCopyWith<_DailyTotalModel> get copyWith => __$DailyTotalModelCopyWithImpl<_DailyTotalModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyTotalModel&&(identical(other.date, date) || other.date == date)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,date,income,expense);

@override
String toString() {
  return 'DailyTotalModel(date: $date, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class _$DailyTotalModelCopyWith<$Res> implements $DailyTotalModelCopyWith<$Res> {
  factory _$DailyTotalModelCopyWith(_DailyTotalModel value, $Res Function(_DailyTotalModel) _then) = __$DailyTotalModelCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double income, double expense
});




}
/// @nodoc
class __$DailyTotalModelCopyWithImpl<$Res>
    implements _$DailyTotalModelCopyWith<$Res> {
  __$DailyTotalModelCopyWithImpl(this._self, this._then);

  final _DailyTotalModel _self;
  final $Res Function(_DailyTotalModel) _then;

/// Create a copy of DailyTotalModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? income = null,Object? expense = null,}) {
  return _then(_DailyTotalModel(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
