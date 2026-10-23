import 'package:flutter_test/flutter_test.dart';
import 'package:Moneta/core/database/app_database.dart';
import 'package:Moneta/core/database/wallet_repository.dart';
import 'package:Moneta/core/network/error/failures.dart';
import 'package:Moneta/core/utils/usecase.dart';
import 'package:Moneta/features/wallets/data/datasources/wallets_local_datasource.dart';
import 'package:Moneta/features/wallets/data/repositories/wallets_repository_impl.dart';
import 'package:Moneta/features/wallets/domain/entities/ecosystem_child_entity.dart';
import 'package:Moneta/features/wallets/domain/usecases/wallet_usecases.dart';
import 'package:Moneta/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:Moneta/features/wallets/presentation/cubit/wallets_state.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late WalletsRepositoryImpl repo;
  late WalletsCubit cubit;

  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 60));

  setUp(() {
    db = newTestDb();
    repo = WalletsRepositoryImpl(
      localDataSource:
          WalletsLocalDataSourceImpl(wallets: WalletRepository(db)),
    );
    cubit = WalletsCubit(
      watchWallets: WatchWalletsUseCase(repo),
      getAllocations: GetAllocationsUseCase(repo),
      saveWallet: SaveWalletUseCase(repo),
      deleteWallet: DeleteWalletUseCase(repo),
      saveAllocations: SaveAllocationsUseCase(repo),
      createTransfer: CreateTransferUseCase(repo),
    )..watch();
  });
  tearDown(() async {
    await cubit.close();
    await db.close();
  });

  Future<void> save(String id, String name,
          {double opening = 0, String? parentId}) async =>
      (await cubit.save(SaveWalletParams(
        id: id,
        name: name,
        type: 'cash',
        openingBalance: opening,
        parentId: parentId,
      )))
          .fold((f) => throw StateError(f.message), (_) {});

  test('simpan dompet tampil di state; nama kosong ditolak', () async {
    final bad = await cubit.save(const SaveWalletParams(name: '  ', type: 'cash'));
    expect(bad.fold((f) => f, (_) => null), isA<ValidationFailure>());

    await save('A', 'Tunai', opening: 100);
    await tick();
    expect(cubit.state.status, WalletsStatus.success);
    expect(cubit.state.wallets.single.balance, 100);
  });

  test('ekosistem: anak dibuat bersama induk', () async {
    final r = await cubit.save(const SaveWalletParams(
      id: 'P',
      name: 'Bank',
      type: 'bank',
      ecosystemChildren: [
        EcosystemChildEntity(name: 'Tabungan', type: 'bank', purpose: 'saving'),
      ],
    ));
    expect(r.isRight(), isTrue);
    await tick();
    expect(cubit.state.wallets.length, 2);
    expect(
        cubit.state.wallets.where((w) => w.parentId == 'P').length, 1);
  });

  test('transfer: saldo kurang -> Failure, saldo tidak berubah', () async {
    await save('A', 'A', opening: 50);
    await save('B', 'B');
    final r = await cubit.transfer(const CreateTransferParams(
        fromWalletId: 'A', toWalletId: 'B', amount: 100));
    expect(r.fold((f) => f, (_) => null), isA<ValidationFailure>());

    final ok = await cubit.transfer(const CreateTransferParams(
        fromWalletId: 'A', toWalletId: 'B', amount: 30, fee: 5));
    expect(ok.isRight(), isTrue);
    await tick();
    final byId = {for (final w in cubit.state.wallets) w.id: w.balance};
    expect(byId['A'], 15);
    expect(byId['B'], 30);
  });

  test('alokasi: simpan aturan lalu distribusikan saldo', () async {
    await save('S', 'Gaji', opening: 100);
    await save('X', 'X');
    await save('Y', 'Y');

    final over = await cubit.saveAllocations(const SaveAllocationsParams(
        sourceWalletId: 'S', percents: {'X': 70, 'Y': 40}));
    expect(over.fold((f) => f, (_) => null), isA<ValidationFailure>());

    final r = await cubit.saveAllocations(const SaveAllocationsParams(
      sourceWalletId: 'S',
      percents: {'X': 60, 'Y': 40},
      distributeAmount: 100,
    ));
    expect(r.isRight(), isTrue);
    await tick();
    final byId = {for (final w in cubit.state.wallets) w.id: w.balance};
    expect(byId['X'], 60);
    expect(byId['Y'], 40);
    expect(byId['S'], 0);

    final rules = (await cubit.allocations('S')).getOrElse(() => const []);
    expect(rules.length, 2);
  });

  test('hapus dompet: hilang dari state', () async {
    await save('A', 'A');
    await tick();
    expect((await cubit.delete('A')).isRight(), isTrue);
    await tick();
    expect(cubit.state.wallets, isEmpty);
  });

  test('GetWalletsUseCase mengembalikan emisi pertama', () async {
    await save('A', 'A', opening: 9);
    final r = await GetWalletsUseCase(repo)(const NoParams());
    expect(r.getOrElse(() => const []).single.openingBalance, 9);
  });
}
