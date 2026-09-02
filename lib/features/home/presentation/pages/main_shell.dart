import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// MainShell manages the persistent Bottom Navigation Bar for the authenticated nested routes
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      // Support navigating to initial location when tapping current tab
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.bgOffWhite,
      body: navigationShell,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 28,
        ),
        decoration: const BoxDecoration(
          color: AppColors.toggleBgColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(36),
          ),
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
      onTap: () => _onItemTapped(index),
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
