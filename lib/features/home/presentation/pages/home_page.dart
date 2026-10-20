import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/components/app_glass_sheet.dart';
import '../../../../core/components/app_toast.dart';
import '../../../../core/components/aurora_header.dart';
import '../../../../core/components/category_icons.dart';
import '../../../../core/components/fun_widgets.dart';
import '../../../../core/database/finance_repository.dart';
import '../../../../core/database/wallet_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../wallets/wallets_page.dart';
import '../../../notifications/detected_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardScreen — static UI (dummy data). Only the user's name is live.
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _cachedName = '';

  @override
  void initState() {
    super.initState();
    _loadCachedName();
  }

  Future<void> _loadCachedName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    if (mounted) setState(() => _cachedName = name);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.user?.fullName != curr.user?.fullName,
      listener: (context, state) {
        final name = state.user?.fullName ?? '';
        if (name.isNotEmpty && name != _cachedName) {
          setState(() => _cachedName = name);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final onlineName = authState.user?.fullName ?? '';
          final email = authState.user?.email ?? '';
          final greetingName = onlineName.isNotEmpty
              ? onlineName
              : _cachedName.isNotEmpty
              ? _cachedName
              : (email.contains('@') ? email.split('@').first : 'Kawan');
          return _DashboardBody(greetingName: greetingName);
        },
      ),
    );
  }
}

// ── Dummy data ──────────────────────────────────────────────────────────────

class _DummyWallet {
  final String name;
  final double balance;
  final IconData icon;
  const _DummyWallet(this.name, this.balance, this.icon);
}

class _Summary {
  final double income;
  final double expense;
  final int count;
  const _Summary(this.income, this.expense, this.count);
}

const _periodLabels = ['Harian', 'Mingguan', 'Bulanan'];
const _periodCaps = ['HARI INI', 'MINGGU INI', 'BULAN INI'];

class _DashboardBody extends StatefulWidget {
  final String greetingName;
  const _DashboardBody({required this.greetingName});

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  int _period = 2;
  int _tab = 0;
  final PageController _pager = PageController();
  final List<ScrollController> _scrolls = List.generate(
    3,
    (_) => ScrollController(),
  );

  String? _selectedWalletId;
  List<_DummyWallet> _wallets = const [];
  List<WalletView> _walletViews = const [];
  List<_Summary> _summaries = const [
    _Summary(0, 0, 0),
    _Summary(0, 0, 0),
    _Summary(0, 0, 0),
  ];
  List<BudgetView> _budgets = const [];
  List<CategoryView> _expenseCats = const [];
  List<AutoScheduleView> _autoSchedules = const [];
  List<_Goal> _goals = const [];
  final List<StreamSubscription<dynamic>> _subs = [];
  final List<StreamSubscription<dynamic>> _summarySubs = [];
  bool _checkingDueSchedules = false;

  WalletView? get _selectedWallet {
    if (_selectedWalletId == null) return null;
    return _walletViews.where((w) => w.id == _selectedWalletId).firstOrNull;
  }

  @override
  void initState() {
    super.initState();
    _bind();
  }

  Future<void> _checkAndRunDueSchedules() async {
    if (_checkingDueSchedules) return;
    _checkingDueSchedules = true;
    try {
      final executed =
          await getIt<FinanceRepository>().processDueAutoSchedules();
      if (!mounted || executed.isEmpty) return;
      if (executed.length == 1) {
        final item = executed.first;
        AppToast.showSuccess(
          context,
          'Auto-Transfer tercatat: ${item.title} (${fmtRp(item.amount)})',
        );
      } else {
        final totalExec = executed.fold<double>(0, (a, e) => a + e.amount);
        AppToast.showSuccess(
          context,
          '${executed.length} jadwal otomatis dijalankan (${fmtRp(totalExec)})',
        );
      }
    } catch (_) {
      // Abaikan bila gagal saat inisialisasi awal
    } finally {
      _checkingDueSchedules = false;
    }
  }

  void _bindSummaries() {
    for (final s in _summarySubs) {
      s.cancel();
    }
    _summarySubs.clear();
    final fin = getIt<FinanceRepository>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final ranges = [
      (today, today.add(const Duration(days: 1))),
      (weekStart, weekStart.add(const Duration(days: 7))),
      (DateTime(now.year, now.month), DateTime(now.year, now.month + 1)),
    ];
    for (var i = 0; i < ranges.length; i++) {
      _summarySubs.add(
        fin
            .watchSummary(
              ranges[i].$1,
              ranges[i].$2,
              walletId: _selectedWalletId,
            )
            .listen((s) {
              if (!mounted) return;
              setState(() {
                final next = [..._summaries];
                next[i] = _Summary(s.income, s.expense, s.count);
                _summaries = next;
              });
            }),
      );
    }
  }

  void _bind() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    final fin = getIt<FinanceRepository>();
    final now = DateTime.now();
    _bindSummaries();
    _subs.add(
      getIt<WalletRepository>().watchWallets().listen((list) {
        if (!mounted) return;
        setState(() {
          _walletViews = list;
          _wallets = [
            for (final w in list)
              _DummyWallet(w.name, w.balance, switch (w.type) {
                'bank' => Icons.account_balance_outlined,
                'e_wallet' => Icons.account_balance_wallet_outlined,
                _ => Icons.payments_outlined,
              }),
          ];
        });
      }),
    );
    _subs.add(
      fin.watchBudgets(now.month, now.year).listen((b) {
        if (mounted) setState(() => _budgets = b);
      }),
    );
    _subs.add(
      fin.watchCategories('expense').listen((c) {
        if (mounted) setState(() => _expenseCats = c);
      }),
    );
    _subs.add(
      fin.watchAutoSchedules().listen((schedules) {
        if (mounted) setState(() => _autoSchedules = schedules);
      }),
    );
    _subs.add(
      fin.watchJars().listen((jars) {
        if (!mounted) return;
        setState(
          () => _goals = [
            for (final j in jars) _Goal(j.id, j.title, j.target, j.saved),
          ],
        );
      }),
    );
    _checkAndRunDueSchedules();
  }

  void _onWalletSelected(String? walletId) {
    setState(() => _selectedWalletId = walletId);
    _bindSummaries();
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    for (final sub in _summarySubs) {
      sub.cancel();
    }
    _pager.dispose();
    for (final c in _scrolls) {
      c.dispose();
    }
    super.dispose();
  }

  void _setTab(int i) {
    if (i == _tab) return;
    _pager.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _showGoalSheet({_Goal? deposit}) {
    final nameC = TextEditingController();
    final amountC = TextEditingController();
    String? walletId = _walletViews.isNotEmpty ? _walletViews.first.id : null;
    AppGlassSheet.show(
      context: context,
      builder: (ctx) => AppGlassSheet(
        title: deposit == null ? 'Buat Tabungan Baru' : 'Setor ke ${deposit.name}',
        subtitle: deposit == null ? 'Target tabungan impianmu' : 'Alokasikan dana tabungan',
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (deposit == null) ...[
                const FunLabel('Nama tabungan'),
                const SizedBox(height: 6),
                _SheetField(controller: nameC, hint: 'Contoh: Beli Laptop'),
                const SizedBox(height: 12),
              ],
              FunLabel(deposit == null ? 'Target (Rp)' : 'Nominal setoran (Rp)'),
              const SizedBox(height: 6),
              _SheetField(
                controller: amountC,
                hint: '0',
                number: true,
                autofocus: deposit != null,
              ),
              if (deposit != null && _walletViews.isNotEmpty) ...[
                const SizedBox(height: 12),
                const FunLabel('Ambil dari dompet'),
                const SizedBox(height: 6),
                StatefulBuilder(
                  builder: (c, setSheet) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FunPill(
                        label: 'Tanpa dompet',
                        selected: walletId == null,
                        onTap: () => setSheet(() => walletId = null),
                      ),
                      for (final w in _walletViews)
                        FunPill(
                          label: w.name,
                          selected: walletId == w.id,
                          onTap: () => setSheet(() => walletId = w.id),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  final v =
                      double.tryParse(
                        amountC.text.replaceAll(RegExp(r'[^\d]'), ''),
                      ) ??
                      0;
                  if (v <= 0) return;
                  final repo = getIt<FinanceRepository>();
                  if (deposit == null) {
                    final n = nameC.text.trim();
                    repo.addJar(
                      title: n.isEmpty ? 'Tabungan Baru' : n,
                      target: v,
                    );
                  } else {
                    repo.deposit(
                      jarId: deposit.id,
                      amount: v,
                      walletId: walletId,
                    );
                  }
                  Navigator.pop(ctx);
                },
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
                    deposit == null ? 'Buat Tabungan' : 'Setor Sekarang',
                    style: const TextStyle(
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

  static const _shortMonths = [
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

  void _showBudgetSheet({BudgetView? editing}) {
    final amountC = TextEditingController(
      text: editing == null ? '' : editing.limit.round().toString(),
    );
    String? categoryId = editing?.categoryId;

    final existingAuto = editing == null
        ? null
        : _autoSchedules
              .where(
                (s) =>
                    s.budgetId == editing.id ||
                    (editing.categoryId != null &&
                        s.categoryId == editing.categoryId),
              )
              .firstOrNull;

    bool enableAuto = existingAuto != null ? existingAuto.isEnabled : false;
    String autoKind = existingAuto?.kind ?? 'expense';
    int dayOfMonth = existingAuto?.dayOfMonth ?? 1;
    final autoTitleC = TextEditingController(
      text: existingAuto?.title ?? '',
    );
    final autoAmountC = TextEditingController(
      text: existingAuto != null ? existingAuto.amount.round().toString() : '',
    );
    String? fromWalletId =
        existingAuto?.walletId ??
        (_walletViews.isNotEmpty ? _walletViews.first.id : null);
    String? toWalletId =
        existingAuto?.toWalletId ??
        (_walletViews.length > 1
            ? _walletViews.firstWhere((w) => w.id != fromWalletId).id
            : null);
    bool executeNow = false;

    AppGlassSheet.show(
      context: context,
      builder: (ctx) => AppGlassSheet(
        title: editing == null ? 'Rencana Anggaran' : 'Ubah Anggaran',
        subtitle: 'Atur batas pengeluaran & jadwal auto-transfer bulanan',
        child: StatefulBuilder(
          builder: (c, setSheet) {
            final selectedCatName = _expenseCats
                .where((cat) => cat.id == categoryId)
                .firstOrNull
                ?.name;
            final now = DateTime.now();
            final alreadyExecuted =
                existingAuto?.isExecutedForMonth(now) ?? false;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunLabel('Kategori'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FunPill(
                        label: 'Semua',
                        selected: categoryId == null,
                        onTap: editing != null
                            ? null
                            : () => setSheet(() => categoryId = null),
                      ),
                      for (final cat in _expenseCats)
                        FunPill(
                          label: cat.name,
                          icon: categoryIcon(cat.icon),
                          selected: categoryId == cat.id,
                          onTap: editing != null
                              ? null
                              : () => setSheet(() {
                                  categoryId = cat.id;
                                  if (autoTitleC.text.trim().isEmpty) {
                                    autoTitleC.text = 'Bayar ${cat.name}';
                                  }
                                }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const FunLabel('Batas per bulan (Rp)'),
                  const SizedBox(height: 6),
                  _SheetField(
                    controller: amountC,
                    hint: '0',
                    number: true,
                    autofocus: editing == null,
                  ),
                  const SizedBox(height: 16),

                  // ── Toggle Auto-Transfer / Pembayaran Otomatis ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: enableAuto
                          ? const Color(0xFFEFF6FF)
                          : AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: enableAuto
                            ? AppColors.accentBlue.withValues(alpha: 0.45)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: enableAuto
                                    ? AppColors.accentBlue
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.event_repeat_rounded,
                                size: 18,
                                color: enableAuto
                                    ? Colors.white
                                    : AppColors.inkSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Auto-Transfer / Bayar Otomatis',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Otomatis jalan setiap tanggal yang diatur (misal bayar kost tgl 1)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: enableAuto,
                              activeThumbColor: AppColors.accentBlue,
                              onChanged: (v) => setSheet(() {
                                enableAuto = v;
                                if (v && autoTitleC.text.trim().isEmpty) {
                                  autoTitleC.text = selectedCatName != null
                                      ? 'Bayar $selectedCatName'
                                      : 'Bayar Kost';
                                }
                              }),
                            ),
                          ],
                        ),
                        if (enableAuto) ...[
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: Color(0xFFDBEAFE)),
                          const SizedBox(height: 12),
                          if (_walletViews.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Tambahkan dompet terlebih dahulu di menu Dompet agar auto-transfer dapat memotong saldo.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                            )
                          else ...[
                            const FunLabel('Jenis Otomatis'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: FunPill(
                                    label: 'Potong Saldo / Bayar',
                                    icon: Icons.receipt_long_rounded,
                                    selected: autoKind == 'expense',
                                    onTap: () =>
                                        setSheet(() => autoKind = 'expense'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FunPill(
                                    label: 'Pindah Dompet',
                                    icon: Icons.swap_horiz_rounded,
                                    selected: autoKind == 'transfer',
                                    onTap: _walletViews.length < 2
                                        ? null
                                        : () => setSheet(
                                            () => autoKind = 'transfer',
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const FunLabel('Nama Pembayaran / Auto-Transfer'),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final preset in const [
                                  'Bayar Kost',
                                  'Listrik & Air',
                                  'WiFi / Internet',
                                  'Cicilan / Tagihan',
                                ])
                                  FunPill(
                                    label: preset,
                                    selected:
                                        autoTitleC.text.trim().toLowerCase() ==
                                        preset.toLowerCase(),
                                    onTap: () =>
                                        setSheet(() => autoTitleC.text = preset),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _SheetField(
                              controller: autoTitleC,
                              hint: 'Contoh: Bayar Kost Bulanan',
                            ),
                            const SizedBox(height: 12),
                            FunLabel('Setiap Tanggal ($dayOfMonth setiap bulan)'),
                            const SizedBox(height: 6),
                            _DayOfMonthSelector(
                              selectedDay: dayOfMonth,
                              onChanged: (d) => setSheet(() => dayOfMonth = d),
                            ),
                            const SizedBox(height: 12),
                            const FunLabel(
                              'Nominal Otomatis (Kosongkan = ikut batas anggaran)',
                            ),
                            const SizedBox(height: 6),
                            _SheetField(
                              controller: autoAmountC,
                              hint: 'Ikuti nominal anggaran di atas',
                              number: true,
                            ),
                            const SizedBox(height: 12),
                            FunLabel(
                              autoKind == 'transfer'
                                  ? 'Dari Dompet Asal'
                                  : 'Potong dari Dompet',
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final w in _walletViews)
                                  FunPill(
                                    label: w.name,
                                    selected: fromWalletId == w.id,
                                    onTap: () => setSheet(() {
                                      fromWalletId = w.id;
                                      if (toWalletId == w.id) {
                                        toWalletId = _walletViews
                                            .where((x) => x.id != w.id)
                                            .firstOrNull
                                            ?.id;
                                      }
                                    }),
                                  ),
                              ],
                            ),
                            if (autoKind == 'transfer' &&
                                _walletViews.length > 1) ...[
                              const SizedBox(height: 12),
                              const FunLabel('Ke Dompet Tujuan'),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final w in _walletViews)
                                    if (w.id != fromWalletId)
                                      FunPill(
                                        label: w.name,
                                        selected: toWalletId == w.id,
                                        onTap: () =>
                                            setSheet(() => toWalletId = w.id),
                                      ),
                                ],
                              ),
                            ],
                            if (!alreadyExecuted && dayOfMonth <= now.day) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      dayOfMonth == now.day
                                          ? 'Hari ini tanggal $dayOfMonth • langsung jalankan untuk bulan ini'
                                          : 'Tanggal $dayOfMonth sudah lewat bulan ini • jalankan juga sekarang?',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.inkSecondary,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value:
                                        dayOfMonth == now.day || executeNow,
                                    activeThumbColor: AppColors.accentBlue,
                                    onChanged: (v) =>
                                        setSheet(() => executeNow = v),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      final v =
                          double.tryParse(
                            amountC.text.replaceAll(RegExp(r'[^\d]'), ''),
                          ) ??
                          0;
                      if (v <= 0) return;
                      final now = DateTime.now();
                      final repo = getIt<FinanceRepository>();
                      final nav = Navigator.of(ctx);

                      final savedBudgetId = await repo.saveBudget(
                        id: editing?.id,
                        categoryId: categoryId,
                        limit: v,
                        month: now.month,
                        year: now.year,
                      );

                      if (enableAuto && fromWalletId != null) {
                        final customAutoAmt =
                            double.tryParse(
                              autoAmountC.text.replaceAll(RegExp(r'[^\d]'), ''),
                            ) ??
                            0;
                        final autoAmt = customAutoAmt > 0 ? customAutoAmt : v;
                        final fallbackTitle = selectedCatName != null
                            ? 'Bayar $selectedCatName'
                            : 'Bayar Kost';
                        final runNow =
                            !alreadyExecuted &&
                            (dayOfMonth == now.day || executeNow);

                        await repo.saveAutoSchedule(
                          id: existingAuto?.id,
                          title: autoTitleC.text.trim().isEmpty
                              ? fallbackTitle
                              : autoTitleC.text.trim(),
                          kind: autoKind,
                          amount: autoAmt,
                          dayOfMonth: dayOfMonth,
                          walletId: fromWalletId!,
                          toWalletId: autoKind == 'transfer'
                              ? toWalletId
                              : null,
                          categoryId: categoryId,
                          budgetId: savedBudgetId,
                          isEnabled: true,
                          executeNowForCurrentMonth: runNow,
                        );
                      } else if (!enableAuto && existingAuto != null) {
                        await repo.toggleAutoSchedule(existingAuto.id, false);
                      }

                      nav.pop();
                    },
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
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (editing != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          getIt<FinanceRepository>().deleteBudget(editing.id);
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Hapus anggaran',
                          style: TextStyle(color: AppColors.expense),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAutoScheduleSheet({AutoScheduleView? editing}) {
    final titleC = TextEditingController(text: editing?.title ?? '');
    final amountC = TextEditingController(
      text: editing == null ? '' : editing.amount.round().toString(),
    );
    final noteC = TextEditingController(text: editing?.note ?? '');
    String kind = editing?.kind ?? 'expense';
    int dayOfMonth = editing?.dayOfMonth ?? 1;
    String? fromWalletId =
        editing?.walletId ??
        (_walletViews.isNotEmpty ? _walletViews.first.id : null);
    String? toWalletId =
        editing?.toWalletId ??
        (_walletViews.length > 1
            ? _walletViews.firstWhere((w) => w.id != fromWalletId).id
            : null);
    String? categoryId =
        editing?.categoryId ??
        (_expenseCats.isNotEmpty
            ? (_expenseCats
                      .where((c) => c.name.toLowerCase() == 'tagihan')
                      .firstOrNull
                      ?.id ??
                  _expenseCats.first.id)
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
          builder: (c, setSheet) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_walletViews.isEmpty) ...[
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
                          label: 'Buka Menu Dompet',
                          icon: Icons.account_balance_wallet_outlined,
                          selected: true,
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const WalletsPage(),
                              ),
                            );
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
                          onTap: _walletViews.length < 2
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
                  const FunLabel('2. Nama Jadwal (Pilih cepat atau ketik)'),
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
                  _SheetField(
                    controller: titleC,
                    hint: kind == 'transfer'
                        ? 'Contoh: Pindah Saldo Kost / Tabungan'
                        : 'Contoh: Bayar Kost-kostan',
                  ),
                  const SizedBox(height: 14),
                  const FunLabel('3. Nominal (Rp)'),
                  const SizedBox(height: 6),
                  _SheetField(
                    controller: amountC,
                    hint: 'Contoh: 1500000',
                    number: true,
                  ),
                  const SizedBox(height: 14),
                  FunLabel(
                    '4. Tanggal Eksekusi: Setiap Tanggal $dayOfMonth',
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
                  const SizedBox(height: 14),
                  FunLabel(
                    kind == 'transfer'
                        ? '5. Dari Dompet Asal'
                        : '5. Potong Saldo dari Dompet',
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final w in _walletViews)
                        FunPill(
                          label: '${w.name} (${fmtRp(w.balance)})',
                          selected: fromWalletId == w.id,
                          onTap: () => setSheet(() {
                            fromWalletId = w.id;
                            if (toWalletId == w.id) {
                              toWalletId = _walletViews
                                  .where((x) => x.id != w.id)
                                  .firstOrNull
                                  ?.id;
                            }
                          }),
                        ),
                    ],
                  ),
                  if (kind == 'transfer' && _walletViews.length > 1) ...[
                    const SizedBox(height: 14),
                    const FunLabel('6. Ke Dompet Tujuan'),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final w in _walletViews)
                          if (w.id != fromWalletId)
                            FunPill(
                              label: w.name,
                              selected: toWalletId == w.id,
                              onTap: () => setSheet(() => toWalletId = w.id),
                            ),
                      ],
                    ),
                  ] else if (kind == 'expense' && _expenseCats.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const FunLabel('6. Kategori Anggaran'),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final cat in _expenseCats)
                          FunPill(
                            label: cat.name,
                            icon: categoryIcon(cat.icon),
                            selected: categoryId == cat.id,
                            onTap: () => setSheet(() => categoryId = cat.id),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  const FunLabel('Catatan (Opsional)'),
                  const SizedBox(height: 6),
                  _SheetField(
                    controller: noteC,
                    hint: 'Contoh: Kost Putra Kamar 12',
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
                  GestureDetector(
                    onTap: () async {
                      final amt =
                          double.tryParse(
                            amountC.text.replaceAll(RegExp(r'[^\d]'), ''),
                          ) ??
                          0;
                      if (amt <= 0) {
                        AppToast.showWarning(
                          context,
                          'Masukkan nominal auto-transfer terlebih dahulu',
                        );
                        return;
                      }
                      if (fromWalletId == null) return;
                      if (kind == 'transfer' &&
                          (toWalletId == null || toWalletId == fromWalletId)) {
                        AppToast.showWarning(
                          context,
                          'Pilih dompet tujuan yang berbeda',
                        );
                        return;
                      }

                      final repo = getIt<FinanceRepository>();
                      final nav = Navigator.of(ctx);
                      final cleanTitle = titleC.text.trim().isEmpty
                          ? (kind == 'transfer'
                                ? 'Auto-Transfer Bulanan'
                                : 'Bayar Kost')
                          : titleC.text.trim();

                      // Cari apakah ada budget yang cocok dengan kategori ini
                      final matchingBudget = kind == 'expense'
                          ? _budgets
                                .where((b) => b.categoryId == categoryId)
                                .firstOrNull
                          : null;

                      await repo.saveAutoSchedule(
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
                      if (!mounted) return;
                      AppToast.showSuccess(
                        context,
                        !alreadyExecuted && executeNow
                            ? 'Jadwal disimpan & ${fmtRp(amt)} berhasil diproses untuk bulan ini'
                            : 'Jadwal otomatis setiap tanggal $dayOfMonth berhasil disimpan',
                      );
                    },
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
                        editing == null
                            ? 'Simpan Jadwal Otomatis'
                            : 'Simpan Perubahan',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (editing != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          getIt<FinanceRepository>().deleteAutoSchedule(
                            editing.id,
                          );
                          Navigator.pop(ctx);
                        },
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
          ),
        ),
      ),
    );
  }

  List<Widget> _budgetTab() {
    final items = _budgets;
    final limit = items.fold<double>(0, (a, e) => a + e.limit);
    final spent = items.fold<double>(0, (a, e) => a + e.spent);
    double ratio(double a, double b) => b <= 0 ? 0 : (a / b);
    final now = DateTime.now();

    final activeSchedules = _autoSchedules.where((s) => s.isEnabled).toList();
    final totalAutoAmount = activeSchedules.fold<double>(
      0,
      (a, s) => a + s.amount,
    );
    final doneCount = activeSchedules
        .where((s) => s.isExecutedForMonth(now))
        .length;

    return [
      FunCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FunLabel('Rencana anggaran bulan ini'),
            const SizedBox(height: 6),
            MoneyText(fmtRp(limit), size: 30),
            const SizedBox(height: 12),
            _ProgressBar(value: ratio(spent, limit)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Terpakai ${fmtRp(spent)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ),
                FunBadge('Sisa ${fmtRp(limit - spent)}'),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

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
            onTap: () => _showAutoScheduleSheet(),
          ),
        ],
      ),
      const SizedBox(height: 10),
      if (_autoSchedules.isEmpty)
        FunCard(
          onTap: () => _showAutoScheduleSheet(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: auroraActiveDecoration(radius: 14),
                child: const Icon(
                  Icons.event_repeat_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belum ada jadwal auto-transfer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkPrimary,
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
                decoration: auroraActiveDecoration(radius: 14),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FunLabel('Total Auto-Transfer / Bulan'),
                    const SizedBox(height: 2),
                    MoneyText(fmtRp(totalAutoAmount), size: 20),
                  ],
                ),
              ),
              FunBadge('$doneCount/${activeSchedules.length} selesai'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (final s in _autoSchedules)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AutoScheduleCard(
              schedule: s,
              now: now,
              shortMonths: _shortMonths,
              onTap: () => _showAutoScheduleSheet(editing: s),
              onToggle: (v) =>
                  getIt<FinanceRepository>().toggleAutoSchedule(s.id, v),
              onExecuteNow: () async {
                final done = await getIt<FinanceRepository>()
                    .executeAutoScheduleNow(s.id);
                if (!mounted || done == null) return;
                AppToast.showSuccess(
                  context,
                  'Berhasil dijalankan: ${done.title} (${fmtRp(done.amount)})',
                );
              },
            ),
          ),
      ],

      const SizedBox(height: 12),
      const Padding(
        padding: EdgeInsets.only(left: 4, bottom: 8),
        child: FunLabel('Anggaran per kategori'),
      ),
      if (items.isEmpty)
        const FunCard(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Text(
                'Belum ada anggaran bulan ini',
                style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
              ),
            ),
          ),
        )
      else
        FunCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Builder(
                  builder: (context) {
                    final linkedAuto = _autoSchedules
                        .where(
                          (s) =>
                              s.isEnabled &&
                              (s.budgetId == items[i].id ||
                                  (items[i].categoryId != null &&
                                      s.categoryId == items[i].categoryId)),
                        )
                        .firstOrNull;
                    return InkWell(
                      onTap: () => _showBudgetSheet(editing: items[i]),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconBox(
                                  items[i].categoryId == null
                                      ? Icons.pie_chart_outline_rounded
                                      : categoryIcon(
                                          _expenseCats
                                              .where(
                                                (c) =>
                                                    c.id == items[i].categoryId,
                                              )
                                              .firstOrNull
                                              ?.icon,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              items[i].categoryName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.inkPrimary,
                                              ),
                                            ),
                                          ),
                                          if (linkedAuto != null) ...[
                                            const SizedBox(width: 6),
                                            FunBadge(
                                              'Auto Tgl ${linkedAuto.dayOfMonth}',
                                              icon: Icons.event_repeat_rounded,
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        '${fmtRp(items[i].spent)} dari ${fmtRp(items[i].limit)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FunBadge(
                                  '${(ratio(items[i].spent, items[i].limit) * 100).round()}%',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _ProgressBar(
                              value: ratio(items[i].spent, items[i].limit),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      const SizedBox(height: 16),
      FunCard(
        onTap: () => _showBudgetSheet(),
        padding: const EdgeInsets.all(16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppColors.inkSecondary),
            SizedBox(width: 8),
            Text(
              'Tambah rencana anggaran',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _piggoTab() {
    final saved = _goals.fold<double>(0, (a, g) => a + g.saved);
    final target = _goals.fold<double>(0, (a, g) => a + g.target);
    return [
      FunCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: auroraActiveDecoration(radius: 18),
              child: const Icon(
                Icons.savings_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunLabel('Total tabungan Piggo'),
                  const SizedBox(height: 4),
                  MoneyText(fmtRp(saved), size: 26),
                  Text(
                    'dari target ${fmtRp(target)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          const Expanded(child: FunLabel('Celengan saya')),
          FunPill(
            label: 'Buat Tabungan',
            icon: Icons.add_rounded,
            selected: true,
            onTap: () => _showGoalSheet(),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (_goals.isEmpty)
        const FunCard(
          padding: EdgeInsets.symmetric(vertical: 36),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                IconBox(
                  Icons.savings_outlined,
                  size: 48,
                  radius: 16,
                  iconSize: 22,
                ),
                SizedBox(height: 12),
                Text(
                  'Belum ada tabungan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      for (final g in _goals)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FunCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBox(Icons.savings_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkPrimary,
                            ),
                          ),
                          Text(
                            '${fmtRp(g.saved)} dari ${fmtRp(g.target)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FunBadge('${(g.progress * 100).round()}%'),
                  ],
                ),
                const SizedBox(height: 12),
                _ProgressBar(value: g.progress),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Kurang ${fmtRp((g.target - g.saved).clamp(0, double.infinity))}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ),
                    FunPill(
                      label: 'Setor',
                      icon: Icons.add_rounded,
                      onTap: () => _showGoalSheet(deposit: g),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => getIt<FinanceRepository>().deleteJar(g.id),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ];
  }

  List<String> _budgetBadges() {
    final activeAuto = _autoSchedules.where((s) => s.isEnabled).length;
    if (_budgets.isEmpty && activeAuto == 0) {
      return const ['Belum ada anggaran'];
    }
    final limit = _budgets.fold<double>(0, (a, b) => a + b.limit);
    final spent = _budgets.fold<double>(0, (a, b) => a + b.spent);
    final now = DateTime.now();
    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day;
    return [
      if (_budgets.isNotEmpty) 'Sisa ${fmtRp(limit - spent)}',
      '$daysLeft hari lagi',
      if (activeAuto > 0)
        '$activeAuto auto-transfer'
      else
        '${_budgets.length} kategori',
    ];
  }

  bool _syncing = false;

  Future<void> _sync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final r = await getIt<SyncService>().sync();
      if (mounted) {
        AppToast.showSuccess(
          context,
          'Sinkron selesai • ${r.pushed} terkirim, ${r.pulled} diterima',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _wallets.fold<double>(0, (a, w) => a + w.balance);
    final s = _summaries[_period];
    final net = s.income - s.expense;

    return Column(
      children: [
        AuroraHeader(
          userName: widget.greetingName,
          onSyncTap: _sync,
          isSyncing: _syncing,
          leading: _HeaderTabs(
            pager: _pager,
            fallbackIndex: _tab,
            onChanged: _setTab,
          ),
          badges: _tab == 1
              ? _budgetBadges()
              : _tab == 2
              ? [
                  '${_goals.length} celengan',
                  '${(_goals.fold<double>(0, (a, g) => a + g.saved) / (_goals.fold<double>(0, (a, g) => a + g.target) == 0 ? 1 : _goals.fold<double>(0, (a, g) => a + g.target)) * 100).round()}% tercapai',
                ]
              : null,
          eyebrow: _tab == 1
              ? 'Rencana pengeluaran'
              : _tab == 2
              ? 'Celengan digital'
              : null,
          headline: _tab == 1
              ? 'Budgeting Plan'
              : _tab == 2
              ? 'Piggo'
              : null,
        ),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -32,
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: Listenable.merge(_scrolls),
                  builder: (context, child) {
                    final sc = _scrolls[_tab];
                    final offset = sc.hasClients ? sc.offset : 0.0;
                    final shadowOpacity = (offset / 40).clamp(0.0, 0.15);
                    final shadowBlur = (offset / 40 * 20).clamp(0.0, 20.0);
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFE0F2FE),
                            Color(0xFFEDE9FE),
                            Color(0xFFF0FDF4),
                            AppColors.canvas,
                          ],
                          stops: [0.0, 0.35, 0.7, 1.0],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: shadowOpacity,
                            ),
                            blurRadius: shadowBlur,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        child: Stack(
                          children: [
                            const _GlassBlob(
                              top: 20,
                              left: -70,
                              color: Color(0xFF86EFAC),
                            ),
                            const _GlassBlob(
                              top: 260,
                              right: -80,
                              color: Color(0xFFA5B4FC),
                            ),
                            const _GlassBlob(
                              top: 560,
                              left: -60,
                              color: Color(0xFF7DD3FC),
                            ),
                            Positioned.fill(child: GlassScope(child: child!)),
                          ],
                        ),
                      ),
                    );
                  },
                  child: PageView.builder(
                    controller: _pager,
                    itemCount: 3,
                    onPageChanged: (p) => setState(() => _tab = p),
                    itemBuilder: (context, page) => RefreshIndicator(
                      onRefresh: () async {
                        _bind();
                        await Future.delayed(const Duration(milliseconds: 300));
                      },
                      child: SingleChildScrollView(
                        controller: _scrolls[page],
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.only(top: 16, bottom: 180),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (page == 1)
                              ..._budgetTab()
                            else if (page == 2)
                              ..._piggoTab()
                            else ...[
                              const DetectedCard(),
                              // ── Total Aset / Dompet ──
                              FunCard(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  12,
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FunLabel(
                                                _selectedWallet != null
                                                    ? 'Saldo • ${_selectedWallet!.name}'
                                                    : 'Total Aset / Dompet',
                                                icon: Icons.wallet_outlined,
                                              ),
                                              const SizedBox(height: 6),
                                              MoneyText(
                                                fmtRp(
                                                  _selectedWallet != null
                                                      ? _selectedWallet!.balance
                                                      : total,
                                                ),
                                                size: 26,
                                              ),
                                            ],
                                          ),
                                        ),
                                        FunRoundButton(
                                          Icons.add_rounded,
                                          onTap: () =>
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const WalletsPage(),
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 66,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        itemCount: _wallets.length + 1,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (_, i) {
                                          if (i == 0) {
                                            return _AllWalletsChip(
                                              total: total,
                                              selected:
                                                  _selectedWalletId == null,
                                              onTap: () =>
                                                  _onWalletSelected(null),
                                            );
                                          }
                                          final w = _walletViews[i - 1];
                                          final dummy = _wallets[i - 1];
                                          return _WalletChip(
                                            dummy,
                                            selected: _selectedWalletId == w.id,
                                            onTap: () => _onWalletSelected(
                                              _selectedWalletId == w.id
                                                  ? null
                                                  : w.id,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Monthly summary ──
                              FunCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: FunTabs(
                                              labels: _periodLabels,
                                              selected: _period,
                                              onChanged: (i) =>
                                                  setState(() => _period = i),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    FunLabel(
                                      _selectedWallet != null
                                          ? 'Arus kas ${_periodCaps[_period]} • ${_selectedWallet!.name}'
                                          : 'Arus kas ${_periodCaps[_period]}',
                                    ),
                                    const SizedBox(height: 6),
                                    MoneyText(
                                      '${net >= 0 ? '+' : '-'}${fmtRp(net.abs())}',
                                      size: 30,
                                    ),
                                    const SizedBox(height: 6),
                                    FunBadge(
                                      net >= 0 ? 'Surplus' : 'Defisit',
                                      icon: net >= 0
                                          ? Icons.trending_up_rounded
                                          : Icons.trending_down_rounded,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _MetricCard(
                                      icon: Icons.south_west_rounded,
                                      label: 'Pemasukan',
                                      value: fmtRp(s.income),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _MetricCard(
                                      icon: Icons.north_east_rounded,
                                      label: 'Pengeluaran',
                                      value: fmtRp(s.expense),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _MetricCard(
                                      icon: Icons.receipt_long_outlined,
                                      label: 'Transaksi',
                                      value: '${s.count}',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Goal {
  final String id;
  final String name;
  final double target;
  final double saved;
  _Goal(this.id, this.name, this.target, this.saved);
  double get progress => target <= 0 ? 0 : (saved / target).clamp(0.0, 1.0);
}

/// Glass pill tab switcher living in the header app bar (Money+ style).
/// Driven continuously by the PageView position so the white pill slides and
/// the labels expand/collapse in sync with the swipe (no flicker).
class _HeaderTabs extends StatelessWidget {
  final PageController pager;
  final int fallbackIndex;
  final ValueChanged<int> onChanged;
  const _HeaderTabs({
    required this.pager,
    required this.fallbackIndex,
    required this.onChanged,
  });

  static const _tabs = [
    (Icons.home_outlined, 'Beranda', 44.0),
    (Icons.pie_chart_outline_rounded, 'Anggaran', 44.0),
    (Icons.savings_outlined, 'Piggo', 44.0),
  ];
  static const double _iconW = 44;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: AnimatedBuilder(
        animation: pager,
        builder: (context, _) {
          double p = fallbackIndex.toDouble();
          if (pager.hasClients && pager.position.haveDimensions) {
            p = (pager.page ?? p).clamp(0.0, _tabs.length - 1.0);
          }
          final widths = <double>[];
          final ts = <double>[];
          for (int i = 0; i < _tabs.length; i++) {
            final t = (1 - (p - i).abs()).clamp(0.0, 1.0);
            ts.add(t);
            widths.add(_iconW + (_tabs[i].$3 - _iconW) * t);
          }
          final lefts = <double>[];
          double acc = 0;
          for (final w in widths) {
            lefts.add(acc);
            acc += w;
          }
          final a = p.floor().clamp(0, _tabs.length - 1);
          final b = (a + 1).clamp(0, _tabs.length - 1);
          final f = p - a;
          final pillLeft = lefts[a] + (lefts[b] - lefts[a]) * f;
          final pillW = widths[a] + (widths[b] - widths[a]) * f;

          return SizedBox(
            width: acc,
            height: 36,
            child: Stack(
              children: [
                Positioned(
                  left: pillLeft,
                  width: pillW,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140F172A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                for (int i = 0; i < _tabs.length; i++)
                  Positioned(
                    left: lefts[i],
                    width: widths[i],
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => onChanged(i),
                      behavior: HitTestBehavior.opaque,
                      child: ClipRect(
                        child: OverflowBox(
                          maxWidth: _tabs[i].$3,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _tabs[i].$1,
                                size: 18,
                                color: Color.lerp(
                                  AppColors.inkPrimary,
                                  AppColors.accentBlue,
                                  ts[i],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Stack(
        children: [
          Container(height: 8, color: glassFill(context)),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: 8,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF38BDF8),
                    Color(0xFF2563EB),
                    Color(0xFF4F46E5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool number;
  final bool autofocus;
  const _SheetField({
    required this.controller,
    required this.hint,
    this.number = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14, color: AppColors.inkPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

/// Soft blurred-looking color blob (radial gradient) that gives the
/// translucent glass cards something to refract over.
class _GlassBlob extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final Color color;
  const _GlassBlob({this.top, this.left, this.right, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.45),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletChip extends StatelessWidget {
  final _DummyWallet wallet;
  final bool selected;
  final VoidCallback? onTap;

  const _WalletChip(this.wallet, {this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 136),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEFF6FF)
              : glassFill(context, normal: Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.accentBlue
                : Colors.white.withValues(alpha: 0.85),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBox(
              wallet.icon,
              size: 32,
              radius: 10,
              iconSize: 16,
              color: selected ? AppColors.accentBlue : null,
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.accentBlue
                        : AppColors.inkSecondary,
                  ),
                ),
                Text(
                  fmtRp(wallet.balance),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AllWalletsChip extends StatelessWidget {
  final double total;
  final bool selected;
  final VoidCallback onTap;

  const _AllWalletsChip({
    required this.total,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEFF6FF)
              : glassFill(context, normal: Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.accentBlue
                : Colors.white.withValues(alpha: 0.85),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBox(
              Icons.all_inclusive_rounded,
              size: 32,
              radius: 10,
              iconSize: 16,
              color: selected ? AppColors.accentBlue : null,
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semua',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.accentBlue
                        : AppColors.inkSecondary,
                  ),
                ),
                Text(
                  fmtRp(total),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return FunCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(icon, size: 28, radius: 8, iconSize: 14),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 2),
          MoneyText(value, size: 14, weight: FontWeight.w700),
        ],
      ),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
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

/// Kartu item jadwal Auto-Transfer / Pembayaran Rutin di tab Budgeting Plan.
class _AutoScheduleCard extends StatelessWidget {
  final AutoScheduleView schedule;
  final DateTime now;
  final List<String> shortMonths;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onExecuteNow;

  const _AutoScheduleCard({
    required this.schedule,
    required this.now,
    required this.shortMonths,
    required this.onTap,
    required this.onToggle,
    required this.onExecuteNow,
  });

  @override
  Widget build(BuildContext context) {
    final executedThisMonth = schedule.isExecutedForMonth(now);
    final nextDate = schedule.nextExecutionDate(now);
    final isTransfer = schedule.kind == 'transfer';
    final routeText = isTransfer
        ? '${schedule.walletName} → ${schedule.toWalletName ?? '-'}'
        : '${schedule.walletName} • ${schedule.categoryName ?? 'Pengeluaran'}';

    final String statusLabel;
    final Color statusBg;
    final Color statusFg;
    final IconData statusIcon;

    if (executedThisMonth) {
      statusLabel = 'Terbayar bulan ini';
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
                            schedule.title,
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
              if (!executedThisMonth)
                FunPill(
                  label: 'Jalankan Sekarang',
                  icon: Icons.play_arrow_rounded,
                  onTap: onExecuteNow,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

