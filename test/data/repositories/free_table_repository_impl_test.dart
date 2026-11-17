// Unit test: repository Tabel Bebas (envelope + failure mapping + mock).

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/core/common/result.dart';
import 'package:soju_fe/core/errors/app_failure.dart';
import 'package:soju_fe/data/datasources/interfaces/free_table_datasource.dart';
import 'package:soju_fe/data/datasources/mock/free_table_mock_datasource.dart';
import 'package:soju_fe/data/repositories/free_table_repository_impl.dart';
import 'package:soju_fe/domain/entities/free_table_entity.dart';
import 'package:soju_fe/domain/repositories/free_table_repository.dart';

class _StubDataSource implements FreeTableDataSource {
  _StubDataSource({this.payload, this.error});

  final Map<String, Object?>? payload;
  final Object? error;
  FreeTableCategoryDraft? lastDraft;

  @override
  Future<Map<String, Object?>> createRawCategory({
    required FreeTableCategoryDraft draft,
  }) async {
    lastDraft = draft;
    final Object? error = this.error;
    if (error != null) {
      throw error;
    }
    return payload ??
        <String, Object?>{'success': true, 'data': draft.toJson()};
  }
}

const FreeTableCategoryDraft _draft = FreeTableCategoryDraft(
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

void main() {
  test('sukses: envelope dan DTO dipetakan ke entity', () async {
    final FreeTableRepository repository = FreeTableRepositoryImpl(
      _StubDataSource(
        payload: <String, Object?>{
          'success': true,
          'data': <String, Object?>{
            'id': 'kategori-1',
            'nama': 'Log Checklist & Suhu Freezer',
            'tipe_arus_kas': 'tabel_bebas',
            'departemen': 'Area Dapur Utama',
            'custom_fields': <Map<String, Object?>>[
              <String, Object?>{
                'id': 'field-1',
                'label': 'Nama Alat / Item',
                'tipe': 'teks',
                'wajib': true,
              },
            ],
          },
        },
      ),
    );

    final Result<FreeTableCategoryEntity> result =
        await repository.createCategory(draft: _draft);

    expect(result.isSuccess, isTrue);
    result.fold(
      onFailure: (AppFailure _) => fail('seharusnya sukses'),
      onSuccess: (FreeTableCategoryEntity category) {
        expect(category.id, 'kategori-1');
        expect(category.name, 'Log Checklist & Suhu Freezer');
        expect(category.fields.single.label, 'Nama Alat / Item');
        expect(category.fields.single.isRequired, isTrue);
      },
    );
  });

  test('envelope success=false menjadi EnvelopeFailure', () async {
    final FreeTableRepository repository = FreeTableRepositoryImpl(
      _StubDataSource(
        payload: <String, Object?>{
          'success': false,
          'message': 'Kategori sudah ada.',
        },
      ),
    );

    final Result<FreeTableCategoryEntity> result =
        await repository.createCategory(draft: _draft);

    expect(result.failureOrNull, isA<EnvelopeFailure>());
    expect(result.failureOrNull?.message, 'Kategori sudah ada.');
  });

  test('data null menjadi EnvelopeFailure', () async {
    final FreeTableRepository repository = FreeTableRepositoryImpl(
      _StubDataSource(payload: <String, Object?>{'success': true}),
    );

    final Result<FreeTableCategoryEntity> result =
        await repository.createCategory(draft: _draft);

    expect(result.failureOrNull, isA<EnvelopeFailure>());
  });

  test('payload rusak menjadi ParsingFailure', () async {
    final FreeTableRepository repository = FreeTableRepositoryImpl(
      _StubDataSource(
        payload: <String, Object?>{
          'success': true,
          'data': <String, Object?>{'nama': '   '},
        },
      ),
    );

    final Result<FreeTableCategoryEntity> result =
        await repository.createCategory(draft: _draft);

    expect(result.failureOrNull, isA<ParsingFailure>());
  });

  test('exception tak terduga menjadi NetworkFailure', () async {
    final FreeTableRepository repository = FreeTableRepositoryImpl(
      _StubDataSource(error: StateError('putus')),
    );

    final Result<FreeTableCategoryEntity> result =
        await repository.createCategory(draft: _draft);

    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('mock datasource mengembalikan draf yang dikirim', () async {
    const FreeTableRepository repository = FreeTableRepositoryImpl(
      FreeTableMockDataSource(),
    );

    final Result<FreeTableCategoryEntity> result =
        await repository.createCategory(draft: _draft);

    expect(result.isSuccess, isTrue);
    result.fold(
      onFailure: (AppFailure _) => fail('seharusnya sukses'),
      onSuccess: (FreeTableCategoryEntity category) {
        expect(category.name, _draft.name);
        expect(category.department, _draft.department);
        expect(category.fields.single.label, 'Nama Alat / Item');
      },
    );
  });
}
