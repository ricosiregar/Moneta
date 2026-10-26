import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/detected_transaction_entity.dart';
import '../entities/notification_source_entity.dart';
import '../repositories/notification_repository.dart';

// ── Inbox ──

class WatchPendingDetectedUseCase {
  final NotificationRepository repository;
  WatchPendingDetectedUseCase(this.repository);

  Stream<Either<Failure, List<DetectedTransactionEntity>>> call() =>
      repository.watchPending();
}

class RecordDetectedUseCase implements UseCase<bool, String> {
  final NotificationRepository repository;
  RecordDetectedUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String id) => repository.record(id);
}

class IgnoreDetectedUseCase implements UseCase<void, String> {
  final NotificationRepository repository;
  IgnoreDetectedUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) => repository.ignore(id);
}

class IgnoreAllDetectedUseCase implements UseCase<void, NoParams> {
  final NotificationRepository repository;
  IgnoreAllDetectedUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      repository.ignoreAll();
}

class ChangeDetectedWalletParams extends Equatable {
  final String id;
  final String walletId;
  const ChangeDetectedWalletParams(this.id, this.walletId);

  @override
  List<Object?> get props => [id, walletId];
}

class ChangeDetectedWalletUseCase
    implements UseCase<void, ChangeDetectedWalletParams> {
  final NotificationRepository repository;
  ChangeDetectedWalletUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangeDetectedWalletParams params) =>
      repository.changeWallet(params.id, params.walletId);
}

class ChangeDetectedTypeParams extends Equatable {
  final String id;
  final String type; // income | expense
  const ChangeDetectedTypeParams(this.id, this.type);

  @override
  List<Object?> get props => [id, type];
}

class ChangeDetectedTypeUseCase
    implements UseCase<void, ChangeDetectedTypeParams> {
  final NotificationRepository repository;
  ChangeDetectedTypeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangeDetectedTypeParams params) =>
      repository.changeType(params.id, params.type);
}

// ── Sumber notifikasi ──

class WatchSourcesUseCase {
  final NotificationRepository repository;
  WatchSourcesUseCase(this.repository);

  Stream<Either<Failure, List<NotificationSourceEntity>>> call() =>
      repository.watchSources();
}

class UpsertSourceParams extends Equatable {
  final String packageName;
  final String walletId;
  const UpsertSourceParams({required this.packageName, required this.walletId});

  @override
  List<Object?> get props => [packageName, walletId];
}

class UpsertSourceUseCase implements UseCase<void, UpsertSourceParams> {
  final NotificationRepository repository;
  UpsertSourceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpsertSourceParams params) async {
    if (params.packageName.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Nama aplikasi tidak boleh kosong'));
    }
    return repository.upsertSource(
      packageName: params.packageName.trim(),
      walletId: params.walletId,
    );
  }
}

class SetSourceEnabledParams extends Equatable {
  final String id;
  final bool enabled;
  const SetSourceEnabledParams(this.id, this.enabled);

  @override
  List<Object?> get props => [id, enabled];
}

class SetSourceEnabledUseCase
    implements UseCase<void, SetSourceEnabledParams> {
  final NotificationRepository repository;
  SetSourceEnabledUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SetSourceEnabledParams params) =>
      repository.setSourceEnabled(params.id, params.enabled);
}

class DeleteSourceUseCase implements UseCase<void, String> {
  final NotificationRepository repository;
  DeleteSourceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteSource(id);
}

// ── Pengaturan ──

class WatchCaptureEnabledUseCase {
  final NotificationRepository repository;
  WatchCaptureEnabledUseCase(this.repository);

  Stream<Either<Failure, bool>> call() => repository.watchCaptureEnabled();
}

class SetCaptureEnabledUseCase implements UseCase<void, bool> {
  final NotificationRepository repository;
  SetCaptureEnabledUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(bool enabled) =>
      repository.setCaptureEnabled(enabled);
}
