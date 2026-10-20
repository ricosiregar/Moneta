import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/categories/categories_manage_page.dart';
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
    final cleaned = val.replaceAll(RegExp(r'[^\d]'), '');
    final formatted = cleaned.isEmpty
        ? ''
        : NumberFormat('#,###', 'id_ID').format(int.parse(cleaned));
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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
    final amount = double.tryParse(
            _amountController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
        0;
    if (amount <= 0) {
      _toast('Isi nominal dulu');
      return;
    }
    if (_wallets.isEmpty) {
      _toast('Buat dompet dulu di Profil \u2192 Kelola Dompet');
      return;
    }
    final cats = _cats;
    final nav = Navigator.of(context);
    try {
      await getIt<FinanceRepository>().addTransaction(
        walletId: _wallets[_wallet.clamp(0, _wallets.length - 1)].id,
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
        _toast('Gagal menyimpan transaksi', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = _cats;
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
            SizedBox(
              height: 40,
              child: _wallets.isEmpty
                  ? const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Belum ada dompet \u2014 buat di Profil \u2192 Kelola Dompet',
                        style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _wallets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => FunPill(
                        label: _wallets[i].name,
                        selected: _wallet == i,
                        onTap: () => setState(() => _wallet = i),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            const FunLabel('Kategori'),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cats.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == cats.length) {
                    return FunPill(
                      label: '+ Kategori',
                      icon: Icons.add_rounded,
                      selected: false,
                      onTap: _openManageCategories,
                    );
                  }
                  return FunPill(
                    label: cats[i].name,
                    icon: categoryIcon(cats[i].icon),
                    selected: _category == i,
                    onTap: () => setState(() => _category = i),
                  );
                },
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
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 16, color: AppColors.inkSecondary),
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
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _noteController,
                      style: const TextStyle(fontSize: 13),
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
