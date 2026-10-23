import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/categories/categories_manage_page.dart';
import '../database/finance_exception.dart';
import '../database/finance_repository.dart';
import '../database/wallet_repository.dart';
import '../di/injection.dart';
import '../theme/app_colors.dart';
import 'app_toast.dart';
import 'category_icons.dart';
import 'fun_widgets.dart';
import 'app_glass_sheet.dart';

/// Add-transaction bottom sheet — menyimpan ke database lokal (Drift).
/// Matches React: amount focus, type, wallet, category, note, date, save.
class TransactionSheet extends StatefulWidget {
  final String initialType; // 'expense' or 'income'

  const TransactionSheet({super.key, this.initialType = 'expense'});

  static Future<void> show(
    BuildContext context, {
    String initialType = 'expense',
  }) {
    return AppGlassSheet.show(
      context: context,
      builder: (_) => TransactionSheet(initialType: initialType),
    );
  }

  @override
  State<TransactionSheet> createState() => _TransactionSheetState();
}

class _TransactionSheetState extends State<TransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late int _type = widget.initialType == 'income' ? 1 : 0;
  int _wallet = 0;
  int _category = 0;
  DateTime _date = DateTime.now();

  List<WalletView> _wallets = const [];
  List<CategoryView> _allCats = const [];
  StreamSubscription<List<CategoryView>>? _catSub;
  StreamSubscription<List<WalletView>>? _walletSub;

  List<CategoryView> get _cats =>
      _allCats.where((c) => c.type == (_type == 1 ? 'income' : 'expense')).toList();

  @override
  void initState() {
    super.initState();
    _walletSub = getIt<WalletRepository>().watchWallets().listen((w) {
      if (mounted) setState(() => _wallets = w);
    });
    _catSub = getIt<FinanceRepository>().watchCategories().listen((c) {
      if (mounted) setState(() => _allCats = c);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _walletSub?.cancel();
    _catSub?.cancel();
    super.dispose();
  }

  Future<void> _openManageCategories() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoriesManagePage(initialTab: _type),
      ),
    );
  }

  void _onAmountChanged(String val) {
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      barrierColor: AppColors.glassScrim,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentBlue,
              onPrimary: Colors.white,
              surface: Color(0xF2FFFFFF),
              onSurface: AppColors.inkPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white.withValues(alpha: 0.92),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: const BorderSide(color: Colors.white, width: 1.5),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _toast(String msg, {bool isError = false}) {
    if (isError) {
      AppToast.showError(context, msg);
    } else {
      AppToast.showWarning(context, msg);
    }
  }

  Future<void> _save() async {
    final amount = parseMoney(_amountController.text);
    if (amount <= 0) {
      _toast('Isi nominal dulu');
      return;
    }
    if (_wallets.isEmpty) {
      _toast('Buat dompet dulu di Profil \u2192 Kelola Dompet');
      return;
    }
    final selectedWallet = _wallets[_wallet.clamp(0, _wallets.length - 1)];
    if (_type == 0 && selectedWallet.balance < amount) {
      _toast(
        'Saldo ${selectedWallet.name} (${fmtRp(selectedWallet.balance)}) tidak mencukupi untuk pengeluaran ${fmtRp(amount)}',
      );
      return;
    }
    final cats = _cats;
    final nav = Navigator.of(context);
    try {
      await getIt<FinanceRepository>().addTransaction(
        walletId: selectedWallet.id,
        categoryId: cats.isEmpty ? null : cats[_category.clamp(0, cats.length - 1)].id,
        type: _type == 1 ? 'income' : 'expense',
        amount: amount,
        note: _noteController.text,
        date: _date,
      );
      nav.pop();
      if (mounted) {
        AppToast.showSuccess(context, 'Transaksi disimpan');
      }
    } catch (e) {
      if (mounted) {
        _toast(
          e is FinanceException ? e.message : 'Gagal menyimpan transaksi',
          isError: true,
        );
      }
    }
  }

  IconData _walletTypeIcon(String type) => switch (type) {
    'bank' => Icons.account_balance_outlined,
    'e_wallet' => Icons.account_balance_wallet_outlined,
    _ => Icons.payments_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final cats = _cats;
    if (_wallet >= _wallets.length) _wallet = 0;
    if (_category >= cats.length) _category = 0;

    return AppGlassSheet(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: FunTabs(
                labels: const ['Pengeluaran', 'Pemasukan'],
                selected: _type,
                onChanged: (i) => setState(() {
                  _type = i;
                  _category = 0;
                }),
              ),
            ),
            const SizedBox(height: 20),

            // ── Amount ──
            Center(
              child: Column(
                children: [
                  const FunLabel('Nominal'),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'Rp ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      IntrinsicWidth(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              minWidth: 60, maxWidth: 240),
                          child: TextField(
                            controller: _amountController,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: const [RupiahInputFormatter()],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: AppColors.inkPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFCBD5E1),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: _onAmountChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const FunLabel('Dompet'),
            const SizedBox(height: 8),
            if (_wallets.isEmpty)
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: glassFill(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.2,
                  ),
                ),
                child: const Text(
                  'Belum ada dompet — buat di Profil → Kelola Dompet',
                  style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                ),
              )
            else
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
                    child: DropdownButton<int>(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      value: _wallet.clamp(0, _wallets.length - 1),
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: Colors.white.withValues(alpha: 0.96),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.inkSecondary,
                      ),
                      items: [
                        for (int i = 0; i < _wallets.length; i++)
                          DropdownMenuItem<int>(
                            value: i,
                            child: Row(
                              children: [
                                Icon(
                                  _walletTypeIcon(_wallets[i].type),
                                  size: 18,
                                  color: AppColors.accentBlue,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${_wallets[i].name} (${fmtRp(_wallets[i].balance)})',
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
                          setState(() => _wallet = val);
                        }
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            const FunLabel('Kategori'),
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
                  child: DropdownButton<int>(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    value:
                        cats.isEmpty ? null : _category.clamp(0, cats.length - 1),
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(16),
                  dropdownColor: Colors.white.withValues(alpha: 0.96),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.inkSecondary,
                  ),
                  hint: const Text(
                    'Pilih kategori...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  items: [
                    for (int i = 0; i < cats.length; i++)
                      DropdownMenuItem<int>(
                        value: i,
                        child: Row(
                          children: [
                            Icon(
                              categoryIcon(cats[i].icon),
                              size: 18,
                              color: AppColors.accentBlue,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cats[i].name,
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
                    const DropdownMenuItem<int>(
                      value: -1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 18,
                            color: AppColors.accentBlue,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '+ Tambah / Kelola Kategori',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val == -1) {
                      _openManageCategories();
                    } else if (val != null) {
                      setState(() => _category = val);
                    }
                  },
                ),
              ),
            ),
          ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
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
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 16, color: AppColors.accentBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat('d MMM yyyy').format(_date),
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
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
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
                      controller: _noteController,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Catatan',
                        hintStyle:
                            TextStyle(color: AppColors.inkMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: _save,
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
                  'Simpan Transaksi',
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
    );
  }
}
