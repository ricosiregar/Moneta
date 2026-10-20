import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import 'app_buttons.dart';

/// Modern Pastel Aurora Header matching MonTrack design rules:
/// - Aurora gradient background (mint/sky/blue)
/// - Top utility buttons (Avatar, Search, Sync/Refresh)
/// - Date / eyebrow text
/// - Time-based greeting with authenticated user name
class AuroraHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSyncTap;
  final bool isSyncing;
  final Widget? trailing;

  /// Widget shown at the left of the app bar row (e.g. tab switcher).
  final Widget? leading;

  /// When set, replaces the date + greeting with a custom title.
  final String? eyebrow;
  final String? headline;

  /// Small glass chips shown under the headline (budget / piggo summary).
  final List<String>? badges;

  const AuroraHeader({
    super.key,
    required this.userName,
    this.onProfileTap,
    this.onSearchTap,
    this.onSyncTap,
    this.isSyncing = false,
    this.trailing,
    this.leading,
    this.eyebrow,
    this.headline,
    this.badges,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get _dateString {
    final now = DateTime.now();
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    } catch (_) {
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      final dayName = days[(now.weekday - 1) % 7];
      final monthName = months[(now.month - 1) % 12];
      return '$dayName, ${now.day} $monthName ${now.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawName = userName.trim().isNotEmpty ? userName.trim() : 'Kawan';
    final name = rawName.split(RegExp(r'\s+')).first;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.auroraHeaderGradient),
      child: ClipRect(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Tabs (left) + reload (right) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        leading ?? const SizedBox(height: 44),
                        if (onSyncTap != null)
                          AppGlassIconButton(
                            onTap: onSyncTap,
                            tooltip: 'Sinkronisasi Data',
                            child: AnimatedRotation(
                              turns: isSyncing ? 1.0 : 0.0,
                              duration: const Duration(seconds: 1),
                              child: Icon(
                                Icons.sync_rounded,
                                size: 20,
                                color: isSyncing
                                    ? AppColors.accentBlue
                                    : AppColors.inkPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Fixed-height text block so the header never jumps
                    // between tabs.
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 74),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            eyebrow ?? _dateString,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (headline != null)
                            Text(
                              headline!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: AppColors.inkPrimary,
                              ),
                            )
                          else
                            Text.rich(
                              TextSpan(
                                text: '$_greeting, ',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.4,
                                  color: AppColors.inkPrimary,
                                ),
                                children: [
                                  TextSpan(
                                    text: name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      color: AppColors.inkPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (headline != null && badges != null) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              children: [
                                for (final b in badges!) _HeaderBadge(b),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String text;
  const _HeaderBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.inkPrimary,
        ),
      ),
    );
  }
}
