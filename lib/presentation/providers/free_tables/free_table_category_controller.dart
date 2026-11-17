// lib/presentation/providers/free_tables/free_table_category_controller.dart
//
// State + controller form "Buat Kategori Baru" Tabel Bebas
// (frame Figma `546:5163`).
//
// Memakai [ChangeNotifier] mengikuti pola AuditLogController karena repo ini
// belum memasang Riverpod. State terpisah memuat status editing/saving/
// success/error, validasi nama, dan daftar kolom kustom.

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/free_table_entity.dart';
import '../../../domain/usecases/free_table_usecases.dart';

/// Status pengiriman form.
enum FreeTableCategoryStatus { editing, saving, success, error }

const List<FreeTableFieldEntity> _initialFields = <FreeTableFieldEntity>[
  FreeTableFieldEntity(
    id: 'field-nama-alat',
    label: 'Nama Alat / Item',
    type: FreeTableFieldType.shortText,
    isRequired: true,
  ),
  FreeTableFieldEntity(
    id: 'field-suhu-kuantitas',
    label: 'Suhu (°C) / Kuantitas',
    type: FreeTableFieldType.number,
    isRequired: true,
  ),
  FreeTableFieldEntity(
    id: 'field-jadwal-servis',
    label: 'Jadwal Servis / Pengecekan',
    type: FreeTableFieldType.date,
  ),
  FreeTableFieldEntity(
    id: 'field-petugas-shift',
    label: 'Petugas Shift (PIC)',
    type: FreeTableFieldType.multipleChoice,
  ),
];

/// State form Buat Kategori Baru.
class FreeTableCategoryState {
  const FreeTableCategoryState({
    this.name = 'Log Checklist & Suhu Freezer',
    this.department = '',
    this.cashflowType = FreeTableCashflowType.freeTable,
    this.fields = _initialFields,
    this.selectedFieldType = FreeTableFieldType.shortText,
    this.status = FreeTableCategoryStatus.editing,
    this.nameError,
    this.fieldsError,
    this.errorMessage,
    this.savedCategory,
  });

  /// Keadaan awal sesuai contoh pada frame `546:5163`.
  const FreeTableCategoryState.initial() : this();

  final String name;
  final String department;
  final FreeTableCashflowType cashflowType;
  final List<FreeTableFieldEntity> fields;
  final FreeTableFieldType selectedFieldType;
  final FreeTableCategoryStatus status;

  /// Pesan validasi di bawah medan nama.
  final String? nameError;

  /// Pesan validasi pada bagian kolom pendataan.
  final String? fieldsError;

  /// Pesan galat pengiriman/validasi yang tampil di footer.
  final String? errorMessage;

  /// Hasil sukses dari repository.
  final FreeTableCategoryEntity? savedCategory;

  bool get isSaving => status == FreeTableCategoryStatus.saving;

  bool get isSuccess => status == FreeTableCategoryStatus.success;

  bool get isError => status == FreeTableCategoryStatus.error;

  /// Draf yang dikirim ke repository.
  FreeTableCategoryDraft toDraft() {
    final String trimmedName = name.trim();
    final String trimmedDepartment = department.trim();
    return FreeTableCategoryDraft(
      name: trimmedName,
      cashflowType: cashflowType,
      department: trimmedDepartment.isEmpty ? null : trimmedDepartment,
      fields: fields,
    );
  }

  FreeTableCategoryState copyWith({
    String? name,
    String? department,
    FreeTableCashflowType? cashflowType,
    List<FreeTableFieldEntity>? fields,
    FreeTableFieldType? selectedFieldType,
    FreeTableCategoryStatus? status,
    String? nameError,
    String? fieldsError,
    String? errorMessage,
    FreeTableCategoryEntity? savedCategory,
    bool clearNameError = false,
    bool clearFieldsError = false,
    bool clearErrorMessage = false,
    bool clearSavedCategory = false,
  }) {
    return FreeTableCategoryState(
      name: name ?? this.name,
      department: department ?? this.department,
      cashflowType: cashflowType ?? this.cashflowType,
      fields: fields ?? this.fields,
      selectedFieldType: selectedFieldType ?? this.selectedFieldType,
      status: status ?? this.status,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      fieldsError: clearFieldsError ? null : (fieldsError ?? this.fieldsError),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      savedCategory:
          clearSavedCategory ? null : (savedCategory ?? this.savedCategory),
    );
  }
}

/// Controller form Buat Kategori Baru.
class FreeTableCategoryController extends ChangeNotifier {
  FreeTableCategoryController({
    required CreateFreeTableCategory createCategory,
    FreeTableCategoryState? initialState,
  })  : _createCategory = createCategory,
        _state = initialState ?? const FreeTableCategoryState.initial();

  final CreateFreeTableCategory _createCategory;

  FreeTableCategoryState _state;
  int _nextFieldId = 1;
  bool _disposed = false;

  /// State saat ini.
  FreeTableCategoryState get state => _state;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (_disposed) {
      return;
    }
    notifyListeners();
  }

  /// Memperbarui nama kategori.
  void updateName(String value) {
    if (_state.isSaving) {
      return;
    }
    _state = _state.copyWith(
      name: value,
      status: FreeTableCategoryStatus.editing,
      clearNameError: true,
      clearErrorMessage: true,
      clearSavedCategory: true,
    );
    _notify();
  }

  /// Memperbarui target departemen/lokasi.
  void updateDepartment(String value) {
    if (_state.isSaving) {
      return;
    }
    _state = _state.copyWith(
      department: value,
      status: FreeTableCategoryStatus.editing,
      clearErrorMessage: true,
      clearSavedCategory: true,
    );
    _notify();
  }

  /// Memilih tipe arus kas.
  void selectCashflowType(FreeTableCashflowType type) {
    if (_state.isSaving || _state.cashflowType == type) {
      return;
    }
    _state = _state.copyWith(
      cashflowType: type,
      status: FreeTableCategoryStatus.editing,
      clearErrorMessage: true,
      clearSavedCategory: true,
    );
    _notify();
  }

  /// Memilih tipe kolom untuk tombol tambah.
  void selectFieldType(FreeTableFieldType type) {
    if (_state.isSaving || _state.selectedFieldType == type) {
      return;
    }
    _state = _state.copyWith(
      selectedFieldType: type,
      status: FreeTableCategoryStatus.editing,
      clearErrorMessage: true,
      clearSavedCategory: true,
    );
    _notify();
  }

  /// Menambah kolom kustom sesuai tipe yang sedang dipilih.
  void addField() {
    if (_state.isSaving) {
      return;
    }
    final FreeTableFieldType type = _state.selectedFieldType;
    final String id = 'custom-field-${_nextFieldId++}';
    final List<FreeTableFieldEntity> fields = <FreeTableFieldEntity>[
      ..._state.fields,
      FreeTableFieldEntity(
        id: id,
        label: _defaultFieldLabel(type),
        type: type,
      ),
    ];
    _state = _state.copyWith(
      fields: fields,
      status: FreeTableCategoryStatus.editing,
      clearFieldsError: true,
      clearErrorMessage: true,
      clearSavedCategory: true,
    );
    _notify();
  }

  /// Menghapus kolom kustom berdasarkan [id].
  void removeField(String id) {
    if (_state.isSaving) {
      return;
    }
    final List<FreeTableFieldEntity> fields = _state.fields
        .where((FreeTableFieldEntity field) => field.id != id)
        .toList(growable: false);
    if (fields.length == _state.fields.length) {
      return;
    }
    _state = _state.copyWith(
      fields: fields,
      status: FreeTableCategoryStatus.editing,
      clearFieldsError: true,
      clearErrorMessage: true,
      clearSavedCategory: true,
    );
    _notify();
  }

  /// Memvalidasi lalu mengirim draf ke repository.
  Future<void> submit() async {
    if (_state.isSaving) {
      return;
    }

    final String trimmedName = _state.name.trim();
    final bool hasName = trimmedName.isNotEmpty;
    final bool hasFields = _state.fields.isNotEmpty;
    if (!hasName || !hasFields) {
      _state = _state.copyWith(
        status: FreeTableCategoryStatus.editing,
        nameError: hasName ? null : 'Nama kategori wajib diisi.',
        fieldsError:
            hasFields ? null : 'Tambahkan minimal satu kolom pendataan.',
        errorMessage: !hasName
            ? 'Nama kategori wajib diisi.'
            : 'Tambahkan minimal satu kolom pendataan.',
        clearNameError: hasName,
        clearFieldsError: hasFields,
        clearSavedCategory: true,
      );
      _notify();
      return;
    }

    final FreeTableCategoryDraft draft = _state.toDraft();
    _state = _state.copyWith(
      status: FreeTableCategoryStatus.saving,
      clearNameError: true,
      clearFieldsError: true,
      clearErrorMessage: true,
      clearSavedCategory: true,
    );
    _notify();

    final Result<FreeTableCategoryEntity> result = await _createCategory(
      draft: draft,
    );

    if (_disposed) {
      return;
    }

    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: FreeTableCategoryStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (FreeTableCategoryEntity category) {
        _state = _state.copyWith(
          status: FreeTableCategoryStatus.success,
          savedCategory: category,
          clearErrorMessage: true,
        );
      },
    );
    _notify();
  }

  String _defaultFieldLabel(FreeTableFieldType type) {
    switch (type) {
      case FreeTableFieldType.shortText:
        return 'Kolom Teks';
      case FreeTableFieldType.number:
        return 'Kolom Angka';
      case FreeTableFieldType.date:
        return 'Kolom Tanggal';
      case FreeTableFieldType.multipleChoice:
        return 'Kolom Pilihan';
    }
  }
}
