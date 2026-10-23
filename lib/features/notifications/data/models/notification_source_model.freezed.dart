// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_source_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationSourceModel {

 String get id; String get packageName; String get walletId; String get parserKey; bool get isEnabled;
/// Create a copy of NotificationSourceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSourceModelCopyWith<NotificationSourceModel> get copyWith => _$NotificationSourceModelCopyWithImpl<NotificationSourceModel>(this as NotificationSourceModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSourceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.parserKey, parserKey) || other.parserKey == parserKey)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,id,packageName,walletId,parserKey,isEnabled);

@override
String toString() {
  return 'NotificationSourceModel(id: $id, packageName: $packageName, walletId: $walletId, parserKey: $parserKey, isEnabled: $isEnabled)';
}


}

/// @nodoc
abstract mixin class $NotificationSourceModelCopyWith<$Res>  {
  factory $NotificationSourceModelCopyWith(NotificationSourceModel value, $Res Function(NotificationSourceModel) _then) = _$NotificationSourceModelCopyWithImpl;
@useResult
$Res call({
 String id, String packageName, String walletId, String parserKey, bool isEnabled
});




}
/// @nodoc
class _$NotificationSourceModelCopyWithImpl<$Res>
    implements $NotificationSourceModelCopyWith<$Res> {
  _$NotificationSourceModelCopyWithImpl(this._self, this._then);

  final NotificationSourceModel _self;
  final $Res Function(NotificationSourceModel) _then;

/// Create a copy of NotificationSourceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? packageName = null,Object? walletId = null,Object? parserKey = null,Object? isEnabled = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,parserKey: null == parserKey ? _self.parserKey : parserKey // ignore: cast_nullable_to_non_nullable
as String,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSourceModel].
extension NotificationSourceModelPatterns on NotificationSourceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSourceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSourceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSourceModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSourceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSourceModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSourceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String packageName,  String walletId,  String parserKey,  bool isEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSourceModel() when $default != null:
return $default(_that.id,_that.packageName,_that.walletId,_that.parserKey,_that.isEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String packageName,  String walletId,  String parserKey,  bool isEnabled)  $default,) {final _that = this;
switch (_that) {
case _NotificationSourceModel():
return $default(_that.id,_that.packageName,_that.walletId,_that.parserKey,_that.isEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String packageName,  String walletId,  String parserKey,  bool isEnabled)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSourceModel() when $default != null:
return $default(_that.id,_that.packageName,_that.walletId,_that.parserKey,_that.isEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationSourceModel extends NotificationSourceModel {
  const _NotificationSourceModel({required this.id, required this.packageName, required this.walletId, required this.parserKey, required this.isEnabled}): super._();
  

@override final  String id;
@override final  String packageName;
@override final  String walletId;
@override final  String parserKey;
@override final  bool isEnabled;

/// Create a copy of NotificationSourceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSourceModelCopyWith<_NotificationSourceModel> get copyWith => __$NotificationSourceModelCopyWithImpl<_NotificationSourceModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSourceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.parserKey, parserKey) || other.parserKey == parserKey)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,id,packageName,walletId,parserKey,isEnabled);

@override
String toString() {
  return 'NotificationSourceModel(id: $id, packageName: $packageName, walletId: $walletId, parserKey: $parserKey, isEnabled: $isEnabled)';
}


}

/// @nodoc
abstract mixin class _$NotificationSourceModelCopyWith<$Res> implements $NotificationSourceModelCopyWith<$Res> {
  factory _$NotificationSourceModelCopyWith(_NotificationSourceModel value, $Res Function(_NotificationSourceModel) _then) = __$NotificationSourceModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String packageName, String walletId, String parserKey, bool isEnabled
});




}
/// @nodoc
class __$NotificationSourceModelCopyWithImpl<$Res>
    implements _$NotificationSourceModelCopyWith<$Res> {
  __$NotificationSourceModelCopyWithImpl(this._self, this._then);

  final _NotificationSourceModel _self;
  final $Res Function(_NotificationSourceModel) _then;

/// Create a copy of NotificationSourceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? packageName = null,Object? walletId = null,Object? parserKey = null,Object? isEnabled = null,}) {
  return _then(_NotificationSourceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,parserKey: null == parserKey ? _self.parserKey : parserKey // ignore: cast_nullable_to_non_nullable
as String,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
