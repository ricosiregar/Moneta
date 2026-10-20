/// Utility to format and sanitize error messages into human-friendly Indonesian text.
/// Prevents raw exception dumps, stack traces, and technical code from reaching the UI.
class AppErrorFormatter {
  static String format(dynamic error) {
    if (error == null) {
      return 'Terjadi kendala. Silakan coba beberapa saat lagi.';
    }

    String raw = error.toString().trim();

    // Strip common technical exception prefixes
    while (_hasPrefix(raw)) {
      if (raw.startsWith('Exception: ')) {
        raw = raw.substring('Exception: '.length).trim();
      } else if (raw.startsWith('AuthException: ')) {
        raw = raw.substring('AuthException: '.length).trim();
      } else if (raw.startsWith('ServerException: ')) {
        raw = raw.substring('ServerException: '.length).trim();
      } else if (raw.startsWith('NetworkException: ')) {
        raw = raw.substring('NetworkException: '.length).trim();
      } else if (raw.startsWith('CacheException: ')) {
        raw = raw.substring('CacheException: '.length).trim();
      } else if (raw.startsWith('FormatException: ')) {
        raw = raw.substring('FormatException: '.length).trim();
      } else if (raw.startsWith('Gagal: Exception: ')) {
        raw = raw.substring('Gagal: Exception: '.length).trim();
      } else if (raw.startsWith('Gagal: ')) {
        raw = raw.substring('Gagal: '.length).trim();
      } else if (raw.startsWith('Gagal impor: Exception: ')) {
        raw = raw.substring('Gagal impor: Exception: '.length).trim();
      } else if (raw.startsWith('Gagal impor: ')) {
        raw = raw.substring('Gagal impor: '.length).trim();
      } else if (raw.startsWith('Gagal menyimpan dompet: Exception: ')) {
        raw = raw.substring('Gagal menyimpan dompet: Exception: '.length).trim();
      } else if (raw.startsWith('Gagal menyimpan dompet: ')) {
        raw = raw.substring('Gagal menyimpan dompet: '.length).trim();
      } else if (raw.startsWith('Gagal menyimpan: Exception: ')) {
        raw = raw.substring('Gagal menyimpan: Exception: '.length).trim();
      } else if (raw.startsWith('Gagal menyimpan: ')) {
        raw = raw.substring('Gagal menyimpan: '.length).trim();
      } else if (raw.startsWith('Terjadi kesalahan sistem: ')) {
        raw = raw.substring('Terjadi kesalahan sistem: '.length).trim();
      } else if (raw.startsWith('Terjadi kesalahan saat masuk: ')) {
        raw = raw.substring('Terjadi kesalahan saat masuk: '.length).trim();
      } else if (raw.startsWith('Terjadi kesalahan saat mendaftar: ')) {
        raw = raw.substring('Terjadi kesalahan saat mendaftar: '.length).trim();
      } else {
        break;
      }
    }

    final lower = raw.toLowerCase();

    // 1. Connection & Network issues
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('networkfailure') ||
        lower.contains('no internet') ||
        lower.contains('clientexception') ||
        lower.contains('connection error')) {
      return 'Koneksi internet bermasalah. Periksa jaringan Anda dan coba lagi.';
    }

    // 2. Timeout
    if (lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('deadline exceeded')) {
      return 'Koneksi melebihi batas waktu. Silakan coba beberapa saat lagi.';
    }

    // 3. Supabase Auth specific messages
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_grant') ||
        lower.contains('invalid_credentials')) {
      return 'Email atau kata sandi salah. Silakan periksa kembali.';
    }

    if (lower.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Silakan periksa kotak masuk atau spam email Anda.';
    }

    if (lower.contains('user already registered') ||
        lower.contains('user already exists') ||
        lower.contains('user_already_exists') ||
        lower.contains('email address already exists')) {
      return 'Email sudah terdaftar. Silakan masuk atau gunakan email lain.';
    }

    if (lower.contains('password should be at least') ||
        lower.contains('weak_password') ||
        lower.contains('password is too short')) {
      return 'Kata sandi minimal 6 karakter.';
    }

    if (lower.contains('invalid email') ||
        lower.contains('valid email') ||
        lower.contains('email address is invalid')) {
      return 'Format email tidak valid. Masukkan email yang benar.';
    }

    if (lower.contains('over_email_send_rate_limit') ||
        lower.contains('email rate limit exceeded')) {
      return 'Terlalu banyak permintaan kirim email. Harap tunggu beberapa saat.';
    }

    if (lower.contains('jwt') ||
        lower.contains('token expired') ||
        lower.contains('session expired') ||
        lower.contains('session_not_found') ||
        lower.contains('unauthorized')) {
      return 'Sesi login telah berakhir. Silakan masuk kembali.';
    }

    // 4. Database / Supabase RLS / Constraint errors
    if (lower.contains('postgrestexception') ||
        lower.contains('row-level security') ||
        lower.contains('violates foreign key') ||
        lower.contains('violates check constraint') ||
        lower.contains('database error') ||
        lower.contains('42501')) {
      return 'Gagal memproses data di server. Silakan coba beberapa saat lagi.';
    }

    if (lower.contains('duplicate key') ||
        lower.contains('unique constraint') ||
        lower.contains('already exists')) {
      return 'Data tersebut sudah tersimpan di sistem.';
    }

    // 5. Raw stack traces or technical json dumps
    if (raw.contains('Stack trace:') ||
        raw.contains('#0 ') ||
        raw.contains('Unhandled Exception:') ||
        raw.contains('FormatException:') ||
        raw.contains('dioexception') ||
        raw.contains('sqlitelocalerror') ||
        raw.contains('{error:') ||
        raw.contains('{"code":')) {
      return 'Terjadi kesalahan sistem. Silakan coba beberapa saat lagi.';
    }

    // If it's a reasonably clean user-facing message, keep it
    return raw.isNotEmpty ? raw : 'Terjadi kesalahan. Silakan coba lagi.';
  }

  static bool _hasPrefix(String s) {
    return s.startsWith('Exception: ') ||
        s.startsWith('AuthException: ') ||
        s.startsWith('ServerException: ') ||
        s.startsWith('NetworkException: ') ||
        s.startsWith('CacheException: ') ||
        s.startsWith('FormatException: ') ||
        s.startsWith('Gagal: ') ||
        s.startsWith('Gagal impor: ') ||
        s.startsWith('Gagal menyimpan dompet: ') ||
        s.startsWith('Gagal menyimpan: ') ||
        s.startsWith('Terjadi kesalahan sistem: ') ||
        s.startsWith('Terjadi kesalahan saat masuk: ') ||
        s.startsWith('Terjadi kesalahan saat mendaftar: ');
  }
}
