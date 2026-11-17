import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Kartu ringkasan metrik pada baris geser horizontal beranda.
///
/// Figma: `Net Profit Metric` (`546:1764`) dan `Cash in Hand Metric`
/// (`546:1752`, `546:1776`).
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.scale,
    required this.title,
    required this.value,
    required this.note,
    this.titleSize = 15.4,
  });

  final double scale;
  final String title;
  final String value;
  final String note;

  /// Ukuran judul bervariasi antar kartu (13.4 / 15.4 pada Figma).
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 193 * scale,
      height: 116 * scale,
      padding: EdgeInsets.all(17.7 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(28 * scale),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      // Stack (bukan Column) agar kartu tidak melaporkan overflow saat font
      // fallback lebih tinggi; judul menempel atas, angka menempel bawah.
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.wordmarkFamily,
                      fontSize: titleSize * scale,
                      fontWeight: FontWeight.w700,
                      color: SojuColors.metricTitle,
                    ),
                  ),
                ),
                Icon(
                  Icons.north_east,
                  size: 13 * scale,
                  color: SojuColors.metricTitle,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.wordmarkFamily,
                    fontSize: 21 * scale,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.metricValue,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.wordmarkFamily,
                    fontSize: 12.2 * scale,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.positive,
                    height: 1.2,
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
