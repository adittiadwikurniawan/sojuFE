import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/analytics_format.dart';
import '../models/analytics_transaction.dart';
import 'category_icon.dart';

/// Satu baris transaksi pada daftar input Analytics (frame `546:2937`).
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.scale,
    required this.transaction,
    this.onTap,
  });

  final double scale;
  final AnalyticsTransaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.isIncome;
    final Color accent = isIncome ? SojuColors.chartGreen : SojuColors.expense;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 12 * scale,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44 * scale,
              height: 44 * scale,
              decoration: BoxDecoration(
                color:
                    isIncome ? SojuColors.incomeSoft : SojuColors.expenseSoft,
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${transaction.date.day}',
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w700,
                      color: accent,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    formatDayMonth(transaction.date).split(' ').last,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 9.5 * scale,
                      fontWeight: FontWeight.w600,
                      color: accent,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: SojuColors.ink,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Row(
                    children: <Widget>[
                      Icon(
                        categoryIconFor(transaction.category, transaction.type),
                        size: 12 * scale,
                        color: SojuColors.analyticsMuted,
                      ),
                      SizedBox(width: 4 * scale),
                      Expanded(
                        child: Text(
                          '${transaction.category} • ${transaction.party}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 11.5 * scale,
                            fontWeight: FontWeight.w400,
                            color: SojuColors.analyticsMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * scale),
            Text(
              formatRupiah(transaction.signedAmount, withSign: true),
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 13.5 * scale,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
