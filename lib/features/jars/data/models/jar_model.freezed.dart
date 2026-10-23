// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jar_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JarModel {

 String get id; String get title; double get target; double get saved; String? get icon; DateTime? get targetDate;
/// Create a copy of JarModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JarModelCopyWith<JarModel> get copyWith => _$JarModelCopyWithImpl<JarModel>(this as JarModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JarModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.target, target) || other.target == target)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,target,saved,icon,targetDate);

@override
String toString() {
  return 'JarModel(id: $id, title: $title, target: $target, saved: $saved, icon: $icon, targetDate: $targetDate)';
}


}

/// @nodoc
abstract mixin class $JarModelCopyWith<$Res>  {
  factory $JarModelCopyWith(JarModel value, $Res Function(JarModel) _then) = _$JarModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, double target, double saved, String? icon, DateTime? targetDate
});




}
/// @nodoc
class _$JarModelCopyWithImpl<$Res>
    implements $JarModelCopyWith<$Res> {
  _$JarModelCopyWithImpl(this._self, this._then);

  final JarModel _self;
  final $Res Function(JarModel) _then;

/// Create a copy of JarModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? target = null,Object? saved = null,Object? icon = freezed,Object? targetDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as double,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as double,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [JarModel].
extension JarModelPatterns on JarModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JarModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JarModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JarModel value)  $default,){
final _that = this;
switch (_that) {
case _JarModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JarModel value)?  $default,){
final _that = this;
switch (_that) {
case _JarModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  double target,  double saved,  String? icon,  DateTime? targetDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JarModel() when $default != null:
return $default(_that.id,_that.title,_that.target,_that.saved,_that.icon,_that.targetDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  double target,  double saved,  String? icon,  DateTime? targetDate)  $default,) {final _that = this;
switch (_that) {
case _JarModel():
return $default(_that.id,_that.title,_that.target,_that.saved,_that.icon,_that.targetDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  double target,  double saved,  String? icon,  DateTime? targetDate)?  $default,) {final _that = this;
switch (_that) {
case _JarModel() when $default != null:
return $default(_that.id,_that.title,_that.target,_that.saved,_that.icon,_that.targetDate);case _:
  return null;

}
}

}

/// @nodoc


class _JarModel extends JarModel {
  const _JarModel({required this.id, required this.title, required this.target, required this.saved, this.icon, this.targetDate}): super._();
  

@override final  String id;
@override final  String title;
@override final  double target;
@override final  double saved;
@override final  String? icon;
@override final  DateTime? targetDate;

/// Create a copy of JarModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JarModelCopyWith<_JarModel> get copyWith => __$JarModelCopyWithImpl<_JarModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JarModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.target, target) || other.target == target)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,target,saved,icon,targetDate);

@override
String toString() {
  return 'JarModel(id: $id, title: $title, target: $target, saved: $saved, icon: $icon, targetDate: $targetDate)';
}


}

/// @nodoc
abstract mixin class _$JarModelCopyWith<$Res> implements $JarModelCopyWith<$Res> {
  factory _$JarModelCopyWith(_JarModel value, $Res Function(_JarModel) _then) = __$JarModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double target, double saved, String? icon, DateTime? targetDate
});




}
/// @nodoc
class __$JarModelCopyWithImpl<$Res>
    implements _$JarModelCopyWith<$Res> {
  __$JarModelCopyWithImpl(this._self, this._then);

  final _JarModel _self;
  final $Res Function(_JarModel) _then;

/// Create a copy of JarModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? target = null,Object? saved = null,Object? icon = freezed,Object? targetDate = freezed,}) {
  return _then(_JarModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as double,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as double,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
