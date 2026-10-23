import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_buttons.dart' show RRectInsetGlassPainter;
import 'fun_widgets.dart' show GlassScope;

/// Premium Liquid Glass Bottom Sheet
/// Delivers an authentic iOS 26 frosted glass modal sheet:
/// - Refractive frosted acrylic base with specular top-edge highlight
/// - Ergonomic pill grab handle
/// - Inset specular lighting (rim highlight + ambient depth)
/// - Keyboard-aware padding & safe area integration
class AppGlassSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final double maxHeightFactor;
  final double borderRadius;

  const AppGlassSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding,
    this.maxHeightFactor = 0.9,
    this.borderRadius = 32.0,
  });

  /// Presents the bottom sheet with a frosted barrier scrim.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.glassScrim,
      useSafeArea: true,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final sheetRadius = Radius.circular(borderRadius);

    return GlassScope(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: sheetRadius),
          boxShadow: AppColors.glassSheetShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: sheetRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: media.size.height * maxHeightFactor,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.glassSheetGradient,
                borderRadius: BorderRadius.vertical(top: sheetRadius),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1.2,
                ),
              ),
              child: CustomPaint(
                painter: RRectInsetGlassPainter(
                  radius: sheetRadius,
                  highlightColor: const Color(0xE6FFFFFF),
                  shadowColor: const Color(0x100F172A),
                  glowColor: const Color(0x20FFFFFF),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.vertical(top: sheetRadius),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
                    child: SafeArea(
                      top: false,
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Frosted Grab Handle ──
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 8),
                            width: 38,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: AppColors.inkMuted.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.65),
                                width: 0.6,
                              ),
                            ),
                          ),
                        ),

                        // ── Header (Title & Subtitle) if provided ──
                        if (title != null) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        title!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                          color: AppColors.inkPrimary,
                                        ),
                                      ),
                                      if (subtitle != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          subtitle!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.inkSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (trailing != null) trailing!,
                              ],
                            ),
                          ),
                        ],

                        // ── Body ──
                        Flexible(
                          child: Padding(
                            padding: padding ??
                                const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: child,
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
      ),
    ),
  );
  }
}
