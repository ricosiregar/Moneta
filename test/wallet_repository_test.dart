import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneta/core/database/app_database.dart';
import 'package:moneta/core/database/wallet_repository.dart';

void main() {
  late AppDatabase db;
  late WalletRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = WalletRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Ecosystem child wallets receive their opening balances', () async {
    await repo.saveWalletWithEcosystemChildren(
      id: 'parent_superbank',
      name: 'Superbank',
      type: 'bank',
      isIncomeSource: true,
      openingBalance: 1000000,
      ecosystemChildren: [
        (
          name: 'OVO',
          type: 'e_wallet',
          purpose: 'E-Wallet Grab & OVO',
          openingBalance: 250000,
        ),
      ],
    );

    final wallets = await repo.watchWallets().first;
    expect(wallets.length, equals(2));

    final parent = wallets.firstWhere((w) => w.id == 'parent_superbank');
    expect(parent.openingBalance, equals(1000000));
    expect(parent.balance, equals(1000000));

    final child = wallets.firstWhere((w) => w.name == 'OVO');
    expect(child.parentId, equals('parent_superbank'));
    expect(child.openingBalance, equals(250000));
    expect(child.balance, equals(250000));
  });
}
