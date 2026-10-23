import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_buttons.dart';

/// Tactile White Card matching MonTrack design specification:
/// Compact, pure white, large controlled corner radius (24px),
/// subtle border (slate-100/80), very soft shadow.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.borderRadius = 24,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ??
          Border.all(
            color: AppColors.border,
            width: 1,
          ),
      boxShadow: boxShadow ?? AppColors.cardShadow,
    );

    if (onTap != null) {
      final r = BorderRadius.circular(borderRadius);
      return Container(
        margin: margin,
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: r,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: r,
            customBorder: RoundedRectangleBorder(borderRadius: r),
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}

/// Frosted Glass Surface with backdrop blur filter & diagonal glass sheen
class AppGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final Gradient? gradient;
  final Border? border;
  final VoidCallback? onTap;

  const AppGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.borderRadius = 24,
    this.blur = 20.0,
    this.tintColor,
    this.gradient,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(borderRadius);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: AppColors.glassShadowSoft,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ??
                  (tintColor != null
                      ? null
                      : AppColors.glassCardGradient),
              color: tintColor,
              borderRadius: r,
              border: border ??
                  Border.all(
                    color: AppColors.glassBorder,
                    width: 1.2,
                  ),
            ),
            child: CustomPaint(
              painter: RRectInsetGlassPainter(
                radius: Radius.circular(borderRadius),
                highlightColor: const Color(0xE6FFFFFF),
                shadowColor: const Color(0x100F172A),
                glowColor: const Color(0x20FFFFFF),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: r,
                clipBehavior: Clip.antiAlias,
                child: onTap != null
                    ? InkWell(
                        onTap: onTap,
                        borderRadius: r,
                        customBorder: RoundedRectangleBorder(borderRadius: r),
                        child: Padding(
                          padding: padding ?? EdgeInsets.zero,
                          child: child,
                        ),
                      )
                    : Padding(
                        padding: padding ?? EdgeInsets.zero,
                        child: child,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Deep Slate Hero Card with soft dark gradient
class AppHeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const AppHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.margin,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppColors.heroSlateGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
