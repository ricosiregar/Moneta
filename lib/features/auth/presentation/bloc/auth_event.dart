import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/auth_state_entity.dart';

part 'auth_event.freezed.dart';

@freezed
abstract class AuthEvent with _$AuthEvent {
  /// Dispatched on app startup to start listening to the reactive auth state stream
  const factory AuthEvent.subscriptionRequested() = AuthSubscriptionRequested;

  /// Internal event dispatched when authStateChanges stream yields an auth event
  const factory AuthEvent.userChanged(AuthStateEntity authStateEntity) =
      AuthUserChanged;

  /// Dispatched when user submits the login form
  const factory AuthEvent.loginSubmitted({
    required String email,
    required String password,
  }) = LoginSubmitted;

  /// Dispatched when user submits the register form
  const factory AuthEvent.registerSubmitted({
    required String email,
    required String password,
    required String fullName,
  }) = RegisterSubmitted;

  /// Dispatched when user clicks Sign in with Google
  const factory AuthEvent.googleSignInSubmitted() = GoogleSignInSubmitted;

  /// Dispatched when user submits the forgot password form
  const factory AuthEvent.forgotPasswordSubmitted({
    required String email,
  }) = ForgotPasswordSubmitted;

  /// Dispatched when user submits a new password from the reset password page
  const factory AuthEvent.updatePasswordSubmitted({
    required String newPassword,
  }) = UpdatePasswordSubmitted;

  /// Dispatched when user logs out
  const factory AuthEvent.logoutRequested() = LogoutRequested;
}
