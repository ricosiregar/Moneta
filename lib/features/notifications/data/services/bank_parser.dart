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

int _firstIndex(String text, List<String> words) {
  var best = -1;
  for (final w in words) {
    final i = text.indexOf(w);
    if (i >= 0 && (best < 0 || i < best)) best = i;
  }
  return best;
}

double? _parseAmount(String text) {
  final lower = text.toLowerCase();
  final re = RegExp(r'(?:rp|idr)\s*\.?\s*([0-9][0-9.,]*)', caseSensitive: false);
  for (final m in re.allMatches(lower)) {
    // Lewati nominal saldo / sisa saldo.
    final before = lower.substring((m.start - 14).clamp(0, lower.length), m.start);
    if (before.contains('saldo') || before.contains('sisa')) continue;

    var s = m.group(1)!;
    s = s.replaceAll(RegExp(r'[.,]+$'), '');
    s = s.replaceFirst(RegExp(r',\d{1,2}$'), ''); // desimal gaya Indonesia
    s = s.replaceAll(RegExp(r'[.,]'), '');
    final v = double.tryParse(s);
    if (v != null && v > 0) return v;
  }
  return null;
}

String? _merchant(String text) {
  final re = RegExp(
    r"(?:ke|di|dari|kepada|merchant|from|to|at)\s+([A-Za-z0-9][A-Za-z0-9 .&'\-]{2,28})",
    caseSensitive: false,
  );
  final m = re.firstMatch(text);
  if (m == null) return null;
  var name = m.group(1)!;
  name = name.split(RegExp(
          r'\s+(?:pada|tanggal|sebesar|rp|idr|dengan|senilai|via|sukses|berhasil|need|contact|on|for)\b',
          caseSensitive: false))
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
  final text = '$title $content';
  final lower = text.toLowerCase();

  final inIdx = _firstIndex(lower, _incomeWords);
  final outIdx = _firstIndex(lower, _expenseWords);
  if (inIdx < 0 && outIdx < 0) return null;

  final String type;
  if (inIdx >= 0 && (outIdx < 0 || inIdx < outIdx)) {
    type = 'income';
  } else {
    type = 'expense';
  }

  final amount = _parseAmount(text);
  if (amount == null) return null;

  return ParsedNotification(amount, type, _merchant(text));
}

/// Aplikasi bank/e-wallet populer (saran saat menambah sumber).
const knownBankPackages = <(String, String)>[
  ('Bank Jago', 'com.jago.digitalBanking'),
  ('SeaBank', 'id.co.bankbkemobile.digitalbank'),
  ('Livin\' Mandiri', 'id.bmri.livin'),
  ('myBCA', 'com.bca.mybca.omni.android'),
  ('BRImo', 'id.co.bri.brimo'),
  ('BNI Mobile', 'src.com.bni'),
  ('GoPay / Gojek', 'com.gojek.app'),
  ('OVO', 'ovo.id'),
  ('DANA', 'id.dana'),
  ('ShopeePay / Shopee', 'com.shopee.id'),
];
