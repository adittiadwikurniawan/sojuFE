import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/analytics_format.dart';
import '../models/analytics_summary.dart';

/// Kartu "Proporsi Arus Kas" dengan grafik donat (frame `546:2937`,
/// node `546:3167`).
class CashFlowDonutCard extends StatelessWidget {
  const CashFlowDonutCard({
    super.key,
    required this.scale,
    required this.summary,
  });

  final double scale;
  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final bool isProfit = summary.netProfit >= 0;
    final int marginPercent = (summary.margin * 100).round();
    final String marginLabel = '${marginPercent > 0 ? '+' : ''}$marginPercent%';

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
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Proporsi Arus Kas',
                  style: TextStyle(
                    fontFamily: AppTypography.wordmarkFamily,
                    fontSize: 15.6 * scale,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.analyticsTitle,
                  ),
                ),
              ),
              Text(
                'Total ${formatRupiah(summary.totalFlow)}',
                style: TextStyle(
                  fontFamily: AppTypography.wordmarkFamily,
                  fontSize: 11.1 * scale,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.analyticsMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 18 * scale),
          Center(
            child: SizedBox(
              width: 196 * scale,
              height: 196 * scale,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  CustomPaint(
                    size: Size.square(196 * scale),
                    painter: _DonutPainter(
                      incomeShare: summary.incomeShare,
                      expenseShare: summary.expenseShare,
                      strokeWidth: 19.57 * scale,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'MARGIN',
                        style: TextStyle(
                          fontFamily: AppTypography.wordmarkFamily,
                          fontSize: 11.1 * scale,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.analyticsMuted,
                        ),
                      ),
                      Text(
                        marginLabel,
                        style: TextStyle(
                          fontFamily: AppTypography.wordmarkFamily,
                          fontSize: 26.7 * scale,
                          fontWeight: FontWeight.w700,
                          color: isProfit
                              ? SojuColors.chartGreen
                              : SojuColors.expense,
                        ),
                      ),
                      Text(
                        isProfit ? 'Surplus' : 'Defisit',
                        style: TextStyle(
                          fontFamily: AppTypography.wordmarkFamily,
                          fontSize: 11.1 * scale,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.analyticsLabel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12 * scale),
          Container(
            padding: EdgeInsets.all(13 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(13 * scale),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _LegendItem(
                    scale: scale,
                    color: SojuColors.chartGreen,
                    label: 'Pemasukan',
                    detail:
                        '${formatPercent(summary.incomeShare)} • ${formatCompactRupiah(summary.income)}',
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _LegendItem(
                    scale: scale,
                    color: SojuColors.expense,
                    label: 'Pengeluaran',
                    detail:
                        '${formatPercent(summary.expenseShare)} • ${formatCompactRupiah(summary.expense)}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.scale,
    required this.color,
    required this.label,
    required this.detail,
  });

  final double scale;
  final Color color;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 13 * scale,
          height: 13 * scale,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5 * scale),
          ),
        ),
        SizedBox(width: 9 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.wordmarkFamily,
                  fontSize: 13.3 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF191C1E),
                ),
              ),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.wordmarkFamily,
                  fontSize: 11.1 * scale,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.incomeShare,
    required this.expenseShare,
    required this.strokeWidth,
  });

  final double incomeShare;
  final double expenseShare;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(
      center,
      radius,
      paint..color = const Color(0xFFF2F4F6),
    );

    const double start = -math.pi / 2;
    if (incomeShare > 0) {
      canvas.drawArc(
        rect,
        start,
        2 * math.pi * incomeShare,
        false,
        paint..color = SojuColors.chartGreen,
      );
    }
    if (expenseShare > 0) {
      canvas.drawArc(
        rect,
        start + 2 * math.pi * incomeShare,
        2 * math.pi * expenseShare,
        false,
        paint..color = SojuColors.expense,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) {
    return oldDelegate.incomeShare != incomeShare ||
        oldDelegate.expenseShare != expenseShare ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
