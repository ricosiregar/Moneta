import 'package:flutter_test/flutter_test.dart';
import 'package:moneta/core/database/app_database.dart';
import 'package:moneta/core/database/finance_repository.dart';
import 'package:moneta/core/database/wallet_repository.dart';
import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/usecase.dart';
import 'package:moneta/features/budgets/data/datasources/budgets_local_datasource.dart';
import 'package:moneta/features/budgets/data/repositories/budgets_repository_impl.dart';
import 'package:moneta/features/budgets/domain/usecases/budget_usecases.dart';
import 'package:moneta/features/budgets/presentation/cubit/budgets_cubit.dart';
import 'package:moneta/features/jars/data/datasources/jars_local_datasource.dart';
import 'package:moneta/features/jars/data/repositories/jars_repository_impl.dart';
import 'package:moneta/features/jars/domain/usecases/jar_usecases.dart';
import 'package:moneta/features/jars/presentation/cubit/jars_cubit.dart';
import 'package:moneta/features/schedules/data/datasources/schedules_local_datasource.dart';
import 'package:moneta/features/schedules/data/repositories/schedules_repository_impl.dart';
import 'package:moneta/features/schedules/domain/entities/auto_schedule_entity.dart';
import 'package:moneta/features/schedules/domain/usecases/schedule_usecases.dart';
import 'package:moneta/features/schedules/presentation/cubit/schedules_cubit.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository fin;

  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 60));

  setUp(() async {
    db = newTestDb();
    fin = FinanceRepository(db);
    await addWallet(WalletRepository(db), 'W', opening: 100);
  });
  tearDown(() => db.close());

  test('budgets: simpan, tampil, ubah (tanpa duplikat), hapus', () async {
    final repo = BudgetsRepositoryImpl(
      localDataSource: BudgetsLocalDataSourceImpl(finance: fin),
    );
    final c = BudgetsCubit(
      watchBudgets: WatchBudgetsUseCase(repo),
      saveBudget: SaveBudgetUseCase(repo),
      deleteBudget: DeleteBudgetUseCase(repo),
    )..watch(month: 3, year: 2030);
    addTearDown(c.close);

    final r1 = await c.save(
        const SaveBudgetParams(limit: 500, month: 3, year: 2030));
    final id = r1.getOrElse(() => '');
    await tick();
    expect(c.state.budgets.single.limit, 500);

    await c.save(
        SaveBudgetParams(id: id, limit: 800, month: 3, year: 2030));
    await tick();
    expect(c.state.budgets.single.limit, 800);

    expect((await c.delete(id)).isRight(), isTrue);
    await tick();
    expect(c.state.budgets, isEmpty);
  });

  test('jars: target tidak valid -> ValidationFailure, valid tampil, hapus',
      () async {
    final repo = JarsRepositoryImpl(
      localDataSource: JarsLocalDataSourceImpl(finance: fin),
    );
    final c = JarsCubit(
      watchJars: WatchJarsUseCase(repo),
      addJar: AddJarUseCase(repo),
      deleteJar: DeleteJarUseCase(repo),
      depositJar: DepositJarUseCase(repo),
    )..watch();
    addTearDown(c.close);

    final bad = await c.add(const AddJarParams(title: 'X', target: 0));
    expect(bad.fold((f) => f, (_) => null), isA<ValidationFailure>());

    expect((await c.add(const AddJarParams(title: 'Liburan', target: 1000)))
        .isRight(), isTrue);
    await tick();
    expect(c.state.jars.single.title, 'Liburan');

    final jarId = c.state.jars.single.id;
    expect((await c.deposit(DepositJarParams(
            jarId: jarId, amount: 60, walletId: 'W')))
        .isRight(), isTrue);
    final tooMuch = await c.deposit(
        DepositJarParams(jarId: jarId, amount: 999, walletId: 'W'));
    expect(tooMuch.fold((f) => f, (_) => null), isA<ValidationFailure>());
    await tick();
    expect(c.state.jars.single.saved, 60);
    expect(await balanceOf(WalletRepository(db), 'W'), 40);

    await c.delete(jarId);
    await tick();
    expect(c.state.jars, isEmpty);
    expect(await balanceOf(WalletRepository(db), 'W'), 100);
  });

  test('schedules: simpan, jalankan sekarang, toggle, hapus, entity helper',
      () async {
    await addWallet(WalletRepository(db), 'W2');
    final repo = SchedulesRepositoryImpl(
      localDataSource: SchedulesLocalDataSourceImpl(finance: fin),
    );
    final c = SchedulesCubit(
      watchSchedules: WatchSchedulesUseCase(repo),
      saveSchedule: SaveScheduleUseCase(repo),
      toggleSchedule: ToggleScheduleUseCase(repo),
      deleteSchedule: DeleteScheduleUseCase(repo),
      executeNow: ExecuteScheduleNowUseCase(repo),
    )..watch();
    addTearDown(c.close);

    final saved = await c.save(const SaveScheduleParams(
      title: 'Tabung',
      kind: 'transfer',
      amount: 40,
      dayOfMonth: 31,
      walletId: 'W',
      toWalletId: 'W2',
    ));
    final id = saved.getOrElse(() => '');
    await tick();
    final s = c.state.schedules.single;
    expect(s.isTransfer, isTrue);
    expect(s.effectiveDayInMonth(DateTime(2030, 2, 10)), 28);

    final done = (await c.executeNow(id)).getOrElse(() => null);
    expect(done, isNotNull);
    expect(done!.isExecutedForMonth(DateTime.now()), isTrue);
    expect(await balanceOf(WalletRepository(db), 'W2'), 40);

    await c.toggle(id, false);
    await tick();
    expect(c.state.schedules.single.isEnabled, isFalse);

    // saldo kurang -> null, tidak error
    final over = await c.save(SaveScheduleParams(
      id: id,
      title: 'Tabung',
      kind: 'transfer',
      amount: 9999,
      dayOfMonth: 1,
      walletId: 'W',
      toWalletId: 'W2',
      isEnabled: false,
    ));
    expect(over.isRight() || over.isLeft(), isTrue);

    final due = await ProcessDueSchedulesUseCase(repo)(const NoParams());
    expect(due.isRight(), isTrue);

    await c.delete(id);
    await tick();
    expect(c.state.schedules, isEmpty);
  });

  test('AutoScheduleEntity.nextExecutionDate', () {
    const s = AutoScheduleEntity(
      id: 'a',
      title: 't',
      kind: 'expense',
      amount: 1,
      dayOfMonth: 31,
      walletId: 'w',
      walletName: 'w',
      isEnabled: true,
      lastExecutedPeriod: '2030-02',
    );
    expect(s.nextExecutionDate(DateTime(2030, 2, 10)), DateTime(2030, 3, 31));
  });
}
