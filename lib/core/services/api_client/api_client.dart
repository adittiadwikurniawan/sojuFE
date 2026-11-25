// lib/core/services/api_client/api_client.dart
//
// Kontrak HTTP client lintas layer (ARCHITECTURE.md §2.6).
//
// Implementasi `http` berada di `data/datasources/remote/` agar core tidak
// bergantung pada package transport tertentu.

import 'api_response.dart';

/// Kontrak pemanggilan REST API.
abstract interface class ApiClient {
  /// GET [path] relatif terhadap base URL / origin API.
  ///
  /// [authenticated] menambahkan header `Authorization: Bearer <token>`.
  Future<ApiResponse> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  });

  /// POST [path] dengan body JSON.
  Future<ApiResponse> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  });

  /// PUT [path] dengan body JSON.
  Future<ApiResponse> put(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  });

  /// PATCH [path] dengan body JSON.
  Future<ApiResponse> patch(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  });

  /// DELETE [path] dengan body JSON opsional.
  Future<ApiResponse> delete(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  });
}
