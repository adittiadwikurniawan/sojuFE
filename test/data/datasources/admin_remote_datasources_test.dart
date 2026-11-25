// test/data/datasources/admin_remote_datasources_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/core/services/api_client/api_client.dart';
import 'package:soju_fe/core/services/api_client/api_response.dart';
import 'package:soju_fe/data/datasources/remote/admin_order_remote_datasource.dart';
import 'package:soju_fe/data/datasources/remote/audit_remote_datasource.dart';
import 'package:soju_fe/data/datasources/remote/dashboard_remote_datasource.dart';
import 'package:soju_fe/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:soju_fe/domain/entities/audit_log_entity.dart';

class _FakeApiClient implements ApiClient {
  String? lastGetPath;
  Map<String, String>? lastGetQuery;
  String? lastPatchPath;
  Object? lastPatchBody;

  ApiResponse getResponse = const ApiResponse(
    statusCode: 200,
    body: <String, Object?>{'success': true, 'data': <Object?>[]},
  );
  ApiResponse patchResponse = const ApiResponse(
    statusCode: 200,
    body: <String, Object?>{'success': true, 'data': <String, Object?>{}},
  );

  @override
  Future<ApiResponse> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    lastGetPath = path;
    lastGetQuery = queryParameters;
    return getResponse;
  }

  @override
  Future<ApiResponse> patch(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    lastPatchPath = path;
    lastPatchBody = body;
    return patchResponse;
  }

  @override
  Future<ApiResponse> post(String path, {Object? body, Map<String, String>? queryParameters, bool authenticated = true}) => throw UnimplementedError();

  @override
  Future<ApiResponse> put(String path, {Object? body, Map<String, String>? queryParameters, bool authenticated = true}) => throw UnimplementedError();

  @override
  Future<ApiResponse> delete(String path, {Object? body, Map<String, String>? queryParameters, bool authenticated = true}) => throw UnimplementedError();
}

void main() {
  group('AdminRemoteDataSources', () {
    late _FakeApiClient fakeClient;

    setUp(() {
      fakeClient = _FakeApiClient();
    });

    test('AuditRemoteDataSource calls /api/v1/audit-log with date range and days query', () async {
      final dataSource = AuditRemoteDataSource(fakeClient);

      // Query with days
      await dataSource.fetchRawAuditLogs(query: const AuditLogQuery(days: 30, page: 2));
      expect(fakeClient.lastGetPath, '/api/v1/audit-log');
      expect(fakeClient.lastGetQuery?['days'], '30');
      expect(fakeClient.lastGetQuery?['page'], '2');

      // Query with custom dates
      await dataSource.fetchRawAuditLogs(
        query: AuditLogQuery(
          startDate: DateTime(2026, 11, 1),
          endDate: DateTime(2026, 11, 20),
          page: 1,
        ),
      );
      expect(fakeClient.lastGetQuery?['dateFrom'], '2026-11-01');
      expect(fakeClient.lastGetQuery?['dateTo'], '2026-11-20');
    });

    test('DashboardRemoteDataSource calls summary, chart, and activities', () async {
      final dataSource = DashboardRemoteDataSource(fakeClient);

      await dataSource.fetchSummary(period: '30d');
      expect(fakeClient.lastGetPath, '/api/v1/dashboard/summary');
      expect(fakeClient.lastGetQuery?['periode'], '30d');

      await dataSource.fetchCashChart(period: '7d');
      expect(fakeClient.lastGetPath, '/api/v1/dashboard/grafik-kas');
      expect(fakeClient.lastGetQuery?['periode'], '7d');

      await dataSource.fetchRecentActivities(limit: 10);
      expect(fakeClient.lastGetPath, '/api/v1/dashboard/aktivitas-terbaru');
      expect(fakeClient.lastGetQuery?['limit'], '10');
    });

    test('TransactionRemoteDataSource calls /api/v1/transactions with search and date filters', () async {
      final dataSource = TransactionRemoteDataSource(fakeClient);

      await dataSource.fetchTransactionsRaw(search: 'Sosis', startDate: '2026-11-01', endDate: '2026-11-25');
      expect(fakeClient.lastGetPath, '/api/v1/transactions');
      expect(fakeClient.lastGetQuery?['search'], 'Sosis');
      expect(fakeClient.lastGetQuery?['tanggal_mulai'], '2026-11-01');
      expect(fakeClient.lastGetQuery?['tanggal_selesai'], '2026-11-25');
    });

    test('AdminOrderRemoteDataSource fetches orders and patches status', () async {
      final dataSource = AdminOrderRemoteDataSource(fakeClient);

      await dataSource.fetchOrdersRaw(status: 'DIPROSES');
      expect(fakeClient.lastGetPath, '/api/v1/customer-orders');
      expect(fakeClient.lastGetQuery?['status'], 'DIPROSES');

      await dataSource.updateOrderStatusRaw(id: 42, status: 'SELESAI');
      expect(fakeClient.lastPatchPath, '/api/v1/customer-orders/42/status');
      expect(fakeClient.lastPatchBody, <String, Object?>{'status': 'SELESAI'});
    });

    test('handles 401 unauthorized gracefully', () async {
      fakeClient.getResponse = const ApiResponse(statusCode: 401, body: <String, Object?>{'message': 'Akses ditolak'});
      final dataSource = AdminOrderRemoteDataSource(fakeClient);

      expect(
        () => dataSource.fetchOrdersRaw(),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });
}
