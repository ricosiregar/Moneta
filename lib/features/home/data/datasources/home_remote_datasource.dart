import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/error/exceptions.dart' as app_ex;
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../repositories/home_repository.dart';

abstract class HomeRemoteDataSource {
  Future<List<WalletModel>> getWallets();
  Future<List<TransactionModel>> getTransactionsThisMonth();
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10});
  Future<List<TransactionModel>> getTransactionsByPeriod(
    TransactionPeriod period,
  );
  Future<double> getTotalExpenseThisMonth();
  Future<double> getTotalBalance();
  Future<WalletModel> addWallet({
    required String name,
    required String type,
    required double balance,
    required String icon,
    required String color,
  });
  Future<TransactionModel> addTransaction({
    required String title,
    required double amount,
    required String type,
    String? walletId,
    String? categoryId,
    DateTime? date,
    String? note,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabase;

  HomeRemoteDataSourceImpl({required this.supabase});

  String get _userId {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      throw app_ex.AuthException(message: 'User tidak login');
    }
    return uid;
  }

  @override
  Future<List<WalletModel>> getWallets() async {
    try {
      final data = await supabase
          .from('wallets')
          .select()
          .eq('user_id', _userId)
          .order('created_at');

      return (data as List)
          .map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is app_ex.AuthException) rethrow;
      throw app_ex.ServerException(message: 'Gagal memuat wallet: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsThisMonth() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(
        now.year,
        now.month,
        1,
      ).toUtc().toIso8601String();
      final endOfMonth = DateTime(
        now.year,
        now.month + 1,
        1,
      ).toUtc().toIso8601String();

      final data = await supabase
          .from('transactions')
          .select('*, categories(name, icon, color)')
          .eq('user_id', _userId)
          .gte('date', startOfMonth)
          .lt('date', endOfMonth)
          .order('date', ascending: false);

      return (data as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is app_ex.AuthException) rethrow;
      throw app_ex.ServerException(message: 'Gagal memuat transaksi: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    try {
      final data = await supabase
          .from('transactions')
          .select('*, categories(name, icon, color)')
          .eq('user_id', _userId)
          .order('date', ascending: false)
          .limit(limit);

      return (data as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is app_ex.AuthException) rethrow;
      throw app_ex.ServerException(
        message: 'Gagal memuat transaksi terbaru: $e',
      );
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByPeriod(
    TransactionPeriod period,
  ) async {
    try {
      final now = DateTime.now();
      late DateTime start;

      switch (period) {
        case TransactionPeriod.daily:
          start = DateTime(now.year, now.month, now.day);
          break;
        case TransactionPeriod.weekly:
          // Senin sebagai awal minggu
          final weekday = now.weekday; // 1=Mon, 7=Sun
          start = DateTime(now.year, now.month, now.day - (weekday - 1));
          break;
        case TransactionPeriod.monthly:
          start = DateTime(now.year, now.month, 1);
          break;
      }

      final end = now;
      final data = await supabase
          .from('transactions')
          .select('*, categories(name, icon, color)')
          .eq('user_id', _userId)
          .gte('date', start.toUtc().toIso8601String())
          .lte('date', end.toUtc().toIso8601String())
          .order('date', ascending: false);

      return (data as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is app_ex.AuthException) rethrow;
      throw app_ex.ServerException(message: 'Gagal memuat transaksi: $e');
    }
  }

  @override
  Future<double> getTotalExpenseThisMonth() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(
        now.year,
        now.month,
        1,
      ).toUtc().toIso8601String();
      final endOfMonth = DateTime(
        now.year,
        now.month + 1,
        1,
      ).toUtc().toIso8601String();

      final data = await supabase
          .from('transactions')
          .select('amount')
          .eq('user_id', _userId)
          .eq('type', 'expense')
          .gte('date', startOfMonth)
          .lt('date', endOfMonth);

      double total = 0.0;
      for (final e in data as List) {
        total += ((e as Map<String, dynamic>)['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      if (e is app_ex.AuthException) rethrow;
      throw app_ex.ServerException(
        message: 'Gagal menghitung total expense: $e',
      );
    }
  }

  @override
  Future<double> getTotalBalance() async {
    try {
      final data = await supabase
          .from('wallets')
          .select('balance')
          .eq('user_id', _userId);

      double total = 0.0;
      for (final e in data as List) {
        total += ((e as Map<String, dynamic>)['balance'] as num).toDouble();
      }
      return total;
    } catch (e) {
      if (e is app_ex.AuthException) rethrow;
      throw app_ex.ServerException(
        message: 'Gagal menghitung total balance: $e',
      );
    }
  }

  @override
  Future<WalletModel> addWallet({
    required String name,
    required String type,
    required double balance,
    required String icon,
    required String color,
  }) async {
    try {
      final data = await supabase
          .from('wallets')
          .insert({
            'user_id': _userId,
            'name': name,
            'type': type,
            'balance': balance,
            'icon': icon,
            'color': color,
          })
          .select()
          .single();

      return WalletModel.fromJson(data);
    } catch (e) {
      if (e is app_ex.AuthException) rethrow;
      throw app_ex.ServerException(message: 'Gagal menambah wallet: $e');
    }
  }

  @override
  Future<TransactionModel> addTransaction({
    required String title,
    required double amount,
    required String type,
    String? walletId,
    String? categoryId,
    DateTime? date,
    String? note,
  }) async {
    try {
      final insertData = <String, dynamic>{
        'user_id': _userId,
        'title': title,
        'amount': amount,
        'type': type,
        'date': (date ?? DateTime.now()).toUtc().toIso8601String(),
      };
      if (walletId != null && walletId.isNotEmpty) {
        insertData['wallet_id'] = walletId;
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        insertData['category_id'] = categoryId;
      }
      if (note != null && note.isNotEmpty) {
        insertData['note'] = note;
      }

      final data = await supabase
          .from('transactions')
          .insert(insertData)
          .select('*, categories(name, icon, color)')
          .single();

      // Update wallet balance if walletId is present
      if (walletId != null && walletId.isNotEmpty) {
        try {
          final walletRes = await supabase
              .from('wallets')
              .select('balance')
              .eq('id', walletId)
              .single();
          final currentBalance = (walletRes['balance'] as num).toDouble();
          final newBalance = type == 'income'
              ? currentBalance + amount
              : currentBalance - amount;
          await supabase
              .from('wallets')
              .update({'balance': newBalance})
              .eq('id', walletId);
        } catch (_) {}
      }

      return TransactionModel.fromJson(data);
    } catch (e) {
      if (e is app_ex.AuthException) rethrow;
      throw app_ex.ServerException(message: 'Gagal menambah transaksi: $e');
    }
  }
}
