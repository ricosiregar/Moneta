import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/components/app_buttons.dart' show RRectInsetGlassPainter;
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
    if (!mounted || wallets.isEmpty) return;
    String selectedId = wallets.any((w) => w.id == d.walletId)
        ? d.walletId!
        : wallets.first.id;

    final picked = await AppGlassSheet.show<String>(
      context: context,
      builder: (ctx) => AppGlassSheet(
        title: 'Pindah ke Dompet',
        subtitle: 'Pilih dompet tujuan transaksi',
        child: StatefulBuilder(
          builder: (context, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FunLabel('Dompet Tujuan'),
              const SizedBox(height: 8),
              Container(
                height: 48,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: glassFill(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      value: selectedId,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: Colors.white.withValues(alpha: 0.96),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.inkSecondary,
                      ),
                      items: [
                        for (final w in wallets)
                          DropdownMenuItem<String>(
                            value: w.id,
                            child: Row(
                              children: [
                                Icon(
                                  switch (w.type) {
                                    'bank' => Icons.account_balance_outlined,
                                    'e_wallet' =>
                                      Icons.account_balance_wallet_outlined,
                                    _ => Icons.payments_outlined,
                                  },
                                  size: 18,
                                  color: AppColors.accentBlue,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${w.name} (${fmtRp(w.balance)})',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setSheet(() => selectedId = val);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(ctx, selectedId),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0x66FFFFFF),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332563EB),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Pindahkan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
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
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.65)),
        ),
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
                      color: income ? AppColors.inkPrimary : AppColors.expense,
                    ),
                  ),
                ),
              ),
              _iconBtn(
                icon: Icons.delete_rounded,
                tooltip: 'Abaikan',
                iconColor: AppColors.expense,
                borderColor: AppColors.expense.withValues(alpha: 0.55),
                onTap: () => _repo.ignore(d.id),
              ),
              const SizedBox(width: 8),
              _iconBtn(
                icon: Icons.swap_horiz_rounded,
                tooltip: 'Pindah Dompet',
                iconColor: AppColors.accentBlue,
                borderColor: const Color(0xFF94A3B8),
                onTap: () => _pickWallet(d),
              ),
              const SizedBox(width: 8),
              _iconBtn(
                icon: Icons.edit_square,
                tooltip: 'Catat',
                iconColor: Colors.white,
                aurora: true,
                onTap: () => _repo.record(d.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required String tooltip,
    required Color iconColor,
    required VoidCallback onTap,
    Color? borderColor,
    bool aurora = false,
  }) {
    const double radius = 10;
    final box = Container(
      width: 36,
      height: 36,
      decoration: aurora
          ? auroraActiveDecoration(radius: radius)
          : BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: borderColor ?? const Color(0xFFCBD5E1),
                width: 1.1,
              ),
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          painter: aurora
              ? const RRectInsetGlassPainter(radius: Radius.circular(radius))
              : null,
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
              shadows: aurora
                  ? const [
                      Shadow(
                        color: Color(0x33000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: box,
      ),
    );
  }
}

