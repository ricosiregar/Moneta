import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/components/app_toast.dart';
import '../../core/components/category_icons.dart';
import '../../core/components/fun_widgets.dart';
import '../../core/database/finance_repository.dart';
import '../../core/database/wallet_repository.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';

// Data live dari Drift (FinanceRepository) dengan filter dompet & tanggal dinamis.

class AnalyticsScreen extends StatefulWidget {
  final String? initialWalletId;
  const AnalyticsScreen({super.key, this.initialWalletId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTimeRange? _customRange;
  String? _selectedWalletId;
  int? _selectedCatIndex;

  final _repo = getIt<FinanceRepository>();
  final _walletRepo = getIt<WalletRepository>();
  final List<StreamSubscription> _subs = [];
  List<WalletView> _wallets = const [];
  PeriodSummary _sum = const PeriodSummary(0, 0, 0);
  List<CategoryTotal> _catTotals = const [];
  List<(DateTime, double, double)> _dailyRaw = const [];
  List<(DateTime, double, double)> _trendRaw = const [];

  DateTime get _effectiveFrom => _customRange?.start ?? _month;
  DateTime get _effectiveTo {
    if (_customRange != null) {
      final e = _customRange!.end;
      return DateTime(e.year, e.month, e.day, 23, 59, 59, 999);
    }
    return DateTime(_month.year, _month.month + 1);
  }

  String get _dateRangeLabel {
    if (_customRange != null) {
      final s = _customRange!.start;
      final e = _customRange!.end;
      if (s.year == e.year) {
        return '${s.day} ${_months[s.month - 1].substring(0, 3)} - ${e.day} ${_months[e.month - 1].substring(0, 3)}';
      }
      return '${s.day}/${s.month}/${s.year} - ${e.day}/${e.month}/${e.year}';
    }
    return '${_months[_month.month - 1]} ${_month.year}';
  }

  @override
  void initState() {
    super.initState();
    _selectedWalletId = widget.initialWalletId;
    _bind();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  void _bind() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    final from = _effectiveFrom;
    final to = _effectiveTo;
    final trendFrom = DateTime(_month.year, _month.month - 5);

    _subs.addAll([
      _walletRepo.watchWallets().listen((w) {
        if (mounted) setState(() => _wallets = w);
      }),
      _repo.watchSummary(from, to, walletId: _selectedWalletId).listen((v) {
        if (mounted) setState(() => _sum = v);
      }),
      _repo
          .watchExpenseByCategory(from, to, walletId: _selectedWalletId)
          .listen((v) {
        if (mounted) setState(() => _catTotals = v);
      }),
      _repo.watchDaily(from, to, walletId: _selectedWalletId).listen((v) {
        if (mounted) setState(() => _dailyRaw = v);
      }),
      _repo.watchDaily(trendFrom, to, walletId: _selectedWalletId).listen((v) {
        if (mounted) setState(() => _trendRaw = v);
      }),
    ]);
  }

  void _shift(int d) {
    final nextMonth = DateTime(_month.year, _month.month + d);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    if (d > 0 && nextMonth.isAfter(currentMonth)) {
      return;
    }
    setState(() {
      _customRange = null;
      _month = nextMonth;
      _selectedCatIndex = null;
    });
    _bind();
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstAllowed = DateTime(2020);
    final lastAllowed = today;

    final monthEnd = DateTime(_month.year, _month.month + 1, 0);
    final safeEnd = monthEnd.isAfter(today) ? today : monthEnd;
    final safeStart = _month.isAfter(today) ? today : _month;
    final initial = _customRange ??
        DateTimeRange(
          start: safeStart,
          end: safeEnd,
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
      initialDateRange: initial,
      helpText: 'Pilih Rentang Tanggal (Maksimal 1 Bulan & s/d Hari ini)',
      confirmText: 'Terapkan',
      cancelText: 'Batal',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.inkPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final diff = picked.end.difference(picked.start).inDays;
      if (diff > 31) {
        if (mounted) {
          AppToast.showWarning(
            context,
            'Rentang tanggal maksimal hanya 1 bulan (31 hari)',
          );
        }
        return;
      }
      setState(() {
        _customRange = picked;
        _month = DateTime(picked.start.year, picked.start.month);
        _selectedCatIndex = null;
      });
      _bind();
    }
  }

  @override
  Widget build(BuildContext context) {
    final income = _sum.income;
    final expense = _sum.expense;
    final net = income - expense;

    final int daysCount;
    final List<String> dailyLabels;
    final List<double> daily;

    if (_customRange != null) {
      daysCount = _customRange!.end.difference(_customRange!.start).inDays + 1;
      daily = List<double>.filled(daysCount, 0);
      dailyLabels = [];
      for (int i = 0; i < daysCount; i++) {
        final cur = _customRange!.start.add(Duration(days: i));
        dailyLabels.add('${cur.day}');
        for (final d in _dailyRaw) {
          if (d.$1.year == cur.year &&
              d.$1.month == cur.month &&
              d.$1.day == cur.day) {
            daily[i] += d.$3;
          }
        }
      }
    } else {
      daysCount = DateTime(_month.year, _month.month + 1, 0).day;
      daily = List<double>.filled(daysCount, 0);
      for (final d in _dailyRaw) {
        if (d.$1.year == _month.year && d.$1.month == _month.month) {
          if (d.$1.day - 1 >= 0 && d.$1.day - 1 < daysCount) {
            daily[d.$1.day - 1] += d.$3;
          }
        }
      }
      dailyLabels = [for (int i = 1; i <= daysCount; i++) '$i'];
    }

    final now = DateTime.now();
    final isCurrent = now.year == _month.year && now.month == _month.month;
    final elapsed = _customRange != null
        ? daysCount
        : (isCurrent ? now.day : daysCount);

    final trend = List<double>.filled(6, 0);
    for (final d in _trendRaw) {
      final idx =
          (d.$1.year - _month.year) * 12 + d.$1.month - _month.month + 5;
      if (idx >= 0 && idx < 6) trend[idx] += d.$3;
    }

    final catSum = _catTotals.fold<double>(0, (a, c) => a + c.total);
    final cats = _catTotals;
    final biggestCat = _catTotals.isEmpty ? null : _catTotals.first;

    final selectedCat = (_selectedCatIndex != null &&
            _selectedCatIndex! >= 0 &&
            _selectedCatIndex! < cats.length)
        ? cats[_selectedCatIndex!]
        : null;

    final selectedCatColor = _selectedCatIndex != null
        ? kChartColors[_selectedCatIndex! % kChartColors.length]
        : null;

    final selectedWalletName = _selectedWalletId == null
        ? 'Semua Dompet'
        : (_wallets.where((w) => w.id == _selectedWalletId).firstOrNull?.name ??
            'Dompet');

    return GlassPage(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          _bind();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FunPageHeader(
              title: 'Analitik',
              subtitle: 'Ringkasan & tren • $selectedWalletName',
              trailing: _MonthSelector(
                label: _dateRangeLabel,
                onPrev: () => _shift(-1),
                onNext: () => _shift(1),
                canNext: _month.isBefore(
                    DateTime(DateTime.now().year, DateTime.now().month)),
                onCenterTap: _pickCustomRange,
              ),
            ),
            const SizedBox(height: 16),

            // ── Filter Wallet Selector ──
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _WalletFilterChip(
                    label: 'Semua Dompet',
                    icon: Icons.all_inclusive_rounded,
                    selected: _selectedWalletId == null,
                    onTap: () {
                      if (_selectedWalletId != null) {
                        setState(() {
                          _selectedWalletId = null;
                          _selectedCatIndex = null;
                        });
                        _bind();
                      }
                    },
                  ),
                  for (final w in _wallets) ...[
                    const SizedBox(width: 8),
                    _WalletFilterChip(
                      label: w.name,
                      icon: switch (w.type) {
                        'bank' => Icons.account_balance_outlined,
                        'e_wallet' => Icons.account_balance_wallet_outlined,
                        _ => Icons.payments_outlined,
                      },
                      selected: _selectedWalletId == w.id,
                      onTap: () {
                        setState(() {
                          _selectedWalletId =
                              _selectedWalletId == w.id ? null : w.id;
                          _selectedCatIndex = null;
                        });
                        _bind();
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Arus Kas Bersih ──
            FunCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunLabel('Arus kas bersih'),
                  const SizedBox(height: 6),
                  MoneyText('${net >= 0 ? '+' : '-'}${fmtRp(net.abs())}',
                      size: 30),
                  const SizedBox(height: 8),
                  FunBadge(
                    net >= 0
                        ? (_customRange != null
                            ? 'Surplus periode ini'
                            : 'Surplus bulan ini')
                        : (_customRange != null
                            ? 'Defisit periode ini'
                            : 'Defisit bulan ini'),
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
                  child: _StatCard(
                    icon: Icons.north_east_rounded,
                    label: 'Pengeluaran',
                    value: fmtRp(expense),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.south_west_rounded,
                    label: 'Pemasukan',
                    value: fmtRp(income),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Rata-rata / Hari',
                    value: fmtRp(elapsed == 0 ? 0 : expense / elapsed),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events_outlined,
                    label: 'Terbesar',
                    value: fmtRp(biggestCat?.total ?? 0),
                    sub: biggestCat?.name ?? '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Pengeluaran Harian ──
            FunCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FunLabel('Pengeluaran harian'),
                      Text(
                        'Total ${fmtRp(daily.fold(0.0, (a, b) => a + b))}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BarChartSimple(
                    values: daily,
                    labels: dailyLabels,
                    height: 176,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Porsi per Kategori (Interaktif & Berubah Sesuai Pilihan) ──
            FunCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FunLabel(
                        selectedCat != null
                            ? 'Porsi • ${selectedCat.name}'
                            : 'Porsi per kategori',
                      ),
                      if (selectedCat != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedCatIndex = null),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close_rounded,
                                    size: 13,
                                    color: AppColors.inkSecondary),
                                SizedBox(width: 4),
                                Text(
                                  'Semua',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.inkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        const Text(
                          'Ketuk kategori untuk fokus',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (cats.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Belum ada pengeluaran pada periode ini',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.inkMuted),
                        ),
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        DonutChart(
                          key: ValueKey(
                            'donut_${_selectedCatIndex}_${selectedCat?.name}',
                          ),
                          size: 138,
                          innerRatio: 0.65,
                          values: selectedCat != null
                              ? [
                                  selectedCat.total,
                                  math.max(0.001, catSum - selectedCat.total)
                                ]
                              : [for (final c in cats) c.total],
                          colors: selectedCat != null
                              ? [selectedCatColor!, const Color(0xFFE2E8F0)]
                              : null,
                          selectedIndex: selectedCat != null ? 0 : null,
                          onSelect: (idx) {
                            if (selectedCat != null) {
                              setState(() => _selectedCatIndex = null);
                            } else if (idx >= 0 && idx < cats.length) {
                              setState(() => _selectedCatIndex = idx);
                            }
                          },
                          center: selectedCat != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconBox(
                                      categoryIcon(selectedCat.icon),
                                      size: 28,
                                      radius: 8,
                                      iconSize: 15,
                                      color: selectedCatColor,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${catSum == 0 ? 0 : (selectedCat.total / catSum * 100).round()}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: selectedCatColor,
                                      ),
                                    ),
                                    const Text(
                                      'dari total',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.inkMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.donut_large_rounded,
                                      size: 20,
                                      color: AppColors.accentBlue,
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'TOTAL',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: AppColors.inkMuted,
                                      ),
                                    ),
                                    Text(
                                      fmtRp(catSum),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.inkPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: selectedCat != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: selectedCatColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            selectedCat.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.inkPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    MoneyText(fmtRp(selectedCat.total),
                                        size: 20),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(catSum == 0 ? 0 : (selectedCat.total / catSum * 100).round())}% porsi pengeluaran',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.inkSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    FunBadge(
                                      '${selectedCat.count} transaksi',
                                      icon: Icons.receipt_long_outlined,
                                    ),
                                  ],
                                )
                              : ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 220),
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        for (int i = 0; i < cats.length; i++)
                                          InkWell(
                                            onTap: () {
                                              setState(
                                                  () => _selectedCatIndex = i);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 4),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color: kChartColors[i %
                                                          kChartColors.length],
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      cats[i].name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .inkPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  FunBadge(
                                                      '${catSum == 0 ? 0 : (cats[i].total / catSum * 100).round()}%'),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.chevron_right_rounded,
                                                    size: 14,
                                                    color: AppColors.inkMuted,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),

                    // When a category is selected: show horizontal quick category switcher & transaction history
                    if (selectedCat != null) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 32,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCatIndex = null),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                      color: const Color(0xFFCBD5E1)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.close_rounded,
                                        size: 12,
                                        color: AppColors.inkSecondary),
                                    SizedBox(width: 4),
                                    Text(
                                      'Semua',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.inkSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            for (int i = 0; i < cats.length; i++) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedCatIndex = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _selectedCatIndex == i
                                        ? kChartColors[
                                            i % kChartColors.length]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _selectedCatIndex == i
                                          ? kChartColors[
                                              i % kChartColors.length]
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_selectedCatIndex != i)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin:
                                              const EdgeInsets.only(right: 6),
                                          decoration: BoxDecoration(
                                            color: kChartColors[
                                                i % kChartColors.length],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      Text(
                                        cats[i].name,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: _selectedCatIndex == i
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: _selectedCatIndex == i
                                              ? Colors.white
                                              : AppColors.inkSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transaksi ${selectedCat.name}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkPrimary,
                            ),
                          ),
                          Text(
                            fmtRp(selectedCat.total),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: selectedCatColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FutureBuilder<List<FeedItem>>(
                        future: _repo.getTransactionsByCategory(
                          from: _effectiveFrom,
                          to: _effectiveTo,
                          categoryId: selectedCat.categoryId,
                          categoryName: selectedCat.name,
                          walletId: _selectedWalletId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          final items = snapshot.data ?? const [];
                          if (items.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Belum ada transaksi pada periode ini',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.inkMuted),
                                ),
                              ),
                            );
                          }
                          final dateFormat =
                              DateFormat('dd MMM, HH:mm', 'id_ID');
                          return Column(
                            children: [
                              for (final item in items.take(10))
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.inkPrimary,
                                              ),
                                            ),
                                            Text(
                                              '${item.wallet} • ${dateFormat.format(item.date)}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.inkMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '-${fmtRp(item.amount)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.expense,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tren 6 Bulan Terakhir ──
            FunCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunLabel('Tren 6 bulan terakhir'),
                  const SizedBox(height: 16),
                  BarChartSimple(
                    values: trend,
                    labels: [
                      for (int i = 5; i >= 0; i--)
                        _months[(_month.month - 1 - i + 12) % 12]
                            .substring(0, 3),
                    ],
                    height: 160,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

class _MonthSelector extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onCenterTap;
  final bool canNext;

  const _MonthSelector({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.onCenterTap,
    this.canNext = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.glassCardGradient,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        boxShadow: AppColors.glassShadowSoft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onPrev,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 32,
              height: 40,
              child: Icon(Icons.chevron_left_rounded,
                  size: 20, color: AppColors.inkSecondary),
            ),
          ),
          GestureDetector(
            onTap: onCenterTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 13, color: AppColors.accentBlue),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: canNext ? onNext : null,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 32,
              height: 40,
              child: Icon(Icons.chevron_right_rounded,
                  size: 20,
                  color: canNext
                      ? AppColors.inkSecondary
                      : AppColors.inkMuted.withValues(alpha: 0.3)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _WalletFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? null : AppColors.glassCardGradient,
          color: selected ? AppColors.accentBlue : null,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.accentBlue
                : AppColors.glassBorder,
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : AppColors.inkSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.inkPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return FunCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(icon, size: 32, radius: 10, iconSize: 16),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 2),
          MoneyText(value, size: 18),
          if (sub != null)
            Text(
              sub!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
