// Unit test: DTO model audit log (GET /api/v1/audit-log).

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/data/models/audit/audit_log_model.dart';
import 'package:soju_fe/domain/entities/audit_log_entity.dart';

void main() {
  group('AuditLogEntryModel.fromRaw', () {
    test('mengurai field lengkap dan memetakan ke entity', () {
      final AuditLogEntryModel model = AuditLogEntryModel.fromJson(
        <String, Object?>{
          'id': 'log-1',
          'waktu': '2026-11-17T09:24:00.000Z',
          'aksi': 'tambah',
          'record_type': 'transaksi',
          'record_nama': 'Penjualan Sosis Solo #1023',
          'detail': 'Jumlah 2 porsi.',
          'pengguna': 'Rina',
        },
      );

      expect(model.id, 'log-1');
      expect(model.aksi, 'tambah');
      expect(model.recordTipe, 'transaksi');
      expect(model.recordNama, 'Penjualan Sosis Solo #1023');
      expect(model.detail, 'Jumlah 2 porsi.');
      expect(model.pengguna, 'Rina');

      final AuditLogEntryEntity entity = model.toEntity();
      expect(entity.waktu, DateTime.utc(2026, 11, 17, 9, 24));
      expect(entity.actionKind, AuditActionKind.created);
    });

    test('pengguna bentuk objek diurai menjadi nama', () {
      final AuditLogEntryModel model = AuditLogEntryModel.fromJson(
        <String, Object?>{
          'waktu': '2026-11-17T02:00:00Z',
          'aksi': 'ubah',
          'user': <String, Object?>{'id': 'u1', 'nama': 'Dimas'},
        },
      );

      expect(model.pengguna, 'Dimas');
      expect(model.recordNama, isNull);
      expect(model.toEntity().actionKind, AuditActionKind.updated);
    });

    test('aksi tak dikenal jatuh ke kategori other', () {
      final AuditLogEntryModel model = AuditLogEntryModel.fromJson(
        <String, Object?>{
          'waktu': '2026-11-17T02:00:00Z',
          'aksi': 'ekspor',
        },
      );

      expect(model.toEntity().actionKind, AuditActionKind.other);
    });

    test('lempar FormatException bila waktu absen', () {
      expect(
        () => AuditLogEntryModel.fromJson(<String, Object?>{
          'aksi': 'tambah',
        }),
        throwsFormatException,
      );
    });

    test('lempar FormatException bila aksi absen', () {
      expect(
        () => AuditLogEntryModel.fromJson(<String, Object?>{
          'waktu': '2026-11-17T02:00:00Z',
        }),
        throwsFormatException,
      );
    });
  });

  group('AuditLogPageModel.fromRaw', () {
    test('mengurai logs dan pagination', () {
      final AuditLogPageModel page = AuditLogPageModel.fromJson(
        <String, Object?>{
          'logs': <Object?>[
            <String, Object?>{
              'id': 'log-1',
              'waktu': '2026-11-17T02:00:00Z',
              'aksi': 'hapus',
              'record_type': 'produk',
              'record_nama': 'Risol Mayo',
            },
          ],
          'pagination': <String, Object?>{
            'page': 2,
            'per_page': 12,
            'total': 34,
            'total_pages': 3,
            'has_next': true,
          },
        },
      );

      final AuditLogPageEntity entity = page.toEntity();
      expect(entity.logs, hasLength(1));
      expect(entity.logs.first.actionKind, AuditActionKind.deleted);
      expect(entity.page, 2);
      expect(entity.perPage, 12);
      expect(entity.total, 34);
      expect(entity.totalPages, 3);
      expect(entity.hasNext, isTrue);
    });

    test('pagination absen tetap terurai dengan fallback', () {
      final AuditLogPageModel page = AuditLogPageModel.fromJson(
        <String, Object?>{
          'logs': <Object?>[],
        },
      );

      expect(page.pagination.page, 1);
      expect(page.pagination.hasNext, isFalse);
      expect(page.toEntity().logs, isEmpty);
    });

    test('lempar FormatException bila logs bukan list', () {
      expect(
        () => AuditLogPageModel.fromJson(<String, Object?>{
          'logs': 'bukan',
        }),
        throwsFormatException,
      );
    });
  });
}
