import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_buttons.dart' show RRectInsetGlassPainter;
import 'fun_widgets.dart' show GlassScope;

/// Premium Liquid Glass Modal Dialog
/// Replaces generic Material AlertDialogs with tactile frosted glass:
/// - Refractive frosted platter with top specular rim
/// - Deep contrast ink typography
/// - Micro-haptic tactile buttons
class AppGlassDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Widget? customIcon;
  final Color? iconColor;
  final String confirmLabel;
  final String cancelLabel;
  final bool showCancel;
  final bool isDestructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final List<Widget>? customActions;

  const AppGlassDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.customIcon,
    this.iconColor,
    this.confirmLabel = 'Konfirmasi',
    this.cancelLabel = 'Batal',
    this.showCancel = true,
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
    this.customActions,
  });

  /// Displays the glass dialog over a frosted barrier scrim.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Widget? customIcon,
    Color? iconColor,
    String confirmLabel = 'Konfirmasi',
    String cancelLabel = 'Batal',
    bool showCancel = true,
    bool isDestructive = false,
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.glassScrim,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AppGlassDialog(
        title: title,
        message: message,
        icon: icon,
        customIcon: customIcon,
        iconColor: iconColor,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        showCancel: showCancel,
        isDestructive: isDestructive,
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          onConfirm?.call();
        },
        onCancel: () {
          Navigator.of(ctx).pop(false);
          onCancel?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const radiusVal = 28.0;
    const r = Radius.circular(radiusVal);

    return GlassScope(
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        elevation: 0,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(r),
            boxShadow: AppColors.glassShadowSoft,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.glassSheetGradient,
                  borderRadius: const BorderRadius.all(r),
                  border: Border.all(
                    color: const Color(0xE6FFFFFF),
                    width: 1.5,
                  ),
                ),
                child: CustomPaint(
                  painter: const RRectInsetGlassPainter(
                    radius: r,
                    highlightColor: Color(0xE6FFFFFF),
                    shadowColor: Color(0x120F172A),
                    glowColor: Color(0x20FFFFFF),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon Badge (if provided)
                        if (customIcon != null) ...[
                          customIcon!,
                          const SizedBox(height: 16),
                        ] else if (icon != null) ...[
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: (iconColor ??
                                      (isDestructive
                                          ? AppColors.expense
                                          : AppColors.accentBlue))
                                  .withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.92),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (iconColor ??
                                          (isDestructive
                                              ? AppColors.expense
                                              : AppColors.accentBlue))
                                      .withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              icon,
                              size: 26,
                              color: iconColor ??
                                  (isDestructive
                                      ? AppColors.expense
                                      : AppColors.accentBlue),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Title
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Message
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Actions
                        if (customActions != null)
                          Row(children: customActions!)
                        else
                          Row(
                            children: [
                              // Cancel Button
                              if (showCancel) ...[
                                Expanded(
                                  child: Container(
                                    height: 46,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.glassCardGradient,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(999),
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(999),
                                        onTap: onCancel ??
                                            () => Navigator.of(context).pop(),
                                        child: Center(
                                          child: Text(
                                            cancelLabel,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.inkSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],

                              // Confirm Button
                              Expanded(
                                child: Container(
                                  height: 46,
                                  decoration: BoxDecoration(
                                    gradient: isDestructive
                                        ? const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFFB7185),
                                              Color(0xFFDC2626),
                                            ],
                                          )
                                        : AppColors.primaryButtonGradient,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0x80FFFFFF),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isDestructive
                                                ? AppColors.expense
                                                : AppColors.accentBlue)
                                            .withValues(alpha: 0.28),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(999),
                                      onTap: onConfirm,
                                      child: Center(
                                        child: Text(
                                          confirmLabel,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
    );
  }
}
