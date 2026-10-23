import 'package:Moneta/core/network/error/failures.dart';
import 'package:Moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/profile_usecases.dart';
import 'profile_state.dart';

/// Profil lokal + aksi data & backup.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetCachedProfileUseCase getCachedProfile,
    required ExportJsonUseCase exportJson,
    required ExportCsvUseCase exportCsv,
    required ImportJsonUseCase importJson,
    required ClearAllDataUseCase clearAll,
  })  : _getCached = getCachedProfile,
        _exportJson = exportJson,
        _exportCsv = exportCsv,
        _importJson = importJson,
        _clearAll = clearAll,
        super(const ProfileState());

  final GetCachedProfileUseCase _getCached;
  final ExportJsonUseCase _exportJson;
  final ExportCsvUseCase _exportCsv;
  final ImportJsonUseCase _importJson;
  final ClearAllDataUseCase _clearAll;

  Future<void> loadCached() async {
    final r = await _getCached(const NoParams());
    r.fold(
      (_) {},
      (p) => emit(state.copyWith(cachedName: p.name, cachedEmail: p.email)),
    );
  }

  /// Perbarui cache tampilan dari data akun terbaru (abaikan nilai kosong).
  void updateFromAccount({String? name, String? email}) => emit(state.copyWith(
        cachedName: (name ?? '').isNotEmpty ? name! : state.cachedName,
        cachedEmail: (email ?? '').isNotEmpty ? email! : state.cachedEmail,
      ));

  Future<Either<Failure, T>> _busy<T>(
    Future<Either<Failure, T>> Function() body,
  ) async {
    emit(state.copyWith(busy: true));
    try {
      return await body();
    } finally {
      emit(state.copyWith(busy: false));
    }
  }

  Future<Either<Failure, void>> exportJson() =>
      _busy(() => _exportJson(const NoParams()));

  Future<Either<Failure, void>> exportCsv() =>
      _busy(() => _exportCsv(const NoParams()));

  Future<Either<Failure, int>> importJson(String source) =>
      _busy(() => _importJson(source));

  Future<Either<Failure, void>> clearAll() =>
      _busy(() => _clearAll(const NoParams()));
}
