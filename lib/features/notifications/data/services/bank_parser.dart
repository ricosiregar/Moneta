/// Hasil parsing satu notifikasi bank / e-wallet.
class ParsedNotification {
  final double amount;
  final String type; // income | expense
  final String? merchant;
  const ParsedNotification(this.amount, this.type, this.merchant);
}

const _incomeWords = [
  'dana masuk',
  'uang masuk',
  'transfer masuk',
  'udah masuk', // Superbank
  'sudah masuk',
  'menerima',
  'diterima',
  'kredit',
  'top up berhasil',
  'setoran',
  'cashback',
  'gaji',
  'bunga',
  // English
  'received',
  'you got',
  'incoming',
  'deposit',
  'refund',
  'interest',
];

const _expenseWords = [
  'pembayaran',
  'pembelian',
  'membayar',
  'dibayar',
  'transfer keluar',
  'transfer ke',
  'melakukan transfer', // SeaBank Realtime Transfer
  'bayar ke', // Superbank
  'mengirim',
  'dikirim',
  'kirim',
  'debit',
  'penarikan',
  'tarik tunai',
  'belanja',
  'transaksi di',
  'payment',
  'bayar',
  // English
  'transferred',
  'you sent',
  'sent',
  'you paid',
  'paid',
  'purchase',
  'withdraw',
  'transfer to',
  'spent',
];

/// Posisi kemunculan pertama salah satu kata (cocok sebagai kata utuh, agar
/// mis. 'sent' tidak cocok di 'consent' atau 'paid' di 'unpaid').
int _firstIndex(String text, List<String> words) {
  var best = -1;
  for (final w in words) {
    final m = RegExp('\\b${RegExp.escape(w)}\\b').firstMatch(text);
    if (m != null && (best < 0 || m.start < best)) best = m.start;
  }
  return best;
}

/// Notifikasi yang bukan transaksi sukses: gagal, OTP, promo.
const _ignoreWords = [
  'gagal',
  'failed',
  'tidak berhasil',
  'dibatalkan',
  'ditolak',
  'otp',
  'kode verifikasi',
  'verification code',
  'promo',
  'diskon',
  'voucher',
  // Iklan / promosi (Inggris & Indonesia)
  'get cashback',
  'dapatkan',
  'discount',
  'enjoy',
  'or more',
  'atau lebih',
  'minimum',
  'jangan lewatkan',
  'buruan',
  'ayo',
  'yuk',
];

/// Nominal yang diawali kata "saldo"/"sisa" (saldo akhir), bukan nominal transaksi.
/// Catatan: "transfer saldo senilai Rp..." (SeaBank) adalah nominal transaksi.
final _balanceBefore = RegExp(
  r'(?:\bsisa(?:\s+saldo)?|\bsaldo(?:\s+(?:akhir|kamu|anda|mu|tersisa|sekarang))?)\s*:?\s*$',
);

/// Kata pengali yang mengikuti angka ("5 million", "2 juta", "500 rb").
final _magnitudeAfter = RegExp(
  r'^\s*(?:million|billion|thousand|juta|miliar|milyar|ribu|jt|rb|k)\b',
);

double? _parseAmount(String text) {
  final lower = text.toLowerCase();
  final re = RegExp(
    r'\b(?:rp|idr)\s*\.?\s*([0-9][0-9.,]*)',
    caseSensitive: false,
  );
  for (final m in re.allMatches(lower)) {
    // Lewati nominal saldo / sisa saldo.
    final before = lower.substring(
      (m.start - 24).clamp(0, lower.length),
      m.start,
    );
    if (_balanceBefore.hasMatch(before)) continue;

    // "IDR 5 million" / "Rp5 juta" = nominal promosi, bukan transaksi; jangan
    // dibaca sebagai 5 rupiah.
    if (_magnitudeAfter.hasMatch(lower.substring(m.end))) continue;

    var s = m.group(1)!;
    s = s.replaceAll(RegExp(r'[.,]+$'), '');
    s = s.replaceFirst(RegExp(r',\d{1,2}$'), ''); // desimal gaya Indonesia
    s = s.replaceAll(RegExp(r'[.,]'), '');
    final v = double.tryParse(s);
    if (v != null && v > 0) return v;
  }
  // Fallback tanpa 'Rp', mis. SeaBank QRIS: "sebesar 10.000 telah berhasil".
  final alt = RegExp(
    r'(?:sebesar|senilai)\s+([0-9][0-9.,]*)',
  ).firstMatch(lower);
  if (alt != null) {
    var s = alt.group(1)!.replaceAll(RegExp(r'[.,]+$'), '');
    s = s.replaceFirst(RegExp(r',\d{1,2}$'), '');
    s = s.replaceAll(RegExp(r'[.,]'), '');
    final v = double.tryParse(s);
    if (v != null && v > 0) return v;
  }
  return null;
}

String? _merchant(String text) {
  final re = RegExp(
    r"\b(?:ke|di|dari|kepada|untuk|merchant|from|to|at)\s+([A-Za-z0-9][A-Za-z0-9 .&'\-]{2,28})",
    caseSensitive: false,
  );
  final m = re.firstMatch(text);
  if (m == null) return null;
  var name = m.group(1)!;
  name = name
      .split(
        RegExp(
          r'\s+(?:pada|tanggal|sebesar|rp|idr|dengan|senilai|via|sukses|berhasil|udah|sudah|telah|rekening|need|contact|on|for)\b',
          caseSensitive: false,
        ),
      )
      .first
      .trim();
  return name.length < 3 ? null : name;
}

/// Parser generik untuk notifikasi bank/e-wallet berbahasa Indonesia.
/// [parserKey] disiapkan agar parser khusus per bank bisa ditambah nanti.
ParsedNotification? parseBankNotification(
  String title,
  String content, {
  String parserKey = 'generic',
}) {
  final text = '$title\n$content';
  final lower = text.toLowerCase();

  if (_firstIndex(lower, _ignoreWords) >= 0) return null;

  final inIdx = _firstIndex(lower, _incomeWords);
  final outIdx = _firstIndex(lower, _expenseWords);
  if (inIdx < 0 && outIdx < 0) return null;

  // Jago: "NAMA has sent Rp15.000 to you." = uang masuk (bukan keluar).
  final incoming = RegExp(r'\bsent\b[^\n]{0,40}?\bto you\b').hasMatch(lower);
  final sender = incoming
      ? RegExp(
          r'^(.+?)\s+has sent',
          caseSensitive: false,
        ).firstMatch(content.trim())?.group(1)?.trim()
      : null;

  final String type;
  if (incoming || (inIdx >= 0 && (outIdx < 0 || inIdx < outIdx))) {
    type = 'income';
  } else {
    type = 'expense';
  }

  final amount = _parseAmount(text);
  if (amount == null) return null;

  return ParsedNotification(amount, type, incoming ? sender : _merchant(text));
}

/// Aplikasi bank/e-wallet populer yang didukung otomatis.
const knownBankPackages = <(String, String)>[
  ('Bank Jago', 'com.jago.digitalBanking'),
  ('SeaBank', 'id.co.bankbkemobile.digitalbank'),
  ('Superbank', 'id.co.bankfama.android'),
  // ('Livin\' Mandiri', 'id.bmri.livin'),
  // ('myBCA', 'com.bca.mybca.omni.android'),
  // ('BRImo', 'id.co.bri.brimo'),
  // ('BNI Mobile', 'src.com.bni'),
  // ('GoPay / Gojek', 'com.gojek.app'),
  // ('OVO', 'ovo.id'),
  // ('DANA', 'id.dana'),
  // ('ShopeePay / Shopee', 'com.shopee.id'),
];

/// Mengembalikan nama bank dari `packageName` bila termasuk dalam [knownBankPackages].
String? bankLabelForPackage(String? packageName) {
  if (packageName == null || packageName.isEmpty) return null;
  for (final entry in knownBankPackages) {
    if (entry.$2 == packageName) return entry.$1;
  }
  return null;
}

String _normalizeBankToken(String input) =>
    input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

/// Mengecek apakah nama dompet cocok dengan nama bank (mis. "Bank Jago" <-> "Jago").
bool doesWalletMatchBank(String walletName, String bankLabel) {
  final w = _normalizeBankToken(walletName);
  final b = _normalizeBankToken(bankLabel);
  if (w.isEmpty || b.isEmpty) return false;
  if (w == b || w.contains(b) || b.contains(w)) return true;
  if (b == 'bankjago' && w.contains('jago')) return true;
  if (b == 'seabank' && w.contains('seabank')) return true;
  if (b == 'superbank' && w.contains('superbank')) return true;
  return false;
}
