import 'package:Moneta/core/network/error/exceptions.dart';
import 'package:Moneta/core/network/error/failures.dart';
import 'package:Moneta/core/utils/app_error_formatter.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/auth_signup_result.dart';
import '../../domain/entities/auth_state_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<AuthStateEntity> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: AppErrorFormatter.format(e.message)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e.message), statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: AppErrorFormatter.format(e.message)));
    } catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e)));
    }
  }

  @override
  Future<Either<Failure, AuthSignUpResult>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final result = await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: AppErrorFormatter.format(e.message)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e.message), statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: AppErrorFormatter.format(e.message)));
    } catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: AppErrorFormatter.format(e.message)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e.message), statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: AppErrorFormatter.format(e.message)));
    } catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e)));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: AppErrorFormatter.format(e.message)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e.message), statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: AppErrorFormatter.format(e.message)));
    } catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e)));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: AppErrorFormatter.format(e.message)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e.message), statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: AppErrorFormatter.format(e.message)));
    } catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e)));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: AppErrorFormatter.format(e.message)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e.message), statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: AppErrorFormatter.format(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = remoteDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: AppErrorFormatter.format(e)));
    }
  }
}
