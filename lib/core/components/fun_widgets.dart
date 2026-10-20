import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_buttons.dart' show RRectInsetGlassPainter;

/// Shared UI primitives mirroring the React (mon-track) design:
/// white "fun-card", monochrome slate text, aurora only for active states.

const List<Color> kChartColors = [
  Color(0xFF2563EB),
  Color(0xFF51C5F7),
  Color(0xFF44E1CC),
  Color(0xFF34D399),
  Color(0xFF38BDF8),
  Color(0xFF10B981),
  Color(0xFF2DD4BF),
  Color(0xFF60A5FA),
];

String fmtRp(num amount, {bool sign = false}) {
  final negative = amount < 0;
  final raw = amount.abs().round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < raw.length; i++) {
    if (i > 0 && (raw.length - i) % 3 == 0) buf.write('.');
    buf.write(raw[i]);
  }
  final prefix = negative ? '-' : (sign ? '+' : '');
  return '${prefix}Rp$buf';
}

class FunCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  const FunCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final glass = GlassScope.of(context);
    final radius = BorderRadius.circular(24);
    final r = const Radius.circular(24);

    return Container(
      width: double.infinity,
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: glass
            ? AppColors.glassCardGradient
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFFBFDFF)],
              ),
        border: Border.all(
          color: glass ? AppColors.glassBorder : const Color(0xCCE2E8F0),
          width: 1.2,
        ),
        boxShadow: glass ? AppColors.glassShadowSoft : AppColors.cardShadow,
      ),
      child: CustomPaint(
        painter: glass
            ? RRectInsetGlassPainter(
                radius: r,
                highlightColor: const Color(0xE6FFFFFF),
                shadowColor: const Color(0x100F172A),
                glowColor: const Color(0x20FFFFFF),
              )
            : null,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: clipBehavior,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Marks a subtree as "glass": cards, chips and badges render as frosted
/// translucent surfaces (no BackdropFilter, so scrolling stays smooth).
class GlassScope extends InheritedWidget {
  const GlassScope({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassScope>() != null;

  @override
  bool updateShouldNotify(GlassScope oldWidget) => false;
}

/// Full-page glassmorphism backdrop: pastel aurora gradient + soft color blobs,
/// with [GlassScope] so every FunCard/pill/badge inside renders as frosted glass.
class GlassPage extends StatelessWidget {
  final Widget child;
  final bool bottom;
  const GlassPage({super.key, required this.child, this.bottom = true});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE0F2FE),
            Color(0xFFEDE9FE),
            Color(0xFFF0FDF4),
            AppColors.canvas,
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          const _Blob(top: -40, left: -70, color: Color(0xFF86EFAC)),
          const _Blob(top: 240, right: -80, color: Color(0xFFA5B4FC)),
          const _Blob(top: 520, left: -60, color: Color(0xFF7DD3FC)),
          Positioned.fill(
            child: GlassScope(
              child: SafeArea(bottom: bottom, child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final Color color;
  const _Blob({this.top, this.left, this.right, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.45),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Translucent fill used for small surfaces inside a [GlassScope].
Color glassFill(BuildContext context, {Color normal = AppColors.surfaceRaised}) =>
    GlassScope.of(context) ? Colors.white.withValues(alpha: 0.6) : normal;

class FunLabel extends StatelessWidget {
  final String text;
  final IconData? icon;
  const FunLabel(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: AppColors.inkMuted),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: AppColors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class IconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  final double radius;
  final double iconSize;
  final Color? color;
  const IconBox(
    this.icon, {
    super.key,
    this.size = 36,
    this.radius = 12,
    this.iconSize = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: glassFill(context),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: iconSize, color: color ?? AppColors.inkSecondary),
    );
  }
}

/// Round slate-100 icon button (e.g. "+" and filters).
class FunRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  const FunRoundButton(this.icon, {super.key, this.onTap, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: glassFill(context),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.inkSecondary),
          ),
        ),
      ),
    );
  }
}

/// Active aurora pill decoration (React `aurora-glass-active`).
BoxDecoration auroraActiveDecoration({double radius = 999}) => BoxDecoration(
      gradient: AppColors.luminousFabGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xB3FFFFFF), width: 1.5),
    );

class FunPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool expand;
  const FunPill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.inkSecondary;
    final shadows = selected
        ? const [
            Shadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 1)),
          ]
        : null;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: fg, shadows: shadows),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
              shadows: shadows,
            ),
          ),
        ),
      ],
    );
    final child = Container(
      height: 36,
      alignment: Alignment.center,
      decoration: selected
          ? auroraActiveDecoration()
          : BoxDecoration(
              color: glassFill(context, normal: Colors.white),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: GlassScope.of(context)
                    ? const Color(0xB3FFFFFF)
                    : const Color(0xCCE2E8F0),
                width: GlassScope.of(context) ? 1.5 : 1,
              ),
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: CustomPaint(
          painter: RRectInsetGlassPainter(
            radius: const Radius.circular(9999),
            highlightColor:
                selected ? const Color(0xD9FFFFFF) : const Color(0xE6FFFFFF),
            shadowColor:
                selected ? const Color(0x33000000) : const Color(0x14000000),
            glowColor:
                selected ? const Color(0x40FFFFFF) : const Color(0x26FFFFFF),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(child: row),
          ),
        ),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: expand ? SizedBox(width: double.infinity, child: child) : child,
    );
  }
}

/// Segmented switcher (slate-100 track, aurora active).
class FunTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const FunTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: glassFill(context, normal: const Color(0xE6F1F5F9)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 32,
                alignment: Alignment.center,
                decoration: i == selected ? auroraActiveDecoration() : null,
                child: CustomPaint(
                  painter: i == selected
                      ? const RRectInsetGlassPainter(
                          radius: Radius.circular(9999),
                        )
                      : null,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: i == selected
                            ? Colors.white
                            : AppColors.inkSecondary,
                        shadows: i == selected
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
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FunPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  const FunPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.inkPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class FunBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  const FunBadge(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: glassFill(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.inkSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class MoneyText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  const MoneyText(
    this.text, {
    super.key,
    this.size = 16,
    this.weight = FontWeight.w800,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: -0.5,
          color: AppColors.inkPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ── Charts ──────────────────────────────────────────────────────────────────

class DonutChart extends StatelessWidget {
  final List<double> values;
  final List<Color>? colors;
  final double size;
  final double innerRatio;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;
  final Widget? center;

  const DonutChart({
    super.key,
    required this.values,
    this.colors,
    this.size = 112,
    this.innerRatio = 0.62,
    this.selectedIndex,
    this.onSelect,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('${values.toString()}_${colors?.length}_$selectedIndex'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        return GestureDetector(
          onTapUp: onSelect == null
              ? null
              : (details) {
                  final total = values.fold<double>(0, (a, b) => a + b);
                  if (total <= 0) return;
                  final centerOffset = Offset(size / 2, size / 2);
                  final dx = details.localPosition.dx - centerOffset.dx;
                  final dy = details.localPosition.dy - centerOffset.dy;
                  final dist = math.sqrt(dx * dx + dy * dy);
                  final outer = size / 2;
                  final inner = outer * innerRatio;
                  if (dist < inner) {
                    onSelect!(-1);
                    return;
                  }
                  if (dist > outer * 1.3) return;

                  var angle = math.atan2(dy, dx) - (-math.pi / 2);
                  if (angle < 0) angle += 2 * math.pi;

                  double start = 0;
                  for (int i = 0; i < values.length; i++) {
                    final sweep = values[i] / total * 2 * math.pi;
                    if (angle >= start && angle <= start + sweep) {
                      onSelect!(i);
                      break;
                    }
                    start += sweep;
                  }
                },
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: _DonutPainter(
                    values,
                    innerRatio,
                    colors: colors,
                    progress: progress,
                    selectedIndex: selectedIndex,
                  ),
                ),
                if (center != null)
                  SizedBox(
                    width: size * innerRatio * 0.9,
                    height: size * innerRatio * 0.9,
                    child: Center(child: center!),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final double innerRatio;
  final List<Color>? colors;
  final double progress;
  final int? selectedIndex;

  _DonutPainter(
    this.values,
    this.innerRatio, {
    this.colors,
    this.progress = 1.0,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    final c = size.center(Offset.zero);
    final outer = size.width / 2;
    final stroke = outer * (1 - innerRatio);
    final rect = Rect.fromCircle(center: c, radius: outer - stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    if (total <= 0) {
      p.color = AppColors.surfaceRaised;
      canvas.drawArc(rect, 0, math.pi * 2, false, p);
      return;
    }
    const gap = 3 * math.pi / 180;
    double start = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final isSelected = selectedIndex == i;
      final sweep = (values[i] / total * math.pi * 2) * progress;
      final baseColor = colors != null && i < colors!.length
          ? colors![i]
          : kChartColors[i % kChartColors.length];

      if (selectedIndex != null && !isSelected && colors == null) {
        p.color = baseColor.withValues(alpha: 0.28);
      } else {
        p.color = baseColor;
      }

      p.strokeWidth = isSelected ? stroke + 4 : stroke;
      final effectiveRect = isSelected
          ? Rect.fromCircle(center: c, radius: outer - (stroke + 4) / 2 + 1)
          : rect;
      canvas.drawArc(
          effectiveRect, start + gap / 2, math.max(0.01, sweep - gap), false, p);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values ||
      old.innerRatio != innerRatio ||
      old.colors != colors ||
      old.progress != progress ||
      old.selectedIndex != selectedIndex;
}

class BarChartSimple extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double height;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;

  const BarChartSimple({
    super.key,
    required this.values,
    required this.labels,
    this.height = 176,
    this.selectedIndex,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(values.toString()),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        return GestureDetector(
          onTapUp: onSelect == null
              ? null
              : (details) {
                  if (values.isEmpty) return;
                  final slot = (context.size?.width ?? 0) / values.length;
                  if (slot <= 0) return;
                  final idx = (details.localPosition.dx / slot).floor();
                  if (idx >= 0 && idx < values.length) {
                    onSelect!(idx);
                  }
                },
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: CustomPaint(
              painter: _BarPainter(
                values,
                labels,
                progress: progress,
                selectedIndex: selectedIndex,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double progress;
  final int? selectedIndex;

  _BarPainter(
    this.values,
    this.labels, {
    this.progress = 1.0,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const labelH = 18.0;
    final chartH = size.height - labelH;
    final grid = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final y = chartH * i / 3;
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(
            Offset(x, y), Offset(math.min(x + 4, size.width), y), grid);
        x += 8;
      }
    }
    if (values.isEmpty) return;
    final maxV = values.reduce(math.max);
    final slot = size.width / values.length;
    final barW = math.min(slot * 0.62, 22.0);
    final step = values.length > 12 ? (values.length / 6).ceil() : 1;
    for (int i = 0; i < values.length; i++) {
      final isSelected = selectedIndex == i;
      final h = maxV <= 0 ? 0.0 : (values[i] / maxV * chartH) * progress;
      final x = slot * i + (slot - barW) / 2;
      final rect = Rect.fromLTWH(x, chartH - h, barW, math.max(h, 2));
      final paint = Paint()
        ..shader = (isSelected
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                  Color(0xFFA855F7),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF51C5F7),
                  Color(0xFF44E1CC),
                  Color(0xFF34D399),
                ],
              ))
            .createShader(Rect.fromLTWH(x, 0, barW, chartH));
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        paint,
      );
      if (i % step == 0 && i < labels.length) {
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.inkPrimary : AppColors.inkMuted,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + barW / 2 - tp.width / 2, chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.values != values ||
      old.labels != labels ||
      old.progress != progress ||
      old.selectedIndex != selectedIndex;
}
