// lib/data/models/audit/audit_log_model.dart
//
// DTO `GET /api/v1/audit-log` (snake_case sesuai PRD Bagian 7, lihat §2.7).
//
// Bentuk yang disepakati (Phase A, kontrak mock):
//
// ```json
// {
//   "success": true,
//   "data": {
//     "logs": [
//       {
//         "id": "log-001",
//         "waktu": "2026-11-17T09:24:00.000Z",
//         "aksi": "tambah",
//         "record_type": "transaksi",
//         "record_nama": "Penjualan Sosis Solo #1023",
//         "detail": "Jumlah 2 porsi, total Rp 36.000",
//         "pengguna": "Rina"          // atau {"nama": "Rina"}
//       }
//     ],
//     "pagination": {
//       "page": 1, "per_page": 12, "total": 34,
//       "total_pages": 3, "has_next": true
//     }
//   }
// }
// ```

import '../../../domain/entities/audit_log_entity.dart';

/// DTO satu baris log audit.
class AuditLogEntryModel {
  const AuditLogEntryModel({
    required this.waktu,
    required this.aksi,
    this.id,
    this.recordTipe,
    this.recordNama,
    this.detail,
    this.pengguna,
  });

  final String? id;
  final DateTime waktu;
  final String aksi;
  final String? recordTipe;
  final String? recordNama;
  final String? detail;

  /// Nama pengguna; `null` bila API tidak mengirim relasi pengguna.
  final String? pengguna;

  /// Mengurai satu baris log; `waktu` dan `aksi` wajib ada.
  ///
  /// Melempar [FormatException] bila field wajib absen/tak valid.
  factory AuditLogEntryModel.fromJson(Map<String, Object?> json) {
    final DateTime waktu = _parseDateTime(json['waktu'] ?? json['time']);
    final Object? rawAksi = json['aksi'] ?? json['action'];
    if (rawAksi is! String || rawAksi.isEmpty) {
      throw const FormatException('Field `aksi` tidak valid.');
    }
    return AuditLogEntryModel(
      id: json['id']?.toString(),
      waktu: waktu,
      aksi: rawAksi,
      recordTipe: json['record_type']?.toString(),
      recordNama: (json['record_nama'] ?? json['record_name'])?.toString(),
      detail: (json['detail'] ?? json['keterangan'])?.toString(),
      pengguna: _parsePengguna(json['pengguna'] ?? json['user']),
    );
  }

  AuditLogEntryEntity toEntity() {
    return AuditLogEntryEntity(
      id: id,
      waktu: waktu,
      aksi: aksi,
      recordTipe: recordTipe,
      recordNama: recordNama,
      detail: detail,
      pengguna: pengguna,
    );
  }
}

/// DTO pagination daftar log.
class AuditLogPaginationModel {
  const AuditLogPaginationModel({
    required this.page,
    required this.hasNext,
    this.perPage,
    this.total,
    this.totalPages,
  });

  final int page;
  final int? perPage;
  final int? total;
  final int? totalPages;
  final bool hasNext;

  /// Toleran terhadap pagination absen (fallback halaman tunggal).
  factory AuditLogPaginationModel.fromJson(Object? raw) {
    if (raw is! Map) {
      return const AuditLogPaginationModel(page: 1, hasNext: false);
    }
    final int? currentPage = _asInt(raw['page'] ?? raw['current_page']);
    final int? lastPage = _asInt(raw['total_pages'] ?? raw['last_page']);
    return AuditLogPaginationModel(
      page: currentPage ?? 1,
      perPage: _asInt(raw['per_page']),
      total: _asInt(raw['total']),
      totalPages: lastPage,
      hasNext: raw['has_next'] is bool
          ? raw['has_next'] as bool
          : (currentPage != null && lastPage != null
              ? currentPage < lastPage
              : false),
    );
  }

  AuditLogPageEntity toEntity(List<AuditLogEntryEntity> logs) {
    return AuditLogPageEntity(
      logs: logs,
      page: page,
      perPage: perPage,
      total: total,
      totalPages: totalPages,
      hasNext: hasNext,
    );
  }
}

/// DTO satu halaman daftar log audit (isi `data` pada envelope).
class AuditLogPageModel {
  const AuditLogPageModel({required this.logs, required this.pagination});

  final List<AuditLogEntryModel> logs;
  final AuditLogPaginationModel pagination;

  /// Mengurai isi `data`; `logs` wajib berupa list.
  ///
  /// Melempar [FormatException] bila bentuk tidak sesuai kontrak.
  factory AuditLogPageModel.fromJson(Object? raw) {
    if (raw is! Map) {
      throw const FormatException('Isi `data` audit-log bukan objek.');
    }
    final Object? rawLogs = raw['logs'] ?? raw['items'];
    if (rawLogs is! List) {
      throw const FormatException('Field `logs` tidak ada pada data audit.');
    }
    final List<AuditLogEntryModel> logs = <AuditLogEntryModel>[
      for (final Object? item in rawLogs)
        AuditLogEntryModel.fromJson(_asMap(item, 'logs[]')),
    ];
    return AuditLogPageModel(
      logs: logs,
      pagination: AuditLogPaginationModel.fromJson(
        raw['pagination'] ?? raw['meta'],
      ),
    );
  }

  AuditLogPageEntity toEntity() {
    return pagination.toEntity(<AuditLogEntryEntity>[
      for (final AuditLogEntryModel log in logs) log.toEntity(),
    ]);
  }
}

Map<String, Object?> _asMap(Object? raw, String field) {
  if (raw is Map) {
    return <String, Object?>{
      for (final MapEntry<Object?, Object?> entry in raw.entries)
        entry.key.toString(): entry.value,
    };
  }
  throw FormatException('Item `$field` bukan objek JSON.');
}

/// Memetakan `pengguna` berbentuk string maupun objek menjadi nama.
String? _parsePengguna(Object? raw) {
  if (raw is String) {
    return raw.isEmpty ? null : raw;
  }
  if (raw is Map) {
    for (final String key in <String>[
      'nama',
      'name',
      'full_name',
      'username',
    ]) {
      final Object? value = raw[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
  }
  return null;
}

DateTime _parseDateTime(Object? raw) {
  if (raw is String) {
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return parsed;
    }
  }
  if (raw is int) {
    // Detik atau milidetik epoch.
    return raw > 100000000000
        ? DateTime.fromMillisecondsSinceEpoch(raw)
        : DateTime.fromMillisecondsSinceEpoch(raw * 1000);
  }
  throw FormatException('Field `waktu` tidak valid: $raw');
}

int? _asInt(Object? raw) {
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }
  if (raw is String) {
    return int.tryParse(raw);
  }
  return null;
}
