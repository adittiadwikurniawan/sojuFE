// Widget test: modal Buat Kategori Baru Tabel Bebas (frame `546:5163`).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/core/themes/app_theme.dart';
import 'package:soju_fe/domain/entities/free_table_entity.dart';
import 'package:soju_fe/domain/repositories/free_table_repository.dart';
import 'package:soju_fe/domain/usecases/free_table_usecases.dart';
import 'package:soju_fe/presentation/providers/free_tables/free_table_category_controller.dart';
import 'package:soju_fe/presentation/screens/free_tables/free_table_category_screen.dart';

const FreeTableCategoryEntity _savedCategory = FreeTableCategoryEntity(
  id: 'kategori-1',
  name: 'Log Checklist & Suhu Freezer',
  cashflowType: FreeTableCashflowType.freeTable,
  department: 'Area Dapur Utama',
  fields: <FreeTableFieldEntity>[
    FreeTableFieldEntity(
      id: 'field-1',
      label: 'Nama Alat / Item',
      type: FreeTableFieldType.shortText,
      isRequired: true,
    ),
  ],
);

class _FakeRepository implements FreeTableRepository {
  _FakeRepository({this.result, this.completer});

  Result<FreeTableCategoryEntity>? result;
  Completer<Result<FreeTableCategoryEntity>>? completer;
  int callCount = 0;

  @override
  Future<Result<FreeTableCategoryEntity>> createCategory({
    required FreeTableCategoryDraft draft,
  }) {
    callCount++;
    final Completer<Result<FreeTableCategoryEntity>>? pending = completer;
    if (pending != null) {
      return pending.future;
    }
    return Future<Result<FreeTableCategoryEntity>>.value(
      result ?? Result<FreeTableCategoryEntity>.success(_savedCategory),
    );
  }
}

Future<void> _pumpScreen(
  WidgetTester tester,
  _FakeRepository repository, {
  Size size = const Size(430, 932),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: FreeTableCategoryScreen(
        onClose: () {},
        controllerFactory: () => FreeTableCategoryController(
          createCategory: CreateFreeTableCategory(repository),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menampilkan seluruh bagian utama form', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(tester, _FakeRepository());

    expect(find.text('Buat Kategori Baru'), findsOneWidget);
    expect(
      find.text('Pendataan operasional fleksibel & non-keuangan'),
      findsOneWidget,
    );
    expect(find.text('Nama Kategori *'), findsOneWidget);
    expect(find.text('Tipe Arus Kas *'), findsOneWidget);
    expect(find.text('Target Departemen / Lokasi'), findsOneWidget);
    expect(find.text('Kolom Pendataan Tambahan'), findsOneWidget);
    expect(find.text('FR-4 Custom Field'), findsOneWidget);
    expect(find.text('Nama Alat / Item'), findsOneWidget);
    expect(find.text('Suhu (°C) / Kuantitas'), findsOneWidget);
    expect(find.text('Jadwal Servis / Pengecekan'), findsOneWidget);
    expect(find.text('Petugas Shift (PIC)'), findsOneWidget);
    expect(find.text('Simpan & Buat Tabel Bebas'), findsOneWidget);
    expect(
      find.text('Tabel baru akan langsung aktif di menu Data Pembukuan.'),
      findsOneWidget,
    );
    expect(find.text('Wajib'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('menambah dan menghapus kolom kustom', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(tester, _FakeRepository());

    final Finder addButton = find.byKey(const Key('free_table_add_field'));
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Kolom Teks'), findsOneWidget);

    final Finder deleteButton = find.byKey(
      const Key('free_table_field_delete_custom-field-1'),
    );
    await tester.ensureVisible(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Kolom Teks'), findsNothing);
  });

  testWidgets('memilih tipe angka lalu menambah kolom', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(tester, _FakeRepository());

    final Finder typeButton = find.byKey(
      const Key('free_table_field_type_number'),
    );
    await tester.ensureVisible(typeButton);
    await tester.pumpAndSettle();
    await tester.tap(typeButton);
    await tester.pumpAndSettle();

    final Finder addButton = find.byKey(const Key('free_table_add_field'));
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Kolom Angka'), findsOneWidget);
  });

  testWidgets('nama kosong menampilkan validasi tanpa memanggil repository', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository();
    await _pumpScreen(tester, repository);

    await tester.enterText(
      find.byKey(const Key('free_table_category_name_field')),
      '',
    );
    await tester.tap(find.byKey(const Key('free_table_save_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('free_table_name_error')), findsOneWidget);
    expect(find.byKey(const Key('free_table_footer_message')), findsOneWidget);
    expect(repository.callCount, 0);
  });

  testWidgets('kolom kosong menampilkan validasi di panel dan footer', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository();
    await _pumpScreen(tester, repository);

    for (final String fieldId in <String>[
      'field-nama-alat',
      'field-suhu-kuantitas',
      'field-jadwal-servis',
      'field-petugas-shift',
    ]) {
      final Finder deleteButton = find.byKey(
        Key('free_table_field_delete_$fieldId'),
      );
      await tester.ensureVisible(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byKey(const Key('free_table_save_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('free_table_fields_error')), findsOneWidget);
    expect(find.byKey(const Key('free_table_footer_message')), findsOneWidget);
    expect(find.text('Tambahkan minimal satu kolom pendataan.'), findsWidgets);
    expect(repository.callCount, 0);
  });

  testWidgets('sukses menampilkan status tersimpan', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository();
    await _pumpScreen(tester, repository);

    await tester.tap(find.byKey(const Key('free_table_save_button')));
    await tester.pumpAndSettle();

    expect(repository.callCount, 1);
    expect(find.byKey(const Key('free_table_success_message')), findsOneWidget);
    expect(find.text('Kategori berhasil dibuat.'), findsOneWidget);
    expect(find.text('Tersimpan'), findsOneWidget);
  });

  testWidgets('gagal menampilkan pesan dan tombol coba lagi', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository(
      result: Result<FreeTableCategoryEntity>.failure(
        const ServerFailure(message: 'Gagal menyimpan kategori.'),
      ),
    );
    await _pumpScreen(tester, repository);

    await tester.tap(find.byKey(const Key('free_table_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Gagal menyimpan kategori.'), findsOneWidget);
    expect(find.text('Coba Simpan Lagi'), findsOneWidget);
    expect(find.byKey(const Key('free_table_footer_message')), findsOneWidget);
  });

  testWidgets('status menyimpan tampil saat request berjalan', (
    WidgetTester tester,
  ) async {
    final Completer<Result<FreeTableCategoryEntity>> completer =
        Completer<Result<FreeTableCategoryEntity>>();
    final _FakeRepository repository = _FakeRepository(completer: completer);
    await _pumpScreen(tester, repository);

    await tester.tap(find.byKey(const Key('free_table_save_button')));
    await tester.pump();

    expect(find.text('Menyimpan...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(
      Result<FreeTableCategoryEntity>.success(_savedCategory),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tersimpan'), findsOneWidget);
  });

  testWidgets('layout tetap utuh pada layar Android sempit', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(
      tester,
      _FakeRepository(),
      size: const Size(320, 568),
    );

    expect(find.text('Buat Kategori Baru'), findsOneWidget);
    expect(find.byKey(const Key('free_table_save_button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
