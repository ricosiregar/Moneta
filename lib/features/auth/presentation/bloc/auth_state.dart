import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

enum AuthStatus {
  /// Initial app launch state, checking active session (renders Splash Page)
  initial,

  /// Login/Register in progress
  loading,

  /// Successfully signed in with active user
  authenticated,

  /// Not signed in or logged out
  unauthenticated,

  /// Registration succeeded but requires email confirmation before login
  registeredNeedsVerification,

  /// App is in password recovery mode from a deep link
  passwordRecovery,

  /// Password reset email sent successfully
  passwordResetEmailSent,

  /// Password updated successfully
  passwordUpdated,

  /// Error occurred during auth operation
  failure,
}

@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    UserEntity? user,
    String? errorMessage,
    String? successMessage,
    String? unverifiedEmail,
  }) = _AuthState;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get isInitial => status == AuthStatus.initial;
  bool get isRegisteredNeedsVerification =>
      status == AuthStatus.registeredNeedsVerification;
  bool get isPasswordResetEmailSent =>
      status == AuthStatus.passwordResetEmailSent;
  bool get isPasswordUpdated => status == AuthStatus.passwordUpdated;
}
