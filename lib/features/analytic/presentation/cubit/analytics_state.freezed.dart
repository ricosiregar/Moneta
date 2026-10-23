// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalyticsState {

 AnalyticsStatus get status; List<WalletEntity> get wallets; PeriodSummaryEntity get summary; List<CategoryTotalEntity> get categories; List<DailyTotalEntity> get daily; List<DailyTotalEntity> get trend; String? get errorMessage;
/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsStateCopyWith<AnalyticsState> get copyWith => _$AnalyticsStateCopyWithImpl<AnalyticsState>(this as AnalyticsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.wallets, wallets)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.daily, daily)&&const DeepCollectionEquality().equals(other.trend, trend)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(wallets),summary,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(daily),const DeepCollectionEquality().hash(trend),errorMessage);

@override
String toString() {
  return 'AnalyticsState(status: $status, wallets: $wallets, summary: $summary, categories: $categories, daily: $daily, trend: $trend, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AnalyticsStateCopyWith<$Res>  {
  factory $AnalyticsStateCopyWith(AnalyticsState value, $Res Function(AnalyticsState) _then) = _$AnalyticsStateCopyWithImpl;
@useResult
$Res call({
 AnalyticsStatus status, List<WalletEntity> wallets, PeriodSummaryEntity summary, List<CategoryTotalEntity> categories, List<DailyTotalEntity> daily, List<DailyTotalEntity> trend, String? errorMessage
});


$PeriodSummaryEntityCopyWith<$Res> get summary;

}
/// @nodoc
class _$AnalyticsStateCopyWithImpl<$Res>
    implements $AnalyticsStateCopyWith<$Res> {
  _$AnalyticsStateCopyWithImpl(this._self, this._then);

  final AnalyticsState _self;
  final $Res Function(AnalyticsState) _then;

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? wallets = null,Object? summary = null,Object? categories = null,Object? daily = null,Object? trend = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnalyticsStatus,wallets: null == wallets ? _self.wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<WalletEntity>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as PeriodSummaryEntity,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryTotalEntity>,daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as List<DailyTotalEntity>,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as List<DailyTotalEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodSummaryEntityCopyWith<$Res> get summary {
  
  return $PeriodSummaryEntityCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsState].
extension AnalyticsStatePatterns on AnalyticsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsState value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsState value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsStatus status,  List<WalletEntity> wallets,  PeriodSummaryEntity summary,  List<CategoryTotalEntity> categories,  List<DailyTotalEntity> daily,  List<DailyTotalEntity> trend,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
return $default(_that.status,_that.wallets,_that.summary,_that.categories,_that.daily,_that.trend,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsStatus status,  List<WalletEntity> wallets,  PeriodSummaryEntity summary,  List<CategoryTotalEntity> categories,  List<DailyTotalEntity> daily,  List<DailyTotalEntity> trend,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsState():
return $default(_that.status,_that.wallets,_that.summary,_that.categories,_that.daily,_that.trend,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsStatus status,  List<WalletEntity> wallets,  PeriodSummaryEntity summary,  List<CategoryTotalEntity> categories,  List<DailyTotalEntity> daily,  List<DailyTotalEntity> trend,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsState() when $default != null:
return $default(_that.status,_that.wallets,_that.summary,_that.categories,_that.daily,_that.trend,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsState implements AnalyticsState {
  const _AnalyticsState({this.status = AnalyticsStatus.initial, final  List<WalletEntity> wallets = const <WalletEntity>[], this.summary = const PeriodSummaryEntity(), final  List<CategoryTotalEntity> categories = const <CategoryTotalEntity>[], final  List<DailyTotalEntity> daily = const <DailyTotalEntity>[], final  List<DailyTotalEntity> trend = const <DailyTotalEntity>[], this.errorMessage}): _wallets = wallets,_categories = categories,_daily = daily,_trend = trend;
  

@override@JsonKey() final  AnalyticsStatus status;
 final  List<WalletEntity> _wallets;
@override@JsonKey() List<WalletEntity> get wallets {
  if (_wallets is EqualUnmodifiableListView) return _wallets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wallets);
}

@override@JsonKey() final  PeriodSummaryEntity summary;
 final  List<CategoryTotalEntity> _categories;
@override@JsonKey() List<CategoryTotalEntity> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<DailyTotalEntity> _daily;
@override@JsonKey() List<DailyTotalEntity> get daily {
  if (_daily is EqualUnmodifiableListView) return _daily;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daily);
}

 final  List<DailyTotalEntity> _trend;
@override@JsonKey() List<DailyTotalEntity> get trend {
  if (_trend is EqualUnmodifiableListView) return _trend;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trend);
}

@override final  String? errorMessage;

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsStateCopyWith<_AnalyticsState> get copyWith => __$AnalyticsStateCopyWithImpl<_AnalyticsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._wallets, _wallets)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._daily, _daily)&&const DeepCollectionEquality().equals(other._trend, _trend)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_wallets),summary,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_daily),const DeepCollectionEquality().hash(_trend),errorMessage);

@override
String toString() {
  return 'AnalyticsState(status: $status, wallets: $wallets, summary: $summary, categories: $categories, daily: $daily, trend: $trend, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsStateCopyWith<$Res> implements $AnalyticsStateCopyWith<$Res> {
  factory _$AnalyticsStateCopyWith(_AnalyticsState value, $Res Function(_AnalyticsState) _then) = __$AnalyticsStateCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsStatus status, List<WalletEntity> wallets, PeriodSummaryEntity summary, List<CategoryTotalEntity> categories, List<DailyTotalEntity> daily, List<DailyTotalEntity> trend, String? errorMessage
});


@override $PeriodSummaryEntityCopyWith<$Res> get summary;

}
/// @nodoc
class __$AnalyticsStateCopyWithImpl<$Res>
    implements _$AnalyticsStateCopyWith<$Res> {
  __$AnalyticsStateCopyWithImpl(this._self, this._then);

  final _AnalyticsState _self;
  final $Res Function(_AnalyticsState) _then;

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? wallets = null,Object? summary = null,Object? categories = null,Object? daily = null,Object? trend = null,Object? errorMessage = freezed,}) {
  return _then(_AnalyticsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnalyticsStatus,wallets: null == wallets ? _self._wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<WalletEntity>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as PeriodSummaryEntity,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryTotalEntity>,daily: null == daily ? _self._daily : daily // ignore: cast_nullable_to_non_nullable
as List<DailyTotalEntity>,trend: null == trend ? _self._trend : trend // ignore: cast_nullable_to_non_nullable
as List<DailyTotalEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AnalyticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodSummaryEntityCopyWith<$Res> get summary {
  
  return $PeriodSummaryEntityCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
