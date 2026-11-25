import 'package:flutter/material.dart';

import 'analytics_format.dart';
import 'analytics_summary.dart';
import 'analytics_transaction.dart';

/// Permintaan ekspor Excel yang dikirim ke lapisan data/API.
///
/// UI tidak membuat berkas sendiri: tombol ekspor memanggil
/// `onExportExcel` dengan data yang sudah terfilter, sehingga endpoint cukup
/// menerima daftar transaksi + rentang periode ini.
@immutable
class AnalyticsExportRequest {
  const AnalyticsExportRequest({
    required this.range,
    required this.transactions,
    required this.summary,
    this.type,
    this.category,
    this.query = '',
  });

  /// Rentang periode yang diekspor.
  final DateTimeRange range;

  /// Transaksi hasil filter saat tombol ekspor ditekan.
  final List<AnalyticsTransaction> transactions;

  /// Ringkasan periode terfilter.
  final AnalyticsSummary summary;

  /// Filter jenis yang aktif (bila ada).
  final TransactionType? type;

  /// Filter kategori yang aktif (bila ada).
  final String? category;

  /// Kata kunci pencarian yang aktif (bila ada).
  final String query;

  /// Label periode untuk judul berkas/lembar Excel.
  String get periodLabel => formatDateRange(range);

  /// Nama berkas usulan, mis. `analitik-2026-10-01_2026-10-31.xlsx`.
  String get fileName {
    String two(int value) => value.toString().padLeft(2, '0');
    final DateTime start = range.start;
    final DateTime end = range.end;
    return 'analitik-${start.year}-${two(start.month)}-${two(start.day)}'
        '_${end.year}-${two(end.month)}-${two(end.day)}.xlsx';
  }
}
