import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

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

  /// Error occurred during auth operation
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final String? unverifiedEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.unverifiedEmail,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get isInitial => status == AuthStatus.initial;
  bool get isRegisteredNeedsVerification =>
      status == AuthStatus.registeredNeedsVerification;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    String? unverifiedEmail,
    bool clearUser = false,
    bool clearError = false,
    bool clearUnverifiedEmail = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      unverifiedEmail: clearUnverifiedEmail
          ? null
          : (unverifiedEmail ?? this.unverifiedEmail),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, unverifiedEmail];
}
