import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/app_buttons.dart'
    show RRectInsetGlassPainter;
import '../../../../core/components/app_glass_dialog.dart';
import '../../../../core/components/app_glass_sheet.dart';
import '../../../../core/components/app_toast.dart';
import '../../../../core/components/fun_widgets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/usecase.dart';
import '../../../wallets/domain/entities/wallet_entity.dart';
import '../../../wallets/domain/usecases/wallet_usecases.dart';
import '../../../wallets/presentation/pages/wallet_form_page.dart';
import '../../data/services/bank_parser.dart';
import '../../domain/entities/detected_transaction_entity.dart';
import '../cubit/detected_inbox_cubit.dart';
import '../cubit/detected_inbox_state.dart';

/// Kartu "N Transaksi Terdeteksi" dari notifikasi bank (Catat / Abaikan / Pindah).
class DetectedCard extends StatefulWidget {
  const DetectedCard({super.key});

  @override
  State<DetectedCard> createState() => _DetectedCardState();
}

class _DetectedCardState extends State<DetectedCard> {
  static const _collapsed = 3;
  bool _expanded = false;

  late final DetectedInboxCubit _cubit = getIt<DetectedInboxCubit>()..watch();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  /// Tampilkan toast bila operasi gagal.
  void _report(Object? failureOrNull) {
    if (failureOrNull != null && mounted) {
      AppToast.showError(context, failureOrNull);
    }
  }

  /// Cari dompet yang sesuai untuk transaksi terdeteksi:
  /// 1. Dompet dari `d.walletId` bila masih aktif.
  /// 2. Auto-match berdasarkan `d.sourcePackage` ke dompet Parent (atau dompet mana pun yang cocok).
  WalletEntity? _resolveTargetWallet(
    DetectedTransactionEntity d,
    List<WalletEntity> wallets,
  ) {
    if (d.walletId != null) {
      final byId = wallets.where((w) => w.id == d.walletId).firstOrNull;
      if (byId != null) return byId;
    }
    final bankName = bankLabelForPackage(d.sourcePackage);
    if (bankName == null) return null;

    final matchedParent = wallets
        .where(
          (w) => w.parentId == null && doesWalletMatchBank(w.name, bankName),
        )
        .firstOrNull;
    if (matchedParent != null) return matchedParent;

    return wallets
        .where((w) => doesWalletMatchBank(w.name, bankName))
        .firstOrNull;
  }

  /// Pilih antara dompet Parent (Induk) atau dompet Child (Anak) bila dompet memiliki child.
  Future<WalletEntity?> _pickParentOrChild(
    WalletEntity parentWallet,
    List<WalletEntity> children,
  ) {
    final options = <WalletEntity>[parentWallet, ...children];
    String selectedId = parentWallet.id;

    return AppGlassSheet.show<WalletEntity>(
      context: context,
      builder: (ctx) => AppGlassSheet(
        title: 'Pilih Dompet Pencatatan',
        subtitle:
            'Dompet ${parentWallet.name} memiliki dompet anak. Pilih tujuan pencatatan:',
        child: StatefulBuilder(
          builder: (context, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final w in options) ...[
                Builder(
                  builder: (context) {
                    final isSelected = w.id == selectedId;
                    final isParent = w.id == parentWallet.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setSheet(() => selectedId = w.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentBlue.withValues(alpha: 0.12)
                                : glassFill(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentBlue
                                  : Colors.white.withValues(alpha: 0.9),
                              width: isSelected ? 1.5 : 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.accentBlue.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  switch (w.type) {
                                    'bank' => Icons.account_balance_outlined,
                                    'e_wallet' =>
                                      Icons.account_balance_wallet_outlined,
                                    _ => Icons.payments_outlined,
                                  },
                                  size: 18,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            w.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.inkPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isParent
                                                ? AppColors.accentBlue
                                                      .withValues(alpha: 0.14)
                                                : AppColors.accentViolet
                                                      .withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            isParent ? 'Induk' : 'Anak',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: isParent
                                                  ? AppColors.accentBlue
                                                  : AppColors.accentViolet,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      fmtRp(w.balance),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.inkSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? AppColors.accentBlue
                                    : AppColors.inkMuted,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  final picked = options.firstWhere((w) => w.id == selectedId);
                  Navigator.pop(ctx, picked);
                },
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
                    'Lanjutkan',
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
  }

  Future<void> _handleRecord(DetectedTransactionEntity d) async {
    var wallets = (await getIt<GetWalletsUseCase>()(
      const NoParams(),
    )).getOrElse(() => const <WalletEntity>[]);
    if (!mounted) return;

    var targetWallet = _resolveTargetWallet(d, wallets);

    // Skenario 1: Dompet bank belum ada -> arahkan buat dompet terlebih dahulu
    if (targetWallet == null) {
      final bankName = bankLabelForPackage(d.sourcePackage) ?? 'Bank';
      final createOk = await AppGlassDialog.show(
        context: context,
        icon: Icons.account_balance_wallet_outlined,
        title: 'Dompet $bankName Belum Ada',
        message:
            'Dompet "$bankName" belum tersedia. Apakah kamu ingin membuat dompet $bankName terlebih dahulu?',
        confirmLabel: 'Buat Dompet',
        cancelLabel: 'Batal',
      );
      if (createOk != true || !mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WalletFormPage(
            all: wallets,
            initialName: bankName,
            initialType: 'bank',
          ),
        ),
      );
      if (!mounted) return;

      // Cek kembali setelah kembali dari halaman pembuatan dompet
      wallets = (await getIt<GetWalletsUseCase>()(
        const NoParams(),
      )).getOrElse(() => const <WalletEntity>[]);
      if (!mounted) return;
      targetWallet = _resolveTargetWallet(d, wallets);
      if (targetWallet == null) return;
    }

    // Skenario 2: Bila dompet memiliki dompet anak (Child), tampilkan modal pilihan Parent vs Child
    final children = wallets
        .where((w) => w.parentId == targetWallet!.id)
        .toList();
    WalletEntity chosenWallet = targetWallet;
    if (children.isNotEmpty) {
      final picked = await _pickParentOrChild(targetWallet, children);
      if (picked == null || !mounted) return;
      chosenWallet = picked;
    }

    // Konfirmasi pop-up sebelum mencatat
    final txTypeLabel = d.type == DetectedType.income
        ? 'pemasukan'
        : 'pengeluaran';
    final confirmOk = await AppGlassDialog.show(
      context: context,
      icon: Icons.edit_square,
      title: 'Catat Transaksi?',
      message:
          'Apakah kamu yakin ingin mencatat $txTypeLabel sebesar ${fmtRp(d.amount)}'
          '${d.merchant != null ? ' (${d.merchant})' : ''} ke dompet "${chosenWallet.name}"?',
      confirmLabel: 'Ya, Catat',
      cancelLabel: 'Batal',
    );
    if (confirmOk != true || !mounted) return;

    if (d.walletId != chosenWallet.id) {
      final cwResult = await _cubit.changeWallet(d.id, chosenWallet.id);
      final cwFailure = cwResult.fold((f) => f.message, (_) => null);
      if (cwFailure != null) {
        _report(cwFailure);
        return;
      }
    }

    final r = await _cubit.record(d.id);
    if (!mounted) return;
    r.fold(
      (f) => _report(f.message),
      (_) => AppToast.showSuccess(
        context,
        'Transaksi berhasil dicatat ke dompet ${chosenWallet.name}',
      ),
    );
  }

  Future<void> _handleIgnore(DetectedTransactionEntity d) async {
    final ok = await AppGlassDialog.show(
      context: context,
      icon: Icons.delete_outline_rounded,
      isDestructive: true,
      title: 'Hapus Transaksi Terdeteksi?',
      message:
          'Apakah kamu yakin ingin menghapus deteksi transaksi sebesar ${fmtRp(d.amount)}'
          '${d.merchant != null ? ' (${d.merchant})' : ''}?',
      confirmLabel: 'Ya, Hapus',
      cancelLabel: 'Batal',
    );
    if (ok != true || !mounted) return;

    final r = await _cubit.ignore(d.id);
    if (!mounted) return;
    r.fold(
      (f) => _report(f.message),
      (_) => AppToast.showSuccess(
        context,
        'Transaksi terdeteksi berhasil dihapus',
      ),
    );
  }

  Future<void> _handleIgnoreAll(int count) async {
    final ok = await AppGlassDialog.show(
      context: context,
      icon: Icons.delete_sweep_outlined,
      isDestructive: true,
      title: 'Hapus Semua Deteksi?',
      message:
          'Apakah kamu yakin ingin menghapus semua ($count) transaksi yang terdeteksi?',
      confirmLabel: 'Ya, Hapus Semua',
      cancelLabel: 'Batal',
    );
    if (ok != true || !mounted) return;

    final r = await _cubit.ignoreAll();
    if (!mounted) return;
    r.fold(
      (f) => _report(f.message),
      (_) => AppToast.showSuccess(
        context,
        'Semua transaksi terdeteksi berhasil dihapus',
      ),
    );
  }

  Future<void> _pickWallet(DetectedTransactionEntity d) async {
    final wallets = (await getIt<GetWalletsUseCase>()(
      const NoParams(),
    )).getOrElse(() => const <WalletEntity>[]);
    if (!mounted) return;
    if (wallets.isEmpty) {
      AppToast.showWarning(
        context,
        'Buat dompet terlebih dahulu di halaman Dompet',
      );
      return;
    }
    String selectedId =
        _resolveTargetWallet(d, wallets)?.id ?? wallets.first.id;
    DetectedType selectedType = d.type;

    final result = await AppGlassSheet.show<(String, DetectedType)>(
      context: context,
      builder: (ctx) => AppGlassSheet(
        title: 'Pindah & Sesuaikan Deteksi',
        subtitle: 'Ubah jenis transaksi atau pindahkan dompet tujuan',
        child: StatefulBuilder(
          builder: (context, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FunLabel('Jenis Transaksi'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FunPill(
                      label: 'Pemasukan',
                      icon: Icons.south_west_rounded,
                      selected: selectedType == DetectedType.income,
                      expand: true,
                      onTap: () =>
                          setSheet(() => selectedType = DetectedType.income),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FunPill(
                      label: 'Pengeluaran',
                      icon: Icons.north_east_rounded,
                      selected: selectedType == DetectedType.expense,
                      expand: true,
                      onTap: () =>
                          setSheet(() => selectedType = DetectedType.expense),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                    child: AppDropdownButton<String>(
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
                onTap: () => Navigator.pop(ctx, (selectedId, selectedType)),
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
    if (result == null || !mounted) return;

    final (pickedId, pickedType) = result;
    final pickedWallet = wallets.where((w) => w.id == pickedId).firstOrNull;
    if (pickedWallet == null) return;

    final typeLabel = pickedType == DetectedType.income
        ? 'pemasukan'
        : 'pengeluaran';
    final confirmOk = await AppGlassDialog.show(
      context: context,
      icon: Icons.swap_horiz_rounded,
      title: 'Simpan Perubahan Deteksi?',
      message:
          'Apakah kamu yakin ingin mengatur transaksi sebesar ${fmtRp(d.amount)} sebagai $typeLabel ke dompet "${pickedWallet.name}"?',
      confirmLabel: 'Ya, Simpan',
      cancelLabel: 'Batal',
    );
    if (confirmOk != true || !mounted) return;

    if (pickedType != d.type) {
      final tr = await _cubit.changeType(d.id, pickedType.value);
      final tf = tr.fold((f) => f.message, (_) => null);
      if (tf != null) {
        _report(tf);
        return;
      }
    }

    final r = await _cubit.changeWallet(d.id, pickedWallet.id);
    if (!mounted) return;
    r.fold(
      (f) => _report(f.message),
      (_) => AppToast.showSuccess(
        context,
        'Transaksi diatur sebagai $typeLabel di dompet ${pickedWallet.name}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetectedInboxCubit, DetectedInboxState>(
      bloc: _cubit,
      builder: (context, state) {
        final items = state.items;
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
                      const Icon(
                        Icons.move_to_inbox_outlined,
                        size: 20,
                        color: AppColors.accentBlue,
                      ),
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
                        child: Text(
                          '+$more lainnya',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () => _handleIgnoreAll(items.length),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'Abaikan Semua',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.expense,
                        ),
                      ),
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

  Widget _row(DetectedTransactionEntity d) {
    final income = d.type == DetectedType.income;
    final when = DateFormat('d MMM, HH.mm', 'id_ID').format(d.detectedAt);
    final walletOrBankLabel =
        d.walletName ?? bankLabelForPackage(d.sourcePackage) ?? 'Dompet';
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
            '$walletOrBankLabel • $when'
            '${d.merchant != null ? ' • ${d.merchant}' : ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.inkMuted,
            ),
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
                tooltip: 'Hapus',
                iconColor: AppColors.expense,
                borderColor: AppColors.expense.withValues(alpha: 0.55),
                onTap: () => _handleIgnore(d),
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
                onTap: () => _handleRecord(d),
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
