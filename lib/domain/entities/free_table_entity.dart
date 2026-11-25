// lib/domain/entities/free_table_entity.dart
//
// Entity domain Tabel Bebas untuk form "Buat Kategori Baru"
// (frame Figma `546:5163`, varian Tabel Bebas).
//
// Entity ini hanya memodelkan data yang tampil pada form: nama kategori,
// tipe arus kas, target departemen/lokasi, dan kolom pendataan tambahan.
// Tidak ada nominal uang atau perhitungan bisnis di client.

/// Tipe arus kas yang dapat dipilih saat membuat kategori.
enum FreeTableCashflowType { income, expense, freeTable }

/// Nilai API untuk [FreeTableCashflowType].
extension FreeTableCashflowTypeX on FreeTableCashflowType {
  /// Label Bahasa Indonesia pada segmented control.
  String get label {
    switch (this) {
      case FreeTableCashflowType.income:
        return 'Pemasukan';
      case FreeTableCashflowType.expense:
        return 'Pengeluaran';
      case FreeTableCashflowType.freeTable:
        return 'Tabel Bebas';
    }
  }

  /// Nilai snake_case yang dikirim ke datasource/API.
  String get apiValue {
    switch (this) {
      case FreeTableCashflowType.income:
        return 'pemasukan';
      case FreeTableCashflowType.expense:
        return 'pengeluaran';
      case FreeTableCashflowType.freeTable:
        return 'tabel_bebas';
    }
  }

  /// Memetakan nilai API; fallback ke [FreeTableCashflowType.freeTable].
  static FreeTableCashflowType fromApi(Object? raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'pemasukan':
      case 'income':
        return FreeTableCashflowType.income;
      case 'pengeluaran':
      case 'expense':
        return FreeTableCashflowType.expense;
      default:
        return FreeTableCashflowType.freeTable;
    }
  }
}

/// Tipe kolom pendataan tambahan (FR-4 Custom Field).
enum FreeTableFieldType { shortText, number, date, multipleChoice }

/// Nilai API + label tampilan untuk [FreeTableFieldType].
extension FreeTableFieldTypeX on FreeTableFieldType {
  /// Label tipe pada daftar kolom, mis. `Teks Bebas`.
  String get label {
    switch (this) {
      case FreeTableFieldType.shortText:
        return 'Teks Bebas';
      case FreeTableFieldType.number:
        return 'Angka';
      case FreeTableFieldType.date:
        return 'Kalender';
      case FreeTableFieldType.multipleChoice:
        return 'Pilihan Ganda';
    }
  }

  /// Label pada grid pemilih tipe, mis. `Teks Pendek`.
  String get pickerLabel {
    switch (this) {
      case FreeTableFieldType.shortText:
        return 'Teks Pendek';
      case FreeTableFieldType.number:
        return 'Angka Nominal';
      case FreeTableFieldType.date:
        return 'Tanggal';
      case FreeTableFieldType.multipleChoice:
        return 'Pilihan Ganda';
    }
  }

  /// Nilai snake_case yang dikirim ke datasource/API.
  String get apiValue {
    switch (this) {
      case FreeTableFieldType.shortText:
        return 'teks';
      case FreeTableFieldType.number:
        return 'angka';
      case FreeTableFieldType.date:
        return 'tanggal';
      case FreeTableFieldType.multipleChoice:
        return 'pilihan_ganda';
    }
  }

  /// Memetakan nilai API; tipe tak dikenal menjadi teks bebas.
  static FreeTableFieldType fromApi(Object? raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'teks':
      case 'text':
      case 'teks_bebas':
      case 'short_text':
        return FreeTableFieldType.shortText;
      case 'angka':
      case 'number':
      case 'angka_nominal':
        return FreeTableFieldType.number;
      case 'tanggal':
      case 'date':
      case 'kalender':
        return FreeTableFieldType.date;
      case 'pilihan_ganda':
      case 'dropdown':
      case 'multiple_choice':
        return FreeTableFieldType.multipleChoice;
      default:
        return FreeTableFieldType.shortText;
    }
  }
}

/// Satu kolom pendataan tambahan pada kategori Tabel Bebas.
class FreeTableFieldEntity {
  const FreeTableFieldEntity({
    required this.id,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.options = const <String>[],
  });

  /// Identitas lokal untuk kunci widget dan operasi hapus.
  final String id;

  /// Nama kolom yang tampil ke pengguna.
  final String label;

  /// Tipe isian kolom.
  final FreeTableFieldType type;

  /// `true` bila kolom bertanda "Wajib".
  final bool isRequired;

  /// Pilihan nilai untuk kolom [FreeTableFieldType.multipleChoice].
  final List<String> options;

  /// Payload kolom untuk datasource/API.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'label': label,
      'tipe': type.apiValue,
      'wajib': isRequired,
      if (options.isNotEmpty) 'opsi': options,
    };
  }
}

/// Data kategori Tabel Bebas yang sudah dibuat.
class FreeTableCategoryEntity {
  const FreeTableCategoryEntity({
    required this.name,
    required this.cashflowType,
    required this.fields,
    this.id,
    this.department,
  });

  /// Identitas dari API (boleh absen pada mock Phase A).
  final String? id;

  /// Nama kategori.
  final String name;

  /// Tipe arus kas kategori.
  final FreeTableCashflowType cashflowType;

  /// Target departemen/lokasi (opsional).
  final String? department;

  /// Kolom pendataan tambahan.
  final List<FreeTableFieldEntity> fields;
}

/// Draf form yang dikirim ke repository saat tombol simpan ditekan.
class FreeTableCategoryDraft {
  const FreeTableCategoryDraft({
    required this.name,
    required this.cashflowType,
    required this.fields,
    this.department,
  });

  final String name;
  final FreeTableCashflowType cashflowType;
  final String? department;
  final List<FreeTableFieldEntity> fields;

  /// Payload snake_case sesuai envelope API Buku Dapur.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'nama': name,
      'tipe_arus_kas': cashflowType.apiValue,
      if (department != null && department!.isNotEmpty)
        'departemen': department,
      'custom_fields': <Map<String, Object?>>[
        for (final FreeTableFieldEntity field in fields) field.toJson(),
      ],
    };
  }
}
