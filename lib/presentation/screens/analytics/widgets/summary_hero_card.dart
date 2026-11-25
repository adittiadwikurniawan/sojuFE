import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../widgets/dashed_divider.dart';
import '../models/analytics_format.dart';
import '../models/analytics_summary.dart';

/// Kartu ringkasan "Evaluasi Bisnis Utama" (frame `546:2937`).
///
/// Seluruh nominal berasal dari [AnalyticsSummary] sehingga pemasukan,
/// pengeluaran, laba, margin, dan catatan evaluasi selalu konsisten dengan
/// transaksi yang lolos filter.
class SummaryHeroCard extends StatelessWidget {
  const SummaryHeroCard(
      {super.key, required this.scale, required this.summary});

  final double scale;
  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final bool isProfit = summary.netProfit >= 0;
    final Color profitColor =
        isProfit ? SojuColors.chartGreen : SojuColors.expense;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18 * scale),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _AmountRow(
            scale: scale,
            icon: Icons.arrow_downward_rounded,
            iconColor: SojuColors.chartGreen,
            iconBackground: SojuColors.incomeSoft,
            label: 'Total Pemasukan',
            value: formatRupiah(summary.income),
            valueColor: SojuColors.chartGreen,
          ),
          SizedBox(height: 9 * scale),
          _AmountRow(
            scale: scale,
            icon: Icons.arrow_upward_rounded,
            iconColor: SojuColors.expenseAccent,
            iconBackground: SojuColors.expenseSoft,
            label: 'Total Pengeluaran',
            value: formatRupiah(-summary.expense, withSign: true),
            valueColor: SojuColors.expense,
          ),
          SizedBox(height: 12 * scale),
          const DashedDivider(height: 1),
          SizedBox(height: 12 * scale),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Keuntungan Bersih',
                  style: TextStyle(
                    fontFamily: AppTypography.wordmarkFamily,
                    fontSize: 15.5 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF191C1E),
                  ),
                ),
              ),
              _MarginBadge(
                scale: scale,
                label:
                    '${formatPercentChange(summary.margin * 100)} ${summary.marginStatus}',
                positive: isProfit,
              ),
            ],
          ),
          SizedBox(height: 4 * scale),
          Text(
            formatRupiah(summary.netProfit),
            style: TextStyle(
              fontFamily: AppTypography.wordmarkFamily,
              fontSize: 35.5 * scale,
              fontWeight: FontWeight.w700,
              color: profitColor,
              height: 1.05,
            ),
          ),
          SizedBox(height: 6 * scale),
          Row(
            children: <Widget>[
              Icon(
                isProfit ? Icons.check_circle_outline : Icons.error_outline,
                size: 15 * scale,
                color: profitColor,
              ),
              SizedBox(width: 5 * scale),
              Expanded(
                child: Text(
                  summary.marginNote,
                  style: TextStyle(
                    fontFamily: AppTypography.wordmarkFamily,
                    fontSize: 13.3 * scale,
                    fontWeight: FontWeight.w400,
                    color: SojuColors.analyticsLabel,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.scale,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final double scale;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 31 * scale,
          height: 31 * scale,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(9 * scale),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16 * scale, color: iconColor),
        ),
        SizedBox(width: 9 * scale),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.wordmarkFamily,
              fontSize: 15.5 * scale,
              fontWeight: FontWeight.w400,
              color: SojuColors.analyticsLabel,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.wordmarkFamily,
            fontSize: 20 * scale,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _MarginBadge extends StatelessWidget {
  const _MarginBadge({
    required this.scale,
    required this.label,
    required this.positive,
  });

  final double scale;
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final Color color = positive ? SojuColors.chartGreen : SojuColors.expense;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 11 * scale,
        vertical: 3 * scale,
      ),
      decoration: BoxDecoration(
        color: positive ? SojuColors.incomeSoft : SojuColors.expenseSoft,
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            positive ? Icons.north_east : Icons.south_east,
            size: 11 * scale,
            color: color,
          ),
          SizedBox(width: 3 * scale),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.wordmarkFamily,
              fontSize: 11.1 * scale,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
