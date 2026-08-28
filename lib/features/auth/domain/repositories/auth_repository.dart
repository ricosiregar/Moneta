import 'package:Moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

/// Domain repository contract for Authentication
abstract class AuthRepository {
  /// Reactive stream of the current authenticated user (emits null on logout/expired session)
  Stream<UserEntity?> get authStateChanges;

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register a new account with email, password, and full name
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign in with Google OAuth
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Get current cached / active authenticated user (one-time check)
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
