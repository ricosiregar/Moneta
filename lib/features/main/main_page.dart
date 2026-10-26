import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/components/floating_bottom_nav.dart';
import '../transactions/presentation/widgets/transaction_sheet.dart';
import '../../core/theme/app_colors.dart';
import 'cubit/bottom_nav_cubit.dart';
import '../analytic/presentation/pages/analytics_page.dart';
import '../home/presentation/pages/home_page.dart';
import '../profile/presentation/pages/profile_page.dart';
import '../transactions/presentation/pages/transactions_page.dart';

/// MainPage manages persistent Floating Island Bottom Navigation + FAB
/// with IndexedStack + BottomNavCubit.
///
/// Matches Moneta architecture:
/// - Tab 0: Beranda (Home / Dashboard)
/// - Tab 1: Aktivitas (Transactions)
/// - Tab 2: Analitik (Analytics)
/// - Tab 3: Akun (Profile & Settings)
/// - Luminous Floating Action Button (FAB) for adding transaction / income / expense
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// Track which tabs have been visited for lazy-loading (4 tabs).
  final List<bool> _visitedTabs = [true, false, false, false];

  void _onTap(int index) {
    final currentIndex = context.read<BottomNavCubit>().state.currentIndex;
    if (currentIndex == index) return;

    if (!_visitedTabs[index]) {
      setState(() {
        _visitedTabs[index] = true;
      });
    }

    context.read<BottomNavCubit>().goTo(index);
  }

  void _openTransactionSheet() {
    TransactionSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, BottomNavState>(
      builder: (context, navState) {
        final activeIndex = navState.currentIndex.clamp(0, 3);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            final handled = context.read<BottomNavCubit>().goBack();
            if (!handled) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.canvas,
            body: Stack(
              children: [
                // ── Screen Content ──
                IndexedStack(
                  index: activeIndex,
                  children: [
                    // Tab 0: Beranda
                    const DashboardScreen(),
                    // Tab 1: Aktivitas (Transactions)
                    _visitedTabs[1]
                        ? const TransactionsScreen()
                        : const SizedBox.shrink(),
                    // Tab 2: Analitik (Analytics)
                    _visitedTabs[2]
                        ? const AnalyticsScreen()
                        : const SizedBox.shrink(),
                    // Tab 3: Akun (Profile)
                    _visitedTabs[3]
                        ? const ProfileScreen()
                        : const SizedBox.shrink(),
                  ],
                ),

                // ── Floating Bottom Navigation Island + Luminous FAB ──
                FloatingBottomNav(
                  currentIndex: activeIndex,
                  onTabSelected: _onTap,
                  onFabTap: _openTransactionSheet,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
