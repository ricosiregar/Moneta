import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/app_colors.dart';
import 'app_buttons.dart' show RRectInsetGlassPainter;
import 'app_luminous_fab.dart';

/// Navigation item model
class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Floating bottom navigation: liquid-glass dock (package: liquid_glass_widgets)
/// with an active pill that uses the same luminous aurora gradient as the FAB.
/// The icon turns white the moment a tab is pressed (and stays white while
/// selected). The glowing FAB floats above the right end of the dock.
class FloatingBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onFabTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onFabTap,
  });

  static const List<NavItemData> items = [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_outlined,
      label: 'Beranda',
    ),
    NavItemData(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_outlined,
      label: 'Aktivitas',
    ),
    NavItemData(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_outlined,
      label: 'Analitik',
    ),
    NavItemData(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_outlined,
      label: 'Pengaturan',
    ),
  ];

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav>
    with SingleTickerProviderStateMixin {
  static const double _barHeight = 62;
  static const double _barVerticalPadding = 14;
  static const double _inner = 7;

  static const List<NavItemData> items = FloatingBottomNav.items;

  late final AnimationController _pos;
  bool _pressed = false;

  int get currentIndex => widget.currentIndex;
  ValueChanged<int> get onTabSelected => widget.onTabSelected;
  VoidCallback get onFabTap => widget.onFabTap;

  @override
  void initState() {
    super.initState();
    _pos = AnimationController.unbounded(
      vsync: this,
      value: widget.currentIndex.toDouble(),
    );
  }

  @override
  void didUpdateWidget(covariant FloatingBottomNav old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      // Jelly spring: under-damped so the pill overshoots and wobbles.
      _pos.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 260, damping: 15),
          _pos.value,
          widget.currentIndex.toDouble(),
          _pos.velocity,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final screenW = MediaQuery.of(context).size.width;
    final dockW = (screenW - 32).clamp(0.0, 264.0);
    final itemW = (dockW - _inner * 2) / items.length;
    final pillH = _barHeight - _inner * 2;

    int indexAt(double dx) =>
        ((dx - _inner) / itemW).floor().clamp(0, items.length - 1);

    void select(int i) {
      if (i == currentIndex) return;
      HapticFeedback.selectionClick();
      onTabSelected(i);
    }

    return Stack(
      children: [
        // ── Liquid glass dock ──
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomInset + _barVerticalPadding,
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                setState(() => _pressed = true);
                select(indexAt(d.localPosition.dx));
              },
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onHorizontalDragStart: (_) => setState(() => _pressed = true),
              onHorizontalDragEnd: (_) => setState(() => _pressed = false),
              onHorizontalDragCancel: () => setState(() => _pressed = false),
              onHorizontalDragUpdate: (d) =>
                  select(indexAt(d.localPosition.dx)),
              child: GlassContainer(
                useOwnLayer: true,
                width: dockW,
                height: _barHeight,
                shape: const LiquidRoundedSuperellipse(borderRadius: 31),
                child: Stack(
                  children: [
                    // Active pill — FAB aurora gradient + white border + inset gloss
                    AnimatedBuilder(
                      animation: _pos,
                      builder: (context, child) {
                        // Squash & stretch from velocity (jelly).
                        final v = _pos.velocity.abs();
                        final stretch = (v * 0.07).clamp(0.0, 0.45);
                        return Positioned(
                          left: _inner + _pos.value * itemW,
                          top: _inner,
                          width: itemW,
                          height: pillH,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.diagonal3Values(
                              1 + stretch,
                              1 - stretch * 0.35,
                              1,
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: AnimatedScale(
                        scale: _pressed ? 1.14 : 1.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.luminousFabGradient,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(
                              color: const Color(0xB3FFFFFF),
                              width: 1.5,
                            ),
                          ),
                          child: const CustomPaint(
                            painter: RRectInsetGlassPainter(
                              radius: Radius.circular(9999),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Icons
                    Positioned.fill(
                      left: _inner,
                      right: _inner,
                      child: Row(
                        children: [
                          for (int i = 0; i < items.length; i++)
                            SizedBox(
                              width: itemW,
                              child: Center(
                                child: _NavIcon(
                                  item: items[i],
                                  isSelected: i == currentIndex,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Glow FAB above the right end of the dock ──
        Positioned(
          right: 16,
          bottom: bottomInset + _barHeight + _barVerticalPadding * 2 + 8,
          child: AppLuminousFab(onTap: onFabTap, tooltip: 'Tambah Transaksi'),
        ),
      ],
    );
  }
}

class _NavIcon extends StatelessWidget {
  final NavItemData item;
  final bool isSelected;

  const _NavIcon({
    required this.item,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      tween: ColorTween(
        end: isSelected ? Colors.white : const Color(0xFF64748B),
      ),
      builder: (context, color, _) {
        return AnimatedScale(
          scale: isSelected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: Icon(
            isSelected ? item.activeIcon : item.icon,
            size: 24,
            color: color,
            semanticLabel: item.label,
            shadows: isSelected
                ? const [
                    Shadow(
                      color: Color(0x33000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
