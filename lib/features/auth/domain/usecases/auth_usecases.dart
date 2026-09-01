import 'package:Moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/auth_signup_result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Stream UseCase to listen to live auth state changes
class GetAuthStateStreamUseCase {
  final AuthRepository repository;

  GetAuthStateStreamUseCase(this.repository);

  Stream<UserEntity?> call() => repository.authStateChanges;
}

/// UseCase to sign in with email & password
class SignInWithEmailUseCase
    implements UseCase<UserEntity, SignInWithEmailParams> {
  final AuthRepository repository;

  SignInWithEmailUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) {
    return repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithEmailParams extends Equatable {
  final String email;
  final String password;

  const SignInWithEmailParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// UseCase to register with email, password, and full name
class SignUpWithEmailUseCase
    implements UseCase<AuthSignUpResult, SignUpWithEmailParams> {
  final AuthRepository repository;

  SignUpWithEmailUseCase(this.repository);

  @override
  Future<Either<Failure, AuthSignUpResult>> call(SignUpWithEmailParams params) {
    return repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
    );
  }
}

class SignUpWithEmailParams extends Equatable {
  final String email;
  final String password;
  final String fullName;

  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

/// UseCase to sign in with Google OAuth
class SignInWithGoogleUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}

/// UseCase to sign out
class SignOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}

/// UseCase to get the currently cached / active user
class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    final result = await repository.getCurrentUser();
    return result.fold((failure) => Left(failure), (user) {
      if (user != null) {
        return Right(user);
      } else {
        return const Left(AuthFailure(message: 'No active session.'));
      }
    });
  }
}
