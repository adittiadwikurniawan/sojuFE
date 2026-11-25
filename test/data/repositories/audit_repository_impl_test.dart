// Unit test: repository audit (mock datasource + envelope + failure mapping).

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/data/datasources/interfaces/audit_datasource.dart';
import 'package:soju_fe/data/datasources/mock/audit_mock_datasource.dart';
import 'package:soju_fe/data/repositories/audit_repository_impl.dart';
import 'package:soju_fe/domain/entities/audit_log_entity.dart';
import 'package:soju_fe/domain/repositories/audit_repository.dart';

/// Datasource palsu yang mengembalikan payload mentah tertentu.
class _StubDataSource implements AuditDataSource {
  _StubDataSource(this.payload);

  final Map<String, Object?> payload;

  @override
  Future<Map<String, Object?>> fetchRawAuditLogs({
    required AuditLogQuery query,
  }) async =>
      payload;
}

void main() {
  final DateTime now = DateTime(2026, 11, 17, 12);

  Map<String, Object?> envelopeWith(List<Map<String, Object?>> logs) {
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'logs': logs,
        'pagination': <String, Object?>{
          'page': 1,
          'per_page': 12,
          'total': logs.length,
          'has_next': false,
        },
      },
    };
  }

  group('AuditRepositoryImpl dengan payload tertentu', () {
    test('sukses: envelope dan DTO dipetakan ke entity', () async {
      final AuditLogRepository repository = AuditRepositoryImpl(
        _StubDataSource(
          envelopeWith(<Map<String, Object?>>[
            <String, Object?>{
              'id': 'log-1',
              'waktu': '2026-11-17T02:00:00Z',
              'aksi': 'tambah',
              'record_type': 'transaksi',
              'record_nama': 'Penjualan #1023',
              'detail': 'Total Rp 36.000.',
              'pengguna': 'Rina',
            },
          ]),
        ),
      );

      final Result<AuditLogPageEntity> result =
          await repository.fetchAuditLogs(query: const AuditLogQuery(days: 7));

      expect(result.isSuccess, isTrue);
      result.fold(
        onFailure: (AppFailure _) => fail('seharusnya sukses'),
        onSuccess: (AuditLogPageEntity page) {
          expect(page.logs, hasLength(1));
          expect(page.logs.first.pengguna, 'Rina');
          expect(page.hasNext, isFalse);
        },
      );
    });

    test('envelope success=false menghasilkan kegagalan', () async {
      final AuditLogRepository repository = AuditRepositoryImpl(
        _StubDataSource(<String, Object?>{
          'success': false,
          'message': 'Akses ditolak.',
        }),
      );

      final Result<AuditLogPageEntity> result =
          await repository.fetchAuditLogs(query: const AuditLogQuery());

      expect(result.isFailure, isTrue);
      result.fold(
        onFailure: (AppFailure failure) {
          expect(failure, isA<EnvelopeFailure>());
          expect(failure.message, 'Akses ditolak.');
        },
        onSuccess: (AuditLogPageEntity _) => fail('seharusnya gagal'),
      );
    });

    test('payload rusak menghasilkan ParsingFailure', () async {
      final AuditLogRepository repository = AuditRepositoryImpl(
        _StubDataSource(<String, Object?>{
          'success': true,
          'data': <String, Object?>{'logs': 'bukan-list'},
        }),
      );

      final Result<AuditLogPageEntity> result =
          await repository.fetchAuditLogs(query: const AuditLogQuery());

      expect(result.failureOrNull, isA<ParsingFailure>());
    });

    test('data null menghasilkan kegagalan envelope', () async {
      final AuditLogRepository repository = AuditRepositoryImpl(
        _StubDataSource(<String, Object?>{'success': true}),
      );

      final Result<AuditLogPageEntity> result =
          await repository.fetchAuditLogs(query: const AuditLogQuery());

      expect(result.failureOrNull, isA<EnvelopeFailure>());
    });
  });

  group('AuditMockDataSource', () {
    late AuditMockDataSource dataSource;

    setUp(() {
      dataSource = AuditMockDataSource(now: () => now);
    });

    test('filter 7 hari tidak memuat log di luar rentang', () async {
      final Map<String, Object?> payload = await dataSource.fetchRawAuditLogs(
          query: const AuditLogQuery(days: 7));

      final Map<String, Object?> data =
          payload['data']! as Map<String, Object?>;
      for (final Object? log in data['logs']! as List<Object?>) {
        final DateTime waktu =
            DateTime.parse((log! as Map<String, Object?>)['waktu']! as String);
        expect(
          now.difference(waktu.toLocal()).inDays,
          lessThanOrEqualTo(8),
        );
      }
      expect((data['pagination']! as Map)['has_next'], isTrue);
    });

    test('paginasi: halaman berikut menghasilkan log berbeda', () async {
      final Map<String, Object?> page1 = await dataSource.fetchRawAuditLogs(
          query: const AuditLogQuery(days: 90));
      final Map<String, Object?> page2 = await dataSource.fetchRawAuditLogs(
          query: const AuditLogQuery(days: 90, page: 2));

      final List<Object?> logs1 =
          (page1['data']! as Map)['logs']! as List<Object?>;
      final List<Object?> logs2 =
          (page2['data']! as Map)['logs']! as List<Object?>;

      expect(logs1, hasLength(12));
      expect(logs2, hasLength(12));
      final String id1 = (logs1.first as Map)['id']! as String;
      final String id2 = (logs2.first as Map)['id']! as String;
      expect(id1, isNot(id2));
    });

    test('rentang kustom memfilter per tanggal secara inklusif', () async {
      final DateTime start = DateTime(2026, 11, 1);
      final DateTime end = DateTime(2026, 11, 5);
      final Map<String, Object?> payload = await dataSource.fetchRawAuditLogs(
        query: AuditLogQuery(startDate: start, endDate: end),
      );

      final List<Object?> logs =
          (payload['data']! as Map)['logs']! as List<Object?>;
      expect(logs, isNotEmpty);
      for (final Object? log in logs) {
        final DateTime waktu = DateTime.parse(
          (log! as Map<String, Object?>)['waktu']! as String,
        ).toLocal();
        final DateTime day = DateTime(waktu.year, waktu.month, waktu.day);
        expect(day.isBefore(start), isFalse);
        expect(day.isAfter(end), isFalse);
      }
    });

    test('opsi semua waktu tetap mengembalikan envelope sukses', () async {
      final Map<String, Object?> payload =
          await dataSource.fetchRawAuditLogs(query: const AuditLogQuery());

      expect(payload['success'], isTrue);
      final Object? total =
          ((payload['data']! as Map)['pagination']! as Map)['total'];
      expect(total, greaterThan(0));
    });
  });
}
