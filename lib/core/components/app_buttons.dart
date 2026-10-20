import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
export 'app_luminous_fab.dart';

/// Lightweight stand-in for BackdropFilter. Backdrop blur inside scrolling
/// content forces a saveLayer every frame (jank + smeared text), and gives no
/// visual benefit over a near-opaque white surface. Only the floating dock and
/// FAB keep real blur.
class GlassBlur extends StatelessWidget {
  final ImageFilter? filter;
  final Widget child;
  const GlassBlur({super.key, this.filter, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

/// Cheap inset-glass edge: a short gradient strip instead of a blurred path.
void _cheapInset(
  Canvas canvas,
  Rect rect,
  Offset offset,
  double blur,
  Color color,
) {
  if (offset == Offset.zero) return; // ambient glow skipped (costly, subtle)
  final h = (blur * 1.5).clamp(3.0, 8.0);
  final top = offset.dy > 0;
  final strip = top
      ? Rect.fromLTWH(rect.left, rect.top, rect.width, h)
      : Rect.fromLTWH(rect.left, rect.bottom - h, rect.width, h);
  canvas.drawRect(
    strip,
    Paint()
      ..shader = LinearGradient(
        begin: top ? Alignment.topCenter : Alignment.bottomCenter,
        end: top ? Alignment.bottomCenter : Alignment.topCenter,
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(strip),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Inset Glass Painters (Emulates CSS `box-shadow: inset ...`)
// Modeled 1:1 on the AppLuminousFab design system
// ─────────────────────────────────────────────────────────────────────────────

/// Circular Inset Glass Painter matching AppLuminousFab:
/// - Inset top specular highlight: `inset 0 1.5px 3px rgba(255,255,255,.85)`
/// - Inset bottom depth:           `inset 0 -2px 4px rgba(0,0,0,.20)`
/// - Inset ambient glow:           `inset 0 0 12px rgba(255,255,255,.25)`
class CircleInsetGlassPainter extends CustomPainter {
  final Color highlightColor;
  final Color shadowColor;
  final Color glowColor;

  const CircleInsetGlassPainter({
    this.highlightColor = const Color(0xD9FFFFFF), // .85 white
    this.shadowColor = const Color(0x26000000),    // .15 black
    this.glowColor = const Color(0x40FFFFFF),      // .25 white
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final circle = Path()..addOval(rect);

    canvas.save();
    canvas.clipPath(circle);

    // CSS paints the FIRST listed shadow on top, so paint in reverse order.
    _inset(canvas, rect, circle, Offset.zero, 12, glowColor);
    _inset(canvas, rect, circle, const Offset(0, -2), 4, shadowColor);
    _inset(canvas, rect, circle, const Offset(0, 1.5), 3, highlightColor);

    canvas.restore();
  }

  void _inset(
    Canvas canvas,
    Rect rect,
    Path path,
    Offset offset,
    double blur,
    Color color,
  ) =>
      _cheapInset(canvas, rect, offset, blur, color);

  @override
  bool shouldRepaint(covariant CircleInsetGlassPainter oldDelegate) =>
      highlightColor != oldDelegate.highlightColor ||
      shadowColor != oldDelegate.shadowColor ||
      glowColor != oldDelegate.glowColor;
}

/// RRect / Pill Inset Glass Painter matching AppLuminousFab:
/// Works for pills (`Radius.circular(9999)`) and rounded rectangles.
class RRectInsetGlassPainter extends CustomPainter {
  final Radius radius;
  final Color highlightColor;
  final Color shadowColor;
  final Color glowColor;

  const RRectInsetGlassPainter({
    required this.radius,
    this.highlightColor = const Color(0xD9FFFFFF), // .85 white
    this.shadowColor = const Color(0x26000000),    // .15 black
    this.glowColor = const Color(0x40FFFFFF),      // .25 white
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, radius);
    final path = Path()..addRRect(rrect);

    canvas.save();
    canvas.clipPath(path);

    _inset(canvas, rect, path, Offset.zero, 12, glowColor);
    _inset(canvas, rect, path, const Offset(0, -2), 4, shadowColor);
    _inset(canvas, rect, path, const Offset(0, 1.5), 3, highlightColor);

    canvas.restore();
  }

  void _inset(
    Canvas canvas,
    Rect rect,
    Path path,
    Offset offset,
    double blur,
    Color color,
  ) =>
      _cheapInset(canvas, rect, offset, blur, color);

  @override
  bool shouldRepaint(covariant RRectInsetGlassPainter oldDelegate) =>
      radius != oldDelegate.radius ||
      highlightColor != oldDelegate.highlightColor ||
      shadowColor != oldDelegate.shadowColor ||
      glowColor != oldDelegate.glowColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. AppGlassIconButton — Circular Luminous Glass Utility Button
// ─────────────────────────────────────────────────────────────────────────────

/// Frosted Glass Utility Button (Avatar, Search, Refresh, Close, Back, etc.):
/// - 44x44 circular button with backdrop-blur-xl (24)
/// - 1.5px border rgba(255,255,255,.7)
/// - Inset glass highlight, shadow, and inner glow
/// - Icon with subtle drop shadow
/// - Press: scale .95 (200ms) with haptics
class AppGlassIconButton extends StatefulWidget {
  final Widget? icon;
  final IconData? iconData;
  final double iconSize;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? iconColor;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double size;
  final Widget? child;

  const AppGlassIconButton({
    super.key,
    this.icon,
    this.iconData,
    this.iconSize = 20,
    this.onTap,
    this.tooltip,
    this.iconColor,
    this.backgroundColor,
    this.gradient,
    this.size = 44,
    this.child,
  });

  @override
  State<AppGlassIconButton> createState() => _AppGlassIconButtonState();
}

class _AppGlassIconButtonState extends State<AppGlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveChild = widget.child ??
        (widget.icon ??
            (widget.iconData != null
                ? Icon(
                    widget.iconData,
                    size: widget.iconSize,
                    color: widget.iconColor ?? AppColors.inkPrimary,
                    shadows: const [
                      Shadow(
                        color: Color(0x26000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  )
                : null));

    return Tooltip(
      message: widget.tooltip ?? '',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: ClipOval(
              child: GlassBlur(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.gradient,
                    color: widget.gradient == null
                        ? (widget.backgroundColor ??
                            Colors.white.withValues(alpha: 0.82))
                        : null,
                    border: Border.all(
                      color: const Color(0xB3FFFFFF), // 70% white
                      width: 1.5,
                    ),
                  ),
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: CircleInsetGlassPainter(
                        highlightColor: const Color(0xD9FFFFFF),
                        shadowColor: widget.gradient != null
                            ? const Color(0x33000000)
                            : const Color(0x1F000000),
                        glowColor: const Color(0x40FFFFFF),
                      ),
                      child: Center(child: effectiveChild),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. AppGlassPillChip — Luminous Frosted Glass Pill Chip
// ─────────────────────────────────────────────────────────────────────────────

/// Frosted Glass Pill Chip matching AppLuminousFab design rules:
/// - Active: Translucent aurora gradient + 1.5px border + inset highlight & depth
/// - Inactive: Frosted translucent white + 1.2px border + soft inset highlight
/// - Press: scale .95 (200ms) with haptics
class AppGlassPillChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Gradient? activeGradient;
  final Color? activeColor;
  final EdgeInsetsGeometry padding;

  const AppGlassPillChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.icon,
    this.activeGradient,
    this.activeColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
  });

  @override
  State<AppGlassPillChip> createState() => _AppGlassPillChipState();
}

class _AppGlassPillChipState extends State<AppGlassPillChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final gradient = isSelected
        ? (widget.activeGradient ??
            (widget.activeColor != null
                ? LinearGradient(
                    colors: [
                      widget.activeColor!,
                      widget.activeColor!.withValues(alpha: 0.85),
                    ],
                  )
                : AppColors.luminousFabGradient))
        : null;

    final bgColor = isSelected ? null : Colors.white.withValues(alpha: 0.80);
    final borderColor = isSelected
        ? const Color(0xB3FFFFFF) // 70% white
        : const Color(0x99FFFFFF); // 60% white

    final textColor = isSelected ? Colors.white : AppColors.inkSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: GlassBlur(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                color: bgColor,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: borderColor,
                  width: 1.5,
                ),
              ),
              child: CustomPaint(
                painter: RRectInsetGlassPainter(
                  radius: const Radius.circular(9999),
                  highlightColor: isSelected
                      ? const Color(0xD9FFFFFF)
                      : const Color(0xE6FFFFFF),
                  shadowColor: isSelected
                      ? const Color(0x33000000)
                      : const Color(0x14000000),
                  glowColor: isSelected
                      ? const Color(0x40FFFFFF)
                      : const Color(0x26FFFFFF),
                ),
                child: Padding(
                  padding: widget.padding,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 15,
                          color: textColor,
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
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: textColor,
                          letterSpacing: -0.1,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Backwards compatibility alias for AppGlassPillChip
typedef AppPillChip = AppGlassPillChip;

// ─────────────────────────────────────────────────────────────────────────────
// 3. AppGlassPeriodToggle — Horizontal Scrolling Luminous Glass Pills
// ─────────────────────────────────────────────────────────────────────────────

/// Integrated Frosted Glass Period Toggle:
/// Clean horizontal scrolling/wrapped pills that never clip or collide with the FAB
class AppGlassPeriodToggle extends StatelessWidget {
  final int selectedIndex; // 0: Harian, 1: Mingguan, 2: Bulanan (or Semua, Harian, ...)
  final ValueChanged<int> onSelected;
  final List<String> labels;

  const AppGlassPeriodToggle({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.labels = const ['Semua', 'Harian', 'Mingguan', 'Bulanan'],
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppGlassPillChip(
              label: labels[index],
              isSelected: isSelected,
              onTap: () => onSelected(index),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. AppGlassTypeToggle — Luminous Frosted Glass Expense/Income Switcher
// ─────────────────────────────────────────────────────────────────────────────

/// Frosted Glass Type Toggle (Pengeluaran / Pemasukan):
/// - Glass track container with blur & white border
/// - Active pill with aurora-like red / emerald gradient & inset highlights
class AppGlassTypeToggle extends StatelessWidget {
  final String selectedType; // 'expense' or 'income'
  final ValueChanged<String> onTypeChanged;

  const AppGlassTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: GlassBlur(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: const Color(0x99FFFFFF),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TypeOptionButton(
                label: 'Pengeluaran',
                typeKey: 'expense',
                isSelected: selectedType == 'expense',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF87171),
                    Color(0xFFEF4444),
                    Color(0xFFDC2626),
                  ],
                ),
                onTap: () => onTypeChanged('expense'),
              ),
              _TypeOptionButton(
                label: 'Pemasukan',
                typeKey: 'income',
                isSelected: selectedType == 'income',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF34D399),
                    Color(0xFF10B981),
                    Color(0xFF059669),
                  ],
                ),
                onTap: () => onTypeChanged('income'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeOptionButton extends StatefulWidget {
  final String label;
  final String typeKey;
  final bool isSelected;
  final Gradient gradient;
  final VoidCallback onTap;

  const _TypeOptionButton({
    required this.label,
    required this.typeKey,
    required this.isSelected,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_TypeOptionButton> createState() => _TypeOptionButtonState();
}

class _TypeOptionButtonState extends State<_TypeOptionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: GlassBlur(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
              decoration: BoxDecoration(
                gradient: isSelected ? widget.gradient : null,
                color: isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(9999),
                border: isSelected
                    ? Border.all(
                        color: const Color(0xB3FFFFFF),
                        width: 1.5,
                      )
                    : null,
              ),
              child: isSelected
                  ? CustomPaint(
                      painter: const RRectInsetGlassPainter(
                        radius: Radius.circular(9999),
                        highlightColor: Color(0xD9FFFFFF),
                        shadowColor: Color(0x33000000),
                        glowColor: Color(0x40FFFFFF),
                      ),
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Color(0x33000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSecondary,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. AppPrimaryButton — Luminous Glass Aurora Primary Action Button
// ─────────────────────────────────────────────────────────────────────────────

/// Primary 52px Action Button with Luminous Glass Aurora (matching AppLuminousFab):
/// - backdrop-blur-xl (24)
/// - Aurora/blue/slate gradient + 1.5px border rgba(255,255,255,.7)
/// - Inset glass highlight, shadow, and inner glow
/// - Text with subtle drop shadow
/// - Press: scale .96 (200ms) with medium impact haptic
class AppPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? textColor;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final bool fullWidth;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.gradient,
    this.textColor,
    this.icon,
    this.height = 52,
    this.borderRadius = 9999, // Pill shape default
    this.fullWidth = true,
  });

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final fgColor = widget.textColor ?? Colors.white;

    final effectiveGradient = widget.gradient ??
        (widget.backgroundColor != null
            ? LinearGradient(
                colors: [
                  widget.backgroundColor!,
                  widget.backgroundColor!.withValues(alpha: 0.9),
                ],
              )
            : AppColors.primaryButtonGradient);

    Widget content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: fgColor,
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: 20,
            color: fgColor,
            shadows: const [
              Shadow(
                color: Color(0x33000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            color: fgColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            shadows: const [
              Shadow(
                color: Color(0x4D000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.isLoading || widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLoading || widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading
          ? null
          : () {
              HapticFeedback.mediumImpact();
              widget.onPressed?.call();
            },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: GlassBlur(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: widget.height,
              width: widget.fullWidth ? double.infinity : null,
              decoration: BoxDecoration(
                gradient: effectiveGradient,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: const Color(0xB3FFFFFF),
                  width: 1.5,
                ),
              ),
              child: CustomPaint(
                painter: RRectInsetGlassPainter(
                  radius: Radius.circular(widget.borderRadius),
                  highlightColor: const Color(0xD9FFFFFF),
                  shadowColor: const Color(0x3D000000),
                  glowColor: const Color(0x33FFFFFF),
                ),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. AppSecondaryButton — Frosted Glass Secondary Button
// ─────────────────────────────────────────────────────────────────────────────

/// Secondary Frosted Glass Button (Cancel, Back, Tertiary actions)
class AppSecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final bool fullWidth;

  const AppSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.height = 52,
    this.borderRadius = 9999,
    this.fullWidth = true,
  });

  @override
  State<AppSecondaryButton> createState() => _AppSecondaryButtonState();
}

class _AppSecondaryButtonState extends State<AppSecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: GlassBlur(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: widget.height,
              width: widget.fullWidth ? double.infinity : null,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: const Color(0x99FFFFFF),
                  width: 1.5,
                ),
              ),
              child: CustomPaint(
                painter: RRectInsetGlassPainter(
                  radius: Radius.circular(widget.borderRadius),
                  highlightColor: const Color(0xE6FFFFFF),
                  shadowColor: const Color(0x14000000),
                  glowColor: const Color(0x26FFFFFF),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize:
                        widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 20, color: AppColors.inkPrimary),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: AppColors.inkPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
