import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/home_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

enum HomeStatus { initial, loading, success, failure }

class HomeState {
  final HomeStatus status;
  final List<WalletModel> wallets;
  final List<TransactionModel> recentTransactions;
  final double totalBalance;
  final double totalExpense;
  final TransactionPeriod selectedPeriod;
  final bool isAddingWallet;
  final bool isAddingTransaction;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.wallets = const [],
    this.recentTransactions = const [],
    this.totalBalance = 0,
    this.totalExpense = 0,
    this.selectedPeriod = TransactionPeriod.monthly,
    this.isAddingWallet = false,
    this.isAddingTransaction = false,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<WalletModel>? wallets,
    List<TransactionModel>? recentTransactions,
    double? totalBalance,
    double? totalExpense,
    TransactionPeriod? selectedPeriod,
    bool? isAddingWallet,
    bool? isAddingTransaction,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      totalBalance: totalBalance ?? this.totalBalance,
      totalExpense: totalExpense ?? this.totalExpense,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isAddingWallet: isAddingWallet ?? this.isAddingWallet,
      isAddingTransaction: isAddingTransaction ?? this.isAddingTransaction,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Expense dihitung ulang dari recentTransactions sesuai periode yang dipilih
  double get filteredExpense {
    final now = DateTime.now();
    late DateTime cutoff;
    switch (selectedPeriod) {
      case TransactionPeriod.daily:
        cutoff = DateTime(now.year, now.month, now.day);
        break;
      case TransactionPeriod.weekly:
        cutoff = DateTime(
          now.year,
          now.month,
          now.day - (now.weekday - 1),
        );
        break;
      case TransactionPeriod.monthly:
        cutoff = DateTime(now.year, now.month, 1);
        break;
    }
    return recentTransactions
        .where((tx) => tx.isExpense && tx.date.isAfter(cutoff))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super(const HomeState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final wallets = await _repository.getWallets();
      final transactions = await _repository.getTransactionsByPeriod(
        state.selectedPeriod,
      );
      final totalBalance = await _repository.getTotalBalance();

      // expense dihitung dari filtered state
      emit(
        state.copyWith(
          status: HomeStatus.success,
          wallets: wallets,
          recentTransactions: transactions,
          totalBalance: totalBalance,
          totalExpense: 0, // tidak dipakai langsung, pakai filteredExpense
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> changePeriod(TransactionPeriod period) async {
    if (state.selectedPeriod == period) return;
    emit(state.copyWith(
      selectedPeriod: period,
      status: HomeStatus.loading,
    ));
    try {
      final transactions = await _repository.getTransactionsByPeriod(period);
      emit(state.copyWith(
        status: HomeStatus.success,
        recentTransactions: transactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addWallet({
    required String name,
    required String type,
    required double balance,
    required String icon,
    required String color,
  }) async {
    emit(state.copyWith(isAddingWallet: true));
    try {
      final newWallet = await _repository.addWallet(
        name: name,
        type: type,
        balance: balance,
        icon: icon,
        color: color,
      );
      final updatedWallets = [...state.wallets, newWallet];
      final newTotalBalance =
          updatedWallets.fold(0.0, (s, w) => s + w.balance);
      emit(state.copyWith(
        isAddingWallet: false,
        wallets: updatedWallets,
        totalBalance: newTotalBalance,
      ));
    } catch (e) {
      emit(state.copyWith(
        isAddingWallet: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    String? walletId,
    String? categoryId,
    DateTime? date,
    String? note,
  }) async {
    emit(state.copyWith(isAddingTransaction: true));
    try {
      await _repository.addTransaction(
        title: title,
        amount: amount,
        type: type,
        walletId: walletId,
        categoryId: categoryId,
        date: date,
        note: note,
      );
      emit(state.copyWith(isAddingTransaction: false));
      await loadDashboard();
    } catch (e) {
      emit(state.copyWith(
        isAddingTransaction: false,
        errorMessage: e.toString(),
      ));
      rethrow;
    }
  }

  Future<void> refresh() => loadDashboard();
}
