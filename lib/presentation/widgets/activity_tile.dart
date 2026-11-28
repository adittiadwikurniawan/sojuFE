import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';
import '../models/activity_view_data.dart';

/// Satu baris daftar riwayat catatan kas (Pemasukan / Pengeluaran).
///
/// Dipakai bersama oleh Beranda, Analytics, dan halaman "Lihat Semua" agar
/// tampilan mutasi kas konsisten dan mudah dibaca.
class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.scale,
    required this.data,
    this.onDetail,
    this.showDetailAction = true,
  });

  final double scale;
  final ActivityData data;
  final VoidCallback? onDetail;

  /// Sembunyikan tombol Detail ketika halaman hanya menyediakan mode lihat.
  final bool showDetailAction;

  @override
  Widget build(BuildContext context) {
    final bool isExpense = data.isExpense;
    final Color accentColor =
        isExpense ? const Color(0xFFEF4444) : SojuColors.brandEmerald;
    final Color softBgColor =
        isExpense ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 74 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              color: softBgColor,
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            alignment: Alignment.center,
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: accentColor,
              size: 22 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w700,
                          color: SojuColors.ink,
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      data.pack,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 13.5 * scale,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4 * scale),
                Row(
                  children: <Widget>[
                    _Badge(
                      scale: scale,
                      label: data.badge,
                      color: accentColor,
                      bgColor: softBgColor,
                    ),
                    SizedBox(width: 6 * scale),
                    Expanded(
                      child: Text(
                        data.variant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 11.5 * scale,
                          fontWeight: FontWeight.w500,
                          color: SojuColors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4 * scale),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        data.sku,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w500,
                          color: SojuColors.textMuted,
                        ),
                      ),
                    ),
                    if (showDetailAction) ...<Widget>[
                      SizedBox(width: 8 * scale),
                      _DetailButton(scale: scale, onTap: onDetail),
                    ],
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
  const _Badge({
    required this.scale,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final double scale;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7 * scale,
        vertical: 2.5 * scale,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 9.5 * scale,
          fontWeight: FontWeight.w700,
          color: color,
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
        height: 20 * scale,
        padding: EdgeInsets.symmetric(horizontal: 8 * scale),
        decoration: BoxDecoration(
          color: SojuColors.blueSoft,
          borderRadius: BorderRadius.circular(30 * scale),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.receipt_long_rounded,
              size: 10 * scale,
              color: SojuColors.brandNavy,
            ),
            SizedBox(width: 3 * scale),
            Text(
              'Detail',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 10 * scale,
                fontWeight: FontWeight.w700,
                color: SojuColors.brandNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
