import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/components/fun_widgets.dart';
import '../../core/components/app_glass_sheet.dart';
import '../../core/database/detected_repository.dart';
import '../../core/database/wallet_repository.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';

/// Kartu "N Transaksi Terdeteksi" dari notifikasi bank (Catat / Abaikan / Pindah).
class DetectedCard extends StatefulWidget {
  const DetectedCard({super.key});

  @override
  State<DetectedCard> createState() => _DetectedCardState();
}

class _DetectedCardState extends State<DetectedCard> {
  static const _collapsed = 3;
  bool _expanded = false;

  DetectedRepository get _repo => getIt<DetectedRepository>();

  Future<void> _pickWallet(DetectedView d) async {
    final wallets = await getIt<WalletRepository>().watchWallets().first;
    if (!mounted) return;
    final picked = await AppGlassSheet.show<String>(
      context: context,
      builder: (ctx) => AppGlassSheet(
        title: 'Pindah ke Dompet',
        subtitle: 'Pilih dompet tujuan transaksi',
        padding: EdgeInsets.zero,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          children: [
            for (final w in wallets)
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.accentBlue),
                title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.inkPrimary)),
                trailing: w.id == d.walletId
                    ? const Icon(Icons.check_rounded, color: AppColors.accentBlue)
                    : null,
                onTap: () => Navigator.pop(ctx, w.id),
              ),
          ],
        ),
      ),
    );
    if (picked != null) await _repo.changeWallet(d.id, picked);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DetectedView>>(
      stream: _repo.watchPending(),
      builder: (context, snap) {
        final items = snap.data ?? const <DetectedView>[];
        if (items.isEmpty) return const SizedBox.shrink();
        final shown = _expanded ? items : items.take(_collapsed).toList();
        final more = items.length - shown.length;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FunCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.move_to_inbox_outlined,
                          size: 20, color: AppColors.accentBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${items.length} Transaksi Terdeteksi',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (final d in shown) _row(d),
                if (more > 0)
                  InkWell(
                    onTap: () => setState(() => _expanded = true),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text('+$more lainnya',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.inkMuted)),
                      ),
                    ),
                  ),
                InkWell(
                  onTap: _repo.ignoreAll,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text('Abaikan Semua',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.expense)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(DetectedView d) {
    final income = d.type == 'income';
    final when = DateFormat('d MMM, HH.mm', 'id_ID').format(d.detectedAt);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${d.walletName ?? 'Dompet'} • $when'
            '${d.merchant != null ? ' • ${d.merchant}' : ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${income ? '+' : '-'}${fmtRp(d.amount)}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: income ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ),
              ),
              _btn('Abaikan', AppColors.surfaceRaised, AppColors.inkSecondary,
                  () => _repo.ignore(d.id)),
              const SizedBox(width: 6),
              _btn('Pindah', const Color(0xFFEEF2FF), AppColors.accentBlue,
                  () => _pickWallet(d)),
              const SizedBox(width: 6),
              _btn('Catat', AppColors.inkPrimary, Colors.white,
                  () => _repo.record(d.id)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }
}
