import 'package:flutter/material.dart';

import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/soju_colors.dart';

/// Header prototype chat penjualan harian/shift.
///
/// Hanya memuat tombol kembali, identitas Soju, badge "Pratinjau", dan judul.
/// Tidak ada notifikasi atau menu tanpa fungsi pada prototype.
class SalesChatHeader extends StatelessWidget {
  const SalesChatHeader({
    super.key,
    required this.scale,
    this.onBack,
  });

  final double scale;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(26 * scale),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            14 * scale,
            8 * scale,
            14 * scale,
            13 * scale,
          ),
          child: Row(
            children: <Widget>[
              Semantics(
                button: true,
                label: 'Kembali',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      key: const Key('sales_chat_back'),
                      width: 40 * scale,
                      height: 40 * scale,
                      decoration: const BoxDecoration(
                        color: SojuColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20 * scale,
                        color: SojuColors.notificationTitle,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/images/ai_sparkle.png',
                          width: 13 * scale,
                          height: 13 * scale,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          'Soju',
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 10.5 * scale,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.notificationTitle,
                          ),
                        ),
                        SizedBox(width: 6 * scale),
                        _PreviewBadge(scale: scale),
                      ],
                    ),
                    SizedBox(height: 3 * scale),
                    Text(
                      'Penjualan Harian/Shift',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w800,
                        color: SojuColors.notificationTitle,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      'Asisten dapur • Mode demo, data tidak disimpan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 9.5 * scale,
                        fontWeight: FontWeight.w400,
                        color: SojuColors.analyticsMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
        vertical: 2.5 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.demoSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SojuColors.demoBorder),
      ),
      child: Text(
        'Pratinjau',
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 8 * scale,
          fontWeight: FontWeight.w700,
          color: SojuColors.demoInk,
        ),
      ),
    );
  }
}
