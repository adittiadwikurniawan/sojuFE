import 'package:flutter/material.dart';

import '../../../utils/format.dart';
import '../../../widgets/bar_chart_card.dart';
import '../models/dashboard_view_data.dart';

/// Kartu "Total Penghasilan" beserta grafik batang mingguan (frame
/// `546:1616`, node `546:1652`).
///
/// Pemetaan data beranda ke [BarChartCard]; kartu grafiknya dipakai bersama
/// dengan layar Analytics (frame `546:2937`).
class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({
    super.key,
    required this.scale,
    required this.data,
    this.onTap,
    this.onDateTap,
  });

  final double scale;
  final RevenueSummary data;

  /// Membuka Analytics saat kartu Total Penghasilan diketuk.
  final VoidCallback? onTap;

  /// Membuka pemilih tanggal dari pil tanggal di header kartu.
  final VoidCallback? onDateTap;

  @override
  Widget build(BuildContext context) {
    final bool isIncomeExpenseChart =
        data.thisWeekLegend.toLowerCase().contains('pemasukan');
    final Widget card = BarChartCard(
      scale: scale,
      onDateTap: onDateTap,
      data: BarChartData(
        title: data.title,
        total: data.total,
        dateLabel: data.dateLabel,
        growth: data.growth,
        growthPositive: !data.growth.startsWith('-'),
        axisMax: data.axisMax,
        // Pada grafik kas: Hijau (secondary) = Pemasukan, Navy (primary) = Pengeluaran.
        primaryLegend:
            isIncomeExpenseChart ? data.lastWeekLegend : data.thisWeekLegend,
        secondaryLegend:
            isIncomeExpenseChart ? data.thisWeekLegend : data.lastWeekLegend,
        valueFormatter: formatChartValue,
        days: <BarChartDay>[
          for (final RevenueDayData day in data.days)
            BarChartDay(
              label: day.label,
              primary: isIncomeExpenseChart ? day.lastWeek : day.thisWeek,
              secondary: isIncomeExpenseChart ? day.thisWeek : day.lastWeek,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }
    return Semantics(
      button: true,
      label: 'Buka Analytics dari Total Penghasilan',
      child: GestureDetector(
        key: const Key('total_penghasilan_card'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: card,
      ),
    );
  }
}
