// Unit test: payload draf Tabel Bebas.

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/domain/entities/free_table_entity.dart';

void main() {
  test('draf memetakan field ke payload snake_case', () {
    const FreeTableCategoryDraft draft = FreeTableCategoryDraft(
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
        FreeTableFieldEntity(
          id: 'field-2',
          label: 'Suhu (°C) / Kuantitas',
          type: FreeTableFieldType.number,
        ),
      ],
    );

    final Map<String, Object?> json = draft.toJson();
    expect(json['nama'], 'Log Checklist & Suhu Freezer');
    expect(json['tipe_arus_kas'], 'tabel_bebas');
    expect(json['departemen'], 'Area Dapur Utama');
    final List<Object?> fields = json['custom_fields']! as List<Object?>;
    expect(fields, hasLength(2));
    expect((fields.first! as Map<String, Object?>)['tipe'], 'teks');
    expect((fields.first! as Map<String, Object?>)['wajib'], isTrue);
    expect((fields.last! as Map<String, Object?>)['wajib'], isFalse);
  });

  test('departemen kosong tidak dikirim', () {
    const FreeTableCategoryDraft draft = FreeTableCategoryDraft(
      name: 'Kategori',
      cashflowType: FreeTableCashflowType.expense,
      department: '',
      fields: <FreeTableFieldEntity>[
        FreeTableFieldEntity(
          id: 'field-1',
          label: 'Kolom',
          type: FreeTableFieldType.date,
        ),
      ],
    );

    final Map<String, Object?> json = draft.toJson();
    expect(json.containsKey('departemen'), isFalse);
    expect(json['tipe_arus_kas'], 'pengeluaran');
  });
}
