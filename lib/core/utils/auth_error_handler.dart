/// Utility class to convert raw auth error messages to user-friendly text.
///
/// This centralizes all error message mapping for consistency across the app.
class AuthErrorHandler {
  AuthErrorHandler._();

  /// Error pattern to user-friendly message mapping (Indonesian)
  static const _errorPatterns = <String, String>{
    // Login errors
    'invalid login credentials': 'Email atau password salah. Silakan periksa kembali.',
    'email not confirmed': 'Email belum diverifikasi. Periksa inbox Anda.',

    // Signup errors
    'user already registered': 'Email ini sudah terdaftar. Silakan masuk.',
    'password should be at least': 'Password minimal 6 karakter.',
    'invalid format': 'Format email tidak valid.',
    'signup requires a valid password': 'Password tidak valid.',

    // OTP errors
    'token has expired': 'Kode verifikasi sudah tidak berlaku. Kirim ulang kode.',
    'otp has expired': 'Kode verifikasi sudah tidak berlaku. Kirim ulang kode.',
    'invalid otp': 'Kode verifikasi salah. Periksa kembali.',

    // Google Sign-In errors
    'sign-in was cancelled': 'Login Google dibatalkan.',
    'canceled': 'Login Google dibatalkan.',
    'authentication is not supported': 'Login Google tidak didukung di perangkat ini.',
    'no id token received': 'Gagal mendapatkan token dari Google. Silakan coba lagi.',

    // Rate limiting
    'request this once every': 'Tunggu sebentar sebelum mencoba lagi.',
    'rate limit': 'Terlalu banyak percobaan. Tunggu beberapa saat.',

    // Network errors
    'socketexception': 'Tidak dapat terhubung. Periksa koneksi internet Anda.',
    'connection closed': 'Koneksi terputus. Silakan coba lagi.',
    'network is unreachable': 'Jaringan tidak tersedia. Periksa koneksi Anda.',
    'connection refused': 'Tidak dapat terhubung ke server.',
    'connection timed out': 'Koneksi timeout. Silakan coba lagi.',

    // Session errors
    'session expired': 'Sesi telah berakhir. Silakan masuk kembali.',
    'refresh token not found': 'Sesi tidak valid. Silakan masuk kembali.',
  };

  /// Convert raw error to user-friendly message.
  ///
  /// Checks the error string against known patterns and returns
  /// an appropriate user-friendly message in Indonesian.
  static String getUserFriendlyMessage(dynamic error) {
    final rawMessage = error.toString().toLowerCase();

    // Remove common exception prefixes for cleaner matching
    final cleanMessage = rawMessage
        .replaceAll('appauthexception:', '')
        .replaceAll('authexception:', '')
        .replaceAll('exception:', '')
        .trim();

    // Check against known error patterns
    for (final entry in _errorPatterns.entries) {
      if (cleanMessage.contains(entry.key)) {
        return entry.value;
      }
    }

    // Fallback for unknown errors
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  /// Check if error is a cancellation (user-initiated, not a real error)
  static bool isCancellationError(dynamic error) {
    final rawMessage = error.toString().toLowerCase();
    return rawMessage.contains('cancelled') ||
        rawMessage.contains('canceled') ||
        rawMessage.contains('sign-in was cancelled');
  }

  /// Check if error requires email verification action
  static bool requiresEmailVerification(dynamic error) {
    final rawMessage = error.toString().toLowerCase();
    return rawMessage.contains('email not confirmed');
  }

  /// Check if error indicates user already exists (should redirect to sign-in)
  static bool isUserAlreadyRegistered(dynamic error) {
    final rawMessage = error.toString().toLowerCase();
    return rawMessage.contains('user already registered');
  }
}
