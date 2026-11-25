// lib/presentation/screens/audit/models/audit_view_data.dart
//
// Kontrak tampilan layar Audit & Stok (hanya bagian audit log).
//
// Memetakan entity domain menjadi teks Bahasa Indonesia yang siap dirender;
// widget tidak mengubah data (baca-saja, MFR-9).

import 'package:flutter/material.dart';

import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/audit_log_entity.dart';
import '../../../utils/format.dart';

/// Satu baris log yang siap ditampilkan.
class AuditLogViewData {
  const AuditLogViewData({
    required this.id,
    required this.waktu,
    required this.kind,
    required this.aksiLabel,
    required this.recordNama,
    this.recordTipe,
    this.detail,
    this.pengguna,
  });

  final String? id;
  final DateTime waktu;
  final AuditActionKind kind;
  final String aksiLabel;
  final String recordNama;
  final String? recordTipe;
  final String? detail;
  final String? pengguna;

  /// Label jam Indonesia: `09.24`.
  String get jamText {
    final String hour = waktu.hour.toString().padLeft(2, '0');
    final String minute = waktu.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }

  factory AuditLogViewData.fromEntity(AuditLogEntryEntity entity) {
    final AuditActionKind kind = entity.actionKind;
    return AuditLogViewData(
      id: entity.id,
      waktu: entity.waktu,
      kind: kind,
      aksiLabel: switch (kind) {
        AuditActionKind.created => 'Ditambahkan',
        AuditActionKind.updated => 'Diubah',
        AuditActionKind.deleted => 'Dihapus',
        AuditActionKind.other => _capitalize(entity.aksi),
      },
      recordNama:
          entity.recordNama ?? _capitalize(entity.recordTipe ?? 'Aktivitas'),
      recordTipe: entity.recordTipe,
      detail: entity.detail,
      pengguna: entity.pengguna,
    );
  }
}

/// Kelompok log per tanggal untuk header `Hari Ini`, `Kemarin`, dsb.
class AuditLogSection {
  const AuditLogSection({required this.label, required this.items});

  final String label;
  final List<AuditLogViewData> items;
}

/// Mengelompokkan daftar log (terurut terbaru lebih dulu) menjadi section
/// per hari mengikuti urutan waktu menurun.
List<AuditLogSection> buildAuditSections(List<AuditLogEntryEntity> logs) {
  final DateTime today = dateOnly(DateTime.now());
  final DateTime yesterday = today.subtract(const Duration(days: 1));

  final List<AuditLogViewData> sorted = logs
      .map(AuditLogViewData.fromEntity)
      .toList()
    ..sort(
      (AuditLogViewData a, AuditLogViewData b) => b.waktu.compareTo(a.waktu),
    );

  final List<AuditLogSection> sections = <AuditLogSection>[];
  for (final AuditLogViewData item in sorted) {
    final DateTime day = dateOnly(item.waktu);
    final String label;
    if (day == today) {
      label = 'Hari Ini';
    } else if (day == yesterday) {
      label = 'Kemarin';
    } else {
      label = '${formatDayMonth(item.waktu)} ${item.waktu.year}';
    }
    final AuditLogSection? last = sections.isEmpty ? null : sections.last;
    if (last != null && last.label == label) {
      last.items.add(item);
    } else {
      sections.add(
        AuditLogSection(label: label, items: <AuditLogViewData>[item]),
      );
    }
  }
  return sections;
}

/// Aksen (warna kuat) dan latar lembut tiap kategori aksi untuk badge.
class AuditActionStyle {
  const AuditActionStyle(this.accent, this.background, this.icon);

  final Color accent;
  final Color background;
  final IconData icon;

  static AuditActionStyle of(AuditActionKind kind) {
    switch (kind) {
      case AuditActionKind.created:
        return const AuditActionStyle(
          SojuColors.chartGreen,
          SojuColors.incomeSoft,
          Icons.add_circle_outline,
        );
      case AuditActionKind.updated:
        return const AuditActionStyle(
          SojuColors.badgeBlue,
          SojuColors.auditUpdateSoft,
          Icons.edit_outlined,
        );
      case AuditActionKind.deleted:
        return const AuditActionStyle(
          SojuColors.expense,
          SojuColors.expenseSoft,
          Icons.delete_outline,
        );
      case AuditActionKind.other:
        return const AuditActionStyle(
          SojuColors.analyticsMuted,
          SojuColors.field,
          Icons.history_outlined,
        );
    }
  }
}

String _capitalize(String raw) {
  if (raw.isEmpty) {
    return 'Aktivitas';
  }
  return '${raw[0].toUpperCase()}${raw.substring(1)}';
}
