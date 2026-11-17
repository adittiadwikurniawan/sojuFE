// Widget test: layar Audit & Stok (frame 546:4741) — 4 state utama dan
// jaminan tidak ada kontrol mutasi bisnis.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/audit_log_entity.dart';
import 'package:soju_fe/domain/repositories/audit_repository.dart';
import 'package:soju_fe/domain/usecases/audit_usecases.dart';
import 'package:soju_fe/presentation/providers/audit/audit_log_controller.dart';
import 'package:soju_fe/presentation/screens/audit/audit_screen.dart';
import 'package:soju_fe/presentation/screens/audit/widgets/audit_range_chips.dart';

/// Repository palsu dengan skenario yang dapat dikonfigurasi.
class _FakeAuditRepository implements AuditLogRepository {
  _FakeAuditRepository({
    this.page,
    this.empty = false,
    this.fail = false,
    this.delay = Duration.zero,
  });

  AuditLogPageEntity? page;
  bool empty;
  bool fail;

  /// Jeda sebelum respons, untuk menguji state loading.
  final Duration delay;
  final List<AuditLogQuery> queries = <AuditLogQuery>[];

  @override
  Future<Result<AuditLogPageEntity>> fetchAuditLogs({
    required AuditLogQuery query,
  }) async {
    queries.add(query);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (fail) {
      return Result.failure(
        const ServerFailure(message: 'Koneksi terputus.'),
      );
    }
    if (empty) {
      return Result.success(
        const AuditLogPageEntity(
          logs: <AuditLogEntryEntity>[],
          page: 1,
          hasNext: false,
        ),
      );
    }
    return Result.success(
      page ??
          const AuditLogPageEntity(
            logs: <AuditLogEntryEntity>[],
            page: 1,
            hasNext: false,
          ),
    );
  }
}

AuditLogPageEntity samplePage() {
  final DateTime now = DateTime.now();
  // Pakai tengah hari agar data contoh tidak berpindah hari saat test
  // dijalankan lewat tengah malam.
  final DateTime todayNoon = DateTime(now.year, now.month, now.day, 12);
  AuditLogEntryEntity entry(
    String id,
    String aksi,
    String nama,
    DateTime waktu,
  ) {
    return AuditLogEntryEntity(
      id: id,
      waktu: waktu,
      aksi: aksi,
      recordTipe: 'transaksi',
      recordNama: nama,
      detail: 'Detail $id.',
      pengguna: 'Rina',
    );
  }

  return AuditLogPageEntity(
    logs: <AuditLogEntryEntity>[
      entry(
        'log-1',
        'tambah',
        'Penjualan Sosis Solo #1023',
        todayNoon,
      ),
      entry(
        'log-2',
        'hapus',
        'Pembelian Ayam Segar',
        todayNoon.subtract(const Duration(days: 2)),
      ),
    ],
    page: 1,
    total: 2,
    hasNext: false,
  );
}

Future<AuditScreen> _screenFor(_FakeAuditRepository repository) async {
  return AuditScreen(
    controllerFactory: () =>
        AuditLogController(getAuditLogs: GetAuditLogs(repository)),
  );
}

Future<void> _pumpWith(
  WidgetTester tester,
  _FakeAuditRepository repository,
) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final AuditScreen screen = await _screenFor(repository);
  await tester.pumpWidget(MaterialApp(home: screen));
}

void main() {
  testWidgets('state data: log audit tampil terkelompok per hari',
      (WidgetTester tester) async {
    final _FakeAuditRepository repository =
        _FakeAuditRepository(page: samplePage());
    await _pumpWith(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Audit & Stok'), findsOneWidget);
    expect(find.text('Log Aktivitas'), findsOneWidget);
    expect(find.text('2 log'), findsOneWidget);
    expect(find.text('Hari Ini'), findsOneWidget);
    expect(find.text('Penjualan Sosis Solo #1023'), findsOneWidget);
    expect(find.text('Ditambahkan'), findsOneWidget);
    // Pengguna tersedia dan ditampilkan (kedua log memakai Rina).
    expect(find.text('Rina'), findsWidgets);
    // Ini chip default 7 hari (kartu tanggal juga menampilkan label yang sama).
    expect(
      find.descendant(
        of: find.byType(AuditRangeChips),
        matching: find.text('7 Hari'),
      ),
      findsOneWidget,
    );
    expect(find.text('Semua log sudah ditampilkan'), findsOneWidget);
  });

  testWidgets('state loading tampil sebelum data siap',
      (WidgetTester tester) async {
    final _FakeAuditRepository repository = _FakeAuditRepository(
      delay: const Duration(milliseconds: 200),
    );
    await _pumpWith(tester, repository);

    // Belum pumpAndSettle: pastikan indikator proses tampil.
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    await tester.pumpAndSettle();
  });

  testWidgets('state empty: pesan kosong bukan galat',
      (WidgetTester tester) async {
    final _FakeAuditRepository repository = _FakeAuditRepository(empty: true);
    await _pumpWith(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Belum ada aktivitas'), findsOneWidget);
    expect(find.text('Coba lagi'), findsNothing);
  });

  testWidgets('state error: tombol Coba lagi memuat ulang',
      (WidgetTester tester) async {
    final _FakeAuditRepository repository = _FakeAuditRepository(fail: true);
    await _pumpWith(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat log audit'), findsOneWidget);
    expect(find.text('Koneksi terputus.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);

    repository.fail = false;
    repository.page = samplePage();
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Penjualan Sosis Solo #1023'), findsOneWidget);
    expect(_queriesCount(repository), 2);
  });

  testWidgets('mengganti rentang memuat ulang dengan days berbeda',
      (WidgetTester tester) async {
    final _FakeAuditRepository repository =
        _FakeAuditRepository(page: samplePage());
    await _pumpWith(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text('30 Hari'));
    await tester.pumpAndSettle();

    expect(repository.queries.last.days, 30);
    expect(
      find.descendant(
        of: find.byType(AuditRangeChips),
        matching: find.text('30 Hari'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('kartu tanggal memakai rentang kustom lalu bisa dihapus',
      (WidgetTester tester) async {
    final _FakeAuditRepository repository =
        _FakeAuditRepository(page: samplePage());
    await _pumpWith(tester, repository);
    await tester.pumpAndSettle();

    final DateTime now = DateTime.now();
    await tester.tap(find.byKey(const Key('date_filter_card')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(Key('soju_calendar_day_${now.year}_${now.month}_1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(repository.queries.last.days, isNull);
    expect(
      repository.queries.last.startDate,
      DateTime(now.year, now.month, 1),
    );
    expect(
      repository.queries.last.endDate,
      DateTime(now.year, now.month, 1),
    );

    await tester.tap(find.byKey(const Key('date_filter_card')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(repository.queries.last.startDate, isNull);
    expect(repository.queries.last.endDate, isNull);
    expect(repository.queries.last.days, 7);
  });

  testWidgets('tidak ada kontrol mutasi (tambah/edit/hapus/rekonsiliasi/AI)',
      (WidgetTester tester) async {
    final _FakeAuditRepository repository =
        _FakeAuditRepository(page: samplePage());
    await _pumpWith(tester, repository);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.byIcon(Icons.edit), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}

int _queriesCount(_FakeAuditRepository repository) => repository.queries.length;
