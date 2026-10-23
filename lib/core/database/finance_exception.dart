/// Kesalahan validasi/aturan bisnis pada operasi keuangan lokal. [message]
/// sudah berupa kalimat yang aman ditampilkan ke user.
class FinanceException implements Exception {
  final String message;
  const FinanceException(this.message);

  @override
  String toString() => message;
}

/// Pastikan [value] angka valid dan > 0 (menolak NaN, tak hingga, nol, minus).
void ensureValidAmount(double value, {String label = 'Nominal'}) {
  if (value.isNaN || value.isInfinite || value <= 0) {
    throw FinanceException('$label harus lebih dari 0');
  }
}
