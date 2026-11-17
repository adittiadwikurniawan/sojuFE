// Unit test: model & perhitungan layar Analytics.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/presentation/screens/analytics/models/analytics_filter.dart';
import 'package:soju_fe/presentation/screens/analytics/models/analytics_format.dart';
import 'package:soju_fe/presentation/screens/analytics/models/analytics_summary.dart';
import 'package:soju_fe/presentation/screens/analytics/models/analytics_transaction.dart';
import 'package:soju_fe/presentation/screens/analytics/models/analytics_view_data.dart';

void main() {
  final AnalyticsViewData data = AnalyticsViewData.sample;
  final DateTimeRange october = monthRangeOf(DateTime(2026, 10));
  final List<AnalyticsTransaction> octoberTransactions =
      data.transactions.where(AnalyticsFilter(range: october).matches).toList();

  group('AnalyticsSummary', () {
    test('menurunkan total bulan berjalan dari transaksi', () {
      final AnalyticsSummary summary =
          AnalyticsSummary.from(octoberTransactions);

      expect(summary.transactionCount, 12);
      expect(summary.income, 15000000);
      expect(summary.expense, 10000000);
      expect(summary.netProfit, 5000000);
      expect(summary.totalFlow, 25000000);
      expect(summary.margin, closeTo(1 / 3, 0.0001));
      expect(summary.incomeShare, closeTo(0.6, 0.0001));
      expect(summary.expenseShare, closeTo(0.4, 0.0001));
      expect(summary.marginStatus, 'Margin Positif');
      expect(summary.marginNote, 'Arus kas sehat & siap dialokasikan');
    });

    test('ringkasan kosong tidak membagi dengan nol', () {
      const AnalyticsSummary empty = AnalyticsSummary.empty;

      expect(empty.hasData, isFalse);
      expect(empty.margin, 0);
      expect(empty.incomeShare, 0);
      expect(empty.expenseShare, 0);
      expect(empty.marginNote, 'Belum ada transaksi pada periode ini');
    });

    test('margin negatif ditandai sebagai defisit', () {
      const AnalyticsSummary loss = AnalyticsSummary(
        income: 1000000,
        expense: 1500000,
        transactionCount: 3,
      );

      expect(loss.netProfit, -500000);
      expect(loss.margin, closeTo(-0.5, 0.0001));
      expect(loss.marginStatus, 'Margin Negatif');
      expect(loss.marginNote, 'Arus kas negatif, evaluasi pengeluaran');
    });
  });

  group('Perhitungan lanjutan', () {
    test('total kategori diurutkan menurun dan porsinya benar', () {
      final List<CategoryTotal> income =
          categoryTotals(octoberTransactions, TransactionType.income);

      expect(income.map((CategoryTotal item) => item.category), <String>[
        'Penjualan Siap Saji',
        'Frozen Food',
      ]);
      expect(income.first.amount, 10000000);
      expect(income.first.count, 4);
      expect(income.first.shareOf(15000000), closeTo(2 / 3, 0.0001));
      expect(income.last.shareOf(15000000), closeTo(1 / 3, 0.0001));
    });

    test('total harian mengisi hari kosong dalam rentang', () {
      final List<DailyTotal> days = dailyTotals(
        octoberTransactions,
        start: DateTime(2026, 10, 25),
        end: DateTime(2026, 10, 31),
      );

      expect(days.length, 7);
      expect(days.first.date, DateTime(2026, 10, 25));
      expect(days.first.income, 3000000);
      expect(days.first.expense, 3000000);
      expect(days.last.date, DateTime(2026, 10, 31));
      expect(days.last.income, 2000000);
      expect(days.last.expense, 0);
    });

    test('pertumbuhan memakai rentang sebelumnya yang sama panjang', () {
      final DateTimeRange previous = previousRangeOf(october);
      expect(previous.start, DateTime(2026, 9, 1));
      expect(previous.end, DateTime(2026, 9, 30));

      final AnalyticsSummary summary = AnalyticsSummary.from(
        data.transactions
            .where(AnalyticsFilter(range: previous).matches)
            .toList(),
      );

      expect(summary.income, 13200000);
      expect(
        percentageChange(15000000, summary.income),
        closeTo(13.636, 0.01),
      );
      expect(percentageChange(0, 0), 0);
      expect(percentageChange(1000, 0), 100);
    });

    test('batas sumbu grafik dibulatkan ke angka rapi', () {
      expect(niceAxisMax(0), 100);
      expect(niceAxisMax(1000), 1000);
      expect(niceAxisMax(1800), 2000);
      expect(niceAxisMax(3000), 5000);
      expect(niceAxisMax(4200), 5000);
    });
  });

  group('AnalyticsFilter', () {
    List<AnalyticsTransaction> apply(AnalyticsFilter filter) {
      return data.transactions.where(filter.matches).toList();
    }

    test('memfilter berdasarkan jenis dan kategori', () {
      expect(
        apply(AnalyticsFilter(range: october, type: TransactionType.income))
            .length,
        7,
      );
      expect(
        apply(AnalyticsFilter(range: october, category: 'Frozen Food')).length,
        3,
      );
    });

    test('memfilter berdasarkan pencarian judul, kategori, dan pihak', () {
      expect(
        apply(AnalyticsFilter(range: october, query: 'pasar')).length,
        2,
      );
      expect(
        apply(AnalyticsFilter(range: october, query: 'FROZEN')).length,
        3,
      );
      expect(
        apply(AnalyticsFilter(range: october, query: 'tidak-ada')).isEmpty,
        isTrue,
      );
    });

    test('memfilter satu tanggal dan mengabaikan jam', () {
      final AnalyticsFilter dayFilter = AnalyticsFilter(
        range: DateTimeRange(
          start: DateTime(2026, 10, 31, 8, 30),
          end: DateTime(2026, 10, 31, 20, 0),
        ),
      );

      final List<AnalyticsTransaction> result = apply(dayFilter);
      expect(result.length, 1);
      expect(result.single.id, 'trx-04');
    });

    test('helper with... mempertahankan filter lain', () {
      final AnalyticsFilter base = const AnalyticsFilter()
          .withType(TransactionType.expense)
          .withCategory('Bahan Baku Segar')
          .withQuery('belanja')
          .withRange(october);

      expect(base.type, TransactionType.expense);
      expect(base.category, 'Bahan Baku Segar');
      expect(base.query, 'belanja');
      expect(base.range, october);
      expect(base.clear().isEmpty, isTrue);
    });
  });

  group('Format angka dan tanggal', () {
    test('rupiah penuh dan bertanda', () {
      expect(formatRupiah(15000000), 'Rp 15.000.000');
      expect(formatRupiah(-10000000, withSign: true), '- Rp 10.000.000');
      expect(formatRupiah(0, withSign: true), 'Rp 0');
    });

    test('rupiah ringkas', () {
      expect(formatCompactRupiah(15000000), 'Rp 15 Jt');
      expect(formatCompactRupiah(1500000), 'Rp 1.5 Jt');
      expect(formatCompactRupiah(500000), 'Rp 500 rb');
      expect(formatCompactRupiah(2500000000), 'Rp 2.5 M');
    });

    test('persen dan pertumbuhan', () {
      expect(formatPercent(0.6), '60%');
      expect(formatPercent(1 / 3, decimals: 1), '33.3%');
      expect(formatPercentChange(13.636), '+13.6%');
      expect(formatPercentChange(-5), '-5%');
      expect(formatPercentChange(0), '0%');
    });

    test('label tanggal dan bulan', () {
      expect(formatMonthYear(DateTime(2026, 10)), 'Oktober 2026');
      expect(formatDateRange(october), '1–31 Okt 2026');
      expect(
        formatDateRange(
          DateTimeRange(
            start: DateTime(2026, 10, 25),
            end: DateTime(2026, 11, 3),
          ),
        ),
        '25 Okt – 3 Nov 2026',
      );
      expect(
        formatDateRange(
          DateTimeRange(
            start: DateTime(2026, 10, 31),
            end: DateTime(2026, 10, 31),
          ),
        ),
        '31 Okt 2026',
      );
    });

    test('label sumbu grafik dalam ribuan', () {
      expect(formatChartValue(0), '0');
      expect(formatChartValue(500), '500rb');
      expect(formatChartValue(1500), '1.5jt');
      expect(formatChartValue(3000), '3jt');
    });
  });
}
