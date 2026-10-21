import 'package:flutter/material.dart';

import '../../core/components/app_glass_dialog.dart';
import '../../core/components/app_glass_sheet.dart';
import '../../core/components/app_toast.dart';
import '../../core/components/category_icons.dart';
import '../../core/components/fun_widgets.dart';
import '../../core/database/finance_repository.dart';
import '../../core/database/wallet_repository.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import 'wallet_form_page.dart';

const _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

IconData _typeIcon(String type) => switch (type) {
  'bank' => Icons.account_balance_outlined,
  'e_wallet' => Icons.account_balance_wallet_outlined,
  _ => Icons.payments_outlined,
};

String _typeLabel(String type) => switch (type) {
  'bank' => 'Bank',
  'e_wallet' => 'E-Wallet',
  _ => 'Tunai',
};

double _parseAmount(String text) => parseMoney(text);

/// Kelola dompet: wallet induk → anak, alokasi gaji, transfer, dan jadwal auto-transfer.
class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  WalletRepository get _repo => getIt<WalletRepository>();
  FinanceRepository get _financeRepo => getIt<FinanceRepository>();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: GlassPage(
        child: StreamBuilder<List<WalletView>>(
          stream: _repo.watchWallets(),
          builder: (context, snap) {
            final wallets = snap.data ?? const <WalletView>[];
            final ids = wallets.map((w) => w.id).toSet();
            final roots = wallets
                .where((w) => w.parentId == null || !ids.contains(w.parentId))
                .toList();
            final total = wallets.fold<double>(0, (a, w) => a + w.balance);

            return StreamBuilder<List<AutoScheduleView>>(
              stream: _financeRepo.watchAutoSchedules(),
              builder: (context, autoSnap) {
                final autoSchedules =
                    autoSnap.data ?? const <AutoScheduleView>[];
                return StreamBuilder<List<CategoryView>>(
                  stream: _financeRepo.watchCategories('expense'),
                  builder: (context, catSnap) {
                    final expenseCats = catSnap.data ?? const <CategoryView>[];
                    return StreamBuilder<List<BudgetView>>(
                      stream: _financeRepo.watchBudgets(now.year, now.month),
                      builder: (context, budgetSnap) {
                        final budgets =
                            budgetSnap.data ?? const <BudgetView>[];
                        final activeSchedules = autoSchedules
                            .where((s) => s.isEnabled)
                            .toList();
                        final totalAutoAmount = activeSchedules.fold<double>(
                          0,
                          (a, s) => a + s.amount,
                        );
                        final doneCount = activeSchedules
                            .where((s) => s.isExecutedForMonth(now))
                            .length;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                12,
                              ),
                              child: Row(
                                children: [
                                  FunRoundButton(
                                    Icons.arrow_back_rounded,
                                    size: 40,
                                    onTap: () => Navigator.pop(context),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: FunPageHeader(
                                      title: 'Dompet',
                                      subtitle:
                                          'Induk, anak, alokasi & auto-transfer',
                                    ),
                                  ),
                                  FunRoundButton(
                                    Icons.swap_horiz_rounded,
                                    size: 40,
                                    onTap: wallets.length < 2
                                        ? null
                                        : () => _showTransfer(context, wallets),
                                  ),
                                  const SizedBox(width: 8),
                                  FunRoundButton(
                                    Icons.add_rounded,
                                    size: 40,
                                    onTap: () =>
                                        _showWalletForm(context, wallets),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  await Future.delayed(
                                    const Duration(milliseconds: 300),
                                  );
                                },
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    32,
                                  ),
                                  children: [
                                    FunCard(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const FunLabel(
                                            'Total Aset',
                                            icon: Icons.wallet_outlined,
                                          ),
                                          const SizedBox(height: 6),
                                          MoneyText(fmtRp(total), size: 28),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${wallets.length} dompet',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.inkMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (wallets.isEmpty) ...[
                                      const FunCard(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Belum ada dompet. Tekan + untuk menambah.',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: AppColors.inkMuted,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    for (final root in roots) ...[
                                      _WalletGroup(
                                        root: root,
                                        children: wallets
                                            .where((w) => w.parentId == root.id)
                                            .toList(),
                                        all: wallets,
                                        repo: _repo,
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    // ── Section: Jadwal Auto-Transfer & Pembayaran Rutin ──
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 4),
                                            child: FunLabel(
                                              'Jadwal Auto-Transfer',
                                              icon: Icons.event_repeat_rounded,
                                            ),
                                          ),
                                        ),
                                        FunPill(
                                          label: 'Atur Jadwal',
                                          icon: Icons.add_rounded,
                                          selected: true,
                                          onTap: () => _showAutoScheduleSheet(
                                            context,
                                            wallets: wallets,
                                            expenseCats: expenseCats,
                                            budgets: budgets,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (autoSchedules.isEmpty)
                                      FunCard(
                                        onTap: () => _showAutoScheduleSheet(
                                          context,
                                          wallets: wallets,
                                          expenseCats: expenseCats,
                                          budgets: budgets,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 22,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 46,
                                              height: 46,
                                              decoration:
                                                  auroraActiveDecoration(
                                                    radius: 14,
                                                  ),
                                              child: const Icon(
                                                Icons.event_repeat_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            const Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Belum ada jadwal auto-transfer',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.inkPrimary,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    'Contoh: Setiap tanggal 1 otomatis bayar kost atau pindah saldo dompet',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors.inkMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              color: AppColors.inkMuted,
                                            ),
                                          ],
                                        ),
                                      )
                                    else ...[
                                      FunCard(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              alignment: Alignment.center,
                                              decoration:
                                                  auroraActiveDecoration(
                                                    radius: 14,
                                                  ),
                                              child: const Icon(
                                                Icons.bolt_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const FunLabel(
                                                    'Total Auto-Transfer / Bulan',
                                                  ),
                                                  const SizedBox(height: 2),
                                                  MoneyText(
                                                    fmtRp(totalAutoAmount),
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            FunBadge(
                                              '$doneCount/${activeSchedules.length} selesai',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      for (final s in autoSchedules)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: _AutoScheduleCard(
                                            schedule: s,
                                            now: now,
                                            shortMonths: _shortMonths,
                                            onTap: () => _showAutoScheduleSheet(
                                              context,
                                              wallets: wallets,
                                              expenseCats: expenseCats,
                                              budgets: budgets,
                                              editing: s,
                                            ),
                                            onToggle: (v) => _financeRepo
                                                .toggleAutoSchedule(s.id, v),
                                            onDelete: () =>
                                                _confirmDeleteAutoSchedule(
                                                  context,
                                                  s,
                                                ),
                                            onExecuteNow: () async {
                                              final fromWallet = wallets
                                                  .where(
                                                    (w) => w.id == s.walletId,
                                                  )
                                                  .firstOrNull;
                                              if (fromWallet != null &&
                                                  fromWallet.balance <
                                                      s.amount) {
                                                AppToast.showWarning(
                                                  context,
                                                  'Saldo ${fromWallet.name} (${fmtRp(fromWallet.balance)}) tidak mencukupi untuk memotong ${fmtRp(s.amount)}',
                                                );
                                                return;
                                              }
                                              final done = await _financeRepo
                                                  .executeAutoScheduleNow(s.id);
                                              if (!context.mounted) return;
                                              if (done == null) {
                                                AppToast.showWarning(
                                                  context,
                                                  'Saldo dompet tidak mencukupi untuk menjalankan jadwal ini',
                                                );
                                                return;
                                              }
                                              AppToast.showSuccess(
                                                context,
                                                'Berhasil dijalankan: ${done.title} (${fmtRp(done.amount)})',
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showWalletForm(
    BuildContext context,
    List<WalletView> all, {
    WalletView? editing,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletFormPage(all: all, editing: editing),
      ),
    );
  }

  void _showTransfer(
    BuildContext context,
    List<WalletView> all, {
    String? initialFromId,
  }) {
    _showSheet(
      context,
      _TransferForm(
        repo: _repo,
        wallets: all,
        initialFromId: initialFromId,
      ),
    );
  }

  Future<void> _confirmDeleteAutoSchedule(
    BuildContext context,
    AutoScheduleView schedule, {
    BuildContext? sheetContext,
  }) async {
    final displayTitle = schedule.kind == 'transfer'
        ? '${schedule.walletName} → ${schedule.toWalletName ?? '-'}'
        : schedule.title;
    final confirmed = await AppGlassDialog.show(
      context: context,
      icon: Icons.delete_outline_rounded,
      title: 'Hapus Jadwal Auto-Transfer?',
      message:
          'Yakin ingin menghapus jadwal "$displayTitle" (${fmtRp(schedule.amount)} setiap tanggal ${schedule.dayOfMonth})?',
      confirmLabel: 'Ya, Hapus',
      cancelLabel: 'Batal',
      isDestructive: true,
    );
    if (confirmed != true) return;
    await _financeRepo.deleteAutoSchedule(schedule.id);
    if (sheetContext != null && sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }
    if (!context.mounted) return;
    AppToast.showSuccess(context, 'Jadwal "$displayTitle" berhasil dihapus');
  }

  void _showAutoScheduleSheet(
    BuildContext context, {
    required List<WalletView> wallets,
    required List<CategoryView> expenseCats,
    required List<BudgetView> budgets,
    AutoScheduleView? editing,
  }) {
    final titleC = TextEditingController(text: editing?.title ?? '');
    final amountC = TextEditingController(
      text: editing == null ? '' : fmtThousands(editing.amount),
    );
    final noteC = TextEditingController(text: editing?.note ?? '');
    String kind = editing?.kind ?? 'expense';
    int dayOfMonth = editing?.dayOfMonth ?? 1;
    String? fromWalletId =
        editing?.walletId ?? (wallets.isNotEmpty ? wallets.first.id : null);
    String? toWalletId =
        editing?.toWalletId ??
        (wallets.length > 1
            ? wallets.firstWhere((w) => w.id != fromWalletId).id
            : null);
    String? categoryId =
        editing?.categoryId ??
        (expenseCats.isNotEmpty
            ? (expenseCats
                      .where((c) => c.name.toLowerCase() == 'tagihan')
                      .firstOrNull
                      ?.id ??
                  expenseCats.first.id)
            : null);
    final now = DateTime.now();
    final alreadyExecuted = editing?.isExecutedForMonth(now) ?? false;
    bool executeNow = !alreadyExecuted && dayOfMonth == now.day;

    AppGlassSheet.show(
      context: context,
      builder: (ctx) => AppGlassSheet(
        title: editing == null
            ? 'Atur Auto-Transfer / Rutin'
            : 'Ubah Jadwal Otomatis',
        subtitle:
            'Otomatis bayar tagihan atau pindah saldo setiap tanggal pilihanmu',
        child: StatefulBuilder(
          builder: (c, setSheet) {
            final selectedFromWallet = wallets
                .where((w) => w.id == fromWalletId)
                .firstOrNull;
            final typedAmount = parseMoney(amountC.text);
            final isBalanceInsufficient =
                selectedFromWallet != null &&
                typedAmount > 0 &&
                selectedFromWallet.balance < typedAmount;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (wallets.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kamu belum memiliki dompet aktif. Tambahkan dompet terlebih dahulu agar fitur Auto-Transfer dapat berjalan.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FunPill(
                            label: 'Tambah Dompet Sekarang',
                            icon: Icons.add_rounded,
                            selected: true,
                            onTap: () {
                              Navigator.pop(ctx);
                              _showWalletForm(context, wallets);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    const FunLabel('1. Jenis Transaksi Otomatis'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: FunPill(
                            label: 'Bayar / Pengeluaran',
                            icon: Icons.receipt_long_rounded,
                            selected: kind == 'expense',
                            onTap: () => setSheet(() => kind = 'expense'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FunPill(
                            label: 'Transfer Dompet',
                            icon: Icons.swap_horiz_rounded,
                            selected: kind == 'transfer',
                            onTap: wallets.length < 2
                                ? () => AppToast.showWarning(
                                    context,
                                    'Butuh minimal 2 dompet untuk transfer antar dompet',
                                  )
                                : () => setSheet(() => kind = 'transfer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FunLabel(
                      kind == 'transfer'
                          ? '2. Dari Dompet Asal'
                          : '2. Potong Saldo dari Dompet',
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: glassFill(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 1.2,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: wallets.any((w) => w.id == fromWalletId)
                              ? fromWalletId
                              : (wallets.isNotEmpty ? wallets.first.id : null),
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
                                      _typeIcon(w.type),
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
                            if (val == null) return;
                            setSheet(() {
                              fromWalletId = val;
                              if (toWalletId == val) {
                                toWalletId = wallets
                                    .where((x) => x.id != val)
                                    .firstOrNull
                                    ?.id;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    if (kind == 'expense') ...[
                      const SizedBox(height: 14),
                      const FunLabel('3. Nama Jadwal (Pilih cepat atau ketik)'),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final preset in const [
                            'Bayar Kost',
                            'Listrik & Air',
                            'WiFi / Internet',
                            'Paket Data',
                            'Alokasi Tabungan',
                          ])
                            FunPill(
                              label: preset,
                              selected:
                                  titleC.text.trim().toLowerCase() ==
                                  preset.toLowerCase(),
                              onTap: () => setSheet(() => titleC.text = preset),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _Field(
                        controller: titleC,
                        hint: 'Contoh: Bayar Kost-kostan',
                      ),
                      if (expenseCats.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const FunLabel('4. Kategori Pengeluaran'),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: glassFill(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                              width: 1.2,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: expenseCats.any((c) => c.id == categoryId)
                                  ? categoryId
                                  : expenseCats.first.id,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(16),
                              dropdownColor: Colors.white.withValues(
                                alpha: 0.96,
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.inkSecondary,
                              ),
                              items: [
                                for (final cat in expenseCats)
                                  DropdownMenuItem<String>(
                                    value: cat.id,
                                    child: Row(
                                      children: [
                                        Icon(
                                          categoryIcon(cat.icon),
                                          size: 18,
                                          color: AppColors.accentBlue,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            cat.name,
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
                                  setSheet(() => categoryId = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ] else if (kind == 'transfer' && wallets.length > 1) ...[
                      const SizedBox(height: 14),
                      const FunLabel('3. Ke Dompet Tujuan'),
                      const SizedBox(height: 6),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: glassFill(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: wallets.any(
                                  (w) =>
                                      w.id == toWalletId &&
                                      w.id != fromWalletId,
                                )
                                ? toWalletId
                                : wallets
                                      .where((w) => w.id != fromWalletId)
                                      .firstOrNull
                                      ?.id,
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(16),
                            dropdownColor: Colors.white.withValues(alpha: 0.96),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.inkSecondary,
                            ),
                            items: [
                              for (final w in wallets)
                                if (w.id != fromWalletId)
                                  DropdownMenuItem<String>(
                                    value: w.id,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _typeIcon(w.type),
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
                                setSheet(() => toWalletId = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    FunLabel(
                      kind == 'transfer'
                          ? '4. Nominal (Rp)'
                          : '5. Nominal (Rp)',
                    ),
                    const SizedBox(height: 6),
                    _Field(
                      controller: amountC,
                      hint: 'Contoh: 1.500.000',
                      money: true,
                      onChanged: (_) => setSheet(() {}),
                    ),
                    if (selectedFromWallet != null && typedAmount > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            isBalanceInsufficient
                                ? Icons.error_outline_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 14,
                            color: isBalanceInsufficient
                                ? AppColors.expense
                                : AppColors.income,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isBalanceInsufficient
                                  ? 'Saldo ${selectedFromWallet.name} (${fmtRp(selectedFromWallet.balance)}) tidak cukup untuk memotong ${fmtRp(typedAmount)}'
                                  : 'Sisa saldo ${selectedFromWallet.name} setelah dipotong: ${fmtRp(selectedFromWallet.balance - typedAmount)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isBalanceInsufficient
                                    ? AppColors.expense
                                    : AppColors.inkSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    const FunLabel('Catatan (Opsional)'),
                    const SizedBox(height: 6),
                    _Field(
                      controller: noteC,
                      hint: kind == 'transfer'
                          ? 'Catatan pindah uang (opsional)'
                          : 'Contoh: Kost Putra Kamar 12',
                    ),
                    const SizedBox(height: 14),
                    FunLabel(
                      '${kind == 'transfer' ? '5' : '6'}. Tanggal Eksekusi: Setiap Tanggal $dayOfMonth',
                      icon: Icons.calendar_today_rounded,
                    ),
                    const SizedBox(height: 6),
                    _DayOfMonthSelector(
                      selectedDay: dayOfMonth,
                      onChanged: (d) => setSheet(() {
                        dayOfMonth = d;
                        if (!alreadyExecuted && d == now.day) {
                          executeNow = true;
                        }
                      }),
                    ),
                    if (!alreadyExecuted && dayOfMonth <= now.day) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 18,
                              color: AppColors.accentBlue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dayOfMonth == now.day
                                    ? 'Hari ini tanggal $dayOfMonth! Langsung proses untuk bulan ini'
                                    : 'Tanggal $dayOfMonth sudah lewat di bulan ini. Proses juga untuk bulan ini sekarang?',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                            ),
                            Switch(
                              value: executeNow,
                              activeThumbColor: AppColors.accentBlue,
                              onChanged: (v) => setSheet(() => executeNow = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _PrimaryButton(
                      editing == null
                          ? 'Simpan Jadwal Otomatis'
                          : 'Simpan Perubahan',
                      () async {
                        final amt = parseMoney(amountC.text);
                        if (amt <= 0) {
                          AppToast.showWarning(
                            context,
                            'Masukkan nominal terlebih dahulu',
                          );
                          return;
                        }
                        if (fromWalletId == null) return;
                        final fromWallet = wallets
                            .where((w) => w.id == fromWalletId)
                            .firstOrNull;
                        if (fromWallet == null) return;
                        if (fromWallet.balance < amt) {
                          AppToast.showWarning(
                            context,
                            'Saldo ${fromWallet.name} (${fmtRp(fromWallet.balance)}) tidak mencukupi untuk nominal ${fmtRp(amt)}',
                          );
                          return;
                        }
                        if (kind == 'transfer' &&
                            (toWalletId == null ||
                                toWalletId == fromWalletId)) {
                          AppToast.showWarning(
                            context,
                            'Pilih dompet tujuan yang berbeda',
                          );
                          return;
                        }

                        final nav = Navigator.of(ctx);
                        final fromName = fromWallet.name;
                        final toName = wallets
                                .where((w) => w.id == toWalletId)
                                .firstOrNull
                                ?.name ??
                            'Dompet Tujuan';
                        final cleanTitle = kind == 'transfer'
                            ? '$fromName → $toName'
                            : (titleC.text.trim().isEmpty
                                  ? 'Bayar Kost'
                                  : titleC.text.trim());

                        final matchingBudget = kind == 'expense'
                            ? budgets
                                  .where((b) => b.categoryId == categoryId)
                                  .firstOrNull
                            : null;

                        await _financeRepo.saveAutoSchedule(
                          id: editing?.id,
                          title: cleanTitle,
                          kind: kind,
                          amount: amt,
                          dayOfMonth: dayOfMonth,
                          walletId: fromWalletId!,
                          toWalletId: kind == 'transfer' ? toWalletId : null,
                          categoryId: kind == 'expense' ? categoryId : null,
                          budgetId: editing?.budgetId ?? matchingBudget?.id,
                          note: noteC.text,
                          isEnabled: editing?.isEnabled ?? true,
                          executeNowForCurrentMonth:
                              !alreadyExecuted && executeNow,
                        );

                        nav.pop();
                        if (!context.mounted) return;
                        AppToast.showSuccess(
                          context,
                          !alreadyExecuted && executeNow
                              ? 'Jadwal disimpan & ${fmtRp(amt)} berhasil diproses untuk bulan ini'
                              : 'Jadwal otomatis setiap tanggal $dayOfMonth berhasil disimpan',
                        );
                      },
                    ),
                    if (editing != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () => _confirmDeleteAutoSchedule(
                            context,
                            editing,
                            sheetContext: ctx,
                          ),
                          child: const Text(
                            'Hapus jadwal otomatis',
                            style: TextStyle(color: AppColors.expense),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _showSheet(BuildContext context, Widget child) {
  return AppGlassSheet.show(
    context: context,
    builder: (_) => child,
  );
}

void _toast(BuildContext context, String msg, {bool isError = false}) {
  if (isError) {
    AppToast.showError(context, msg);
  } else {
    AppToast.showWarning(context, msg);
  }
}

// ── Group (induk + anak) ─────────────────────────────────────────────────

class _WalletGroup extends StatelessWidget {
  final WalletView root;
  final List<WalletView> children;
  final List<WalletView> all;
  final WalletRepository repo;
  const _WalletGroup({
    required this.root,
    required this.children,
    required this.all,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return FunCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WalletRow(
            wallet: root,
            hasChildren: children.isNotEmpty,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WalletFormPage(all: all, editing: root),
              ),
            ),
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final c in children)
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 4),
                child: _WalletRow(
                  wallet: c,
                  child: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WalletFormPage(all: all, editing: c),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            FunPill(
              label: 'Atur Alokasi',
              icon: Icons.tune_rounded,
              selected: true,
              expand: true,
              onTap: () => _showSheet(
                context,
                _AllocationForm(repo: repo, source: root, children: children),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  final WalletView wallet;
  final bool child;
  final bool hasChildren;
  final VoidCallback onTap;
  const _WalletRow({
    required this.wallet,
    this.child = false,
    this.hasChildren = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      _typeLabel(wallet.type),
      if (wallet.purpose != null) wallet.purpose!,
    ].join(' • ');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            IconBox(_typeIcon(wallet.type), size: child ? 36 : 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          wallet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: child ? 13 : 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                      ),
                      if (!child && (wallet.isIncomeSource || hasChildren)) ...[
                        const SizedBox(width: 6),
                        const FunBadge('Dompet Parent'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            MoneyText(fmtRp(wallet.balance), size: child ? 13 : 15),
          ],
        ),
      ),
    );
  }
}

// ── Sheet building blocks ────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SheetShell({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return AppGlassSheet(
      title: title,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool money;
  final bool number;
  final String? prefix;
  final ValueChanged<String>? onChanged;
  const _Field({
    required this.controller,
    required this.hint,
    this.money = false,
    this.number = false,
    this.prefix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: glassFill(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: (money || number)
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: money ? const [RupiahInputFormatter()] : null,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.inkPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix,
          hintStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
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
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

Widget _gap(double h) => SizedBox(height: h);

// ── Alokasi ──────────────────────────────────────────────────────────────

class _AllocationForm extends StatefulWidget {
  final WalletRepository repo;
  final WalletView source;
  final List<WalletView> children;
  const _AllocationForm({
    required this.repo,
    required this.source,
    required this.children,
  });

  @override
  State<_AllocationForm> createState() => _AllocationFormState();
}

class _AllocationFormState extends State<_AllocationForm> {
  late final Map<String, TextEditingController> _ctrls = {
    for (final c in widget.children) c.id: TextEditingController(),
  };
  bool _autoTransfer = true;

  @override
  void initState() {
    super.initState();
    widget.repo.getAllocations(widget.source.id).then((rules) {
      if (!mounted) return;
      for (final r in rules) {
        final p = r.percent;
        if (p != null) {
          _ctrls[r.targetWalletId]?.text = p == p.roundToDouble()
              ? p.round().toString()
              : p.toString();
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _pct(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  double get _totalPct => _ctrls.values.fold(0, (a, c) => a + _pct(c));

  double _share(double pct) =>
      (widget.source.balance * pct / 100).roundToDouble();

  double get _totalShare =>
      _ctrls.values.fold(0, (a, c) => a + _share(_pct(c)));

  Future<void> _save() async {
    final totalPct = _totalPct;
    if (totalPct > 100) {
      _toast(context, 'Total alokasi tidak boleh lebih dari 100%');
      return;
    }

    final totalShare = _totalShare;
    if (_autoTransfer && totalShare > widget.source.balance) {
      _toast(
        context,
        'Saldo ${widget.source.name} tidak cukup (${fmtRp(widget.source.balance)})',
      );
      return;
    }

    final nav = Navigator.of(context);
    final percents = {for (final e in _ctrls.entries) e.key: _pct(e.value)};

    if (_autoTransfer && totalShare > 0 && widget.source.balance > 0) {
      await widget.repo.distributeAllocations(
        sourceWalletId: widget.source.id,
        percents: percents,
        baseAmount: widget.source.balance,
      );
      nav.pop();
      if (!mounted) return;
      AppToast.showSuccess(
        context,
        'Alokasi tersimpan & ${fmtRp(totalShare)} berhasil dipindahkan dari ${widget.source.name}',
      );
    } else {
      await widget.repo.saveAllocations(widget.source.id, percents);
      nav.pop();
      if (!mounted) return;
      AppToast.showSuccess(context, 'Aturan alokasi berhasil disimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPct = _totalPct;
    final totalShare = _totalShare;
    final remainingPct = (100 - totalPct).clamp(0, 100);
    final remainingBalance = (widget.source.balance - totalShare).clamp(
      0,
      double.infinity,
    );

    return _SheetShell(
      title: 'Atur Alokasi: ${widget.source.name}',
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppColors.glassCardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.2,
            ),
            boxShadow: AppColors.glassShadowSoft,
          ),
          child: Row(
            children: [
              IconBox(_typeIcon(widget.source.type), size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.source.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const FunBadge('Dompet Parent'),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Saldo: ${fmtRp(widget.source.balance)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _gap(16),
        for (final c in widget.children) ...[
          Builder(
            builder: (context) {
              final pct = _pct(_ctrls[c.id]!);
              final share = _share(pct);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.inkPrimary,
                              ),
                            ),
                            if (c.purpose != null)
                              Text(
                                c.purpose!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: _Field(
                          controller: _ctrls[c.id]!,
                          hint: '0',
                          number: true,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '%',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (pct > 0 && widget.source.balance > 0) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '→ ${fmtRp(share)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          _gap(10),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: totalPct > 100
                ? AppColors.expense.withValues(alpha: 0.1)
                : glassFill(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: totalPct > 100
                  ? AppColors.expense.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.9),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Alokasi: ${totalPct.toStringAsFixed(totalPct == totalPct.roundToDouble() ? 0 : 1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: totalPct > 100
                          ? AppColors.expense
                          : AppColors.inkPrimary,
                    ),
                  ),
                  if (widget.source.balance > 0)
                    Text(
                      fmtRp(totalShare),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: totalPct > 100
                            ? AppColors.expense
                            : AppColors.inkPrimary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sisa di ${widget.source.name}: ${remainingPct.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  if (widget.source.balance > 0)
                    Text(
                      fmtRp(remainingBalance),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.inkMuted,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        _gap(12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pindahkan saldo otomatis',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkPrimary,
                    ),
                  ),
                  Text(
                    'Otomatis transfer dari ${widget.source.name} ke dompet anak saat disimpan',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _autoTransfer,
              onChanged: (v) => setState(() => _autoTransfer = v),
            ),
          ],
        ),
        _gap(16),
        _PrimaryButton(
          _autoTransfer && totalShare > 0
              ? 'Simpan & Pindahkan (${fmtRp(totalShare)})'
              : 'Simpan Alokasi',
          _save,
        ),
      ],
    );
  }
}

// ── Transfer ─────────────────────────────────────────────────────────────

class _TransferForm extends StatefulWidget {
  final WalletRepository repo;
  final List<WalletView> wallets;
  final String? initialFromId;
  const _TransferForm({
    required this.repo,
    required this.wallets,
    this.initialFromId,
  });

  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  final _amount = TextEditingController();
  final _fee = TextEditingController();
  final _note = TextEditingController();
  late String _from;
  late String _to;

  @override
  void initState() {
    super.initState();
    final initFrom = widget.initialFromId != null &&
            widget.wallets.any((w) => w.id == widget.initialFromId)
        ? widget.initialFromId!
        : widget.wallets.first.id;
    _from = initFrom;
    final available = widget.wallets.where((w) => w.id != _from).toList();
    _to = available.isNotEmpty ? available.first.id : '';
  }

  @override
  void dispose() {
    _amount.dispose();
    _fee.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = _parseAmount(_amount.text);
    final fee = _parseAmount(_fee.text);
    if (amount <= 0) {
      _toast(context, 'Isi nominal transfer');
      return;
    }
    if (_to.isEmpty) {
      _toast(context, 'Pilih dompet tujuan');
      return;
    }
    if (_from == _to) {
      _toast(context, 'Dompet asal dan tujuan harus berbeda');
      return;
    }
    final fromWallet = widget.wallets.where((w) => w.id == _from).firstOrNull;
    final totalCut = amount + fee;
    if (fromWallet != null && fromWallet.balance < totalCut) {
      _toast(
        context,
        'Saldo ${fromWallet.name} (${fmtRp(fromWallet.balance)}) tidak mencukupi untuk memindahkan ${fmtRp(totalCut)}',
      );
      return;
    }

    final nav = Navigator.of(context);
    try {
      await widget.repo.createTransfer(
        fromWalletId: _from,
        toWalletId: _to,
        amount: amount,
        fee: fee,
        note: _note.text,
      );
      nav.pop();
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final toWallets = [
      for (final w in widget.wallets)
        if (w.id != _from) w,
    ];

    return _SheetShell(
      title: 'Pindah Uang',
      children: [
        const FunLabel('Dari'),
        _gap(8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: glassFill(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.wallets.any((w) => w.id == _from)
                  ? _from
                  : (widget.wallets.isNotEmpty ? widget.wallets.first.id : null),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              dropdownColor: Colors.white.withValues(alpha: 0.96),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.inkSecondary,
              ),
              items: [
                for (final w in widget.wallets)
                  DropdownMenuItem<String>(
                    value: w.id,
                    child: Row(
                      children: [
                        Icon(
                          _typeIcon(w.type),
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
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _from = v;
                  if (_to == v ||
                      !widget.wallets.any((w) => w.id == _to && w.id != v)) {
                    final next = widget.wallets
                        .where((w) => w.id != v)
                        .firstOrNull;
                    _to = next?.id ?? '';
                  }
                });
              },
            ),
          ),
        ),
        _gap(16),
        const FunLabel('Ke'),
        _gap(8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: glassFill(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: toWallets.any((w) => w.id == _to)
                  ? _to
                  : (toWallets.isNotEmpty ? toWallets.first.id : null),
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              dropdownColor: Colors.white.withValues(alpha: 0.96),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.inkSecondary,
              ),
              items: [
                for (final w in toWallets)
                  DropdownMenuItem<String>(
                    value: w.id,
                    child: Row(
                      children: [
                        Icon(
                          _typeIcon(w.type),
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
              onChanged: (v) {
                if (v != null) {
                  setState(() => _to = v);
                }
              },
            ),
          ),
        ),
        _gap(16),
        const FunLabel('Nominal'),
        _gap(8),
        _Field(controller: _amount, hint: '0', money: true, prefix: 'Rp '),
        _gap(16),
        const FunLabel('Biaya admin (opsional)'),
        _gap(8),
        _Field(controller: _fee, hint: '0', money: true, prefix: 'Rp '),
        _gap(16),
        _Field(controller: _note, hint: 'Catatan'),
        _gap(20),
        _PrimaryButton('Pindahkan', _save),
      ],
    );
  }
}

/// Pemilih tanggal 1..31 setiap bulan dengan chip cepat & deretan angka.
class _DayOfMonthSelector extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onChanged;

  const _DayOfMonthSelector({
    required this.selectedDay,
    required this.onChanged,
  });

  static const _quickDays = <(int, String)>[
    (1, 'Tgl 1 • Awal Bulan'),
    (5, 'Tgl 5'),
    (10, 'Tgl 10'),
    (15, 'Tgl 15'),
    (25, 'Tgl 25 • Gajian'),
    (28, 'Tgl 28'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final q in _quickDays)
              FunPill(
                label: q.$2,
                selected: selectedDay == q.$1,
                onTap: () => onChanged(q.$1),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 31,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = day == selectedDay;
              return GestureDetector(
                onTap: () => onChanged(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: isSelected
                      ? auroraActiveDecoration(radius: 12)
                      : BoxDecoration(
                          color: glassFill(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                            width: 1.2,
                          ),
                        ),
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.inkPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Kartu item jadwal Auto-Transfer / Pembayaran Rutin di halaman Dompet.
class _AutoScheduleCard extends StatelessWidget {
  final AutoScheduleView schedule;
  final DateTime now;
  final List<String> shortMonths;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onExecuteNow;
  final VoidCallback onDelete;

  const _AutoScheduleCard({
    required this.schedule,
    required this.now,
    required this.shortMonths,
    required this.onTap,
    required this.onToggle,
    required this.onExecuteNow,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final executedThisMonth = schedule.isExecutedForMonth(now);
    final nextDate = schedule.nextExecutionDate(now);
    final isTransfer = schedule.kind == 'transfer';
    final displayTitle = isTransfer
        ? '${schedule.walletName} → ${schedule.toWalletName ?? '-'}'
        : schedule.title;
    final hasNote = schedule.note != null && schedule.note!.trim().isNotEmpty;
    final routeText = isTransfer
        ? (hasNote ? schedule.note!.trim() : 'Transfer rutin antar dompet')
        : '${schedule.walletName} • ${schedule.categoryName ?? 'Pengeluaran'}';

    final String statusLabel;
    final Color statusBg;
    final Color statusFg;
    final IconData statusIcon;

    if (executedThisMonth) {
      statusLabel = isTransfer
          ? 'Ditransfer bulan ini'
          : 'Terbayar bulan ini';
      statusBg = const Color(0xFFDCFCE7);
      statusFg = const Color(0xFF15803D);
      statusIcon = Icons.check_circle_rounded;
    } else if (!schedule.isEnabled) {
      statusLabel = 'Nonaktif';
      statusBg = const Color(0xFFF1F5F9);
      statusFg = AppColors.inkMuted;
      statusIcon = Icons.pause_circle_outline_rounded;
    } else {
      final isToday =
          nextDate.year == now.year &&
          nextDate.month == now.month &&
          nextDate.day == now.day;
      statusLabel = isToday
          ? 'Jatuh tempo hari ini'
          : 'Jadwal: ${nextDate.day} ${shortMonths[nextDate.month - 1]}';
      statusBg = const Color(0xFFEFF6FF);
      statusFg = AppColors.accentBlue;
      statusIcon = Icons.schedule_rounded;
    }

    return FunCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Badge Tanggal Kalender
              Container(
                width: 46,
                height: 46,
                decoration: schedule.isEnabled
                    ? auroraActiveDecoration(radius: 14)
                    : BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TGL',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: schedule.isEnabled
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppColors.inkMuted,
                      ),
                    ),
                    Text(
                      '${schedule.dayOfMonth}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: schedule.isEnabled
                            ? Colors.white
                            : AppColors.inkSecondary,
                      ),
                    ),
                  ],
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
                            displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: schedule.isEnabled
                                  ? AppColors.inkPrimary
                                  : AppColors.inkMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        FunBadge(
                          isTransfer ? 'Transfer' : 'Auto-Bayar',
                          icon: isTransfer
                              ? Icons.swap_horiz_rounded
                              : Icons.bolt_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      routeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(fmtRp(schedule.amount), size: 15),
                  SizedBox(
                    height: 28,
                    child: Transform.scale(
                      scale: 0.8,
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: schedule.isEnabled,
                        activeThumbColor: AppColors.accentBlue,
                        onChanged: onToggle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: statusFg),
                    const SizedBox(width: 5),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusFg,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!executedThisMonth) ...[
                FunPill(
                  label: 'Jalankan Sekarang',
                  icon: Icons.play_arrow_rounded,
                  onTap: onExecuteNow,
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.expenseLight.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.expense,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
