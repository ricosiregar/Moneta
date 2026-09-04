import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import 'cubit/bottom_nav_cubit.dart';
import '../analytic/analytics_page.dart';
import '../home/presentation/pages/home_page.dart';
import '../profile/profile_page.dart';
import '../report/reports_page.dart';
import '../transactions/transactions_page.dart';

/// MainPage mengelola persistent Bottom Navigation Bar menggunakan
/// pendekatan IndexedStack + BottomNavCubit.
///
/// Pattern ini diadaptasi dari Metland-Card MainPage:
/// - IndexedStack menjaga state semua tab (tidak di-rebuild saat pindah tab)
/// - Lazy loading: tab hanya di-render saat pertama kali dikunjungi
/// - History stack: tombol back Android kembali ke tab sebelumnya
/// - BottomNavCubit (BLoC) mengelola state navigasi terpusat
///
/// Berbeda dari StatefulShellRoute GoRouter, pendekatan ini tidak
/// mengikat navigasi tab ke URL routing, sehingga lebih fleksibel
/// untuk navigasi tab yang tidak perlu deep link.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// Track tab mana saja yang sudah pernah dikunjungi (lazy loading).
  /// Index 0 (Home) langsung true karena itu tab awal.
  final List<bool> _visitedTabs = [true, false, false, false, false];

  void _onTap(int index) {
    final currentIndex = context.read<BottomNavCubit>().state.currentIndex;
    if (currentIndex == index) return;

    // Tandai tab sudah dikunjungi agar di-render (lazy loading)
    if (!_visitedTabs[index]) {
      setState(() {
        _visitedTabs[index] = true;
      });
    }

    context.read<BottomNavCubit>().goTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, BottomNavState>(
      builder: (context, navState) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            // Coba kembali ke tab sebelumnya dari history
            final handled = context.read<BottomNavCubit>().goBack();
            if (!handled) {
              // History kosong → keluar dari aplikasi
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.bgOffWhite,
            body: IndexedStack(
              index: navState.currentIndex,
              children: [
                // Tab 0: Home / Dashboard
                const DashboardScreen(),
                // Tab 1: Analytics — lazy load
                _visitedTabs[1]
                    ? const AnalyticsScreen()
                    : const SizedBox.shrink(),
                // Tab 2: Transactions — lazy load
                _visitedTabs[2]
                    ? const TransactionsScreen()
                    : const SizedBox.shrink(),
                // Tab 3: Reports — lazy load
                _visitedTabs[3]
                    ? const ReportsScreen()
                    : const SizedBox.shrink(),
                // Tab 4: Profile — lazy load
                _visitedTabs[4]
                    ? const ProfileScreen()
                    : const SizedBox.shrink(),
              ],
            ),
            bottomNavigationBar: _buildBottomNav(navState.currentIndex),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(int currentIndex) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 28),
      decoration: const BoxDecoration(
        color: AppColors.toggleBgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            index: 0,
            currentIndex: currentIndex,
          ),
          _buildNavItem(
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart_rounded,
            index: 1,
            currentIndex: currentIndex,
          ),
          _buildNavItem(
            icon: Icons.sync_alt_rounded,
            activeIcon: Icons.sync_alt_rounded,
            index: 2,
            currentIndex: currentIndex,
          ),
          _buildNavItem(
            icon: Icons.layers_outlined,
            activeIcon: Icons.layers_rounded,
            index: 3,
            currentIndex: currentIndex,
          ),
          _buildNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            index: 4,
            currentIndex: currentIndex,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required int currentIndex,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: isSelected
            ? const EdgeInsets.all(12)
            : const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.yellowGradient : null,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x33FFA700),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.textDark : const Color(0xFF8E8E93),
          size: 26,
        ),
      ),
    );
  }
}
