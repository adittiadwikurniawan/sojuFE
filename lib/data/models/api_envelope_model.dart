// lib/data/models/api_envelope_model.dart
//
// Envelope respons API `{success, data, message?}` (PRD Bagian 7).

/// Envelope generik seluruh endpoint `/api/v1/*`.
///
/// [data] dipertahankan sebagai `Object?` agar tiap fitur memetakan isinya
/// dengan model masing-masing (mis. `AuditLogPageModel.fromJson`).
class ApiEnvelopeModel {
  const ApiEnvelopeModel({
    required this.success,
    this.data,
    this.message,
  });

  /// `true` bila permintaan berhasil di sisi server.
  final bool success;

  /// Isi data (bentuknya kontrak per-endpoint).
  final Object? data;

  /// Pesan dari server (mis. pesan galat), bila ada.
  final String? message;

  /// Mengurai map hasil decode JSON.
  ///
  /// Melempar [FormatException] bila [raw] bukan map atau `success` absen,
  /// agar repository dapat memetakannya ke [ParsingFailure].
  factory ApiEnvelopeModel.fromRaw(Object? raw) {
    if (raw is! Map) {
      throw const FormatException('Envelope respons bukan objek JSON.');
    }
    final Object? success = raw['success'];
    if (success is! bool) {
      throw const FormatException('Field `success` tidak ada pada envelope.');
    }
    return ApiEnvelopeModel(
      success: success,
      data: raw['data'],
      message: raw['message'] is String ? raw['message'] as String : null,
    );
  }
}
