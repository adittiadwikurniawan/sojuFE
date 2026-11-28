// lib/data/datasources/remote/http_api_client.dart
//
// Implementasi ApiClient memakai package `http`.
//
// Tanggung jawab:
// - menyusun URL dari base URL yang di-inject composition root;
// - menambahkan Bearer token untuk request terautentikasi;
// - decode JSON dan memetakan kegagalan transport ke AppFailure.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../app/config/app_config.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../../../core/services/token_storage/token_storage.dart';

/// ApiClient berbasis package `http`.
class HttpApiClient implements ApiClient {
  HttpApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    http.Client? client,
    Duration timeout = const Duration(seconds: 45),
  })  : _origin = AppConfig.normalizeApiOrigin(baseUrl),
        _defaultV1BaseUrl = '${AppConfig.normalizeApiOrigin(baseUrl)}/api/v1',
        _tokenStorage = tokenStorage,
        _client = client ?? http.Client(),
        _timeout = timeout;

  final String _origin;
  final String _defaultV1BaseUrl;
  final TokenStorage _tokenStorage;
  final http.Client _client;
  final Duration _timeout;

  static const List<String> _rootApiPrefixes = <String>[
    '/api/v1',
    '/api/customer',
    '/api/public',
  ];

  /// Menyusun [Uri] lintas prefix (`/api/v1/*`, `/api/customer/*`, `/api/public/*`)
  /// sekaligus menjaga kompatibilitas path relatif v1 seperti `/auth/login`.
  Uri resolveUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final String normalizedPath = path.startsWith('/') ? path : '/$path';
    final bool isRootPrefixed = _rootApiPrefixes.any(
      (String prefix) =>
          normalizedPath == prefix ||
          normalizedPath.startsWith('$prefix/') ||
          normalizedPath.startsWith('$prefix?'),
    );
    final String base = isRootPrefixed ? _origin : _defaultV1BaseUrl;
    final Uri parsed = Uri.parse('$base$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) {
      return parsed;
    }
    return parsed.replace(
      queryParameters: <String, String>{
        ...parsed.queryParameters,
        ...queryParameters,
      },
    );
  }

  @override
  Future<ApiResponse> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _send(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  @override
  Future<ApiResponse> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  @override
  Future<ApiResponse> put(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _send(
      method: 'PUT',
      path: path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  @override
  Future<ApiResponse> patch(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _send(
      method: 'PATCH',
      path: path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  @override
  Future<ApiResponse> delete(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _send(
      method: 'DELETE',
      path: path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  Future<ApiResponse> _send({
    required String method,
    required String path,
    Object? body,
    Map<String, String>? queryParameters,
    required bool authenticated,
  }) async {
    final Uri uri = resolveUri(path, queryParameters: queryParameters);
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };

    if (authenticated) {
      final String? token = await _tokenStorage.read();
      if (token == null || token.isEmpty) {
        throw const UnauthorizedFailure();
      }
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final String? encodedBody = body == null ? null : jsonEncode(body);
      final Future<http.Response> requestFuture = switch (method) {
        'GET' => _client.get(uri, headers: headers),
        'POST' => _client.post(uri, headers: headers, body: encodedBody),
        'PUT' => _client.put(uri, headers: headers, body: encodedBody),
        'PATCH' => _client.patch(uri, headers: headers, body: encodedBody),
        'DELETE' => _client.delete(uri, headers: headers, body: encodedBody),
        _ => throw ArgumentError.value(method, 'method', 'Unsupported HTTP method'),
      };
      final http.Response response = await requestFuture.timeout(_timeout);

      final Object? decoded =
          response.body.isEmpty ? null : jsonDecode(response.body);

      return ApiResponse(
        statusCode: response.statusCode,
        body: decoded,
      );
    } on TimeoutException {
      throw const NetworkFailure(
        message: 'Koneksi ke server terlalu lama. Coba lagi.',
      );
    } on http.ClientException {
      throw const NetworkFailure();
    } on FormatException {
      throw const ParsingFailure();
    } on AppFailure {
      rethrow;
    } on Object {
      throw const NetworkFailure();
    }
  }
}
