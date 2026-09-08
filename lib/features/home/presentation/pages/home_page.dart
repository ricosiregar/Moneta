import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/home_repository.dart';
import '../cubit/home_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper: Format Rupiah
// ─────────────────────────────────────────────────────────────────────────────

String _fmtRupiah(double amount) {
  final negative = amount < 0;
  final raw = amount.abs().toStringAsFixed(0);
  final buf = StringBuffer();
  for (int i = 0; i < raw.length; i++) {
    if (i > 0 && (raw.length - i) % 3 == 0) buf.write('.');
    buf.write(raw[i]);
  }
  return '${negative ? '-' : ''}Rp $buf';
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardScreen
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
    context.read<HomeCubit>().loadDashboard();
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
              : (email.contains('@') ? email.split('@').first : 'Welcome Back');
          return _DashboardBody(greetingName: greetingName);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DashboardBody
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardBody extends StatefulWidget {
  final String greetingName;
  const _DashboardBody({required this.greetingName});

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFFFFEA00), Color(0xFFFFA700), Color(0xFFFF7200)],
  );
  static const Color bgColor = Color(0xFFF9F9F5);
  static const Color textDark = Color(0xFF141414);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color accentExpense = Color(0xFF2B5B84);
  static const Color darkPillColor = Color(0xFF131D26);
  static const Color toggleBgColor = Color(0xFFFFF7D6);

  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _timeGreeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showAddWalletSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<HomeCubit>(),
        child: const _AddWalletSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        final wallets = homeState.wallets;
        final transactions = homeState.recentTransactions;
        final isLoading = homeState.status == HomeStatus.loading;
        final isOnAddPage = _selectedIndex >= wallets.length;

        final activeWallet = wallets.isNotEmpty
            ? wallets[_selectedIndex.clamp(0, wallets.length - 1)]
            : null;

        final displayBalance = isLoading
            ? '...'
            : isOnAddPage || activeWallet == null
            ? _fmtRupiah(homeState.totalBalance)
            : _fmtRupiah(activeWallet.balance);

        final displayExpense = isLoading
            ? '...'
            : _fmtRupiah(homeState.filteredExpense);

        return RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().refresh(),
          color: const Color(0xFFFF7200),
          child: Scaffold(
            body: Container(
              decoration: const BoxDecoration(gradient: yellowGradient),
              child: Stack(
                children: [
                  // ── YELLOW HEADER ────────────────────────────────────────
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, ${widget.greetingName}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textDark,
                                    ),
                                  ),
                                  Text(
                                    _timeGreeting,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: textDark,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none,
                                  color: textDark,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Balance & Expense
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.north_east,
                                          size: 14,
                                          color: textDark,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Total Balance',
                                          style: TextStyle(color: textDark),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: isLoading
                                          ? const _LoadingIndicator(
                                              color: textDark,
                                            )
                                          : Text(
                                              displayBalance,
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: textDark,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.black26,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.south_west,
                                          size: 14,
                                          color: textDark,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Total Expense',
                                          style: TextStyle(color: textDark),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: isLoading
                                          ? const _LoadingIndicator(
                                              color: accentExpense,
                                            )
                                          : Text(
                                              '-$displayExpense',
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: accentExpense,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── WHITE DRAGGABLE SHEET ────────────────────────────────
                  DraggableScrollableSheet(
                    initialChildSize: 0.68,
                    minChildSize: 0.68,
                    maxChildSize: 0.92,
                    snap: true,
                    snapSizes: const [0.68, 0.92],
                    builder: (ctx, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                        ),
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          children: [
                            // Drag handle
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 16,
                                ),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                            // ── Wallet Card Carousel ────────────────────
                            if (isLoading)
                              const SizedBox(
                                height: 195,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFF7200),
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                height: 195,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: wallets.length + 1,
                                  onPageChanged: (i) =>
                                      setState(() => _selectedIndex = i),
                                  itemBuilder: (ctx, i) {
                                    if (i == wallets.length) {
                                      return _AddCardButton(
                                        onTap: _showAddWalletSheet,
                                      );
                                    }
                                    return _ATMCardWidget(
                                      wallet: wallets[i],
                                      userName: widget.greetingName,
                                      isSelected: i == _selectedIndex,
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 14),

                            // ── Page Dots ───────────────────────────────
                            if (!isLoading)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  wallets.length + 1,
                                  (i) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: i == _selectedIndex ? 20 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: i == _selectedIndex
                                          ? darkPillColor
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),

                            // ── Period Toggle ───────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: toggleBgColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    _PeriodTab(
                                      label: 'Daily',
                                      period: TransactionPeriod.daily,
                                      selected:
                                          homeState.selectedPeriod ==
                                          TransactionPeriod.daily,
                                    ),
                                    _PeriodTab(
                                      label: 'Weekly',
                                      period: TransactionPeriod.weekly,
                                      selected:
                                          homeState.selectedPeriod ==
                                          TransactionPeriod.weekly,
                                    ),
                                    _PeriodTab(
                                      label: 'Monthly',
                                      period: TransactionPeriod.monthly,
                                      selected:
                                          homeState.selectedPeriod ==
                                          TransactionPeriod.monthly,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Error ───────────────────────────────────
                            if (homeState.status == HomeStatus.failure)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'Gagal memuat data: ${homeState.errorMessage}',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),

                            // ── Transactions ────────────────────────────
                            if (isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFF7200),
                                  ),
                                ),
                              )
                            else if (transactions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 32,
                                  horizontal: 24,
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: 48,
                                        color: textMuted,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Belum ada transaksi',
                                        style: TextStyle(
                                          color: textMuted,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ...transactions.map<Widget>(
                                (tx) => _TransactionTile(transaction: tx),
                              ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Period Toggle Tab
// ─────────────────────────────────────────────────────────────────────────────

class _PeriodTab extends StatelessWidget {
  final String label;
  final TransactionPeriod period;
  final bool selected;

  const _PeriodTab({
    required this.label,
    required this.period,
    required this.selected,
  });

  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFFFFEA00), Color(0xFFFFA700), Color(0xFFFF7200)],
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<HomeCubit>().changePeriod(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: selected ? yellowGradient : null,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected
                    ? const Color(0xFF141414)
                    : const Color(0xFF8E8E93),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ATM Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class _ATMCardWidget extends StatelessWidget {
  final WalletModel wallet;
  final String userName;
  final bool isSelected;

  const _ATMCardWidget({
    required this.wallet,
    required this.userName,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = wallet.gradientColors;
    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.93,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.last.withValues(alpha: 0.45),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -25,
              right: -25,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -35,
              left: 70,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              wallet.iconData,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            wallet.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 36,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.credit_card_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Saldo Tersedia',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _fmtRupiah(wallet.balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userName.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          wallet.type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Card Button
// ─────────────────────────────────────────────────────────────────────────────

class _AddCardButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCardButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFEA00), Color(0xFFFF7200)],
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tambah Wallet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF141414),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tambahkan dompet baru',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Wallet Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddWalletSheet extends StatefulWidget {
  const _AddWalletSheet();

  @override
  State<_AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<_AddWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  String _selectedType = 'cash';
  String _selectedIcon = 'account_balance_wallet';
  String _selectedColor = 'yellow';

  static const _types = [
    ('cash', 'Tunai', Icons.payments_outlined),
    ('bank', 'Bank', Icons.account_balance_outlined),
    ('e_wallet', 'E-Wallet', Icons.phone_android_outlined),
  ];

  static const _icons = [
    ('account_balance_wallet', Icons.account_balance_wallet_outlined),
    ('savings', Icons.savings_outlined),
    ('shopping_bag', Icons.shopping_bag_outlined),
    ('directions_bus', Icons.directions_bus_outlined),
    ('restaurant', Icons.restaurant_outlined),
    ('favorite', Icons.favorite_outline),
    ('movie', Icons.movie_outlined),
  ];

  static const _colors = [
    ('yellow', Color(0xFFFFEA00), 'Kuning'),
    ('blue', Color(0xFF1A73E8), 'Biru'),
    ('orange', Color(0xFFFF6D00), 'Oranye'),
    ('teal', Color(0xFF00897B), 'Hijau Tua'),
    ('pink', Color(0xFFE91E63), 'Merah Muda'),
    ('purple', Color(0xFF7C4DFF), 'Ungu'),
    ('green', Color(0xFF43A047), 'Hijau'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final rawBalance = _balanceController.text
        .replaceAll('.', '')
        .replaceAll(',', '');
    final balance = double.tryParse(rawBalance) ?? 0.0;

    await context.read<HomeCubit>().addWallet(
      name: _nameController.text.trim(),
      type: _selectedType,
      balance: balance,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isLoading = state.isAddingWallet;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tambah Wallet Baru',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Kelola saldo & pengeluaran per dompet',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),

                  // Nama wallet
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nama Wallet',
                      hintText: 'Contoh: BCA, GoPay, Dompet',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFFFA700),
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Saldo awal
                  TextFormField(
                    controller: _balanceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Saldo Awal',
                      prefixText: 'Rp  ',
                      hintText: '0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFFFA700),
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null; // boleh 0
                      final n = double.tryParse(v);
                      if (n == null || n < 0) return 'Saldo tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tipe wallet
                  const Text(
                    'Tipe Wallet',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: _types.map((t) {
                      final selected = _selectedType == t.$1;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedType = t.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFF7200)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFFFF7200)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  t.$3,
                                  size: 22,
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t.$2,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Pilih ikon
                  const Text(
                    'Ikon',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _icons.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final ic = _icons[i];
                        final selected = _selectedIcon == ic.$1;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = ic.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFF7200)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFFFF7200)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Icon(
                              ic.$2,
                              size: 24,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pilih warna
                  const Text(
                    'Warna Kartu',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final c = _colors[i];
                        final selected = _selectedColor == c.$1;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = c.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.$2,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: c.$2.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: selected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: const Color(0xFFFF7200),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan Wallet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction Tile
// ─────────────────────────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionTile({required this.transaction});

  static const Color textDark = Color(0xFF141414);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color accentExpense = Color(0xFF2B5B84);
  static const Color accentIncome = Color(0xFF52B788);

  IconData get _icon {
    switch (transaction.categoryIcon) {
      case 'directions_bus':
        return Icons.directions_bus_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'savings':
        return Icons.savings_outlined;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'movie':
        return Icons.movie_outlined;
      case 'favorite':
        return Icons.favorite_outline;
      default:
        return transaction.isIncome
            ? Icons.account_balance_wallet_outlined
            : Icons.payment_outlined;
    }
  }

  Color get _iconBg {
    if (transaction.isIncome) return accentIncome;
    switch (transaction.categoryColor) {
      case 'blue':
        return const Color(0xFF1A73E8);
      case 'orange':
        return const Color(0xFFFF6D00);
      case 'teal':
        return const Color(0xFF00897B);
      case 'pink':
        return const Color(0xFFE91E63);
      case 'purple':
        return const Color(0xFF7C4DFF);
      case 'green':
        return const Color(0xFF43A047);
      default:
        return accentExpense;
    }
  }

  String get _formattedDate {
    final d = transaction.date;
    final months = [
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
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m - ${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final amountText = transaction.isExpense
        ? '-${_fmtRupiah(transaction.amount)}'
        : '+${_fmtRupiah(transaction.amount)}';
    final amountColor = transaction.isExpense ? accentExpense : accentIncome;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _iconBg, shape: BoxShape.circle),
            child: Icon(_icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _formattedDate,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 35, color: Colors.grey.shade300),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Text(
              transaction.categoryName ?? '-',
              style: const TextStyle(color: textDark, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Container(width: 1, height: 35, color: Colors.grey.shade300),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              amountText,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: amountColor,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading Indicator helper
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingIndicator extends StatelessWidget {
  final Color color;
  const _LoadingIndicator({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}
