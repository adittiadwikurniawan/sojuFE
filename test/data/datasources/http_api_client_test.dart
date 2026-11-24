// Test: HttpApiClient mendukung GET/POST/PUT/PATCH/DELETE, resolusi URL
// multi-prefix, injeksi header Bearer, serta pemetaan error ke AppFailure.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/core/services/api_client/api_response.dart';
import 'package:soju_fe/core/services/token_storage/token_storage.dart';
import 'package:soju_fe/data/datasources/remote/http_api_client.dart';

void main() {
  group('HttpApiClient — URL multi-prefix resolution', () {
    test('menangani baseUrl berakhiran /api/v1 dengan semua prefix', () {
      final HttpApiClient client = HttpApiClient(
        baseUrl: 'http://192.168.1.10:4000/api/v1/',
        tokenStorage: _MemoryTokenStorage(),
        client: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(
        client.resolveUri('/auth/login').toString(),
        'http://192.168.1.10:4000/api/v1/auth/login',
      );
      expect(
        client.resolveUri('auth/me').toString(),
        'http://192.168.1.10:4000/api/v1/auth/me',
      );
      expect(
        client.resolveUri('/api/v1/users', queryParameters: <String, String>{
          'search': 'dea',
          'aktif': 'true',
        }).toString(),
        'http://192.168.1.10:4000/api/v1/users?search=dea&aktif=true',
      );
      expect(
        client.resolveUri('/api/customer/keranjang').toString(),
        'http://192.168.1.10:4000/api/customer/keranjang',
      );
      expect(
        client.resolveUri('/api/public/products').toString(),
        'http://192.168.1.10:4000/api/public/products',
      );
    });

    test('menangani baseUrl origin-only dengan semua prefix dan relative v1', () {
      final HttpApiClient client = HttpApiClient(
        baseUrl: 'https://api.soju.id',
        tokenStorage: _MemoryTokenStorage(),
        client: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(
        client.resolveUri('/auth/login').toString(),
        'https://api.soju.id/api/v1/auth/login',
      );
      expect(
        client.resolveUri('/api/v1/ai/chat').toString(),
        'https://api.soju.id/api/v1/ai/chat',
      );
      expect(
        client.resolveUri('/api/customer/auth/masuk').toString(),
        'https://api.soju.id/api/customer/auth/masuk',
      );
      expect(
        client.resolveUri(
          '/api/public/products?kategori=kopi',
          queryParameters: <String, String>{'aktif': 'true'},
        ).toString(),
        'https://api.soju.id/api/public/products?kategori=kopi&aktif=true',
      );
    });
  });

  group('HttpApiClient — HTTP verbs & headers', () {
    test('mengirim GET, POST, PUT, PATCH, DELETE dengan JSON dan Bearer token',
        () async {
      final List<http.Request> captured = <http.Request>[];
      final _MemoryTokenStorage storage = _MemoryTokenStorage(token: 'jwt-123');
      final HttpApiClient client = HttpApiClient(
        baseUrl: 'http://localhost:4000/api/v1',
        tokenStorage: storage,
        client: MockClient((http.Request request) async {
          captured.add(request);
          return http.Response(
            jsonEncode(<String, Object?>{
              'success': true,
              'method': request.method,
            }),
            200,
          );
        }),
      );

      final ApiResponse getRes = await client.get(
        '/api/v1/users',
        queryParameters: <String, String>{'peran': 'ADMIN'},
      );
      final ApiResponse postRes = await client.post(
        '/auth/login',
        body: <String, Object?>{'email': 'a@b.com'},
        authenticated: false,
      );
      final ApiResponse putRes = await client.put(
        '/api/customer/keranjang',
        body: <String, Object?>{'items': <Object?>[]},
      );
      final ApiResponse patchRes = await client.patch(
        '/api/v1/customer-orders/5/status',
        body: <String, Object?>{'status': 'DIPROSES'},
      );
      final ApiResponse deleteRes = await client.delete(
        '/api/v1/users/9',
      );

      expect(getRes.statusCode, 200);
      expect(postRes.statusCode, 200);
      expect(putRes.statusCode, 200);
      expect(patchRes.statusCode, 200);
      expect(deleteRes.statusCode, 200);

      expect(captured.map((http.Request r) => r.method).toList(), <String>[
        'GET',
        'POST',
        'PUT',
        'PATCH',
        'DELETE',
      ]);

      // GET: authenticated, no Content-Type, query params preserved
      expect(captured[0].url.toString(), 'http://localhost:4000/api/v1/users?peran=ADMIN');
      expect(captured[0].headers['Accept'], 'application/json');
      expect(captured[0].headers['Authorization'], 'Bearer jwt-123');
      expect(captured[0].headers.containsKey('Content-Type'), isFalse);

      // POST: unauthenticated, JSON body & Content-Type
      expect(captured[1].url.toString(), 'http://localhost:4000/api/v1/auth/login');
      expect(captured[1].headers['Authorization'], isNull);
      expect(captured[1].headers['Content-Type'], 'application/json');
      expect(jsonDecode(captured[1].body), <String, Object?>{'email': 'a@b.com'});

      // PUT: customer prefix, JSON body, Bearer token
      expect(captured[2].url.toString(), 'http://localhost:4000/api/customer/keranjang');
      expect(captured[2].headers['Authorization'], 'Bearer jwt-123');
      expect(captured[2].headers['Content-Type'], 'application/json');
      expect(jsonDecode(captured[2].body), <String, Object?>{'items': <Object?>[]});

      // PATCH: v1 prefix, JSON body, Bearer token
      expect(captured[3].url.toString(), 'http://localhost:4000/api/v1/customer-orders/5/status');
      expect(captured[3].headers['Authorization'], 'Bearer jwt-123');
      expect(captured[3].headers['Content-Type'], 'application/json');
      expect(jsonDecode(captured[3].body), <String, Object?>{'status': 'DIPROSES'});

      // DELETE: v1 prefix, no body, Bearer token
      expect(captured[4].url.toString(), 'http://localhost:4000/api/v1/users/9');
      expect(captured[4].headers['Authorization'], 'Bearer jwt-123');
      expect(captured[4].headers.containsKey('Content-Type'), isFalse);
    });

    test('mengembalikan body null ketika respons kosong (204)', () async {
      final HttpApiClient client = HttpApiClient(
        baseUrl: 'http://localhost:4000',
        tokenStorage: _MemoryTokenStorage(token: 'jwt-123'),
        client: MockClient((_) async => http.Response('', 204)),
      );

      final ApiResponse res = await client.delete('/api/v1/users/9');
      expect(res.statusCode, 204);
      expect(res.body, isNull);
    });
  });

  group('HttpApiClient — AppFailure error mapping', () {
    test('melempar UnauthorizedFailure jika authenticated=true tanpa token',
        () async {
      final HttpApiClient client = HttpApiClient(
        baseUrl: 'http://localhost:4000',
        tokenStorage: _MemoryTokenStorage(),
        client: MockClient((_) async => http.Response('{}', 200)),
      );

      await expectLater(
        () => client.patch('/api/v1/users/1', body: <String, Object?>{}),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('melempar NetworkFailure saat timeout', () async {
      final HttpApiClient client = HttpApiClient(
        baseUrl: 'http://localhost:4000',
        tokenStorage: _MemoryTokenStorage(token: 'jwt-123'),
        timeout: const Duration(milliseconds: 10),
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 60));
          return http.Response('{}', 200);
        }),
      );

      await expectLater(
        () => client.put('/api/customer/keranjang', body: <String, Object?>{}),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('melempar NetworkFailure saat http.ClientException', () async {
      final HttpApiClient client = HttpApiClient(
        baseUrl: 'http://localhost:4000',
        tokenStorage: _MemoryTokenStorage(token: 'jwt-123'),
        client: MockClient((_) async {
          throw http.ClientException('connection refused');
        }),
      );

      await expectLater(
        () => client.delete('/api/v1/users/1'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('melempar ParsingFailure saat respons bukan JSON valid', () async {
      final HttpApiClient client = HttpApiClient(
        baseUrl: 'http://localhost:4000',
        tokenStorage: _MemoryTokenStorage(token: 'jwt-123'),
        client: MockClient((_) async => http.Response('<html>error</html>', 200)),
      );

      await expectLater(
        () => client.get('/api/public/products', authenticated: false),
        throwsA(isA<ParsingFailure>()),
      );
    });
  });
}

class _MemoryTokenStorage implements TokenStorage {
  _MemoryTokenStorage({this.token});

  String? token;
  String? role;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async {
    this.token = token;
  }

  @override
  Future<String?> readRole() async => role;

  @override
  Future<void> writeRole(String role) async {
    this.role = role;
  }

  @override
  Future<void> clear() async {
    token = null;
    role = null;
  }
}
