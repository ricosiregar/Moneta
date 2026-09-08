import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../home/data/models/transaction_model.dart';
import '../home/presentation/cubit/home_cubit.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadDashboard();
  }

  static String _fmtRupiah(double amount) {
    final raw = amount.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buf.write('.');
      buf.write(raw[i]);
    }
    return 'Rp $buf';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOffWhite,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refresh(),
              color: AppColors.deepOrange,
              child: CustomScrollView(
                slivers: [
                  // ── Header ───────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Riwayat Transaksi',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x0A000000), blurRadius: 10),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.filter_list_rounded,
                                color: AppColors.textDark,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Loading ──────────────────────────────────────────────
                  if (state.status == HomeStatus.loading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.deepOrange,
                        ),
                      ),
                    )

                  // ── Error ────────────────────────────────────────────────
                  else if (state.status == HomeStatus.failure)
                    SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 12),
                              Text(
                                state.errorMessage ?? 'Terjadi kesalahan',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<HomeCubit>().refresh(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.deepOrange,
                                ),
                                child: const Text('Coba Lagi',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )

                  // ── Empty ────────────────────────────────────────────────
                  else if (state.recentTransactions.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada transaksi',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )

                  // ── Transactions grouped by date ─────────────────────────
                  else
                    _TransactionList(
                        transactions: state.recentTransactions,
                        fmtRupiah: _fmtRupiah),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction list grouped by date
// ─────────────────────────────────────────────────────────────────────────────

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String Function(double) fmtRupiah;

  const _TransactionList({
    required this.transactions,
    required this.fmtRupiah,
  });

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Hari Ini';
    if (d == yesterday) return 'Kemarin';

    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Group by date
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in transactions) {
      final label = _dateLabel(tx.date);
      grouped.putIfAbsent(label, () => []).add(tx);
    }

    final sections = grouped.entries.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, sectionIndex) {
          final section = sections[sectionIndex];
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSection(section.key),
                ...section.value.map(
                  (tx) => _buildTransactionItem(tx),
                ),
              ],
            ),
          );
        },
        childCount: sections.length,
      ),
    );
  }

  Widget _buildDateSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8E8E93),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final isExpense = tx.isExpense;
    final amountText =
        isExpense ? '-${fmtRupiah(tx.amount)}' : '+${fmtRupiah(tx.amount)}';
    final amountColor =
        isExpense ? const Color(0xFF2B5B84) : const Color(0xFF52B788);

    final icon = _iconFor(tx.categoryIcon, isExpense);
    final iconBg = _iconBgFor(tx.categoryColor, isExpense);

    final h = tx.date.hour.toString().padLeft(2, '0');
    final m = tx.date.minute.toString().padLeft(2, '0');
    final timeStr = '$h:$m';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration:
                BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String? categoryIcon, bool isExpense) {
    switch (categoryIcon) {
      case 'directions_bus':
        return Icons.directions_bus_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'savings':
        return Icons.savings_outlined;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'movie':
        return Icons.movie_outlined;
      case 'favorite':
        return Icons.favorite_outline;
      default:
        return isExpense
            ? Icons.payment_outlined
            : Icons.account_balance_wallet_outlined;
    }
  }

  Color _iconBgFor(String? color, bool isExpense) {
    if (!isExpense) return const Color(0xFF52B788);
    switch (color) {
      case 'blue':
        return const Color(0xFF1A73E8);
      case 'orange':
        return const Color(0xFFFF6D00);
      case 'teal':
        return const Color(0xFF00897B);
      case 'pink':
        return const Color(0xFFE91E63);
      case 'purple':
        return const Color(0xFF7C4DFF);
      case 'green':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF2B5B84);
    }
  }
}
