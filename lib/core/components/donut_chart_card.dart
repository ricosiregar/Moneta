import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategorySliceData {
  final String name;
  final double percentage;
  final Color color;

  const CategorySliceData({
    required this.name,
    required this.percentage,
    required this.color,
  });
}

/// Category Donut Chart Card matching Gambar 1 reference:
/// - "PENGELUARAN PER KATEGORI" title in bold uppercase slate
/// - Circular donut ring chart on the left
/// - Category legend with percentage on the right
class CategoryDonutCard extends StatelessWidget {
  final List<CategorySliceData> slices;

  const CategoryDonutCard({
    super.key,
    required this.slices,
  });

  static const List<CategorySliceData> defaultSlices = [
    CategorySliceData(
      name: 'Lainnya',
      percentage: 0.66,
      color: Color(0xFF2563EB), // Blue
    ),
    CategorySliceData(
      name: 'Makanan',
      percentage: 0.18,
      color: Color(0xFF38BDF8), // Sky Cyan
    ),
    CategorySliceData(
      name: 'Transportasi',
      percentage: 0.14,
      color: Color(0xFF2DD4BF), // Bright Teal
    ),
    CategorySliceData(
      name: 'Minuman',
      percentage: 0.02,
      color: Color(0xFF10B981), // Emerald
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final displaySlices = slices.isNotEmpty ? slices : defaultSlices;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PENGELUARAN PER KATEGORI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.inkSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              // ── Left: Donut Chart Ring ──
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _DonutChartPainter(slices: displaySlices),
                ),
              ),

              const SizedBox(width: 24),

              // ── Right: Legend ──
              Expanded(
                child: Column(
                  children: displaySlices.map((slice) {
                    final pct = (slice.percentage * 100).round();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: slice.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              slice.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.inkPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategorySliceData> slices;

  const _DonutChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    const strokeWidth = 16.0;

    double startAngle = -pi / 2;

    for (final slice in slices) {
      if (slice.percentage <= 0) continue;
      final sweepAngle = slice.percentage * 2 * pi;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Small gap between slices
      const gapAngle = 0.08;
      final actualSweep = max(0.01, sweepAngle - gapAngle);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gapAngle / 2,
        actualSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
