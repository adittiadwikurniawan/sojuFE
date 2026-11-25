// Unit test: controller log audit (state loading/data/empty/error + retry).

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/audit_log_entity.dart';
import 'package:soju_fe/domain/repositories/audit_repository.dart';
import 'package:soju_fe/domain/usecases/audit_usecases.dart';
import 'package:soju_fe/presentation/providers/audit/audit_log_controller.dart';

/// Repository palsu yang mencatat query dan mengembalikan jawaban tetap.
class _FakeAuditRepository implements AuditLogRepository {
  _FakeAuditRepository({
    this.page,
    this.failure,
  });

  AuditLogPageEntity? page;
  AppFailure? failure;
  final List<AuditLogQuery> queries = <AuditLogQuery>[];

  @override
  Future<Result<AuditLogPageEntity>> fetchAuditLogs({
    required AuditLogQuery query,
  }) async {
    queries.add(query);
    final AppFailure? failure = this.failure;
    if (failure != null) {
      return Result.failure(failure);
    }
    return Result.success(
      page ??
          AuditLogPageEntity(
            logs: const <AuditLogEntryEntity>[],
            page: query.page,
            hasNext: false,
          ),
    );
  }
}

AuditLogEntryEntity entry(String id, {DateTime? waktu}) {
  return AuditLogEntryEntity(
    id: id,
    waktu: waktu ?? DateTime(2026, 11, 17, 9),
    aksi: 'tambah',
    recordNama: 'Record $id',
  );
}

void main() {
  test('load sukses menghasilkan state data dengan pagination', () async {
    final _FakeAuditRepository repository = _FakeAuditRepository(
      page: AuditLogPageEntity(
        logs: <AuditLogEntryEntity>[entry('a'), entry('b')],
        page: 1,
        total: 42,
        hasNext: true,
      ),
    );
    final AuditLogController controller = AuditLogController(
      getAuditLogs: GetAuditLogs(repository),
    );

    await controller.load();

    expect(controller.state.status, AuditLogStatus.data);
    expect(controller.state.logs, hasLength(2));
    expect(controller.state.totalCount, 42);
    expect(controller.state.hasNext, isTrue);
    // Rentang default 7 hari terkirim ke repository.
    expect(repository.queries.single.days, 7);
    expect(repository.queries.single.page, 1);
  });

  test('daftar kosong adalah state empty, bukan error', () async {
    final AuditLogController controller = AuditLogController(
      getAuditLogs: GetAuditLogs(_FakeAuditRepository()),
    );

    await controller.load();

    expect(controller.state.status, AuditLogStatus.empty);
    expect(controller.state.totalCount, 0);
  });

  test('kegagalan menghasilkan state error dengan pesan', () async {
    final AuditLogController controller = AuditLogController(
      getAuditLogs: GetAuditLogs(
        _FakeAuditRepository(
          failure: const ServerFailure(message: 'Server bermasalah.'),
        ),
      ),
    );

    await controller.load();

    expect(controller.state.status, AuditLogStatus.error);
    expect(controller.state.errorMessage, 'Server bermasalah.');
  });

  test('setRange memuat ulang dengan days sesuai opsi', () async {
    final _FakeAuditRepository repository = _FakeAuditRepository(
      page: AuditLogPageEntity(
        logs: <AuditLogEntryEntity>[entry('a')],
        page: 1,
        total: 1,
        hasNext: true,
      ),
    );
    final AuditLogController controller = AuditLogController(
      getAuditLogs: GetAuditLogs(repository),
    );

    await controller.load();
    await controller.setRange(AuditRangeOption.days30);

    expect(controller.state.range, AuditRangeOption.days30);
    expect(repository.queries.last.days, 30);
    expect(repository.queries.last.page, 1);
    // Opsi semua waktu mengirim null.
    await controller.setRange(AuditRangeOption.all);
    expect(repository.queries.last.days, isNull);
  });

  test('setCustomRange mengirim start/end dan menghapus days', () async {
    final _FakeAuditRepository repository = _FakeAuditRepository();
    final AuditLogController controller = AuditLogController(
      getAuditLogs: GetAuditLogs(repository),
    );

    await controller.load();
    await controller.setCustomRange(
      DateTimeRange(
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 5),
      ),
    );

    expect(controller.state.hasCustomRange, isTrue);
    expect(repository.queries.last.startDate, DateTime(2026, 10, 1));
    expect(repository.queries.last.endDate, DateTime(2026, 10, 5));
    expect(repository.queries.last.days, isNull);

    // Memilih preset lagi harus menghapus rentang kustom.
    await controller.setRange(AuditRangeOption.days30);

    expect(controller.state.hasCustomRange, isFalse);
    expect(repository.queries.last.startDate, isNull);
    expect(repository.queries.last.endDate, isNull);
    expect(repository.queries.last.days, 30);
  });

  test('loadMore menambahkan log halaman berikut', () async {
    final _FakeAuditRepository repository = _FakeAuditRepository();
    repository.page = AuditLogPageEntity(
      logs: <AuditLogEntryEntity>[entry('a1'), entry('a2')],
      page: 1,
      total: 20,
      hasNext: true,
    );
    final AuditLogController controller = AuditLogController(
      getAuditLogs: GetAuditLogs(repository),
    );
    await controller.load();

    repository.page = AuditLogPageEntity(
      logs: <AuditLogEntryEntity>[entry('b1')],
      page: 2,
      total: 20,
      hasNext: false,
    );
    await controller.loadMore();

    expect(controller.state.logs, hasLength(3));
    expect(controller.state.page, 2);
    expect(controller.state.hasNext, isFalse);
    expect(controller.state.status, AuditLogStatus.data);
    expect(repository.queries.last.page, 2);
    expect(repository.queries.last.days, 7);
  });

  test('gagal muat selengkapnya tetap mempertahankan data', () async {
    final _FakeAuditRepository repository = _FakeAuditRepository();
    repository.page = AuditLogPageEntity(
      logs: <AuditLogEntryEntity>[entry('a1')],
      page: 1,
      total: 20,
      hasNext: true,
    );
    final AuditLogController controller = AuditLogController(
      getAuditLogs: GetAuditLogs(repository),
    );
    await controller.load();

    repository.failure = const NetworkFailure();
    await controller.loadMore();

    expect(controller.state.status, AuditLogStatus.data);
    expect(controller.state.logs, hasLength(1));
    expect(controller.state.loadMoreFailed, isTrue);
    expect(controller.state.isLoadingMore, isFalse);
    expect(controller.state.errorMessage, isNotNull);
  });
}
