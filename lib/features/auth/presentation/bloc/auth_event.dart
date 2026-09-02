import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_state_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on app startup to start listening to the reactive auth state stream
class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

/// Internal event dispatched when authStateChanges stream yields an auth event
class AuthUserChanged extends AuthEvent {
  final AuthStateEntity authStateEntity;

  const AuthUserChanged(this.authStateEntity);

  @override
  List<Object?> get props => [authStateEntity];
}

/// Dispatched when user submits the login form
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Dispatched when user submits the register form
class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

/// Dispatched when user clicks Sign in with Google
class GoogleSignInSubmitted extends AuthEvent {
  const GoogleSignInSubmitted();
}

/// Dispatched when user submits the forgot password form
class ForgotPasswordSubmitted extends AuthEvent {
  final String email;

  const ForgotPasswordSubmitted({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Dispatched when user submits a new password from the reset password page
class UpdatePasswordSubmitted extends AuthEvent {
  final String newPassword;

  const UpdatePasswordSubmitted({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}

/// Dispatched when user logs out
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
