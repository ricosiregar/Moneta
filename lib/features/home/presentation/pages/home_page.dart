import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/components/app_glass_dialog.dart';
import '../../../../core/components/app_glass_sheet.dart';
import '../../../../core/components/app_toast.dart';
import '../../../../core/components/aurora_header.dart';
import '../../../../core/components/category_icons.dart';
import '../../../../core/components/fun_widgets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../wallets/presentation/pages/wallets_page.dart';
import '../../../budgets/domain/entities/budget_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../wallets/domain/entities/wallet_entity.dart';
import '../cubit/home_cubit.dart';
import '../../../budgets/domain/usecases/budget_usecases.dart';
import '../../../budgets/presentation/cubit/budgets_cubit.dart';
import '../../../jars/domain/usecases/jar_usecases.dart';
import '../../../jars/presentation/cubit/jars_cubit.dart';
import '../../../schedules/domain/usecases/schedule_usecases.dart';
import '../../../../core/utils/usecase.dart';
import '../../../notifications/presentation/widgets/detected_card.dart';
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
  List<WalletEntity> _walletViews = const [];
  final HomeCubit _homeCubit = getIt<HomeCubit>();
  List<_Summary> _summaries = const [
    _Summary(0, 0, 0),
    _Summary(0, 0, 0),
    _Summary(0, 0, 0),
  ];
  List<BudgetEntity> _budgets = const [];
  final BudgetsCubit _budgetsCubit = getIt<BudgetsCubit>();
  final JarsCubit _jarsCubit = getIt<JarsCubit>();
  List<CategoryEntity> _expenseCats = const [];
  List<_Goal> _goals = const [];
  final List<StreamSubscription<dynamic>> _subs = [];
  final List<StreamSubscription<dynamic>> _summarySubs = [];
  bool _checkingDueSchedules = false;

  WalletEntity? get _selectedWallet {
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
      final executed = (await getIt<ProcessDueSchedulesUseCase>()(
        const NoParams(),
      ))
          .getOrElse(() => const []);
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

  void _bindSummaries() => _homeCubit.watchSummaries(walletId: _selectedWalletId);

  void _bind() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    final now = DateTime.now();
    _subs.add(
      _homeCubit.stream.listen((st) {
        if (!mounted) return;
        setState(() {
          _walletViews = st.wallets;
          _wallets = [
            for (final w in st.wallets)
              _DummyWallet(w.name, w.balance, switch (w.type) {
                'bank' => Icons.account_balance_outlined,
                'e_wallet' => Icons.account_balance_wallet_outlined,
                _ => Icons.payments_outlined,
              }),
          ];
          _expenseCats = st.expenseCategories;
          _summaries = [
            for (final x in st.summaries) _Summary(x.income, x.expense, x.count),
          ];
        });
      }),
    );
    _homeCubit.start();
    _subs.add(
      _budgetsCubit.stream.listen((st) {
        if (mounted) setState(() => _budgets = st.budgets);
      }),
    );
    _subs.add(
      _jarsCubit.stream.listen((st) {
        if (!mounted) return;
        setState(
          () => _goals = [
            for (final j in st.jars) _Goal(j.id, j.title, j.target, j.saved),
          ],
        );
      }),
    );
    _budgetsCubit.watch(month: now.month, year: now.year);
    _jarsCubit.watch();
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
    _homeCubit.close();
    _budgetsCubit.close();
    _jarsCubit.close();
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

  Future<void> _confirmDeleteBudget(
    BudgetEntity budget, {
    BuildContext? sheetContext,
  }) async {
    final ok = await AppGlassDialog.show(
      context: context,
      icon: Icons.delete_outline_rounded,
      title: 'Hapus Rencana Anggaran?',
      message:
          'Yakin ingin menghapus anggaran kategori "${budget.categoryName}" (${fmtRp(budget.limit)})?',
      confirmLabel: 'Ya, Hapus',
      cancelLabel: 'Batal',
      isDestructive: true,
    );
    if (ok != true || !mounted) return;
    final res = await _budgetsCubit.delete(budget.id);
    if (!mounted) return;
    if (res.isLeft()) {
      res.fold((f) => AppToast.showError(context, f.message), (_) {});
      return;
    }
    if (sheetContext != null && sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
    if (!mounted) return;
    AppToast.showSuccess(
      context,
      'Anggaran "${budget.categoryName}" berhasil dihapus',
    );
  }

  Future<void> _confirmDeleteGoal(
    _Goal goal, {
    BuildContext? sheetContext,
  }) async {
    final ok = await AppGlassDialog.show(
      context: context,
      icon: Icons.delete_outline_rounded,
      title: 'Hapus Celengan Digital?',
      message:
          'Yakin ingin menghapus celengan "${goal.name}"? Data tabungan ini akan dihapus.',
      confirmLabel: 'Ya, Hapus',
      cancelLabel: 'Batal',
      isDestructive: true,
    );
    if (ok != true || !mounted) return;
    final res = await _jarsCubit.delete(goal.id);
    if (!mounted) return;
    if (res.isLeft()) {
      res.fold((f) => AppToast.showError(context, f.message), (_) {});
      return;
    }
    if (sheetContext != null && sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
    if (!mounted) return;
    AppToast.showSuccess(
      context,
      'Celengan "${goal.name}" berhasil dihapus',
    );
  }

  void _showGoalSheet({_Goal? deposit}) {
    final nameC = TextEditingController();
    final amountC = TextEditingController();
    String? walletId = _walletViews.isNotEmpty ? _walletViews.first.id : null;
    AppGlassSheet.show(
      context: context,
      builder: (ctx) => AppGlassSheet(
        title: deposit == null
            ? 'Buat Celengan Digital'
            : 'Setor ke ${deposit.name}',
        subtitle: deposit == null
            ? 'Target celengan impianmu'
            : 'Alokasikan dana ke celengan digital',
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (deposit == null) ...[
                const FunLabel('Nama celengan'),
                const SizedBox(height: 6),
                _SheetField(controller: nameC, hint: 'Contoh: Beli Laptop'),
                const SizedBox(height: 12),
              ],
              FunLabel(
                deposit == null ? 'Target (Rp)' : 'Nominal setoran (Rp)',
              ),
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
                  builder: (c, setSheet) => Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xD9FFFFFF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          value: _walletViews.any((w) => w.id == walletId)
                              ? walletId!
                              : '__none__',
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.accentBlue,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        dropdownColor: Colors.white,
                        menuMaxHeight: 280,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkPrimary,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: '__none__',
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const ChickenBankIcon(
                                    size: 17,
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Tanpa dompet (catat di celengan saja)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (final w in _walletViews)
                            DropdownMenuItem<String>(
                              value: w.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      w.type == 'cash'
                                          ? Icons.payments_rounded
                                          : w.type == 'ewallet'
                                          ? Icons.phone_android_rounded
                                          : Icons.account_balance_rounded,
                                      size: 16,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${w.name} (${fmtRp(w.balance)})',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (val) {
                          setSheet(() {
                            walletId = val == '__none__' ? null : val;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              ],
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final v = parseMoney(amountC.text);
                  if (v <= 0) {
                    AppToast.showWarning(
                      context,
                      'Masukkan nominal terlebih dahulu',
                    );
                    return;
                  }
                  if (deposit != null && walletId != null) {
                    final fromWallet = _walletViews
                        .where((w) => w.id == walletId)
                        .firstOrNull;
                    if (fromWallet != null && fromWallet.balance < v) {
                      AppToast.showWarning(
                        context,
                        'Saldo ${fromWallet.name} (${fmtRp(fromWallet.balance)}) tidak mencukupi untuk setoran ${fmtRp(v)}',
                      );
                      return;
                    }
                  }
                  try {
                    if (deposit == null) {
                      final n = nameC.text.trim();
                      final res = await _jarsCubit.add(AddJarParams(
                        title: n.isEmpty ? 'Celengan Baru' : n,
                        target: v,
                      ));
                      if (res.isLeft()) {
                        if (mounted) {
                          res.fold(
                            (f) => AppToast.showError(context, f.message),
                            (_) {},
                          );
                        }
                        return;
                      }
                    } else {
                      final res = await _jarsCubit.deposit(DepositJarParams(
                        jarId: deposit.id,
                        amount: v,
                        walletId: walletId,
                      ));
                      if (res.isLeft()) {
                        if (mounted) {
                          res.fold(
                            (f) => AppToast.showError(context, f.message),
                            (_) {},
                          );
                        }
                        return;
                      }
                    }
                  } catch (e) {
                    if (mounted) AppToast.showError(context, e);
                    return;
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
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
                    deposit == null ? 'Buat Celengan' : 'Setor Sekarang',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (deposit != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        _confirmDeleteGoal(deposit, sheetContext: ctx),
                    child: const Text(
                      'Hapus celengan digital',
                      style: TextStyle(color: AppColors.expense),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetSheet({BudgetEntity? editing}) {
    final amountC = TextEditingController(
      text: editing == null ? '' : fmtThousands(editing.limit),
    );
    String? categoryId = editing?.categoryId;

    AppGlassSheet.show(
      context: context,
      builder: (ctx) => AppGlassSheet(
        title: editing == null ? 'Rencana Anggaran' : 'Ubah Anggaran',
        subtitle: 'Atur batas pengeluaran bulanan per kategori',
        child: StatefulBuilder(
          builder: (c, setSheet) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunLabel('Kategori'),
                  const SizedBox(height: 6),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xD9FFFFFF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          value: _expenseCats.any((c) => c.id == categoryId)
                              ? categoryId!
                              : '__all__',
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.accentBlue,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          dropdownColor: Colors.white,
                          menuMaxHeight: 280,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkPrimary,
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: '__all__',
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.grid_view_rounded,
                                      size: 16,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Semua Kategori',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            for (final cat in _expenseCats)
                              DropdownMenuItem<String>(
                                value: cat.id,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        categoryIcon(cat.icon),
                                        size: 16,
                                        color: AppColors.accentBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        cat.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                          onChanged: editing != null
                              ? null
                              : (val) {
                                  setSheet(() {
                                    categoryId = val == '__all__' ? null : val;
                                  });
                                },
                        ),
                      ),
                    ),
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
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      final v = parseMoney(amountC.text);
                      if (v <= 0) {
                        AppToast.showWarning(
                          context,
                          'Masukkan batas anggaran terlebih dahulu',
                        );
                        return;
                      }
                      final now = DateTime.now();
                      final nav = Navigator.of(ctx);

                      final res = await _budgetsCubit.save(SaveBudgetParams(
                        id: editing?.id,
                        categoryId: categoryId,
                        limit: v,
                        month: now.month,
                        year: now.year,
                      ));
                      if (!mounted) return;
                      if (res.isLeft()) {
                        res.fold(
                          (f) => AppToast.showError(context, f.message),
                          (_) {},
                        );
                        return;
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
                        onPressed: () =>
                            _confirmDeleteBudget(editing, sheetContext: ctx),
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

  List<Widget> _budgetTab() {
    final items = _budgets;
    final limit = items.fold<double>(0, (a, e) => a + e.limit);
    final spent = items.fold<double>(0, (a, e) => a + e.spent);
    double ratio(double a, double b) => b <= 0 ? 0 : (a / b);

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
                InkWell(
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(24) : Radius.zero,
                    bottom: i == items.length - 1
                        ? const Radius.circular(24)
                        : Radius.zero,
                  ),
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
                                            (c) => c.id == items[i].categoryId,
                                          )
                                          .firstOrNull
                                          ?.icon,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    items[i].categoryName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkPrimary,
                                    ),
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
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _confirmDeleteBudget(items[i]),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.expenseLight.withValues(
                                    alpha: 0.75,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 17,
                                  color: AppColors.expense,
                                ),
                              ),
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

  List<Widget> _celenganTab() {
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
              child: const ChickenBankIcon(
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunLabel('Total Celengan Digital'),
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
          const Expanded(child: FunLabel('Celengan Digital saya')),
          FunPill(
            label: 'Buat Celengan',
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
                IconBox.chicken(
                  size: 48,
                  radius: 16,
                  iconSize: 24,
                ),
                SizedBox(height: 12),
                Text(
                  'Belum ada celengan digital',
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
                    const IconBox.chicken(),
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
                      onTap: () => _confirmDeleteGoal(g),
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
          ),
        ),
    ];
  }

  List<String> _budgetBadges() {
    if (_budgets.isEmpty) {
      return const ['Belum ada anggaran'];
    }
    final limit = _budgets.fold<double>(0, (a, b) => a + b.limit);
    final spent = _budgets.fold<double>(0, (a, b) => a + b.spent);
    final now = DateTime.now();
    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day;
    return [
      'Sisa ${fmtRp(limit - spent)}',
      '$daysLeft hari lagi',
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
        final msg =
            'Sinkron selesai • ${r.pushed} terkirim, ${r.pulled} diterima';
        if (r.failed > 0) {
          AppToast.showWarning(
            context,
            '$msg • ${r.failed} data dilewati & akan dicoba lagi',
          );
        } else {
          AppToast.showSuccess(context, msg);
        }
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
              ? 'Tabungan & target impian'
              : null,
          headline: _tab == 1
              ? 'Budgeting Plan'
              : _tab == 2
              ? 'Celengan Digital'
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
                              ..._celenganTab()
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

  static const _tabs = <(IconData?, String, double)>[
    (Icons.home_outlined, 'Beranda', 44.0),
    (Icons.pie_chart_outline_rounded, 'Anggaran', 44.0),
    (null, 'Celengan Digital', 44.0),
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
                              if (_tabs[i].$1 != null)
                                Icon(
                                  _tabs[i].$1,
                                  size: 18,
                                  color: Color.lerp(
                                    AppColors.inkPrimary,
                                    AppColors.accentBlue,
                                    ts[i],
                                  ),
                                )
                              else
                                ChickenBankIcon(
                                  size: 19,
                                  color: Color.lerp(
                                    AppColors.inkPrimary,
                                    AppColors.accentBlue,
                                    ts[i],
                                  )!,
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
        color: glassFill(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        inputFormatters: number ? const [RupiahInputFormatter()] : null,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.inkPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: number ? 'Rp ' : null,
          prefixStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.inkSecondary,
          ),
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

