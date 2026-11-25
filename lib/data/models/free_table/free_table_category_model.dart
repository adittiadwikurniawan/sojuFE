// lib/data/models/free_table/free_table_category_model.dart
//
// DTO pembuatan kategori Tabel Bebas.
//
// Bentuk `data` pada envelope Phase A:
//
// ```json
// {
//   "nama": "Log Checklist & Suhu Freezer",
//   "tipe_arus_kas": "tabel_bebas",
//   "departemen": "Area Dapur Utama",
//   "custom_fields": [
//     {
//       "id": "field-nama-alat",
//       "label": "Nama Alat / Item",
//       "tipe": "teks",
//       "wajib": true
//     }
//   ]
// }
// ```
//
// Datasource REST Phase B cukup mengembalikan bentuk yang sama; model ini
// yang memetakan ke entity domain.

import '../../../domain/entities/free_table_entity.dart';

/// DTO satu kolom pendataan tambahan.
class FreeTableFieldModel {
  const FreeTableFieldModel({
    required this.id,
    required this.label,
    required this.type,
    required this.isRequired,
    this.options = const <String>[],
  });

  final String id;
  final String label;
  final FreeTableFieldType type;
  final bool isRequired;
  final List<String> options;

  /// Mengurai satu kolom; `label` wajib ada.
  factory FreeTableFieldModel.fromJson(Object? raw, {required int index}) {
    final Map<String, Object?> json = _asMap(raw, 'custom_fields[$index]');
    final String? label = _asString(json['label'] ?? json['nama']);
    if (label == null || label.trim().isEmpty) {
      throw FormatException('Field `label` kolom ke-$index tidak valid.');
    }
    return FreeTableFieldModel(
      id: _asString(json['id']) ?? 'field-${index + 1}',
      label: label,
      type: FreeTableFieldTypeX.fromApi(json['tipe'] ?? json['type']),
      isRequired: _asBool(json['wajib'] ?? json['required']),
      options: _asStringList(json['opsi'] ?? json['options']),
    );
  }

  FreeTableFieldEntity toEntity() {
    return FreeTableFieldEntity(
      id: id,
      label: label,
      type: type,
      isRequired: isRequired,
      options: options,
    );
  }
}

/// DTO kategori Tabel Bebas pada isi `data` envelope.
class FreeTableCategoryModel {
  const FreeTableCategoryModel({
    required this.name,
    required this.cashflowType,
    required this.fields,
    this.id,
    this.department,
  });

  final String? id;
  final String name;
  final FreeTableCashflowType cashflowType;
  final String? department;
  final List<FreeTableFieldModel> fields;

  /// Mengurai isi `data`; `nama` wajib berupa string tidak kosong.
  factory FreeTableCategoryModel.fromJson(Object? raw) {
    final Map<String, Object?> json = _asMap(raw, 'data');
    final String? name = _asString(json['nama'] ?? json['name']);
    if (name == null || name.trim().isEmpty) {
      throw const FormatException('Field `nama` kategori tidak valid.');
    }

    final Object? rawFields = json['custom_fields'] ?? json['fields'];
    if (rawFields != null && rawFields is! List) {
      throw const FormatException('Field `custom_fields` bukan list.');
    }
    final List<Object?> fieldItems =
        rawFields is List ? rawFields : const <Object?>[];
    final List<FreeTableFieldModel> fields = <FreeTableFieldModel>[
      for (int i = 0; i < fieldItems.length; i++)
        FreeTableFieldModel.fromJson(fieldItems[i], index: i),
    ];

    return FreeTableCategoryModel(
      id: _asString(json['id']),
      name: name,
      cashflowType: FreeTableCashflowTypeX.fromApi(
        json['tipe_arus_kas'] ?? json['cashflow_type'],
      ),
      department: _asString(json['departemen'] ?? json['department']),
      fields: fields,
    );
  }

  FreeTableCategoryEntity toEntity() {
    return FreeTableCategoryEntity(
      id: id,
      name: name,
      cashflowType: cashflowType,
      department: department,
      fields: <FreeTableFieldEntity>[
        for (final FreeTableFieldModel field in fields) field.toEntity(),
      ],
    );
  }
}

Map<String, Object?> _asMap(Object? raw, String field) {
  if (raw is Map) {
    return <String, Object?>{
      for (final MapEntry<Object?, Object?> entry in raw.entries)
        entry.key.toString(): entry.value,
    };
  }
  throw FormatException('Field `$field` bukan objek JSON.');
}

String? _asString(Object? raw) {
  if (raw is String) {
    final String value = raw.trim();
    return value.isEmpty ? null : value;
  }
  return null;
}

bool _asBool(Object? raw) {
  if (raw is bool) {
    return raw;
  }
  if (raw is num) {
    return raw != 0;
  }
  if (raw is String) {
    return raw.toLowerCase() == 'true' || raw == '1';
  }
  return false;
}

List<String> _asStringList(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return <String>[
    for (final Object? item in raw)
      if (item is String && item.trim().isNotEmpty) item.trim(),
  ];
}
