import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../network/error/failures.dart';

/// Base UseCase contract for executing domain logic asynchronously
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use when a UseCase does not require any parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
