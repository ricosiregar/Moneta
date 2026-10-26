import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/auth_signup_result.dart';
import '../entities/auth_state_entity.dart';
import '../entities/user_entity.dart';

/// Domain repository contract for Authentication
abstract class AuthRepository {
  /// Reactive stream of the current authentication state and user
  Stream<AuthStateEntity> get authStateChanges;

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register a new account with email, password, and full name
  Future<Either<Failure, AuthSignUpResult>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign in with Google OAuth
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Update password with new password
  Future<Either<Failure, void>> updatePassword(String newPassword);

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Get current cached / active authenticated user (one-time check)
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
