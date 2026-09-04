// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent()';
}


}

/// @nodoc
class $AuthEventCopyWith<$Res>  {
$AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}


/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthSubscriptionRequested value)?  subscriptionRequested,TResult Function( AuthUserChanged value)?  userChanged,TResult Function( LoginSubmitted value)?  loginSubmitted,TResult Function( RegisterSubmitted value)?  registerSubmitted,TResult Function( GoogleSignInSubmitted value)?  googleSignInSubmitted,TResult Function( ForgotPasswordSubmitted value)?  forgotPasswordSubmitted,TResult Function( UpdatePasswordSubmitted value)?  updatePasswordSubmitted,TResult Function( LogoutRequested value)?  logoutRequested,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthSubscriptionRequested() when subscriptionRequested != null:
return subscriptionRequested(_that);case AuthUserChanged() when userChanged != null:
return userChanged(_that);case LoginSubmitted() when loginSubmitted != null:
return loginSubmitted(_that);case RegisterSubmitted() when registerSubmitted != null:
return registerSubmitted(_that);case GoogleSignInSubmitted() when googleSignInSubmitted != null:
return googleSignInSubmitted(_that);case ForgotPasswordSubmitted() when forgotPasswordSubmitted != null:
return forgotPasswordSubmitted(_that);case UpdatePasswordSubmitted() when updatePasswordSubmitted != null:
return updatePasswordSubmitted(_that);case LogoutRequested() when logoutRequested != null:
return logoutRequested(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthSubscriptionRequested value)  subscriptionRequested,required TResult Function( AuthUserChanged value)  userChanged,required TResult Function( LoginSubmitted value)  loginSubmitted,required TResult Function( RegisterSubmitted value)  registerSubmitted,required TResult Function( GoogleSignInSubmitted value)  googleSignInSubmitted,required TResult Function( ForgotPasswordSubmitted value)  forgotPasswordSubmitted,required TResult Function( UpdatePasswordSubmitted value)  updatePasswordSubmitted,required TResult Function( LogoutRequested value)  logoutRequested,}){
final _that = this;
switch (_that) {
case AuthSubscriptionRequested():
return subscriptionRequested(_that);case AuthUserChanged():
return userChanged(_that);case LoginSubmitted():
return loginSubmitted(_that);case RegisterSubmitted():
return registerSubmitted(_that);case GoogleSignInSubmitted():
return googleSignInSubmitted(_that);case ForgotPasswordSubmitted():
return forgotPasswordSubmitted(_that);case UpdatePasswordSubmitted():
return updatePasswordSubmitted(_that);case LogoutRequested():
return logoutRequested(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthSubscriptionRequested value)?  subscriptionRequested,TResult? Function( AuthUserChanged value)?  userChanged,TResult? Function( LoginSubmitted value)?  loginSubmitted,TResult? Function( RegisterSubmitted value)?  registerSubmitted,TResult? Function( GoogleSignInSubmitted value)?  googleSignInSubmitted,TResult? Function( ForgotPasswordSubmitted value)?  forgotPasswordSubmitted,TResult? Function( UpdatePasswordSubmitted value)?  updatePasswordSubmitted,TResult? Function( LogoutRequested value)?  logoutRequested,}){
final _that = this;
switch (_that) {
case AuthSubscriptionRequested() when subscriptionRequested != null:
return subscriptionRequested(_that);case AuthUserChanged() when userChanged != null:
return userChanged(_that);case LoginSubmitted() when loginSubmitted != null:
return loginSubmitted(_that);case RegisterSubmitted() when registerSubmitted != null:
return registerSubmitted(_that);case GoogleSignInSubmitted() when googleSignInSubmitted != null:
return googleSignInSubmitted(_that);case ForgotPasswordSubmitted() when forgotPasswordSubmitted != null:
return forgotPasswordSubmitted(_that);case UpdatePasswordSubmitted() when updatePasswordSubmitted != null:
return updatePasswordSubmitted(_that);case LogoutRequested() when logoutRequested != null:
return logoutRequested(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  subscriptionRequested,TResult Function( AuthStateEntity authStateEntity)?  userChanged,TResult Function( String email,  String password)?  loginSubmitted,TResult Function( String email,  String password,  String fullName)?  registerSubmitted,TResult Function()?  googleSignInSubmitted,TResult Function( String email)?  forgotPasswordSubmitted,TResult Function( String newPassword)?  updatePasswordSubmitted,TResult Function()?  logoutRequested,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthSubscriptionRequested() when subscriptionRequested != null:
return subscriptionRequested();case AuthUserChanged() when userChanged != null:
return userChanged(_that.authStateEntity);case LoginSubmitted() when loginSubmitted != null:
return loginSubmitted(_that.email,_that.password);case RegisterSubmitted() when registerSubmitted != null:
return registerSubmitted(_that.email,_that.password,_that.fullName);case GoogleSignInSubmitted() when googleSignInSubmitted != null:
return googleSignInSubmitted();case ForgotPasswordSubmitted() when forgotPasswordSubmitted != null:
return forgotPasswordSubmitted(_that.email);case UpdatePasswordSubmitted() when updatePasswordSubmitted != null:
return updatePasswordSubmitted(_that.newPassword);case LogoutRequested() when logoutRequested != null:
return logoutRequested();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  subscriptionRequested,required TResult Function( AuthStateEntity authStateEntity)  userChanged,required TResult Function( String email,  String password)  loginSubmitted,required TResult Function( String email,  String password,  String fullName)  registerSubmitted,required TResult Function()  googleSignInSubmitted,required TResult Function( String email)  forgotPasswordSubmitted,required TResult Function( String newPassword)  updatePasswordSubmitted,required TResult Function()  logoutRequested,}) {final _that = this;
switch (_that) {
case AuthSubscriptionRequested():
return subscriptionRequested();case AuthUserChanged():
return userChanged(_that.authStateEntity);case LoginSubmitted():
return loginSubmitted(_that.email,_that.password);case RegisterSubmitted():
return registerSubmitted(_that.email,_that.password,_that.fullName);case GoogleSignInSubmitted():
return googleSignInSubmitted();case ForgotPasswordSubmitted():
return forgotPasswordSubmitted(_that.email);case UpdatePasswordSubmitted():
return updatePasswordSubmitted(_that.newPassword);case LogoutRequested():
return logoutRequested();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  subscriptionRequested,TResult? Function( AuthStateEntity authStateEntity)?  userChanged,TResult? Function( String email,  String password)?  loginSubmitted,TResult? Function( String email,  String password,  String fullName)?  registerSubmitted,TResult? Function()?  googleSignInSubmitted,TResult? Function( String email)?  forgotPasswordSubmitted,TResult? Function( String newPassword)?  updatePasswordSubmitted,TResult? Function()?  logoutRequested,}) {final _that = this;
switch (_that) {
case AuthSubscriptionRequested() when subscriptionRequested != null:
return subscriptionRequested();case AuthUserChanged() when userChanged != null:
return userChanged(_that.authStateEntity);case LoginSubmitted() when loginSubmitted != null:
return loginSubmitted(_that.email,_that.password);case RegisterSubmitted() when registerSubmitted != null:
return registerSubmitted(_that.email,_that.password,_that.fullName);case GoogleSignInSubmitted() when googleSignInSubmitted != null:
return googleSignInSubmitted();case ForgotPasswordSubmitted() when forgotPasswordSubmitted != null:
return forgotPasswordSubmitted(_that.email);case UpdatePasswordSubmitted() when updatePasswordSubmitted != null:
return updatePasswordSubmitted(_that.newPassword);case LogoutRequested() when logoutRequested != null:
return logoutRequested();case _:
  return null;

}
}

}

/// @nodoc


class AuthSubscriptionRequested implements AuthEvent {
  const AuthSubscriptionRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSubscriptionRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.subscriptionRequested()';
}


}




/// @nodoc


class AuthUserChanged implements AuthEvent {
  const AuthUserChanged(this.authStateEntity);
  

 final  AuthStateEntity authStateEntity;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUserChangedCopyWith<AuthUserChanged> get copyWith => _$AuthUserChangedCopyWithImpl<AuthUserChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUserChanged&&(identical(other.authStateEntity, authStateEntity) || other.authStateEntity == authStateEntity));
}


@override
int get hashCode => Object.hash(runtimeType,authStateEntity);

@override
String toString() {
  return 'AuthEvent.userChanged(authStateEntity: $authStateEntity)';
}


}

/// @nodoc
abstract mixin class $AuthUserChangedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthUserChangedCopyWith(AuthUserChanged value, $Res Function(AuthUserChanged) _then) = _$AuthUserChangedCopyWithImpl;
@useResult
$Res call({
 AuthStateEntity authStateEntity
});


$AuthStateEntityCopyWith<$Res> get authStateEntity;

}
/// @nodoc
class _$AuthUserChangedCopyWithImpl<$Res>
    implements $AuthUserChangedCopyWith<$Res> {
  _$AuthUserChangedCopyWithImpl(this._self, this._then);

  final AuthUserChanged _self;
  final $Res Function(AuthUserChanged) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? authStateEntity = null,}) {
  return _then(AuthUserChanged(
null == authStateEntity ? _self.authStateEntity : authStateEntity // ignore: cast_nullable_to_non_nullable
as AuthStateEntity,
  ));
}

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthStateEntityCopyWith<$Res> get authStateEntity {
  
  return $AuthStateEntityCopyWith<$Res>(_self.authStateEntity, (value) {
    return _then(_self.copyWith(authStateEntity: value));
  });
}
}

/// @nodoc


class LoginSubmitted implements AuthEvent {
  const LoginSubmitted({required this.email, required this.password});
  

 final  String email;
 final  String password;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginSubmittedCopyWith<LoginSubmitted> get copyWith => _$LoginSubmittedCopyWithImpl<LoginSubmitted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginSubmitted&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'AuthEvent.loginSubmitted(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $LoginSubmittedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $LoginSubmittedCopyWith(LoginSubmitted value, $Res Function(LoginSubmitted) _then) = _$LoginSubmittedCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$LoginSubmittedCopyWithImpl<$Res>
    implements $LoginSubmittedCopyWith<$Res> {
  _$LoginSubmittedCopyWithImpl(this._self, this._then);

  final LoginSubmitted _self;
  final $Res Function(LoginSubmitted) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(LoginSubmitted(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RegisterSubmitted implements AuthEvent {
  const RegisterSubmitted({required this.email, required this.password, required this.fullName});
  

 final  String email;
 final  String password;
 final  String fullName;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterSubmittedCopyWith<RegisterSubmitted> get copyWith => _$RegisterSubmittedCopyWithImpl<RegisterSubmitted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterSubmitted&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.fullName, fullName) || other.fullName == fullName));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,fullName);

@override
String toString() {
  return 'AuthEvent.registerSubmitted(email: $email, password: $password, fullName: $fullName)';
}


}

/// @nodoc
abstract mixin class $RegisterSubmittedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $RegisterSubmittedCopyWith(RegisterSubmitted value, $Res Function(RegisterSubmitted) _then) = _$RegisterSubmittedCopyWithImpl;
@useResult
$Res call({
 String email, String password, String fullName
});




}
/// @nodoc
class _$RegisterSubmittedCopyWithImpl<$Res>
    implements $RegisterSubmittedCopyWith<$Res> {
  _$RegisterSubmittedCopyWithImpl(this._self, this._then);

  final RegisterSubmitted _self;
  final $Res Function(RegisterSubmitted) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? fullName = null,}) {
  return _then(RegisterSubmitted(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class GoogleSignInSubmitted implements AuthEvent {
  const GoogleSignInSubmitted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoogleSignInSubmitted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.googleSignInSubmitted()';
}


}




/// @nodoc


class ForgotPasswordSubmitted implements AuthEvent {
  const ForgotPasswordSubmitted({required this.email});
  

 final  String email;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForgotPasswordSubmittedCopyWith<ForgotPasswordSubmitted> get copyWith => _$ForgotPasswordSubmittedCopyWithImpl<ForgotPasswordSubmitted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordSubmitted&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'AuthEvent.forgotPasswordSubmitted(email: $email)';
}


}

/// @nodoc
abstract mixin class $ForgotPasswordSubmittedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $ForgotPasswordSubmittedCopyWith(ForgotPasswordSubmitted value, $Res Function(ForgotPasswordSubmitted) _then) = _$ForgotPasswordSubmittedCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$ForgotPasswordSubmittedCopyWithImpl<$Res>
    implements $ForgotPasswordSubmittedCopyWith<$Res> {
  _$ForgotPasswordSubmittedCopyWithImpl(this._self, this._then);

  final ForgotPasswordSubmitted _self;
  final $Res Function(ForgotPasswordSubmitted) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(ForgotPasswordSubmitted(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UpdatePasswordSubmitted implements AuthEvent {
  const UpdatePasswordSubmitted({required this.newPassword});
  

 final  String newPassword;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePasswordSubmittedCopyWith<UpdatePasswordSubmitted> get copyWith => _$UpdatePasswordSubmittedCopyWithImpl<UpdatePasswordSubmitted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePasswordSubmitted&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}


@override
int get hashCode => Object.hash(runtimeType,newPassword);

@override
String toString() {
  return 'AuthEvent.updatePasswordSubmitted(newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class $UpdatePasswordSubmittedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $UpdatePasswordSubmittedCopyWith(UpdatePasswordSubmitted value, $Res Function(UpdatePasswordSubmitted) _then) = _$UpdatePasswordSubmittedCopyWithImpl;
@useResult
$Res call({
 String newPassword
});




}
/// @nodoc
class _$UpdatePasswordSubmittedCopyWithImpl<$Res>
    implements $UpdatePasswordSubmittedCopyWith<$Res> {
  _$UpdatePasswordSubmittedCopyWithImpl(this._self, this._then);

  final UpdatePasswordSubmitted _self;
  final $Res Function(UpdatePasswordSubmitted) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? newPassword = null,}) {
  return _then(UpdatePasswordSubmitted(
newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LogoutRequested implements AuthEvent {
  const LogoutRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogoutRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.logoutRequested()';
}


}




// dart format on
