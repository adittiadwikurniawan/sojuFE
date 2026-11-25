import 'package:flutter/material.dart';

import 'analytics_format.dart';
import 'analytics_transaction.dart';

/// Filter aktif pada layar Analytics.
///
/// Filter bersifat immutable; widget cukup memanggil `with...` lalu memakai
/// hasilnya untuk menurunkan ulang seluruh angka lewat
/// `AnalyticsSummary.from`.
@immutable
class AnalyticsFilter {
  const AnalyticsFilter({
    this.range,
    this.type,
    this.category,
    this.query = '',
  });

  /// Rentang tanggal aktif; `null` berarti mengikuti bulan yang ditampilkan.
  final DateTimeRange? range;

  /// Jenis arus kas yang dipilih; `null` berarti semua.
  final TransactionType? type;

  /// Kategori/pos yang dipilih; `null` berarti semua.
  final String? category;

  /// Kata kunci pencarian (judul, kategori, atau pihak).
  final String query;

  bool get hasDateRange => range != null;

  bool get hasType => type != null;

  bool get hasCategory => category != null;

  /// Apakah ada filter selain tanggal (jenis/kategori/pencarian).
  bool get hasRefinements =>
      type != null || category != null || query.trim().isNotEmpty;

  /// Apakah tidak ada filter sama sekali.
  bool get isEmpty => range == null && !hasRefinements;

  /// Menguji satu transaksi terhadap seluruh filter.
  bool matches(AnalyticsTransaction transaction) {
    if (type != null && transaction.type != type) {
      return false;
    }
    if (category != null && transaction.category != category) {
      return false;
    }
    final String keyword = query.trim().toLowerCase();
    if (keyword.isNotEmpty) {
      final String haystack =
          '${transaction.title} ${transaction.category} ${transaction.party}'
              .toLowerCase();
      if (!haystack.contains(keyword)) {
        return false;
      }
    }
    final DateTimeRange? activeRange = range;
    if (activeRange != null) {
      final DateTime date = dateOnly(transaction.date);
      if (date.isBefore(dateOnly(activeRange.start)) ||
          date.isAfter(dateOnly(activeRange.end))) {
        return false;
      }
    }
    return true;
  }

  AnalyticsFilter withRange(DateTimeRange? value) {
    return AnalyticsFilter(
      range: value,
      type: type,
      category: category,
      query: query,
    );
  }

  AnalyticsFilter withType(TransactionType? value) {
    return AnalyticsFilter(
      range: range,
      type: value,
      category: category,
      query: query,
    );
  }

  AnalyticsFilter withCategory(String? value) {
    return AnalyticsFilter(
      range: range,
      type: type,
      category: value,
      query: query,
    );
  }

  AnalyticsFilter withQuery(String value) {
    return AnalyticsFilter(
      range: range,
      type: type,
      category: category,
      query: value,
    );
  }

  /// Menghapus seluruh filter.
  AnalyticsFilter clear() => const AnalyticsFilter();
}
