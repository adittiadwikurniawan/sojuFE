// lib/core/errors/app_failure.dart
//
// Typed failure aplikasi (transport, HTTP, envelope, parse, auth).
//
// Presentation hanya membaca [message] untuk ditampilkan; jenis kegagalan
// dipakai untuk penanganan khusus (mis. [UnauthorizedFailure] mengarahkan ke
// login sesuai `ARCHITECTURE.md` §2.5).

/// Basis kegagalan ter-tipe pada aplikasi Buku Dapur.
sealed class AppFailure {
  const AppFailure({required this.message});

  /// Pesan yang siap dibaca pengguna (Bahasa Indonesia).
  final String message;
}

/// Koneksi ke server gagal (tanpa respons HTTP).
class NetworkFailure extends AppFailure {
  const NetworkFailure({String? message})
      : super(
          message: message ??
              'Tidak dapat terhubung ke server. Periksa koneksi internet '
                  'lalu coba lagi.',
        );
}

/// Server merespons dengan status HTTP di luar rentang sukses.
class ServerFailure extends AppFailure {
  const ServerFailure({this.statusCode, String? message})
      : super(
          message:
              message ?? 'Server sedang bermasalah. Coba beberapa saat lagi.',
        );

  final int? statusCode;
}

/// Envelope `{success, data, message?}` tidak sesuai kontrak.
class EnvelopeFailure extends AppFailure {
  const EnvelopeFailure({String? message})
      : super(message: message ?? 'Respon server tidak valid.');
}

/// Payload tidak dapat diurai menjadi model.
class ParsingFailure extends AppFailure {
  const ParsingFailure({String? message})
      : super(message: message ?? 'Data dari server tidak dapat dibaca.');
}

/// Token tidak valid / sesi berakhir (HTTP 401).
class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({String? message})
      : super(message: message ?? 'Sesi berakhir. Silakan masuk kembali.');
}
