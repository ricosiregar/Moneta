import 'package:intl/intl.dart';

/// App-wide Formatter Utility for Currency, Dates, and Numbers.
class AppFormatter {
  AppFormatter._();

  // ====================================================================
  // CURRENCY FORMATTERS
  // ====================================================================

  /// Formats double/num amount to Rupiah string.
  /// Example: 150000 -> "Rp 150.000"
  static String formatRupiah(num amount, {bool withSymbol = true, int decimalDigits = 0}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: withSymbol ? 'Rp ' : '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Formats large numbers compactly.
  /// Example: 1500000 -> "Rp 1,5 jt", 50000 -> "Rp 50 rb"
  static String formatCompactRupiah(num amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} rb';
    }
    return formatRupiah(amount);
  }

  // ====================================================================
  // DATE & TIME FORMATTERS
  // ====================================================================

  /// Example: 28 Agustus 2026
  static String formatDateFull(DateTime date, {String locale = 'id_ID'}) {
    return DateFormat('d MMMM yyyy', locale).format(date);
  }

  /// Example: 28 Ags 2026
  static String formatDateShort(DateTime date, {String locale = 'id_ID'}) {
    return DateFormat('d MMM yyyy', locale).format(date);
  }

  /// Example: 28/08/2026
  static String formatDateNumeric(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Example: 15:43
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Example: 28 Agustus 2026, 15:43
  static String formatDateTime(DateTime date, {String locale = 'id_ID'}) {
    return DateFormat('d MMMM yyyy, HH:mm', locale).format(date);
  }

  /// Human friendly relative date (e.g. "Hari ini", "Kemarin", or "28 Ags 2026")
  static String formatRelativeDate(DateTime date, {String locale = 'id_ID'}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hari ini';
    } else if (targetDate == yesterday) {
      return 'Kemarin';
    } else {
      return formatDateShort(date, locale: locale);
    }
  }
}

// ====================================================================
// CONVENIENCE EXTENSIONS
// ====================================================================

extension NumFormatterX on num {
  String toRupiah({bool withSymbol = true, int decimalDigits = 0}) =>
      AppFormatter.formatRupiah(this, withSymbol: withSymbol, decimalDigits: decimalDigits);

  String toCompactRupiah() => AppFormatter.formatCompactRupiah(this);
}

extension DateTimeFormatterX on DateTime {
  String toDateFull({String locale = 'id_ID'}) => AppFormatter.formatDateFull(this, locale: locale);
  String toDateShort({String locale = 'id_ID'}) => AppFormatter.formatDateShort(this, locale: locale);
  String toNumericDate() => AppFormatter.formatDateNumeric(this);
  String toTime() => AppFormatter.formatTime(this);
  String toDateTimeFormatted({String locale = 'id_ID'}) => AppFormatter.formatDateTime(this, locale: locale);
  String toRelativeDate({String locale = 'id_ID'}) => AppFormatter.formatRelativeDate(this, locale: locale);
}
