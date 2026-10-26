import 'dart:async';

import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/jar_usecases.dart';
import 'jars_state.dart';

/// Daftar celengan: pantau, tambah, hapus.
class JarsCubit extends Cubit<JarsState> {
  JarsCubit({
    required WatchJarsUseCase watchJars,
    required AddJarUseCase addJar,
    required DeleteJarUseCase deleteJar,
    required DepositJarUseCase depositJar,
  })  : _watch = watchJars,
        _add = addJar,
        _delete = deleteJar,
        _deposit = depositJar,
        super(const JarsState());

  final WatchJarsUseCase _watch;
  final AddJarUseCase _add;
  final DeleteJarUseCase _delete;
  final DepositJarUseCase _deposit;
  StreamSubscription<dynamic>? _sub;

  void watch() {
    _sub?.cancel();
    emit(state.copyWith(status: JarsStatus.loading));
    _sub = _watch().listen((r) => r.fold(
          (f) => emit(state.copyWith(
            status: JarsStatus.failure,
            errorMessage: f.message,
          )),
          (j) => emit(state.copyWith(
            status: JarsStatus.success,
            jars: j,
            errorMessage: null,
          )),
        ));
  }

  Future<Either<Failure, void>> add(AddJarParams p) => _add(p);

  Future<Either<Failure, void>> delete(String id) => _delete(id);

  Future<Either<Failure, void>> deposit(DepositJarParams p) => _deposit(p);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
