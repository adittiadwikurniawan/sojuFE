// Unit test: controller form Buat Kategori Baru Tabel Bebas.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/domain/entities/free_table_entity.dart';
import 'package:soju_fe/domain/repositories/free_table_repository.dart';
import 'package:soju_fe/domain/usecases/free_table_usecases.dart';
import 'package:soju_fe/presentation/providers/free_tables/free_table_category_controller.dart';

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
  final List<FreeTableCategoryDraft> drafts = <FreeTableCategoryDraft>[];
  int callCount = 0;

  @override
  Future<Result<FreeTableCategoryEntity>> createCategory({
    required FreeTableCategoryDraft draft,
  }) {
    callCount++;
    drafts.add(draft);
    final Completer<Result<FreeTableCategoryEntity>>? pending = completer;
    if (pending != null) {
      return pending.future;
    }
    return Future<Result<FreeTableCategoryEntity>>.value(
      result ?? Result<FreeTableCategoryEntity>.success(_savedCategory),
    );
  }
}

FreeTableCategoryController _controller(_FakeRepository repository) {
  return FreeTableCategoryController(
    createCategory: CreateFreeTableCategory(repository),
  );
}

void main() {
  test('state awal sesuai contoh frame Tabel Bebas', () {
    final FreeTableCategoryController controller = _controller(
      _FakeRepository(),
    );
    addTearDown(controller.dispose);

    final FreeTableCategoryState state = controller.state;
    expect(state.name, 'Log Checklist & Suhu Freezer');
    expect(state.department, isEmpty);
    expect(state.cashflowType, FreeTableCashflowType.freeTable);
    expect(state.fields, hasLength(4));
    expect(state.selectedFieldType, FreeTableFieldType.shortText);
    expect(state.status, FreeTableCategoryStatus.editing);
    expect(state.nameError, isNull);
    expect(state.fieldsError, isNull);
  });

  test('memperbarui nama, departemen, dan tipe arus kas', () {
    final FreeTableCategoryController controller = _controller(
      _FakeRepository(),
    );
    addTearDown(controller.dispose);

    controller.updateName('Log Freezer');
    controller.updateDepartment('Area Dapur');
    controller.selectCashflowType(FreeTableCashflowType.expense);

    expect(controller.state.name, 'Log Freezer');
    expect(controller.state.department, 'Area Dapur');
    expect(controller.state.cashflowType, FreeTableCashflowType.expense);
  });

  test('menambah dan menghapus kolom sesuai tipe terpilih', () {
    final FreeTableCategoryController controller = _controller(
      _FakeRepository(),
    );
    addTearDown(controller.dispose);

    controller.selectFieldType(FreeTableFieldType.number);
    controller.addField();

    expect(controller.state.fields, hasLength(5));
    final FreeTableFieldEntity added = controller.state.fields.last;
    expect(added.id, 'custom-field-1');
    expect(added.label, 'Kolom Angka');
    expect(added.type, FreeTableFieldType.number);
    expect(added.isRequired, isFalse);

    controller.removeField(added.id);
    expect(controller.state.fields, hasLength(4));
    expect(
      controller.state.fields.any(
        (FreeTableFieldEntity field) => field.id == added.id,
      ),
      isFalse,
    );
  });

  test('nama kosong tidak dikirim dan menampilkan validasi', () async {
    final _FakeRepository repository = _FakeRepository();
    final FreeTableCategoryController controller = _controller(repository);
    addTearDown(controller.dispose);

    controller.updateName('   ');
    await controller.submit();

    expect(repository.callCount, 0);
    expect(controller.state.status, FreeTableCategoryStatus.editing);
    expect(controller.state.nameError, 'Nama kategori wajib diisi.');
    expect(controller.state.errorMessage, 'Nama kategori wajib diisi.');
  });

  test('kolom kosong tidak dikirim dan menampilkan validasi', () async {
    final _FakeRepository repository = _FakeRepository();
    final FreeTableCategoryController controller = _controller(repository);
    addTearDown(controller.dispose);

    for (final FreeTableFieldEntity field
        in List<FreeTableFieldEntity>.of(controller.state.fields)) {
      controller.removeField(field.id);
    }
    await controller.submit();

    expect(repository.callCount, 0);
    expect(controller.state.fields, isEmpty);
    expect(
      controller.state.fieldsError,
      'Tambahkan minimal satu kolom pendataan.',
    );
  });

  test('submit sukses memetakan draf dan menyimpan hasil', () async {
    final _FakeRepository repository = _FakeRepository();
    final FreeTableCategoryController controller = _controller(repository);
    addTearDown(controller.dispose);

    controller.updateName('  Log Freezer  ');
    controller.updateDepartment('  Area Dapur  ');
    await controller.submit();

    expect(repository.callCount, 1);
    expect(repository.drafts.single.name, 'Log Freezer');
    expect(repository.drafts.single.department, 'Area Dapur');
    expect(repository.drafts.single.fields, hasLength(4));
    expect(controller.state.status, FreeTableCategoryStatus.success);
    expect(controller.state.savedCategory, _savedCategory);
    expect(controller.state.errorMessage, isNull);
  });

  test('submit gagal menampilkan pesan kegagalan', () async {
    final _FakeRepository repository = _FakeRepository(
      result: Result<FreeTableCategoryEntity>.failure(
        const ServerFailure(message: 'Gagal menyimpan kategori.'),
      ),
    );
    final FreeTableCategoryController controller = _controller(repository);
    addTearDown(controller.dispose);

    await controller.submit();

    expect(controller.state.status, FreeTableCategoryStatus.error);
    expect(controller.state.errorMessage, 'Gagal menyimpan kategori.');
    expect(controller.state.savedCategory, isNull);
  });

  test('status saving tampil saat request masih berjalan', () async {
    final Completer<Result<FreeTableCategoryEntity>> completer =
        Completer<Result<FreeTableCategoryEntity>>();
    final _FakeRepository repository = _FakeRepository(completer: completer);
    final FreeTableCategoryController controller = _controller(repository);
    addTearDown(controller.dispose);

    final Future<void> pending = controller.submit();
    expect(controller.state.isSaving, isTrue);

    completer.complete(
      Result<FreeTableCategoryEntity>.success(_savedCategory),
    );
    await pending;

    expect(controller.state.isSaving, isFalse);
    expect(controller.state.status, FreeTableCategoryStatus.success);
  });

  test('request yang selesai setelah dispose tidak memberi notifikasi',
      () async {
    final Completer<Result<FreeTableCategoryEntity>> completer =
        Completer<Result<FreeTableCategoryEntity>>();
    final FreeTableCategoryController controller = _controller(
      _FakeRepository(completer: completer),
    );

    final Future<void> pending = controller.submit();
    controller.dispose();

    completer.complete(
      Result<FreeTableCategoryEntity>.success(_savedCategory),
    );

    await expectLater(pending, completes);
  });

  test('mengubah form setelah sukses kembali ke editing', () async {
    final _FakeRepository repository = _FakeRepository();
    final FreeTableCategoryController controller = _controller(repository);
    addTearDown(controller.dispose);

    await controller.submit();
    expect(controller.state.isSuccess, isTrue);

    controller.updateName('Nama Baru');
    expect(controller.state.status, FreeTableCategoryStatus.editing);
    expect(controller.state.savedCategory, isNull);
  });
}
