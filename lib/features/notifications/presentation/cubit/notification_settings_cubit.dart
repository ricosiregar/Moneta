import 'dart:async';

import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/notification_usecases.dart';
import 'notification_settings_state.dart';

/// Pengaturan deteksi: saklar aktif dan daftar aplikasi yang dipantau.
class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit({
    required WatchSourcesUseCase watchSources,
    required WatchCaptureEnabledUseCase watchCaptureEnabled,
    required SetCaptureEnabledUseCase setCaptureEnabled,
    required UpsertSourceUseCase upsertSource,
    required SetSourceEnabledUseCase setSourceEnabled,
    required DeleteSourceUseCase deleteSource,
  })  : _watchSources = watchSources,
        _watchCaptureEnabled = watchCaptureEnabled,
        _setCaptureEnabled = setCaptureEnabled,
        _upsertSource = upsertSource,
        _setSourceEnabled = setSourceEnabled,
        _deleteSource = deleteSource,
        super(const NotificationSettingsState());

  final WatchSourcesUseCase _watchSources;
  final WatchCaptureEnabledUseCase _watchCaptureEnabled;
  final SetCaptureEnabledUseCase _setCaptureEnabled;
  final UpsertSourceUseCase _upsertSource;
  final SetSourceEnabledUseCase _setSourceEnabled;
  final DeleteSourceUseCase _deleteSource;

  StreamSubscription<dynamic>? _sourcesSub;
  StreamSubscription<dynamic>? _captureSub;

  void start() {
    _sourcesSub?.cancel();
    _captureSub?.cancel();
    _sourcesSub = _watchSources().listen((r) => r.fold(
          (f) => emit(state.copyWith(errorMessage: f.message)),
          (list) => emit(state.copyWith(sources: list, errorMessage: null)),
        ));
    _captureSub = _watchCaptureEnabled().listen((r) => r.fold(
          (f) => emit(state.copyWith(errorMessage: f.message)),
          (on) => emit(state.copyWith(captureEnabled: on)),
        ));
  }

  Future<Either<Failure, void>> setCaptureEnabled(bool on) =>
      _setCaptureEnabled(on);

  Future<Either<Failure, void>> addSource({
    required String packageName,
    required String walletId,
  }) =>
      _upsertSource(
          UpsertSourceParams(packageName: packageName, walletId: walletId));

  Future<Either<Failure, void>> setSourceEnabled(String id, bool enabled) =>
      _setSourceEnabled(SetSourceEnabledParams(id, enabled));

  Future<Either<Failure, void>> deleteSource(String id) => _deleteSource(id);

  @override
  Future<void> close() {
    _sourcesSub?.cancel();
    _captureSub?.cancel();
    return super.close();
  }
}
