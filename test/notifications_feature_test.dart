import 'package:flutter_test/flutter_test.dart';
import 'package:Moneta/core/database/app_database.dart';
import 'package:Moneta/core/database/detected_repository.dart';
import 'package:Moneta/core/database/wallet_repository.dart';
import 'package:Moneta/core/utils/usecase.dart';
import 'package:Moneta/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:Moneta/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:Moneta/features/notifications/domain/entities/detected_transaction_entity.dart';
import 'package:Moneta/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:Moneta/features/notifications/presentation/cubit/detected_inbox_cubit.dart';
import 'package:Moneta/features/notifications/presentation/cubit/detected_inbox_state.dart';
import 'package:Moneta/features/notifications/presentation/cubit/notification_settings_cubit.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late DetectedRepository detected;
  late NotificationRepositoryImpl repo;

  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 60));

  setUp(() async {
    db = newTestDb();
    detected = DetectedRepository(db);
    repo = NotificationRepositoryImpl(
      localDataSource: NotificationLocalDataSourceImpl(detected: detected),
    );
    await addWallet(WalletRepository(db), 'W', opening: 1000);
  });
  tearDown(() => db.close());

  DetectedInboxCubit inbox() => DetectedInboxCubit(
        watchPending: WatchPendingDetectedUseCase(repo),
        record: RecordDetectedUseCase(repo),
        ignore: IgnoreDetectedUseCase(repo),
        ignoreAll: IgnoreAllDetectedUseCase(repo),
        changeWallet: ChangeDetectedWalletUseCase(repo),
      );

  Future<void> add(String fp, double amount, {String type = 'expense'}) =>
      detected.addDetected(
        fingerprint: fp,
        walletId: 'W',
        sourcePackage: 'com.bank',
        amount: amount,
        type: type,
        detectedAt: DateTime.now(),
      );

  test('inbox menampilkan pending lalu record -> true sekali, hilang dari inbox',
      () async {
    await add('a', 50);
    final cubit = inbox()..watch();
    addTearDown(cubit.close);
    await tick();
    expect(cubit.state.status, DetectedInboxStatus.success);
    expect(cubit.state.items.single.type, DetectedType.expense);

    final id = cubit.state.items.single.id;
    expect((await cubit.record(id)).getOrElse(() => false), isTrue);
    expect((await cubit.record(id)).getOrElse(() => true), isFalse);
    await tick();
    expect(cubit.state.items, isEmpty);
    expect(await activeCount(db, 'transactions'), 1);
  });

  test('ignore dan ignoreAll mengosongkan inbox tanpa membuat transaksi',
      () async {
    await add('a', 10);
    await add('b', 20);
    await add('c', 30, type: 'income');
    final cubit = inbox()..watch();
    addTearDown(cubit.close);
    await tick();
    expect(cubit.state.items.length, 3);

    await cubit.ignore(cubit.state.items.first.id);
    await tick();
    expect(cubit.state.items.length, 2);

    await cubit.ignoreAll();
    await tick();
    expect(cubit.state.items, isEmpty);
    expect(await activeCount(db, 'transactions'), 0);
  });

  test('settings: tambah sumber, nonaktifkan, hapus, saklar deteksi', () async {
    final cubit = NotificationSettingsCubit(
      watchSources: WatchSourcesUseCase(repo),
      watchCaptureEnabled: WatchCaptureEnabledUseCase(repo),
      setCaptureEnabled: SetCaptureEnabledUseCase(repo),
      upsertSource: UpsertSourceUseCase(repo),
      setSourceEnabled: SetSourceEnabledUseCase(repo),
      deleteSource: DeleteSourceUseCase(repo),
    )..start();
    addTearDown(cubit.close);

    expect(
        (await cubit.addSource(packageName: '  ', walletId: 'W')).isLeft(),
        isTrue);

    await cubit.addSource(packageName: 'com.bank', walletId: 'W');
    await tick();
    expect(cubit.state.sources.single.packageName, 'com.bank');
    expect(cubit.state.sources.single.isEnabled, isTrue);

    final id = cubit.state.sources.single.id;
    await cubit.setSourceEnabled(id, false);
    await tick();
    expect(cubit.state.sources.single.isEnabled, isFalse);

    await cubit.setCaptureEnabled(true);
    await tick();
    expect(cubit.state.captureEnabled, isTrue);

    await cubit.deleteSource(id);
    await tick();
    expect(cubit.state.sources, isEmpty);
  });

  test('IgnoreAll memakai NoParams (kontrak usecase)', () async {
    await add('a', 5);
    final r = await IgnoreAllDetectedUseCase(repo)(const NoParams());
    expect(r.isRight(), isTrue);
  });
}
