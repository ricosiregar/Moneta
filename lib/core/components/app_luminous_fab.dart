import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'app_buttons.dart' show GlassBlur;

/// Luminous Glass Aurora FAB — 1:1 port of the web `#add-expense-fab`:
/// - 62x62 circle, backdrop-blur-xl (24)
/// - translucent aurora gradient (AppColors.luminousFabGradient)
/// - 1.5px border rgba(255,255,255,.7)
/// - INSET-only shadows (no outer glow, same as the web inline style):
///     inset 0 1.5px 3px  rgba(255,255,255,.85)
///     inset 0 -2px 4px   rgba(0,0,0,.2)
///     inset 0 0 12px     rgba(255,255,255,.25)
/// - white plus, strokeWidth 2.85 on a 24 grid, scaled to 32px, + drop shadow
/// - press: scale .95 (200ms)
class AppLuminousFab extends StatefulWidget {
  final VoidCallback onTap;
  final String tooltip;
  final double size;

  const AppLuminousFab({
    super.key,
    required this.onTap,
    this.tooltip = 'Tambah Transaksi',
    this.size = 62,
  });

  @override
  State<AppLuminousFab> createState() => _AppLuminousFabState();
}

class _AppLuminousFabState extends State<AppLuminousFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
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
                    gradient: AppColors.luminousFabGradient,
                    border: Border.all(
                      color: const Color(0xB3FFFFFF), // white @ 70%
                      width: 1.5,
                    ),
                  ),
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: const _InsetGlassPainter(),
                      child: const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CustomPaint(painter: _PlusPainter()),
                        ),
                      ),
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

/// Emulates CSS `box-shadow: inset ...` (Flutter has no inset shadows).
/// Shadow = area outside the circle shifted by [offset], blurred, clipped to the circle.
class _InsetGlassPainter extends CustomPainter {
  const _InsetGlassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final circle = Path()..addOval(rect);

    canvas.save();
    canvas.clipPath(circle);

    // CSS paints the FIRST listed shadow on top, so paint in reverse order.
    _inset(
      canvas,
      rect,
      circle,
      Offset.zero,
      12,
      const Color(0x40FFFFFF),
    ); // .25
    _inset(
      canvas,
      rect,
      circle,
      const Offset(0, -2),
      4,
      const Color(0x33000000),
    ); // .20
    _inset(
      canvas,
      rect,
      circle,
      const Offset(0, 1.5),
      3,
      const Color(0xD9FFFFFF),
    ); // .85

    canvas.restore();
  }

  void _inset(
    Canvas canvas,
    Rect rect,
    Path circle,
    Offset offset,
    double blur,
    Color color,
  ) {
    final outer = Path()..addRect(rect.inflate(blur * 3 + 8));
    final shadow = Path.combine(
      PathOperation.difference,
      outer,
      circle.shift(offset),
    );
    canvas.drawPath(
      shadow,
      Paint()
        ..color = color
        // CSS blur radius B == Gaussian sigma B / 2
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _InsetGlassPainter oldDelegate) => false;
}

/// Lucide "plus" (M5 12h14 / M12 5v14) with strokeWidth 2.85 on a 24 grid,
/// plus `drop-shadow(0 1px 2px rgba(0,0,0,.3))`.
class _PlusPainter extends CustomPainter {
  const _PlusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final path = Path()
      ..moveTo(5 * s, 12 * s)
      ..lineTo(19 * s, 12 * s)
      ..moveTo(12 * s, 5 * s)
      ..lineTo(12 * s, 19 * s);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.85 * s
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      path.shift(const Offset(0, 1)),
      base
        ..color = const Color(0x4D000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.85 * s
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _PlusPainter oldDelegate) => false;
}
