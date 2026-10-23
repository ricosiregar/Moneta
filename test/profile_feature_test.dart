import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Moneta/core/backup/backup_service.dart';
import 'package:Moneta/core/database/app_database.dart';
import 'package:Moneta/core/database/wallet_repository.dart';
import 'package:Moneta/core/network/error/failures.dart';
import 'package:Moneta/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:Moneta/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:Moneta/features/profile/domain/usecases/profile_usecases.dart';
import 'package:Moneta/features/profile/presentation/cubit/profile_cubit.dart';

import 'support/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProfileCubit cubitFor(AppDatabase db) {
    final repo = ProfileRepositoryImpl(
      localDataSource:
          ProfileLocalDataSourceImpl(backup: BackupService(db)),
    );
    return ProfileCubit(
      getCachedProfile: GetCachedProfileUseCase(repo),
      exportJson: ExportJsonUseCase(repo),
      exportCsv: ExportCsvUseCase(repo),
      importJson: ImportJsonUseCase(repo),
      clearAll: ClearAllDataUseCase(repo),
    );
  }

  test('profil tersimpan dibaca dari prefs dan bisa diperbarui', () async {
    SharedPreferences.setMockInitialValues(
        {'user_name': 'Rico', 'saved_email': 'r@x.id'});
    final db = newTestDb();
    addTearDown(db.close);
    final c = cubitFor(db);
    addTearDown(c.close);

    await c.loadCached();
    expect(c.state.cachedName, 'Rico');
    expect(c.state.cachedEmail, 'r@x.id');

    c.updateFromAccount(name: '', email: 'baru@x.id');
    expect(c.state.cachedName, 'Rico'); // kosong diabaikan
    expect(c.state.cachedEmail, 'baru@x.id');
  });

  test('impor: berkas rusak -> ValidationFailure; cadangan valid dipulihkan',
      () async {
    final src = newTestDb();
    addTearDown(src.close);
    await addWallet(WalletRepository(src), 'W', opening: 70);
    final json = await BackupService(src).buildJson();

    final dst = newTestDb();
    addTearDown(dst.close);
    final c = cubitFor(dst);
    addTearDown(c.close);

    final bad = await c.importJson('bukan json');
    expect(bad.fold((f) => f, (_) => null), isA<ValidationFailure>());
    expect(await activeCount(dst, 'wallets'), 0);

    final seen = <int>[];
    final sub = WalletRepository(dst).watchWallets().listen((w) => seen.add(w.length));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final ok = await c.importJson(json);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(seen.last, 1); // stream ikut segar tanpa sinkron
    await sub.cancel();
    expect(ok.getOrElse(() => 0), greaterThan(0));
    expect(await activeCount(dst, 'wallets'), 1);
    expect(c.state.busy, isFalse);
  });

  test('hapus semua data mengosongkan tabel', () async {
    final db = newTestDb();
    addTearDown(db.close);
    await addWallet(WalletRepository(db), 'W', opening: 10);
    final c = cubitFor(db);
    addTearDown(c.close);

    // UI mengamati stream: harus langsung kosong tanpa sinkron.
    final stream = WalletRepository(db).watchWallets();
    final seen = <int>[];
    final sub = stream.listen((w) => seen.add(w.length));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(seen.last, 1);

    expect((await c.clearAll()).isRight(), isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(seen.last, 0);
    await sub.cancel();
    expect(await activeCount(db, 'wallets'), 0);
  });
}
