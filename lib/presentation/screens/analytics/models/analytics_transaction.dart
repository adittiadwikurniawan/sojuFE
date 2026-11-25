import 'package:flutter/foundation.dart';

/// Jenis arus kas pada layar Analytics.
enum TransactionType {
  /// Uang masuk.
  income('Pemasukan'),

  /// Uang keluar.
  expense('Pengeluaran');

  const TransactionType(this.label);

  /// Label tampilan.
  final String label;
}

/// Satu transaksi yang tercatat (frame `546:2937`).
///
/// [amount] selalu bernilai positif; tanda arus kas ditentukan oleh [type].
/// Model ini menjadi kontrak UI ↔ data: respons API cukup dipetakan ke kelas
/// ini, seluruh perhitungan diturunkan di [AnalyticsSummary] dan helper
/// terkait.
@immutable
class AnalyticsTransaction {
  const AnalyticsTransaction({
    required this.id,
    required this.date,
    required this.title,
    required this.category,
    required this.type,
    required this.amount,
    required this.party,
    this.note,
  });

  final String id;
  final DateTime date;

  /// Judul singkat transaksi (mis. `Penjualan Sosis Solo`).
  final String title;

  /// Kategori/pos (mis. `Bahan Baku Segar`).
  final String category;

  final TransactionType type;

  /// Nominal rupiah, selalu ≥ 0.
  final double amount;

  /// Pihak terkait: pembeli (pemasukan) atau suplier (pengeluaran).
  final String party;

  final String? note;

  bool get isIncome => type == TransactionType.income;

  /// Nominal bertanda: positif untuk pemasukan, negatif untuk pengeluaran.
  double get signedAmount => isIncome ? amount : -amount;

  @override
  String toString() => 'AnalyticsTransaction($id, $title, $type, $amount)';
}
