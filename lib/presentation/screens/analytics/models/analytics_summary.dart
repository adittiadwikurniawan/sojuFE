import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'analytics_format.dart';
import 'analytics_transaction.dart';

/// Ringkasan arus kas hasil turunan dari daftar transaksi.
///
/// Semua angka pada layar Analytics (hero card, donat, grafik, rincian
/// kategori) dihitung dari kelas ini sehingga tidak ada nominal hardcoded di
/// widget dan data dari API langsung menghasilkan angka yang konsisten.
@immutable
class AnalyticsSummary {
  const AnalyticsSummary({
    required this.income,
    required this.expense,
    required this.transactionCount,
  });

  /// Total pemasukan (rupiah).
  final double income;

  /// Total pengeluaran (rupiah, positif).
  final double expense;

  /// Jumlah transaksi yang dihitung.
  final int transactionCount;

  /// Ringkasan kosong saat filter tidak menemukan transaksi.
  static const AnalyticsSummary empty = AnalyticsSummary(
    income: 0,
    expense: 0,
    transactionCount: 0,
  );

  /// Menghitung ringkasan dari sekumpulan transaksi.
  factory AnalyticsSummary.from(Iterable<AnalyticsTransaction> transactions) {
    double income = 0;
    double expense = 0;
    int count = 0;
    for (final AnalyticsTransaction transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
      count++;
    }
    return AnalyticsSummary(
      income: income,
      expense: expense,
      transactionCount: count,
    );
  }

  /// Laba bersih (pemasukan − pengeluaran).
  double get netProfit => income - expense;

  /// Total arus kas (pemasukan + pengeluaran) untuk proporsi donat.
  double get totalFlow => income + expense;

  /// Margin laba terhadap pemasukan (`0` bila belum ada pemasukan).
  double get margin => income == 0 ? 0 : netProfit / income;

  /// Porsi pemasukan terhadap total arus kas (`0..1`).
  double get incomeShare => totalFlow == 0 ? 0 : income / totalFlow;

  /// Porsi pengeluaran terhadap total arus kas (`0..1`).
  double get expenseShare => totalFlow == 0 ? 0 : expense / totalFlow;

  bool get hasData => transactionCount > 0;

  /// Catatan evaluasi singkat pada hero card, diturunkan dari margin.
  String get marginNote {
    if (!hasData) {
      return 'Belum ada transaksi pada periode ini';
    }
    if (netProfit < 0) {
      return 'Arus kas negatif, evaluasi pengeluaran';
    }
    if (margin < 0.2) {
      return 'Arus kas tipis, jaga pengeluaran';
    }
    return 'Arus kas sehat & siap dialokasikan';
  }

  /// Label status margin pada badge hero card.
  String get marginStatus =>
      netProfit >= 0 ? 'Margin Positif' : 'Margin Negatif';
}

/// Total satu kategori pada rincian transaksi.
@immutable
class CategoryTotal {
  const CategoryTotal({
    required this.category,
    required this.type,
    required this.amount,
    required this.count,
  });

  final String category;
  final TransactionType type;
  final double amount;

  /// Jumlah transaksi pada kategori ini.
  final int count;

  /// Porsi kategori terhadap total jenisnya (`0..1`).
  double shareOf(double total) => total == 0 ? 0 : amount / total;
}

/// Mengelompokkan transaksi per kategori untuk [type] tertentu, terbesar
/// lebih dulu.
List<CategoryTotal> categoryTotals(
  Iterable<AnalyticsTransaction> transactions,
  TransactionType type,
) {
  final Map<String, double> amounts = <String, double>{};
  final Map<String, int> counts = <String, int>{};
  for (final AnalyticsTransaction transaction in transactions) {
    if (transaction.type != type) {
      continue;
    }
    amounts.update(
      transaction.category,
      (double value) => value + transaction.amount,
      ifAbsent: () => transaction.amount,
    );
    counts.update(
      transaction.category,
      (int value) => value + 1,
      ifAbsent: () => 1,
    );
  }
  final List<CategoryTotal> result = <CategoryTotal>[
    for (final MapEntry<String, double> entry in amounts.entries)
      CategoryTotal(
        category: entry.key,
        type: type,
        amount: entry.value,
        count: counts[entry.key] ?? 0,
      ),
  ]..sort((CategoryTotal a, CategoryTotal b) => b.amount.compareTo(a.amount));
  return result;
}

/// Total arus kas pada satu hari, dipakai grafik tren harian.
@immutable
class DailyTotal {
  const DailyTotal({
    required this.date,
    required this.income,
    required this.expense,
  });

  final DateTime date;
  final double income;
  final double expense;

  double get net => income - expense;
}

/// Total harian inklusif dari [start] sampai [end].
List<DailyTotal> dailyTotals(
  Iterable<AnalyticsTransaction> transactions, {
  required DateTime start,
  required DateTime end,
}) {
  final DateTime first = dateOnly(start);
  final DateTime last = dateOnly(end);
  final Map<DateTime, DailyTotal> byDate = <DateTime, DailyTotal>{
    for (DateTime day = first;
        !day.isAfter(last);
        day = DateTime(day.year, day.month, day.day + 1))
      day: DailyTotal(date: day, income: 0, expense: 0),
  };
  for (final AnalyticsTransaction transaction in transactions) {
    final DateTime key = dateOnly(transaction.date);
    final DailyTotal? current = byDate[key];
    if (current == null) {
      continue;
    }
    byDate[key] = DailyTotal(
      date: current.date,
      income: current.income + (transaction.isIncome ? transaction.amount : 0),
      expense:
          current.expense + (transaction.isIncome ? 0 : transaction.amount),
    );
  }
  return byDate.values.toList(growable: false);
}

/// Perubahan relatif `current` terhadap `previous` dalam persen.
///
/// Mengembalikan `0` bila keduanya kosong, dan `100` bila hanya [current] yang
/// bernilai (kenaikan dari nol).
double percentageChange(double current, double previous) {
  if (previous == 0) {
    return current == 0 ? 0 : 100;
  }
  return (current - previous) / previous * 100;
}

/// Batas atas sumbu grafik yang "bulat" untuk nilai maksimum [raw] (satuan
/// ribuan), mis. `3000` → `5000`.
int niceAxisMax(int raw) {
  if (raw <= 0) {
    return 100;
  }
  final int exponent = (math.log(raw) / math.ln10).floor();
  final int magnitude = math.pow(10, exponent).round();
  final double normalized = raw / magnitude;
  final int factor;
  if (normalized <= 1) {
    factor = 1;
  } else if (normalized <= 2) {
    factor = 2;
  } else if (normalized <= 5) {
    factor = 5;
  } else {
    factor = 10;
  }
  return factor * magnitude;
}
