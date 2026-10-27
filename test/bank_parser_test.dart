import 'package:flutter_test/flutter_test.dart';
import 'package:moneta/features/notifications/data/services/bank_parser.dart';

void _expectParsed(
  ParsedNotification? p, {
  required double amount,
  required String type,
  String? merchant,
}) {
  expect(p, isNotNull, reason: 'seharusnya terdeteksi');
  expect(p!.amount, amount);
  expect(p.type, type);
  if (merchant != null) expect(p.merchant, merchant);
}

void main() {
  group('SeaBank', () {
    test('transfer masuk "saldo senilai" bukan dianggap saldo akhir', () {
      final p = parseBankNotification(
        'Transfer Masuk',
        'Kamu menerima transfer saldo senilai Rp35.000 dari FERGIANO DEREN RYAN...',
      );
      _expectParsed(p, amount: 35000, type: 'income');
      expect(p!.merchant, startsWith('FERGIANO'));
    });

    test('transfer masuk ke rekening + ref number', () {
      final p = parseBankNotification(
        'Transfer Masuk',
        'Kamu menerima transfer saldo senilai Rp13.000 ke rekening 1673. '
            'Ref. number 20261026FAMAIDJ1010O0294673823.',
      );
      _expectParsed(p, amount: 13000, type: 'income');
    });

    test('Realtime Transfer = pengeluaran', () {
      final p = parseBankNotification(
        'Realtime Transfer',
        'Kamu baru melakukan transfer real-time senilai Rp10.000 pada '
            '26 Oct 2026 11:08. Jika kamu tidak melakukan ini, segera hubungi 1500130.',
      );
      _expectParsed(p, amount: 10000, type: 'expense');
    });

    test('QRIS tanpa "Rp" (fallback sebesar)', () {
      final p = parseBankNotification(
        'Pembayaran QRIS berhasil',
        'Pembayaran QRIS untuk parkiran motor sonic sebesar 10.000 telah berhasil.',
      );
      _expectParsed(
        p,
        amount: 10000,
        type: 'expense',
        merchant: 'parkiran motor sonic',
      );
    });
  });

  group('Superbank', () {
    test('Transfer ke ... berhasil', () {
      final p = parseBankNotification(
        'Transfer ke Dnid Ramxxxx berhasil',
        'Transfer sebesar Rp100.000,00 dari Tabungan Utama kamu berhasil.',
      );
      _expectParsed(p,
          amount: 100000, type: 'expense', merchant: 'Dnid Ramxxxx');
    });

    test('uang masuk dari ...', () {
      final p = parseBankNotification(
        'Asik, ada uang masuk dari NAUFAL ILHAM RAMADHAN',
        'Rp200.000,00 udah masuk ke Tabungan Utama kamu. Klik untuk lihat detailnya 🤑',
      );
      _expectParsed(p,
          amount: 200000, type: 'income', merchant: 'NAUFAL ILHAM RAMADHAN');
    });

    test('bayar ke kaiaccess', () {
      final p = parseBankNotification(
        'Berhasil bayar ke kaiaccess',
        'Pembayaran sebesar Rp4.000,00 dari OVO Nabung kamu berhasil.',
      );
      _expectParsed(p, amount: 4000, type: 'expense', merchant: 'kaiaccess');
    });

    test('Transfer dari Siska udah masuk', () {
      final p = parseBankNotification(
        'Transfer dari Siska udah masuk',
        'Rp10.000,00 udah masuk ke Tabungan Utama kamu 🤑',
      );
      _expectParsed(p, amount: 10000, type: 'income', merchant: 'Siska');
    });

    test('bayar ke Sobur Mas Hendra', () {
      final p = parseBankNotification(
        'Berhasil bayar ke Sobur Mas Hendra',
        'Pembayaran Rp18.000,00 dari Tabungan Utama kamu berhasil.',
      );
      _expectParsed(p,
          amount: 18000, type: 'expense', merchant: 'Sobur Mas Hendra');
    });
  });

  group('Jago', () {
    test('You have paid = pengeluaran', () {
      final p = parseBankNotification(
        'Jago',
        'You have paid Rp 12.000 to jagocoffee.com/. Need help? Contact Tanya Jago at 1500 746.',
      );
      _expectParsed(p, amount: 12000, type: 'expense');
    });

    test('"X has sent RpN to you" = pemasukan (bug awal)', () {
      final p = parseBankNotification(
        'Jago',
        'RICO PAHLEVI SIREGAR has sent Rp15.000 to you. Need help? Contact Tanya Jago at 1500 746.',
      );
      _expectParsed(p,
          amount: 15000, type: 'income', merchant: 'RICO PAHLEVI SIREGAR');
    });

    test('"You sent RpN to X" tetap pengeluaran', () {
      final p = parseBankNotification('Jago', 'You sent Rp20.000 to Budi.');
      _expectParsed(p, amount: 20000, type: 'expense');
    });
  });

  group('Penyaringan', () {
    test('transaksi gagal diabaikan', () {
      expect(
        parseBankNotification('Transfer gagal', 'Transfer Rp50.000 gagal.'),
        isNull,
      );
    });

    test('OTP diabaikan', () {
      expect(
        parseBankNotification('Kode OTP', 'OTP kamu 123456. Transfer Rp50.000'),
        isNull,
      );
    });

    test('promo diabaikan', () {
      expect(
        parseBankNotification('Promo', 'Dapatkan cashback Rp50.000 sekarang!'),
        isNull,
      );
    });

    test('tanpa nominal -> null', () {
      expect(parseBankNotification('Info', 'Transfer masuk berhasil'), isNull);
    });

    test('iklan Jago "cashback ... IDR 5 million" diabaikan (bug 5 perak)', () {
      expect(
        parseBankNotification(
          'Diversify beyond stocks',
          'Get cashback on your first forex purchase of IDR 5 million or more',
        ),
        isNull,
      );
    });

    test('iklan Jago diskon 20% diabaikan', () {
      expect(
        parseBankNotification(
          'Great food, better prices',
          'Head to Ta Wan and enjoy 20% DISCOUNT!',
        ),
        isNull,
      );
    });

    test('nominal berpengali ("IDR 5 million") tidak dibaca 5 rupiah', () {
      // Tanpa kata iklan sekalipun, angka berpengali tidak boleh jadi 5.
      expect(
        parseBankNotification('Info', 'Purchase of IDR 5 million recorded'),
        isNull,
      );
      expect(
        parseBankNotification('Info', 'Pembayaran Rp2 juta berhasil'),
        isNull,
      );
    });

    test('tanpa kata kunci -> null', () {
      expect(parseBankNotification('Info', 'Saldo kamu Rp500.000'), isNull);
    });

    test('kata kunci harus kata utuh ("consent" bukan "sent")', () {
      expect(
        parseBankNotification('Info', 'Please consent to terms Rp10.000'),
        isNull,
      );
    });
  });

  group('Nominal', () {
    test('saldo akhir dilewati, nominal transaksi dipakai', () {
      final p = parseBankNotification(
        'Pembayaran',
        'Pembayaran Rp20.000 berhasil. Saldo Rp500.000',
      );
      _expectParsed(p, amount: 20000, type: 'expense');
    });

    test('hanya saldo akhir -> null', () {
      expect(
        parseBankNotification('Pembayaran berhasil', 'Sisa saldo Rp500.000'),
        isNull,
      );
    });

    test('desimal gaya Indonesia ,50 dibuang', () {
      final p = parseBankNotification('Debit', 'Debit Rp1.500.000,50');
      _expectParsed(p, amount: 1500000, type: 'expense');
    });

    test('format "Rp 12.000" dengan spasi', () {
      final p = parseBankNotification('x', 'Pembayaran Rp 12.000 berhasil');
      _expectParsed(p, amount: 12000, type: 'expense');
    });
  });

  group('Bank helper', () {
    test('bankLabelForPackage', () {
      expect(bankLabelForPackage('com.jago.digitalBanking'), 'Bank Jago');
      expect(
        bankLabelForPackage('id.co.bankbkemobile.digitalbank'),
        'SeaBank',
      );
      expect(bankLabelForPackage('id.co.bankfama.android'), 'Superbank');
      expect(bankLabelForPackage('x.y.z'), isNull);
      expect(bankLabelForPackage(null), isNull);
    });

    test('doesWalletMatchBank', () {
      expect(doesWalletMatchBank('Jago', 'Bank Jago'), isTrue);
      expect(doesWalletMatchBank('SeaBank Utama', 'SeaBank'), isTrue);
      expect(doesWalletMatchBank('Super Bank', 'Superbank'), isTrue);
      expect(doesWalletMatchBank('Mandiri', 'Bank Jago'), isFalse);
    });
  });
}
