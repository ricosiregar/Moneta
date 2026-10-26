import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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

// ignore: deprecated_member_use
final Pattern _nonDigitPattern = RegExp(r'[^\d]');
// ignore: deprecated_member_use
final Pattern _leadingZerosPattern = RegExp(r'^0+(?=\d)');
// ignore: deprecated_member_use
final Pattern _thousandsPattern = RegExp(r'\B(?=(\d{3})+(?!\d))');
// ignore: deprecated_member_use
final Pattern _dateMonthYearPattern = RegExp(r'^(\d{2})(\d{2})(\d{1,4})$');
// ignore: deprecated_member_use
final Pattern _dateMonthPattern = RegExp(r'^(\d{2})(\d{1,2})$');
// ignore: deprecated_member_use
final Pattern _compactDateParsePattern = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
// ignore: deprecated_member_use
final Pattern _rawDigitsDateParsePattern = RegExp(r'^(\d{2})(\d{2})(\d{4})$');
// ignore: deprecated_member_use
final Pattern _nonDecimalPattern = RegExp(r'[^\d.,]');

/// Memformat angka menjadi string ribuan dengan titik menggunakan RegExp (contoh: 1500000 -> 1.500.000).
String fmtThousands(num amount) {
  final raw = amount.abs().round().toString();
  return raw.replaceAllMapped(_thousandsPattern, (_) => '.');
}

/// Memformat teks input nominal uang dengan RegExp pemisah ribuan.
String formatMoneyString(String input) {
  final digits = input.replaceAll(_nonDigitPattern, '');
  if (digits.isEmpty) return '';
  final normalized = digits.replaceFirst(_leadingZerosPattern, '');
  return normalized.replaceAllMapped(_thousandsPattern, (_) => '.');
}

/// Mengurai string nominal uang berformat ribuan menjadi nilai double.
double parseMoney(String input) {
  final digits = input.replaceAll(_nonDigitPattern, '');
  if (digits.isEmpty) return 0;
  return double.tryParse(digits) ?? 0;
}

/// TextInputFormatter berbasis RegExp untuk semua input nominal uang.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatMoneyString(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// TextInputFormatter berbasis RegExp untuk input angka/persentase desimal.
class DecimalInputFormatter extends TextInputFormatter {
  const DecimalInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(_nonDecimalPattern, '');
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}

/// Memformat teks input tanggal angka menggunakan RegExp menjadi DD/MM/YYYY
/// (contoh: 11092026 -> 11/09/2026).
String formatDateString(String input) {
  var digits = input.replaceAll(_nonDigitPattern, '');
  if (digits.isEmpty) return '';
  if (digits.length > 8) {
    digits = digits.substring(0, 8);
  }
  if (digits.length >= 5) {
    return digits.replaceFirstMapped(
      _dateMonthYearPattern,
      (m) => '${m[1]}/${m[2]}/${m[3]}',
    );
  }
  if (digits.length >= 3) {
    return digits.replaceFirstMapped(
      _dateMonthPattern,
      (m) => '${m[1]}/${m[2]}',
    );
  }
  return digits;
}

/// Mengurai string tanggal berformat DD/MM/YYYY atau DDMMYYYY menjadi [DateTime].
DateTime? parseDateString(String? inputString) {
  if (inputString == null) return null;
  final trimmed = inputString.trim();
  Match? match = _compactDateParsePattern.matchAsPrefix(trimmed);
  match ??= _rawDigitsDateParsePattern.matchAsPrefix(
    trimmed.replaceAll(_nonDigitPattern, ''),
  );
  if (match == null) return null;
  final day = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final year = int.tryParse(match.group(3)!);
  if (day == null || month == null || year == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  final result = DateTime(year, month, day);
  if (result.year != year || result.month != month || result.day != day) {
    return null;
  }
  return result;
}

/// TextInputFormatter berbasis RegExp untuk input tanggal manual (DD/MM/YYYY).
class DateInputFormatter extends TextInputFormatter {
  const DateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatDateString(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Pembungkus dialog DatePicker / DateRangePicker yang otomatis memasang
/// RegExp formatter DD/MM/YYYY (mis. ketik 11092026 -> 11/09/2026) pada mode
/// input tanggal manual di kalender.
class AppDatePickerWrapper extends StatefulWidget {
  final Widget child;
  const AppDatePickerWrapper({super.key, required this.child});

  @override
  State<AppDatePickerWrapper> createState() => _AppDatePickerWrapperState();
}

class _AppDatePickerWrapperState extends State<AppDatePickerWrapper> {
  final Map<TextEditingController, VoidCallback> _attachedControllers = {};
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocusChanged);
    _scheduleScan();
  }

  void _onFocusChanged() {
    _scheduleScan();
  }

  void _scheduleScan() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scanAndAttach(context);
    });
  }

  void _scanAndAttach(BuildContext rootContext) {
    void visitor(Element element) {
      if (element is StatefulElement && element.state is EditableTextState) {
        final editableState = element.state as EditableTextState;
        final controller = editableState.widget.controller;
        if (!_attachedControllers.containsKey(controller)) {
          void listener() {
            if (_isFormatting) return;
            final raw = controller.text;
            if (raw.isEmpty) return;
            final formatted = formatDateString(raw);
            if (formatted != raw) {
              _isFormatting = true;
              try {
                final newValue = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(
                    offset: formatted.length,
                  ),
                );
                if (editableState.mounted) {
                  editableState.userUpdateTextEditingValue(
                    newValue,
                    SelectionChangedCause.keyboard,
                  );
                } else {
                  controller.value = newValue;
                }
              } finally {
                _isFormatting = false;
              }
            }
          }

          controller.addListener(listener);
          _attachedControllers[controller] = listener;
        }
      }
      element.visitChildren(visitor);
    }

    rootContext.visitChildElements(visitor);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChanged);
    for (final entry in _attachedControllers.entries) {
      entry.key.removeListener(entry.value);
    }
    _attachedControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleScan();
    return Localizations.override(
      context: context,
      delegates: const [_IdDateMaterialLocalizationsDelegate()],
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _scheduleScan(),
        onPointerUp: (_) => _scheduleScan(),
        child: widget.child,
      ),
    );
  }
}

class _IdDateMaterialLocalizations extends DefaultMaterialLocalizations {
  const _IdDateMaterialLocalizations();

  @override
  String get dateHelpText => 'dd/mm/yyyy';

  @override
  String get dateInputLabel => 'Masukkan tanggal';

  @override
  String get dateRangeStartLabel => 'Tanggal mulai';

  @override
  String get dateRangeEndLabel => 'Tanggal akhir';

  @override
  String get invalidDateFormatLabel => 'Format tidak valid (dd/mm/yyyy)';

  @override
  String get invalidDateRangeLabel => 'Rentang tanggal tidak valid';

  @override
  String get dateOutOfRangeLabel => 'Tanggal di luar rentang';

  @override
  String formatCompactDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  @override
  DateTime? parseCompactDate(String? inputString) =>
      parseDateString(inputString);
}

class _IdDateMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _IdDateMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
        const _IdDateMaterialLocalizations(),
      );

  @override
  bool shouldReload(_IdDateMaterialLocalizationsDelegate old) => false;
}

String fmtRp(num amount, {bool sign = false}) {
  final negative = amount < 0;
  final formatted = fmtThousands(amount);
  final prefix = negative ? '-' : (sign ? '+' : '');
  return '${prefix}Rp$formatted';
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
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final glass = GlassScope.of(context);
    final radius = BorderRadius.circular(24);
    final r = const Radius.circular(24);
    final effectiveClip =
        clipBehavior == Clip.none ? Clip.antiAlias : clipBehavior;

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
          clipBehavior: effectiveClip,
          child: onTap != null
              ? InkWell(
                  borderRadius: radius,
                  customBorder: RoundedRectangleBorder(borderRadius: radius),
                  onTap: onTap,
                  child: Padding(padding: padding, child: child),
                )
              : Padding(padding: padding, child: child),
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

/// Vector icon berbentuk Ayam / Celengan Ayam dengan gaya garis (outline)
/// yang serasi dengan Material Outlined Icons.
class ChickenBankIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ChickenBankIcon({
    super.key,
    this.size = 20,
    this.color = AppColors.inkSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ChickenBankPainter(color: color),
    );
  }
}

class _ChickenBankPainter extends CustomPainter {
  final Color color;
  const _ChickenBankPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.85 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Siluet badan & kepala ayam (menghadap ke kiri, ekor melengkung di kanan)
    final body = Path()
      ..moveTo(6.0 * s, 12.2 * s)
      // Leher & kepala bulat
      ..cubicTo(5.8 * s, 9.2 * s, 6.6 * s, 6.8 * s, 8.8 * s, 6.8 * s)
      ..cubicTo(10.5 * s, 6.8 * s, 11.2 * s, 8.2 * s, 11.6 * s, 9.6 * s)
      // Punggung celengan
      ..lineTo(16.2 * s, 9.6 * s)
      // Ekor ayam melengkung ke atas kanan
      ..cubicTo(17.8 * s, 9.4 * s, 19.2 * s, 7.6 * s, 20.4 * s, 6.8 * s)
      ..cubicTo(21.2 * s, 9.5 * s, 20.6 * s, 13.0 * s, 19.0 * s, 15.0 * s)
      // Perut membulat di bawah
      ..cubicTo(17.0 * s, 17.6 * s, 11.5 * s, 18.0 * s, 8.2 * s, 16.0 * s)
      ..cubicTo(6.6 * s, 15.0 * s, 6.1 * s, 13.6 * s, 6.0 * s, 12.2 * s)
      ..close();
    canvas.drawPath(body, stroke);

    // Jengger (mahkota ayam di atas kepala)
    final comb = Path()
      ..moveTo(7.4 * s, 6.9 * s)
      ..quadraticBezierTo(7.6 * s, 4.0 * s, 8.9 * s, 5.4 * s)
      ..quadraticBezierTo(10.2 * s, 3.8 * s, 10.6 * s, 7.1 * s);
    canvas.drawPath(comb, stroke);

    // Paruh ayam di kiri kepala
    final beak = Path()
      ..moveTo(6.0 * s, 8.7 * s)
      ..lineTo(3.2 * s, 9.9 * s)
      ..lineTo(5.9 * s, 11.0 * s);
    canvas.drawPath(beak, stroke);

    // Mata ayam
    canvas.drawCircle(Offset(8.4 * s, 9.2 * s), 1.05 * s, fill);

    // Sayap lengkung di tengah badan
    final wing = Path()
      ..moveTo(11.0 * s, 12.2 * s)
      ..cubicTo(11.2 * s, 14.6 * s, 14.8 * s, 14.8 * s, 15.8 * s, 12.5 * s);
    canvas.drawPath(wing, stroke);

    // Koin kecil di punggung celengan ayam
    final coin = Path()
      ..moveTo(12.3 * s, 9.5 * s)
      ..arcToPoint(
        Offset(15.5 * s, 9.5 * s),
        radius: Radius.circular(1.6 * s),
        clockwise: true,
      );
    canvas.drawPath(coin, stroke);

    // Kaki ayam
    canvas.drawLine(
      Offset(11.4 * s, 17.2 * s),
      Offset(10.8 * s, 20.2 * s),
      stroke,
    );
    canvas.drawLine(
      Offset(14.8 * s, 17.2 * s),
      Offset(15.4 * s, 20.2 * s),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ChickenBankPainter oldDelegate) =>
      oldDelegate.color != color;
}

class IconBox extends StatelessWidget {
  final IconData? icon;
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

  const IconBox.chicken({
    super.key,
    this.size = 36,
    this.radius = 12,
    this.iconSize = 18,
    this.color,
  }) : icon = null;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.inkSecondary;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: glassFill(context),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: icon != null
          ? Icon(icon, size: iconSize, color: effectiveColor)
          : ChickenBankIcon(size: iconSize, color: effectiveColor),
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
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
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
            child: row,
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
                decoration: i == selected ? auroraActiveDecoration() : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: CustomPaint(
                    painter: i == selected
                        ? const RRectInsetGlassPainter(
                            radius: Radius.circular(9999),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Center(
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
  final Color? color;
  const FunBadge(this.text, {super.key, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.inkSecondary;
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
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
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
    final colorsSig = colors?.map((c) => c.toARGB32()).join(',') ?? '';
    return TweenAnimationBuilder<double>(
      key: ValueKey('${values.toString()}_${colorsSig}_$selectedIndex'),
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

// ── Dynamic Position Dropdown ───────────────────────────────────────────────

/// Pengganti [DropdownButton] yang otomatis menutup keyboard saat diklik dan
/// memperbarui posisi popup menu secara real-time mengikuti pergerakan tombol
/// (misalnya ketika bottom sheet turun saat keyboard tertutup).
class AppDropdownButton<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final ValueChanged<T?>? onChanged;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final Widget? icon;
  final Widget? hint;
  final TextStyle? style;

  const AppDropdownButton({
    super.key,
    this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = false,
    this.padding,
    this.borderRadius,
    this.dropdownColor,
    this.menuMaxHeight,
    this.icon,
    this.hint,
    this.style,
  });

  @override
  State<AppDropdownButton<T>> createState() => _AppDropdownButtonState<T>();
}

class _AppDropdownButtonState<T> extends State<AppDropdownButton<T>> {
  bool get _enabled =>
      widget.items != null &&
      widget.items!.isNotEmpty &&
      widget.onChanged != null;

  void _handleTap() {
    final items = widget.items;
    if (!_enabled || items == null) return;

    // Tutup keyboard aktif terlebih dahulu agar modal bergerak ke posisi normal
    // dan popup menu ikut mengikuti posisi tombol secara dinamis.
    FocusManager.instance.primaryFocus?.unfocus();

    final navigator = Navigator.of(context);
    final overlayBox =
        navigator.overlay?.context.findRenderObject() as RenderBox?;
    final buttonBox = context.findRenderObject() as RenderBox?;
    if (buttonBox == null || !buttonBox.hasSize) return;

    final initialRect =
        buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox) &
            buttonBox.size;

    final effectiveStyle = widget.style ??
        Theme.of(context).textTheme.titleMedium ??
        const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.inkPrimary,
        );

    navigator
        .push<_AppDropdownResult<T>>(
          _AppDropdownRoute<T>(
            buttonContext: context,
            initialButtonRect: initialRect,
            items: items,
            selectedValue: widget.value,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            dropdownColor: widget.dropdownColor ?? Colors.white,
            menuMaxHeight: widget.menuMaxHeight,
            style: effectiveStyle,
          ),
        )
        .then((result) {
          if (!mounted || result == null) return;
          widget.onChanged?.call(result.value);
        });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ??
        Theme.of(context).textTheme.titleMedium ??
        const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.inkPrimary,
        );

    DropdownMenuItem<T>? selectedItem;
    final items = widget.items;
    if (items != null && widget.value != null) {
      for (final item in items) {
        if (item.value == widget.value) {
          selectedItem = item;
          break;
        }
      }
    }

    final Widget displayChild = selectedItem != null
        ? DefaultTextStyle(
            style: effectiveStyle,
            child: selectedItem.child,
          )
        : DefaultTextStyle(
            style: effectiveStyle.copyWith(color: AppColors.inkMuted),
            child: widget.hint ?? const SizedBox.shrink(),
          );

    final Widget iconWidget = IconTheme.merge(
      data: IconThemeData(
        color: _enabled ? AppColors.inkSecondary : AppColors.inkMuted,
        size: 24,
      ),
      child: widget.icon ?? const Icon(Icons.arrow_drop_down),
    );

    Widget result = SizedBox(
      height: kMinInteractiveDimension,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (widget.isExpanded)
            Expanded(child: displayChild)
          else
            Flexible(child: displayChild),
          const SizedBox(width: 4),
          iconWidget,
        ],
      ),
    );

    if (widget.padding != null) {
      result = Padding(padding: widget.padding!, child: result);
    }

    return Semantics(
      button: true,
      child: InkWell(
        onTap: _enabled ? _handleTap : null,
        borderRadius: widget.borderRadius,
        child: result,
      ),
    );
  }
}

class _AppDropdownResult<T> {
  final T? value;
  const _AppDropdownResult(this.value);
}

class _AppDropdownRoute<T> extends PopupRoute<_AppDropdownResult<T>> {
  final BuildContext buttonContext;
  final Rect initialButtonRect;
  final List<DropdownMenuItem<T>> items;
  final T? selectedValue;
  final BorderRadius borderRadius;
  final Color dropdownColor;
  final double? menuMaxHeight;
  final TextStyle style;

  _AppDropdownRoute({
    required this.buttonContext,
    required this.initialButtonRect,
    required this.items,
    required this.selectedValue,
    required this.borderRadius,
    required this.dropdownColor,
    required this.menuMaxHeight,
    required this.style,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 180);

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _AppDropdownMenuPage<T>(
      route: this,
      animation: animation,
    );
  }
}

class _AppDropdownMenuPage<T> extends StatefulWidget {
  final _AppDropdownRoute<T> route;
  final Animation<double> animation;

  const _AppDropdownMenuPage({
    required this.route,
    required this.animation,
  });

  @override
  State<_AppDropdownMenuPage<T>> createState() =>
      _AppDropdownMenuPageState<T>();
}

class _AppDropdownMenuPageState<T> extends State<_AppDropdownMenuPage<T>>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final ValueNotifier<Rect> _buttonRectNotifier =
      ValueNotifier<Rect>(widget.route.initialButtonRect);
  late final Ticker _ticker;
  int _trackUntilMs = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick);
    _extendTracking(1200);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncButtonRect());
  }

  @override
  void didChangeMetrics() {
    _extendTracking(800);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncButtonRect());
  }

  void _extendTracking(int durationMs) {
    final target = DateTime.now().millisecondsSinceEpoch + durationMs;
    if (target > _trackUntilMs) {
      _trackUntilMs = target;
    }
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    _syncButtonRect();
    if (DateTime.now().millisecondsSinceEpoch > _trackUntilMs) {
      _ticker.stop();
    }
  }

  void _syncButtonRect() {
    if (!mounted) return;
    final btnCtx = widget.route.buttonContext;
    if (!btnCtx.mounted) return;
    try {
      final pageObj = context.findRenderObject();
      final buttonObj = btnCtx.findRenderObject();
      if (pageObj is RenderBox &&
          pageObj.attached &&
          pageObj.hasSize &&
          buttonObj is RenderBox &&
          buttonObj.attached &&
          buttonObj.hasSize) {
        final nextRect =
            buttonObj.localToGlobal(Offset.zero, ancestor: pageObj) &
                buttonObj.size;
        if (nextRect != _buttonRectNotifier.value) {
          _buttonRectNotifier.value = nextRect;
        }
      }
    } catch (_) {
      // Abaikan jika sedang di tengah transisi layout frame.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _buttonRectNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final curved = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: CustomSingleChildLayout(
        delegate: _AppDropdownLayoutDelegate(
          buttonRectListenable: _buttonRectNotifier,
          menuMaxHeight: widget.route.menuMaxHeight,
          viewPadding: media.padding,
        ),
        child: FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            alignment: Alignment.topCenter,
            child: Material(
              color: widget.route.dropdownColor,
              elevation: 10,
              shadowColor: const Color(0x280F172A),
              shape: RoundedRectangleBorder(
                borderRadius: widget.route.borderRadius,
                side: const BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int index = 0;
                        index < widget.route.items.length;
                        index++)
                      Builder(
                        builder: (context) {
                          final item = widget.route.items[index];
                          final isSelected =
                              item.value == widget.route.selectedValue;
                          return InkWell(
                            onTap: item.enabled
                                ? () {
                                    item.onTap?.call();
                                    Navigator.of(context).pop(
                                      _AppDropdownResult<T>(item.value),
                                    );
                                  }
                                : null,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              alignment: item.alignment,
                              color: isSelected
                                  ? AppColors.accentBlue.withValues(alpha: 0.08)
                                  : null,
                              child: DefaultTextStyle(
                                style: widget.route.style,
                                child: item.child,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppDropdownLayoutDelegate extends SingleChildLayoutDelegate {
  final ValueNotifier<Rect> buttonRectListenable;
  final double? menuMaxHeight;
  final EdgeInsets viewPadding;

  _AppDropdownLayoutDelegate({
    required this.buttonRectListenable,
    required this.menuMaxHeight,
    required this.viewPadding,
  }) : super(relayout: buttonRectListenable);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final buttonRect = buttonRectListenable.value;
    final maxAllowedWidth = math.max(0.0, constraints.maxWidth - 16.0);
    final double width = buttonRect.width
        .clamp(
          math.min(120.0, maxAllowedWidth),
          maxAllowedWidth,
        )
        .toDouble();
    final availableHeight = math.max(
      120.0,
      constraints.maxHeight - viewPadding.top - viewPadding.bottom - 24.0,
    );
    final maxHeight = math.min(
      constraints.maxHeight,
      menuMaxHeight != null
          ? math.min(menuMaxHeight!, availableHeight)
          : math.min(300.0, availableHeight),
    );
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: math.max(0.0, maxHeight),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final buttonRect = buttonRectListenable.value;
    final double left = buttonRect.left.clamp(
      8.0,
      math.max(8.0, size.width - childSize.width - 8.0),
    );

    final double topLimit = viewPadding.top + 8.0;
    final double bottomLimit = math.max(
      topLimit,
      size.height - viewPadding.bottom - childSize.height - 8.0,
    );
    final double top = buttonRect.top.clamp(topLimit, bottomLimit);

    return Offset(left, top);
  }

  @override
  bool shouldRelayout(covariant _AppDropdownLayoutDelegate oldDelegate) {
    return oldDelegate.buttonRectListenable != buttonRectListenable ||
        oldDelegate.menuMaxHeight != menuMaxHeight ||
        oldDelegate.viewPadding != viewPadding;
  }
}
