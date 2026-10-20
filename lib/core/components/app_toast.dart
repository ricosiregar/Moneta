import 'dart:async';
import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../theme/app_colors.dart';
import '../utils/app_error_formatter.dart';

enum ToastType { success, error, warning, info }

/// Modern, floating Top-of-Screen Toast notification system for Moneta.
/// Replaces standard bottom SnackBars with animated, top-positioned toasts.
class AppToast {
  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  /// Dismiss currently displayed toast if any
  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    if (_currentEntry != null) {
      try {
        _currentEntry?.remove();
      } catch (_) {}
      _currentEntry = null;
    }
  }

  /// Show a generic top toast
  static void show(
    BuildContext? context,
    String message, {
    ToastType type = ToastType.info,
    String? title,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    // If error type, ensure message is formatted cleanly
    final sanitizedMessage =
        type == ToastType.error ? AppErrorFormatter.format(message) : message;

    final targetOverlay = _resolveOverlay(context);
    if (targetOverlay == null) {
      debugPrint('[AppToast] Unable to find Overlay to show toast: $sanitizedMessage');
      return;
    }

    // Dismiss existing toast immediately
    dismiss();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopToastWidget(
        message: sanitizedMessage,
        type: type,
        title: title,
        onDismiss: () {
          if (_currentEntry == entry) {
            dismiss();
          }
        },
      ),
    );

    _currentEntry = entry;
    targetOverlay.insert(entry);

    _timer = Timer(duration, () {
      if (_currentEntry == entry) {
        dismiss();
      }
    });
  }

  /// Show a success top toast (Emerald theme)
  static void showSuccess(
    BuildContext? context,
    String message, {
    String? title,
  }) {
    show(
      context,
      message,
      type: ToastType.success,
      title: title ?? 'Berhasil',
    );
  }

  /// Show an error top toast (Rose/Coral theme) with automatic clean error formatting
  static void showError(
    BuildContext? context,
    dynamic error, {
    String? title,
  }) {
    final cleanMessage = AppErrorFormatter.format(error);
    show(
      context,
      cleanMessage,
      type: ToastType.error,
      title: title ?? 'Perhatian',
    );
  }

  /// Show a warning top toast (Amber theme)
  static void showWarning(
    BuildContext? context,
    String message, {
    String? title,
  }) {
    show(
      context,
      message,
      type: ToastType.warning,
      title: title ?? 'Pemberitahuan',
    );
  }

  /// Show an info top toast (Royal Blue theme)
  static void showInfo(
    BuildContext? context,
    String message, {
    String? title,
  }) {
    show(
      context,
      message,
      type: ToastType.info,
      title: title,
    );
  }

  static OverlayState? _resolveOverlay(BuildContext? context) {
    if (context != null && context.mounted) {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay != null) return overlay;
    }
    return rootNavigatorKey.currentState?.overlay;
  }
}

class _TopToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final String? title;
  final VoidCallback onDismiss;

  const _TopToastWidget({
    required this.message,
    required this.type,
    this.title,
    required this.onDismiss,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutBack,
    ));

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    ));

    _animCtrl.forward();
  }

  Future<void> _handleDismiss() async {
    await _animCtrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.income;
      case ToastType.error:
        return AppColors.expense;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.accentBlue;
    }
  }

  Color get _bgColor {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFFF0FDF4); // light emerald
      case ToastType.error:
        return const Color(0xFFFEF2F2); // light rose
      case ToastType.warning:
        return const Color(0xFFFFFBEB); // light amber
      case ToastType.info:
        return const Color(0xFFEFF6FF); // light blue
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: _animCtrl,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! < -4) {
                _handleDismiss();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _accentColor.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon badge with tinted background
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _accentColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _icon,
                        color: _accentColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.title != null) ...[
                          Text(
                            widget.title!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _accentColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkPrimary,
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Close button
                  GestureDetector(
                    onTap: _handleDismiss,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.inkMuted.withValues(alpha: 0.8),
                      ),
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
}
