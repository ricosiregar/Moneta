import 'dart:async';

import 'package:Moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auto_schedule_entity.dart';
import '../../domain/usecases/schedule_usecases.dart';
import 'schedules_state.dart';

/// Jadwal otomatis: pantau daftar, simpan, aktif/nonaktif, hapus, jalankan.
class SchedulesCubit extends Cubit<SchedulesState> {
  SchedulesCubit({
    required WatchSchedulesUseCase watchSchedules,
    required SaveScheduleUseCase saveSchedule,
    required ToggleScheduleUseCase toggleSchedule,
    required DeleteScheduleUseCase deleteSchedule,
    required ExecuteScheduleNowUseCase executeNow,
  })  : _watch = watchSchedules,
        _save = saveSchedule,
        _toggle = toggleSchedule,
        _delete = deleteSchedule,
        _execute = executeNow,
        super(const SchedulesState());

  final WatchSchedulesUseCase _watch;
  final SaveScheduleUseCase _save;
  final ToggleScheduleUseCase _toggle;
  final DeleteScheduleUseCase _delete;
  final ExecuteScheduleNowUseCase _execute;
  StreamSubscription<dynamic>? _sub;

  void watch() {
    _sub?.cancel();
    emit(state.copyWith(status: SchedulesStatus.loading));
    _sub = _watch().listen((r) => r.fold(
          (f) => emit(state.copyWith(
            status: SchedulesStatus.failure,
            errorMessage: f.message,
          )),
          (s) => emit(state.copyWith(
            status: SchedulesStatus.success,
            schedules: s,
            errorMessage: null,
          )),
        ));
  }

  Future<Either<Failure, String>> save(SaveScheduleParams p) => _save(p);

  Future<Either<Failure, void>> toggle(String id, bool enabled) =>
      _toggle(ToggleScheduleParams(id, enabled));

  Future<Either<Failure, void>> delete(String id) => _delete(id);

  Future<Either<Failure, AutoScheduleEntity?>> executeNow(String id) =>
      _execute(id);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
