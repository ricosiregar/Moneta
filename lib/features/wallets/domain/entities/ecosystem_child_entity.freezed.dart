// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ecosystem_child_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EcosystemChildEntity {

 String get name; String get type; String get purpose; double get openingBalance;
/// Create a copy of EcosystemChildEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EcosystemChildEntityCopyWith<EcosystemChildEntity> get copyWith => _$EcosystemChildEntityCopyWithImpl<EcosystemChildEntity>(this as EcosystemChildEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EcosystemChildEntity&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.openingBalance, openingBalance) || other.openingBalance == openingBalance));
}


@override
int get hashCode => Object.hash(runtimeType,name,type,purpose,openingBalance);

@override
String toString() {
  return 'EcosystemChildEntity(name: $name, type: $type, purpose: $purpose, openingBalance: $openingBalance)';
}


}

/// @nodoc
abstract mixin class $EcosystemChildEntityCopyWith<$Res>  {
  factory $EcosystemChildEntityCopyWith(EcosystemChildEntity value, $Res Function(EcosystemChildEntity) _then) = _$EcosystemChildEntityCopyWithImpl;
@useResult
$Res call({
 String name, String type, String purpose, double openingBalance
});




}
/// @nodoc
class _$EcosystemChildEntityCopyWithImpl<$Res>
    implements $EcosystemChildEntityCopyWith<$Res> {
  _$EcosystemChildEntityCopyWithImpl(this._self, this._then);

  final EcosystemChildEntity _self;
  final $Res Function(EcosystemChildEntity) _then;

/// Create a copy of EcosystemChildEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? purpose = null,Object? openingBalance = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,openingBalance: null == openingBalance ? _self.openingBalance : openingBalance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EcosystemChildEntity].
extension EcosystemChildEntityPatterns on EcosystemChildEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EcosystemChildEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EcosystemChildEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EcosystemChildEntity value)  $default,){
final _that = this;
switch (_that) {
case _EcosystemChildEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EcosystemChildEntity value)?  $default,){
final _that = this;
switch (_that) {
case _EcosystemChildEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  String purpose,  double openingBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EcosystemChildEntity() when $default != null:
return $default(_that.name,_that.type,_that.purpose,_that.openingBalance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  String purpose,  double openingBalance)  $default,) {final _that = this;
switch (_that) {
case _EcosystemChildEntity():
return $default(_that.name,_that.type,_that.purpose,_that.openingBalance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  String purpose,  double openingBalance)?  $default,) {final _that = this;
switch (_that) {
case _EcosystemChildEntity() when $default != null:
return $default(_that.name,_that.type,_that.purpose,_that.openingBalance);case _:
  return null;

}
}

}

/// @nodoc


class _EcosystemChildEntity implements EcosystemChildEntity {
  const _EcosystemChildEntity({required this.name, required this.type, required this.purpose, this.openingBalance = 0});
  

@override final  String name;
@override final  String type;
@override final  String purpose;
@override@JsonKey() final  double openingBalance;

/// Create a copy of EcosystemChildEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EcosystemChildEntityCopyWith<_EcosystemChildEntity> get copyWith => __$EcosystemChildEntityCopyWithImpl<_EcosystemChildEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EcosystemChildEntity&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.openingBalance, openingBalance) || other.openingBalance == openingBalance));
}


@override
int get hashCode => Object.hash(runtimeType,name,type,purpose,openingBalance);

@override
String toString() {
  return 'EcosystemChildEntity(name: $name, type: $type, purpose: $purpose, openingBalance: $openingBalance)';
}


}

/// @nodoc
abstract mixin class _$EcosystemChildEntityCopyWith<$Res> implements $EcosystemChildEntityCopyWith<$Res> {
  factory _$EcosystemChildEntityCopyWith(_EcosystemChildEntity value, $Res Function(_EcosystemChildEntity) _then) = __$EcosystemChildEntityCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, String purpose, double openingBalance
});




}
/// @nodoc
class __$EcosystemChildEntityCopyWithImpl<$Res>
    implements _$EcosystemChildEntityCopyWith<$Res> {
  __$EcosystemChildEntityCopyWithImpl(this._self, this._then);

  final _EcosystemChildEntity _self;
  final $Res Function(_EcosystemChildEntity) _then;

/// Create a copy of EcosystemChildEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? purpose = null,Object? openingBalance = null,}) {
  return _then(_EcosystemChildEntity(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,openingBalance: null == openingBalance ? _self.openingBalance : openingBalance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
