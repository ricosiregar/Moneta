import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/app_glass_dialog.dart';
import '../../../../core/components/app_toast.dart';
import '../../../../core/components/category_icons.dart';
import '../../../../core/components/fun_widgets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/pages/categories_manage_page.dart';
import '../../../wallets/domain/entities/wallet_entity.dart';
import '../../domain/entities/feed_item_entity.dart';
import '../cubit/transactions_cubit.dart';

// Daftar aktivitas dari database lokal (Drift).

class _Tx {
  final String group;
  final String title;
  final String category;
  final String wallet;
  final double amount; // negative = expense
  final IconData icon;
  final bool transfer;
  final String id;
  final DateTime date;
  final String? walletId;
  final String? toWalletId;
  final String? categoryId;
  const _Tx(
    this.group,
    this.title,
    this.category,
    this.wallet,
    this.amount,
    this.icon, {
    this.transfer = false,
    this.id = '',
    required this.date,
    this.walletId,
    this.toWalletId,
    this.categoryId,
  });
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _type = 0; // 0 semua, 1 pengeluaran, 2 pemasukan, 3 pindah
  bool _filterOpen = false;
  String _query = '';
  String? _selectedWalletId;
  String? _selectedCategory;
  String? _selectedCategoryId;

  static const int _pageSize = 15;
  int _visibleCount = _pageSize;
  bool _isLoadingMore = false;
  late final ScrollController _scrollController;

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  late DateTime _startDate;
  late DateTime _endDate;

  Timer? _debounceTimer;
  late final TextEditingController _searchCtrl;

  static const _tabs = ['Semua', 'Pengeluaran', 'Pemasukan', 'Pindah Uang'];

  late final TransactionsCubit _cubit = getIt<TransactionsCubit>()..watch();
  StreamSubscription<dynamic>? _sub;

  // Pemetaan feed -> _Tx di-cache selama daftar sumbernya tidak berubah.
  List<FeedItemEntity>? _feedSource;
  List<_Tx> _txsCache = const [];

  List<_Tx> get _txs {
    final items = _cubit.state.items;
    if (!identical(items, _feedSource)) {
      _feedSource = items;
      _txsCache = [for (final i in items) _fromFeed(i)];
    }
    return _txsCache;
  }

  List<WalletEntity> get _wallets => _cubit.state.wallets;
  List<CategoryEntity> get _categories => _cubit.state.categories;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    _endDate = _today;
    _startDate = _today;

    _sub = _cubit.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    _scrollController.dispose();
    _sub?.cancel();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _visibleCount < _filtered.length) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _visibleCount >= _filtered.length) return;
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, _filtered.length);
      _isLoadingMore = false;
    });
  }

  void _onSearchChanged(String v) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _query = v.trim();
          _visibleCount = _pageSize;
        });
      }
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchCtrl.clear();
    setState(() {
      _query = '';
      _visibleCount = _pageSize;
    });
  }

  void _clearAllFilters() {
    _debounceTimer?.cancel();
    _searchCtrl.clear();
    setState(() {
      _type = 0;
      _query = '';
      _selectedWalletId = null;
      _selectedCategory = null;
      _selectedCategoryId = null;
      _applyToday();
      _visibleCount = _pageSize;
    });
  }

  Future<void> _openManageCategories() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoriesManagePage(
          initialTab: _type == 2 ? 1 : 0,
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final today = _today;
    final firstAllowed = DateTime(2020);
    final lastAllowed = today;

    final initial = DateTimeRange(
      start: _startDate.isAfter(today) ? today : _startDate,
      end: _endDate.isAfter(today) ? today : _endDate,
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
      initialDateRange: initial,
      barrierColor: AppColors.glassScrim,
      helpText: 'Pilih Rentang Tanggal (Maks 1 Bulan & s/d Hari ini)',
      confirmText: 'Terapkan',
      cancelText: 'Batal',
      fieldStartHintText: 'dd/mm/yyyy',
      fieldEndHintText: 'dd/mm/yyyy',
      fieldStartLabelText: 'Tanggal mulai',
      fieldEndLabelText: 'Tanggal akhir',
      errorFormatText: 'Format tidak valid (dd/mm/yyyy)',
      errorInvalidText: 'Tanggal di luar rentang',
      errorInvalidRangeText: 'Rentang tanggal tidak valid',
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
          child: AppDatePickerWrapper(child: child!),
        );
      },
    );

    if (picked != null) {
      final diff = picked.end.difference(picked.start).inDays;
      if (diff > 31) {
        if (mounted) {
          AppToast.showWarning(
            context,
            'Rentang tanggal maksimal 1 bulan (31 hari)',
          );
        }
        return;
      }
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end.isAfter(today) ? today : picked.end;
        _visibleCount = _pageSize;
      });
    }
  }

  void _applyToday() {
    final today = _today;
    setState(() {
      _startDate = today;
      _endDate = today;
      _visibleCount = _pageSize;
    });
  }

  void _applyPresetDays(int days) {
    final today = _today;
    setState(() {
      _startDate = today.subtract(Duration(days: days - 1));
      _endDate = today;
      _visibleCount = _pageSize;
    });
  }

  bool get _isToday {
    final today = _today;
    return _startDate.year == today.year &&
        _startDate.month == today.month &&
        _startDate.day == today.day &&
        _endDate.year == today.year &&
        _endDate.month == today.month &&
        _endDate.day == today.day;
  }

  bool _isPresetDays(int days) {
    final today = _today;
    final expectedStart = today.subtract(Duration(days: days - 1));
    return _startDate.year == expectedStart.year &&
        _startDate.month == expectedStart.month &&
        _startDate.day == expectedStart.day &&
        _endDate.year == today.year &&
        _endDate.month == today.month &&
        _endDate.day == today.day;
  }

  bool get _isCustomDateRange => !_isToday;

  void _resetDateRange() {
    _applyToday();
  }

  String get _dateRangeString {
    final f = DateFormat('d MMM yyyy', 'id_ID');
    if (_isToday) {
      return 'Hari Ini (${f.format(_today)})';
    }
    if (_startDate.year == _endDate.year &&
        _startDate.month == _endDate.month &&
        _startDate.day == _endDate.day) {
      return f.format(_startDate);
    }
    return '${f.format(_startDate)} - ${f.format(_endDate)}';
  }

  bool get _hasFilterPills =>
      _selectedWalletId != null ||
      _selectedCategory != null ||
      _isCustomDateRange;

  bool get _hasAnyFilter => _hasFilterPills || _query.isNotEmpty || _type != 0;

  static String _groupLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    return DateFormat('EEEE, d MMM', 'id_ID').format(d);
  }

  static _Tx _fromFeed(FeedItemEntity i) {
    final transfer = i.isTransfer;
    return _Tx(
      _groupLabel(i.date),
      i.title,
      i.category,
      i.wallet,
      i.kind == FeedKind.expense ? -i.amount : i.amount,
      categoryIcon(i.iconKey),
      transfer: transfer,
      id: i.id,
      date: i.date,
      walletId: i.walletId,
      toWalletId: i.toWalletId,
      categoryId: i.categoryId,
    );
  }

  List<_Tx> get _filtered => _txs.where((t) {
    final okType = switch (_type) {
      1 => !t.transfer && t.amount < 0,
      2 => !t.transfer && t.amount > 0,
      3 => t.transfer,
      _ => true,
    };
    final okWallet =
        _selectedWalletId == null ||
        t.walletId == _selectedWalletId ||
        t.toWalletId == _selectedWalletId;
    final okCategory =
        _selectedCategory == null ||
        t.category.toLowerCase() == _selectedCategory!.toLowerCase() ||
        (t.categoryId != null && t.categoryId == _selectedCategoryId);

    final startDay = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
    );
    final endDay = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
    );
    final okDate = !t.date.isBefore(startDay) && !t.date.isAfter(endDay);

    final q = _query.toLowerCase();
    final okQ =
        q.isEmpty ||
        t.title.toLowerCase().contains(q) ||
        t.category.toLowerCase().contains(q) ||
        t.wallet.toLowerCase().contains(q);
    return okType && okWallet && okCategory && okDate && okQ;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final allList = _filtered;
    final pagedList = allList.take(_visibleCount).toList();

    final groups = <String, List<_Tx>>{};
    for (final t in pagedList) {
      groups.putIfAbsent(t.group, () => []).add(t);
    }

    final rawCats = _type == 1
        ? _categories.where((c) => c.type == CategoryType.expense).toList()
        : _type == 2
        ? _categories.where((c) => c.type == CategoryType.income).toList()
        : _categories;

    final seenCats = <String>{};
    final displayCats = <CategoryEntity>[];
    for (final c in rawCats) {
      if (seenCats.add(c.name.toLowerCase())) {
        displayCats.add(c);
      }
    }

    return GlassPage(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _visibleCount = _pageSize;
          });
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FunPageHeader(
              title: 'Aktivitas',
              subtitle: allList.isEmpty
                  ? '0 transaksi tercatat'
                  : 'Menampilkan ${pagedList.length} dari ${allList.length} transaksi',
              trailing: FunPill(
                label: _hasFilterPills
                    ? 'Filter Aktif'
                    : (_filterOpen ? 'Tutup Filter' : 'Filter'),
                icon: Icons.tune_rounded,
                selected: _filterOpen || _hasFilterPills,
                onTap: () => setState(() => _filterOpen = !_filterOpen),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: AppColors.glassCardGradient,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1.2,
                ),
                boxShadow: AppColors.glassShadowSoft,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.inkMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      onSubmitted: (v) {
                        _debounceTimer?.cancel();
                        setState(() {
                          _query = v.trim();
                          _visibleCount = _pageSize;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.inkPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Cari catatan, kategori, atau dompet...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.inkMuted,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (int i = 0; i < _tabs.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    FunPill(
                      label: _tabs[i],
                      selected: _type == i,
                      onTap: () => setState(() {
                        _type = i;
                        _visibleCount = _pageSize;
                        if (_selectedCategory != null) {
                          final valid =
                              i == 0 ||
                              (i == 1 &&
                                  _categories.any(
                                    (c) =>
                                        c.name == _selectedCategory &&
                                        c.type == CategoryType.expense,
                                  )) ||
                              (i == 2 &&
                                  _categories.any(
                                    (c) =>
                                        c.name == _selectedCategory &&
                                        c.type == CategoryType.income,
                                  ));
                          if (!valid) {
                            _selectedCategory = null;
                            _selectedCategoryId = null;
                          }
                        }
                      }),
                    ),
                  ],
                ],
              ),
            ),
            if (_filterOpen) ...[
              const SizedBox(height: 12),
              FunCard(
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Filter Dompet (Pertama) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const FunLabel('Dompet / Rekening'),
                        if (_selectedWalletId != null)
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedWalletId = null;
                              _visibleCount = _pageSize;
                            }),
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 46,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: glassFill(context, normal: Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedWalletId != null
                              ? AppColors.accentBlue.withValues(alpha: 0.5)
                              : const Color(0xFFE2E8F0),
                          width: _selectedWalletId != null ? 1.5 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: DropdownButtonHideUnderline(
                          child: AppDropdownButton<String>(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            value: _selectedWalletId != null &&
                                    _wallets
                                        .any((w) => w.id == _selectedWalletId)
                                ? _selectedWalletId!
                                : '__all__',
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(16),
                            dropdownColor: Colors.white.withValues(alpha: 0.96),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.inkSecondary,
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: '__all__',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.all_inclusive_rounded,
                                      size: 18,
                                      color: AppColors.accentBlue,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Semua Dompet',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.inkPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              for (final w in _wallets)
                                DropdownMenuItem<String>(
                                  value: w.id,
                                  child: Row(
                                    children: [
                                      Icon(
                                        switch (w.type) {
                                          'bank' =>
                                            Icons.account_balance_outlined,
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
                              setState(() {
                                _selectedWalletId =
                                    (val == null || val == '__all__')
                                        ? null
                                        : val;
                                _visibleCount = _pageSize;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    // ── 2. Filter Kategori (Kedua) ──
                    if (_type != 3) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const FunLabel('Kategori'),
                          if (_selectedCategory != null)
                            GestureDetector(
                              onTap: () => setState(() {
                                _selectedCategory = null;
                                _selectedCategoryId = null;
                                _visibleCount = _pageSize;
                              }),
                              child: const Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 46,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: glassFill(context, normal: Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedCategory != null
                                ? AppColors.accentBlue.withValues(alpha: 0.5)
                                : const Color(0xFFE2E8F0),
                            width: _selectedCategory != null ? 1.5 : 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: DropdownButtonHideUnderline(
                            child: AppDropdownButton<String>(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              value: _selectedCategory != null &&
                                      displayCats.any(
                                        (c) => c.name == _selectedCategory,
                                      )
                                  ? _selectedCategory!
                                  : '__all__',
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(16),
                              dropdownColor:
                                  Colors.white.withValues(alpha: 0.96),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.inkSecondary,
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: '__all__',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        size: 18,
                                        color: AppColors.accentBlue,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Semua Kategori',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.inkPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                for (final c in displayCats)
                                  DropdownMenuItem<String>(
                                    value: c.name,
                                    child: Row(
                                      children: [
                                        Icon(
                                          categoryIcon(c.icon),
                                          size: 18,
                                          color: AppColors.accentBlue,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            c.name,
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
                                const DropdownMenuItem<String>(
                                  value: '__manage__',
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
                                if (val == '__manage__') {
                                  _openManageCategories();
                                } else if (val == null || val == '__all__') {
                                  setState(() {
                                    _selectedCategory = null;
                                    _selectedCategoryId = null;
                                    _visibleCount = _pageSize;
                                  });
                                } else {
                                  final matched = displayCats
                                      .where((c) => c.name == val)
                                      .firstOrNull;
                                  setState(() {
                                    _selectedCategory = val;
                                    _selectedCategoryId = matched?.id;
                                    _visibleCount = _pageSize;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],

                    // ── 3. Filter Rentang Tanggal (Ketiga) ──
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const FunLabel('Rentang Tanggal'),
                        if (_isCustomDateRange)
                          GestureDetector(
                            onTap: _resetDateRange,
                            child: const Text(
                              'Reset (Hari Ini)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: glassFill(context, normal: Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isCustomDateRange
                                ? AppColors.accentBlue.withValues(alpha: 0.5)
                                : const Color(0xFFE2E8F0),
                            width: _isCustomDateRange ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.date_range_rounded,
                              size: 18,
                              color: AppColors.accentBlue,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dateRangeString,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_endDate.difference(_startDate).inDays + 1} hari dipilih (maksimal 31 hari)',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.edit_calendar_outlined,
                              size: 16,
                              color: AppColors.inkSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          FunPill(
                            label: 'Hari Ini',
                            selected: _isToday,
                            onTap: _applyToday,
                          ),
                          const SizedBox(width: 8),
                          FunPill(
                            label: '7 Hari',
                            selected: _isPresetDays(7),
                            onTap: () => _applyPresetDays(7),
                          ),
                          const SizedBox(width: 8),
                          FunPill(
                            label: '14 Hari',
                            selected: _isPresetDays(14),
                            onTap: () => _applyPresetDays(14),
                          ),
                          const SizedBox(width: 8),
                          FunPill(
                            label: '30 Hari Terakhir',
                            selected: _isPresetDays(30),
                            onTap: () => _applyPresetDays(30),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_hasAnyFilter)
                          GestureDetector(
                            onTap: _clearAllFilters,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Hapus semua filter',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.expense,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (allList.isEmpty)
              FunCard(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: const SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      IconBox(
                        Icons.receipt_long_outlined,
                        size: 48,
                        radius: 16,
                        iconSize: 22,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              for (final e in groups.entries) _Group(e.key, e.value),
              if (_isLoadingMore) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentBlue,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Memuat transaksi...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (_visibleCount < allList.length) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: GestureDetector(
                      onTap: _loadMore,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: glassFill(context, normal: Colors.white),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: AppColors.accentBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Muat 15 lagi (${allList.length - _visibleCount} tersisa)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    ),
  );
  }
}

class _Group extends StatelessWidget {
  final String label;
  final List<_Tx> items;
  const _Group(this.label, this.items);

  @override
  Widget build(BuildContext context) {
    final inc = items
        .where((t) => !t.transfer && t.amount > 0)
        .fold<double>(0, (a, t) => a + t.amount);
    final exp = items
        .where((t) => !t.transfer && t.amount < 0)
        .fold<double>(0, (a, t) => a + t.amount.abs());
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                if (inc > 0)
                  FunBadge('+${fmtRp(inc)}', color: AppColors.inkPrimary),
                if (inc > 0 && exp > 0) const SizedBox(width: 6),
                if (exp > 0)
                  FunBadge('-${fmtRp(exp)}', color: AppColors.expense),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FunCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _TxRow(
                    items[i],
                    isFirst: i == 0,
                    isLast: i == items.length - 1,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final _Tx tx;
  final bool isFirst;
  final bool isLast;
  const _TxRow(this.tx, {this.isFirst = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final sub = tx.transfer ? tx.wallet : '${tx.category} · ${tx.wallet}';
    final isExpense = !tx.transfer && tx.amount < 0;
    final rowRadius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(24) : Radius.zero,
      bottom: isLast ? const Radius.circular(24) : Radius.zero,
    );
    return InkWell(
      borderRadius: rowRadius,
      customBorder: RoundedRectangleBorder(borderRadius: rowRadius),
      onLongPress: tx.id.isEmpty ? null : () => _confirmDelete(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconBox(tx.icon, size: 44, radius: 14, iconSize: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              tx.transfer
                  ? fmtRp(tx.amount.abs())
                  : fmtRp(tx.amount, sign: true),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isExpense ? AppColors.expense : AppColors.inkPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await AppGlassDialog.show(
      context: context,
      title: 'Hapus Catatan?',
      message: 'Transaksi "${tx.title}" akan dihapus permanen.',
      icon: Icons.delete_outline_rounded,
      isDestructive: true,
      confirmLabel: 'Hapus',
    );
    if (ok != true) return;
    final result =
        await getIt<TransactionsCubit>().delete(tx.id, isTransfer: tx.transfer);
    if (!context.mounted) return;
    result.fold(
      (failure) => AppToast.showError(context, failure.message),
      (_) {},
    );
  }
}
