// lib/core/services/api_client/api_response.dart
//
// Respons mentah dari ApiClient: status HTTP + body JSON yang sudah di-decode.
// Pemetaan status/envelope dilakukan di data layer, bukan di core.

/// Respons HTTP yang sudah di-decode.
class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.body,
  });

  /// Status HTTP, mis. 200, 401, 500.
  final int statusCode;

  /// Body JSON hasil `jsonDecode`, atau `null` bila body kosong.
  final Object? body;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
