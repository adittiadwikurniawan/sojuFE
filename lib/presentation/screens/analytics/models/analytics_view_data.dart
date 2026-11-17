import 'package:flutter/material.dart';

import 'analytics_format.dart';
import 'analytics_transaction.dart';

/// Model tampilan layar Analytics (frame Figma `546:2937`).
///
/// Widget analytics hanya membaca data dari kelas ini. Saat API siap, respons
/// DTO cukup dipetakan ke [AnalyticsViewData] lalu seluruh angka diturunkan
/// lewat `AnalyticsSummary.from` / helper pada `analytics_summary.dart`.
@immutable
class AnalyticsViewData {
  const AnalyticsViewData({
    required this.avatarAsset,
    required this.month,
    required this.transactions,
    this.searchHint = 'Cari Kas Mu',
  });

  /// Avatar pada bilah atas.
  final String avatarAsset;

  /// Bulan yang ditampilkan (diambil tanggal 1).
  final DateTime month;

  /// Seluruh transaksi yang tersedia, termasuk bulan sebelumnya agar
  /// pertumbuhan periode dapat dihitung.
  final List<AnalyticsTransaction> transactions;

  final String searchHint;

  /// Rentang penuh bulan yang ditampilkan.
  DateTimeRange get monthRange => monthRangeOf(month);

  /// Tanggal transaksi terbaru; dipakai sebagai jangkar strip tanggal dan
  /// grafik agar data contoh langsung terlihat.
  DateTime get latestTransactionDate {
    DateTime latest = monthRange.end;
    for (final AnalyticsTransaction transaction in transactions) {
      if (transaction.date.isAfter(latest)) {
        latest = transaction.date;
      }
    }
    return dateOnly(latest);
  }

  /// Data contoh hasil slicing Figma.
  ///
  /// Nominal disusun agar totalnya sama dengan desain: pemasukan
  /// Rp 15.000.000, pengeluaran Rp 10.000.000, laba Rp 5.000.000
  /// (margin 33,3%), dengan 12 transaksi pada Oktober 2026.
  static final AnalyticsViewData sample = AnalyticsViewData(
    avatarAsset: 'assets/images/avatar_profil.png',
    month: DateTime(2026, 10),
    transactions: <AnalyticsTransaction>[
      // --- Pemasukan Oktober 2026 (Rp 15.000.000) ---
      AnalyticsTransaction(
        id: 'trx-01',
        date: DateTime(2026, 10, 25),
        title: 'Penjualan Sosis Solo',
        category: 'Penjualan Siap Saji',
        type: TransactionType.income,
        amount: 3000000,
        party: 'Bu Rina',
        note: '45 pack',
      ),
      AnalyticsTransaction(
        id: 'trx-02',
        date: DateTime(2026, 10, 27),
        title: 'Pesanan Katering',
        category: 'Penjualan Siap Saji',
        type: TransactionType.income,
        amount: 2500000,
        party: 'Pak Budi',
      ),
      AnalyticsTransaction(
        id: 'trx-03',
        date: DateTime(2026, 10, 29),
        title: 'Penjualan Harian',
        category: 'Penjualan Siap Saji',
        type: TransactionType.income,
        amount: 2500000,
        party: 'Pelanggan Umum',
      ),
      AnalyticsTransaction(
        id: 'trx-04',
        date: DateTime(2026, 10, 31),
        title: 'Pesanan Warung',
        category: 'Penjualan Siap Saji',
        type: TransactionType.income,
        amount: 2000000,
        party: 'Warung Sari',
      ),
      AnalyticsTransaction(
        id: 'trx-05',
        date: DateTime(2026, 10, 26),
        title: 'Frozen Food Restock',
        category: 'Frozen Food',
        type: TransactionType.income,
        amount: 2000000,
        party: 'Toko Berkah',
      ),
      AnalyticsTransaction(
        id: 'trx-06',
        date: DateTime(2026, 10, 28),
        title: 'Frozen Food Grosir',
        category: 'Frozen Food',
        type: TransactionType.income,
        amount: 1500000,
        party: 'Agen Malang',
      ),
      AnalyticsTransaction(
        id: 'trx-07',
        date: DateTime(2026, 10, 30),
        title: 'Frozen Food Pasar',
        category: 'Frozen Food',
        type: TransactionType.income,
        amount: 1500000,
        party: 'Pasar Gadang',
      ),

      // --- Pengeluaran Oktober 2026 (Rp 10.000.000) ---
      AnalyticsTransaction(
        id: 'trx-08',
        date: DateTime(2026, 10, 25),
        title: 'Belanja Bahan Baku',
        category: 'Bahan Baku Segar',
        type: TransactionType.expense,
        amount: 3000000,
        party: 'Pasar Gadang',
      ),
      AnalyticsTransaction(
        id: 'trx-09',
        date: DateTime(2026, 10, 27),
        title: 'Bumbu & Kemasan',
        category: 'Bahan Baku Segar',
        type: TransactionType.expense,
        amount: 2500000,
        party: 'Toko Sembako Jaya',
      ),
      AnalyticsTransaction(
        id: 'trx-10',
        date: DateTime(2026, 10, 29),
        title: 'Daging Ayam',
        category: 'Bahan Baku Segar',
        type: TransactionType.expense,
        amount: 1500000,
        party: 'CV Sumber Protein',
      ),
      AnalyticsTransaction(
        id: 'trx-11',
        date: DateTime(2026, 10, 26),
        title: 'Gas LPG 3kg',
        category: 'Gas LPG & Listrik',
        type: TransactionType.expense,
        amount: 1800000,
        party: 'Agen Gas',
      ),
      AnalyticsTransaction(
        id: 'trx-12',
        date: DateTime(2026, 10, 30),
        title: 'Token Listrik',
        category: 'Gas LPG & Listrik',
        type: TransactionType.expense,
        amount: 1200000,
        party: 'PLN',
      ),

      // --- September 2026, pembanding pertumbuhan (+13,6%) ---
      AnalyticsTransaction(
        id: 'trx-13',
        date: DateTime(2026, 9, 12),
        title: 'Penjualan Sosis Solo',
        category: 'Penjualan Siap Saji',
        type: TransactionType.income,
        amount: 6000000,
        party: 'Bu Rina',
      ),
      AnalyticsTransaction(
        id: 'trx-14',
        date: DateTime(2026, 9, 20),
        title: 'Frozen Food Grosir',
        category: 'Frozen Food',
        type: TransactionType.income,
        amount: 4200000,
        party: 'Agen Malang',
      ),
      AnalyticsTransaction(
        id: 'trx-15',
        date: DateTime(2026, 9, 25),
        title: 'Pesanan Katering',
        category: 'Penjualan Siap Saji',
        type: TransactionType.income,
        amount: 3000000,
        party: 'Pak Budi',
      ),
      AnalyticsTransaction(
        id: 'trx-16',
        date: DateTime(2026, 9, 10),
        title: 'Belanja Bahan Baku',
        category: 'Bahan Baku Segar',
        type: TransactionType.expense,
        amount: 5000000,
        party: 'Pasar Gadang',
      ),
      AnalyticsTransaction(
        id: 'trx-17',
        date: DateTime(2026, 9, 22),
        title: 'Gas & Listrik',
        category: 'Gas LPG & Listrik',
        type: TransactionType.expense,
        amount: 2000000,
        party: 'Agen Gas',
      ),
      AnalyticsTransaction(
        id: 'trx-18',
        date: DateTime(2026, 9, 28),
        title: 'Kemasan',
        category: 'Bahan Baku Segar',
        type: TransactionType.expense,
        amount: 2000000,
        party: 'Toko Sembako Jaya',
      ),
    ],
  );
}

/// Rentang penuh satu bulan.
DateTimeRange monthRangeOf(DateTime date) {
  return DateTimeRange(
    start: DateTime(date.year, date.month, 1),
    end: DateTime(date.year, date.month + 1, 0),
  );
}

/// Rentang pembanding sebelum [range] dengan durasi yang sama.
DateTimeRange previousRangeOf(DateTimeRange range) {
  final DateTime start = dateOnly(range.start);
  final DateTime end = dateOnly(range.end);
  final DateTime fullMonthEnd = DateTime(start.year, start.month + 1, 0);
  if (start.day == 1 && end == fullMonthEnd) {
    final DateTime previousEnd = DateTime(start.year, start.month, 0);
    return DateTimeRange(
      start: DateTime(previousEnd.year, previousEnd.month, 1),
      end: previousEnd,
    );
  }
  final int days = end.difference(start).inDays + 1;
  final DateTime previousEnd = DateTime(start.year, start.month, start.day - 1);
  final DateTime previousStart =
      DateTime(previousEnd.year, previousEnd.month, previousEnd.day - days + 1);
  return DateTimeRange(start: previousStart, end: previousEnd);
}

/// Tujuh hari (Senin–Minggu) pada minggu yang memuat [date].
List<DateTime> weekOf(DateTime date) {
  final DateTime start = startOfWeek(date);
  return <DateTime>[
    for (int i = 0; i < 7; i++)
      DateTime(start.year, start.month, start.day + i),
  ];
}
