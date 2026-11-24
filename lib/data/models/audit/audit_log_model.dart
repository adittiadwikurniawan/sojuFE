// lib/data/models/audit/audit_log_model.dart
//
// DTO `GET /api/v1/audit-log` (snake_case dan camelCase backend Express).

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

  /// Mengurai satu baris log; `waktu` dan `aksi` wajib ada atau di-fallback.
  factory AuditLogEntryModel.fromJson(Map<String, Object?> json) {
    final DateTime waktu = _parseDateTime(
      json['waktu'] ?? json['time'] ?? json['dibuatPada'] ?? json['createdAt'],
    );
    final Object? rawAksi =
        json['aksi'] ?? json['action'] ?? json['actionLabel'];
    if (rawAksi is! String || rawAksi.isEmpty) {
      throw const FormatException('Field `aksi` tidak valid.');
    }
    final String aksi = rawAksi;

    return AuditLogEntryModel(
      id: json['id']?.toString(),
      waktu: waktu,
      aksi: aksi,
      recordTipe: (json['record_type'] ??
              json['recordType'] ??
              json['tabelTarget'] ??
              json['sheet'])
          ?.toString(),
      recordNama: (json['record_nama'] ??
              json['record_name'] ??
              json['recordLabel'] ??
              json['labelRecord'] ??
              json['targetNama'])
          ?.toString(),
      detail: (json['detail'] ?? json['keterangan'])?.toString(),
      pengguna: _parsePengguna(
        json['pengguna'] ?? json['user'] ?? json['dibuatOleh'],
      ),
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

  factory AuditLogPaginationModel.fromJson(Object? raw) {
    if (raw is! Map) {
      return const AuditLogPaginationModel(page: 1, hasNext: false);
    }
    final int? currentPage =
        _asInt(raw['page'] ?? raw['current_page'] ?? raw['currentPage']);
    final int? lastPage =
        _asInt(raw['total_pages'] ?? raw['totalPages'] ?? raw['last_page']);
    final int? total = _asInt(raw['total'] ?? raw['totalCount']);
    final int? perPage = _asInt(raw['per_page'] ?? raw['limit'] ?? raw['pageSize']);

    final bool hasNext = raw['has_next'] is bool
        ? raw['has_next'] as bool
        : (currentPage != null && lastPage != null
            ? currentPage < lastPage
            : false);

    return AuditLogPaginationModel(
      page: currentPage ?? 1,
      perPage: perPage,
      total: total,
      totalPages: lastPage,
      hasNext: hasNext,
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

  factory AuditLogPageModel.fromJson(Object? raw) {
    if (raw is! Map) {
      throw const FormatException('Isi `data` audit-log bukan objek.');
    }
    final Object? rawLogs = raw['logs'] ?? raw['items'] ?? raw['data'];
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
      'email',
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
