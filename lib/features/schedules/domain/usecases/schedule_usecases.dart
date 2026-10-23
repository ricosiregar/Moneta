import 'package:Moneta/core/network/error/failures.dart';
import 'package:Moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/auto_schedule_entity.dart';
import '../repositories/schedules_repository.dart';

class WatchSchedulesUseCase {
  final SchedulesRepository repository;
  WatchSchedulesUseCase(this.repository);

  Stream<Either<Failure, List<AutoScheduleEntity>>> call() =>
      repository.watchSchedules();
}

class SaveScheduleParams extends Equatable {
  final String? id;
  final String title;
  final String kind;
  final double amount;
  final int dayOfMonth;
  final String walletId;
  final String? toWalletId;
  final String? categoryId;
  final String? budgetId;
  final String? note;
  final bool isEnabled;
  final bool executeNowForCurrentMonth;

  const SaveScheduleParams({
    this.id,
    required this.title,
    required this.kind,
    required this.amount,
    required this.dayOfMonth,
    required this.walletId,
    this.toWalletId,
    this.categoryId,
    this.budgetId,
    this.note,
    this.isEnabled = true,
    this.executeNowForCurrentMonth = false,
  });

  @override
  List<Object?> get props => [
        id, title, kind, amount, dayOfMonth, walletId, toWalletId, categoryId,
        budgetId, note, isEnabled, executeNowForCurrentMonth,
      ];
}

class SaveScheduleUseCase implements UseCase<String, SaveScheduleParams> {
  final SchedulesRepository repository;
  SaveScheduleUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SaveScheduleParams p) =>
      repository.saveSchedule(
        id: p.id,
        title: p.title,
        kind: p.kind,
        amount: p.amount,
        dayOfMonth: p.dayOfMonth,
        walletId: p.walletId,
        toWalletId: p.toWalletId,
        categoryId: p.categoryId,
        budgetId: p.budgetId,
        note: p.note,
        isEnabled: p.isEnabled,
        executeNowForCurrentMonth: p.executeNowForCurrentMonth,
      );
}

class ToggleScheduleParams extends Equatable {
  final String id;
  final bool isEnabled;
  const ToggleScheduleParams(this.id, this.isEnabled);

  @override
  List<Object?> get props => [id, isEnabled];
}

class ToggleScheduleUseCase implements UseCase<void, ToggleScheduleParams> {
  final SchedulesRepository repository;
  ToggleScheduleUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleScheduleParams p) =>
      repository.toggleSchedule(p.id, p.isEnabled);
}

class DeleteScheduleUseCase implements UseCase<void, String> {
  final SchedulesRepository repository;
  DeleteScheduleUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteSchedule(id);
}

class ExecuteScheduleNowUseCase implements UseCase<AutoScheduleEntity?, String> {
  final SchedulesRepository repository;
  ExecuteScheduleNowUseCase(this.repository);

  /// Aksi manual user ("Jalankan sekarang"): selalu force.
  @override
  Future<Either<Failure, AutoScheduleEntity?>> call(String id) =>
      repository.executeNow(id, force: true);
}

class ProcessDueSchedulesUseCase
    implements UseCase<List<AutoScheduleEntity>, NoParams> {
  final SchedulesRepository repository;
  ProcessDueSchedulesUseCase(this.repository);

  @override
  Future<Either<Failure, List<AutoScheduleEntity>>> call(NoParams params) =>
      repository.processDue();
}
