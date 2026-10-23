import 'dart:async';

import 'package:Moneta/core/database/finance_exception.dart';
import 'package:Moneta/core/network/error/failures.dart';
import 'package:Moneta/core/utils/app_error_formatter.dart';
import 'package:dartz/dartz.dart';

/// Ubah exception database lokal menjadi [Failure].
Failure toLocalFailure(Object e) {
  if (e is FinanceException) return ValidationFailure(message: e.message);
  return CacheFailure(message: AppErrorFormatter.format(e));
}

Future<Either<Failure, T>> guardLocal<T>(Future<T> Function() body) async {
  try {
    return Right(await body());
  } catch (e) {
    return Left(toLocalFailure(e));
  }
}

/// Bungkus stream data menjadi stream [Either] (error stream -> Left).
Stream<Either<Failure, R>> guardStream<T, R>(
  Stream<T> source,
  R Function(T) map,
) =>
    source.transform(
      StreamTransformer<T, Either<Failure, R>>.fromHandlers(
        handleData: (v, sink) {
          try {
            sink.add(Right(map(v)));
          } catch (e) {
            sink.add(Left(toLocalFailure(e)));
          }
        },
        handleError: (e, _, sink) => sink.add(Left(toLocalFailure(e))),
      ),
    );
