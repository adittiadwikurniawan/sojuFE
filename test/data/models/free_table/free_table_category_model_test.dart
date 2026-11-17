// Unit test: DTO kategori Tabel Bebas (envelope data → entity).

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/data/models/free_table/free_table_category_model.dart';
import 'package:soju_fe/domain/entities/free_table_entity.dart';

void main() {
  group('FreeTableCategoryModel.fromJson', () {
    test('memetakan payload valid ke entity', () {
      final FreeTableCategoryModel model = FreeTableCategoryModel.fromJson(
        <String, Object?>{
          'id': 'kategori-1',
          'nama': 'Log Checklist & Suhu Freezer',
          'tipe_arus_kas': 'tabel_bebas',
          'departemen': 'Area Dapur Utama',
          'custom_fields': <Map<String, Object?>>[
            <String, Object?>{
              'id': 'field-nama-alat',
              'label': 'Nama Alat / Item',
              'tipe': 'teks',
              'wajib': true,
            },
            <String, Object?>{
              'id': 'field-suhu',
              'label': 'Suhu (°C) / Kuantitas',
              'tipe': 'angka',
              'wajib': true,
            },
            <String, Object?>{
              'id': 'field-jadwal',
              'label': 'Jadwal Servis / Pengecekan',
              'tipe': 'tanggal',
            },
            <String, Object?>{
              'id': 'field-pic',
              'label': 'Petugas Shift (PIC)',
              'tipe': 'pilihan_ganda',
            },
          ],
        },
      );

      final FreeTableCategoryEntity entity = model.toEntity();
      expect(entity.id, 'kategori-1');
      expect(entity.name, 'Log Checklist & Suhu Freezer');
      expect(entity.cashflowType, FreeTableCashflowType.freeTable);
      expect(entity.department, 'Area Dapur Utama');
      expect(entity.fields, hasLength(4));
      expect(entity.fields[0].type, FreeTableFieldType.shortText);
      expect(entity.fields[1].type, FreeTableFieldType.number);
      expect(entity.fields[2].type, FreeTableFieldType.date);
      expect(entity.fields[3].type, FreeTableFieldType.multipleChoice);
      expect(entity.fields[0].isRequired, isTrue);
      expect(entity.fields[2].isRequired, isFalse);
    });

    test('menerima alias nama/type dan fallback id kolom', () {
      final FreeTableCategoryModel model = FreeTableCategoryModel.fromJson(
        <String, Object?>{
          'name': 'Kategori Alias',
          'cashflow_type': 'income',
          'fields': <Map<String, Object?>>[
            <String, Object?>{
              'nama': 'Kolom Alias',
              'type': 'number',
              'required': 1,
            },
          ],
        },
      );

      final FreeTableCategoryEntity entity = model.toEntity();
      expect(entity.name, 'Kategori Alias');
      expect(entity.cashflowType, FreeTableCashflowType.income);
      expect(entity.fields.single.id, 'field-1');
      expect(entity.fields.single.label, 'Kolom Alias');
      expect(entity.fields.single.type, FreeTableFieldType.number);
      expect(entity.fields.single.isRequired, isTrue);
    });

    test('tipe tidak dikenal menjadi teks bebas', () {
      final FreeTableCategoryModel model = FreeTableCategoryModel.fromJson(
        <String, Object?>{
          'nama': 'Kategori',
          'tipe_arus_kas': 'tidak_dikenal',
          'custom_fields': <Map<String, Object?>>[
            <String, Object?>{
              'label': 'Kolom',
              'tipe': 'sesuatu',
            },
          ],
        },
      );

      final FreeTableCategoryEntity entity = model.toEntity();
      expect(entity.cashflowType, FreeTableCashflowType.freeTable);
      expect(entity.fields.single.type, FreeTableFieldType.shortText);
    });

    test('payload bukan map menghasilkan FormatException', () {
      expect(
        () => FreeTableCategoryModel.fromJson('bukan-map'),
        throwsFormatException,
      );
    });

    test('nama kosong menghasilkan FormatException', () {
      expect(
        () => FreeTableCategoryModel.fromJson(<String, Object?>{
          'nama': '   ',
          'custom_fields': <Object?>[],
        }),
        throwsFormatException,
      );
    });

    test('custom_fields bukan list menghasilkan FormatException', () {
      expect(
        () => FreeTableCategoryModel.fromJson(<String, Object?>{
          'nama': 'Kategori',
          'custom_fields': 'bukan-list',
        }),
        throwsFormatException,
      );
    });

    test('kolom tanpa label menghasilkan FormatException', () {
      expect(
        () => FreeTableCategoryModel.fromJson(<String, Object?>{
          'nama': 'Kategori',
          'custom_fields': <Map<String, Object?>>[
            <String, Object?>{'tipe': 'teks'},
          ],
        }),
        throwsFormatException,
      );
    });
  });
}
