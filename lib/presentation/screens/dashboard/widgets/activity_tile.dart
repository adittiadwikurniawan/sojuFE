import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/dashboard_view_data.dart';

/// Satu baris daftar "Aktivitas" pada beranda (frame `546:1616`,
/// node `669:1955`).
class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.scale,
    required this.data,
    this.onDetail,
  });

  final double scale;
  final DashboardActivityData data;
  final VoidCallback? onDetail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 83 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 99 * scale,
            height: 78.3 * scale,
            decoration: BoxDecoration(
              color: SojuColors.surfaceMuted,
              borderRadius: BorderRadius.circular(5 * scale),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5 * scale),
              child: Image.asset(
                data.imageAsset,
                width: 78 * scale,
                height: 67 * scale,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    _Badge(scale: scale, label: data.badge),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        data.pack,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2 * scale),
                Text(
                  data.variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.textMuted,
                  ),
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        data.sku,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    _DetailButton(scale: scale, onTap: onDetail),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.scale, required this.label});

  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
        vertical: 3.5 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.badgeBlue,
        borderRadius: BorderRadius.circular(20.5 * scale),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 8.2 * scale,
          fontWeight: FontWeight.w700,
          color: SojuColors.surface,
        ),
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  const _DetailButton({required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 16 * scale,
        padding: EdgeInsets.symmetric(horizontal: 5 * scale),
        decoration: BoxDecoration(
          color: SojuColors.positive,
          borderRadius: BorderRadius.circular(30 * scale),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.edit, size: 7 * scale, color: SojuColors.surface),
            SizedBox(width: 2.5 * scale),
            Text(
              'Detail',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 9 * scale,
                fontWeight: FontWeight.w700,
                color: SojuColors.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
