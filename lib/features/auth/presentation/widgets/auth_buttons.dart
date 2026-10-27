import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/app_buttons.dart'
    show GlassBlur, RRectInsetGlassPainter;

/// Full-screen loading overlay with darkened backdrop and centered Aurora spinner
class AuroraLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const AuroraLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: const Color(0x660F172A),
                  alignment: Alignment.center,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: AppColors.glassSheetGradient,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x260F172A),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(child: AuroraSpinner(size: 42)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Animated circular spinner with Moneta Aurora gradient
class AuroraSpinner extends StatefulWidget {
  final double size;
  final double strokeWidth;

  const AuroraSpinner({super.key, this.size = 42, this.strokeWidth = 4.2});

  @override
  State<AuroraSpinner> createState() => _AuroraSpinnerState();
}

class _AuroraSpinnerState extends State<AuroraSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _AuroraSpinnerPainter(strokeWidth: widget.strokeWidth),
      ),
    );
  }
}

class _AuroraSpinnerPainter extends CustomPainter {
  final double strokeWidth;

  const _AuroraSpinnerPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Subtle background ring
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFE2E8F0);
    canvas.drawCircle(center, radius, trackPaint);

    // Aurora gradient arc
    const sweepAngle = 1.55 * math.pi;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: 0.0,
        endAngle: sweepAngle,
        colors: [
          Color(0x1A2563EB),
          Color(0xFF2563EB),
          Color(0xFF51C5F7),
          Color(0xFF44E1CC),
          Color(0xFF34D399),
        ],
        stops: [0.0, 0.25, 0.55, 0.80, 1.0],
      ).createShader(rect);

    canvas.drawArc(rect, 0.15, sweepAngle - 0.15, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _AuroraSpinnerPainter oldDelegate) =>
      oldDelegate.strokeWidth != strokeWidth;
}

/// Primary call-to-action button with Luminous Glass Aurora styling (matching Add Transaction FAB)
class PrimaryGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final showGradient = onPressed != null || isLoading;
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: showGradient
            ? [
                BoxShadow(
                  color: AppColors.accentBlue.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GlassBlur(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: showGradient ? AppColors.luminousFabGradient : null,
              color: !showGradient
                  ? AppColors.inkMuted.withValues(alpha: 0.3)
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xB3FFFFFF), width: 1.5),
            ),
            child: CustomPaint(
              painter: showGradient
                  ? const RRectInsetGlassPainter(radius: Radius.circular(16))
                  : null,
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color: Color(0x33000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
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

/// Official looking Google Sign In Button with Frosted Glass surface
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0C0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GlassBlur(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xF0FFFFFF), Color(0x9EFFFFFF)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.3),
            ),
            child: OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGoogleIcon(),
                  const SizedBox(width: 12),
                  const Text(
                    "Lanjutkan dengan Google",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      child: const Image(
        image: NetworkImage(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
        ),
        width: 20,
        height: 20,
        errorBuilder: _fallbackIcon,
      ),
    );
  }

  static Widget _fallbackIcon(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 26);
  }
}

/// Or divider with custom text
class AuthDivider extends StatelessWidget {
  final String label;

  const AuthDivider({super.key, this.label = 'atau masuk dengan'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.inkMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}
