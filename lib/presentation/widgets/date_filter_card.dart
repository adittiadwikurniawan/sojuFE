import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';

/// Kartu ringkas pemicu kalender tanggal.
///
/// Desain kalender lengkap ada pada [SojuCalendarCard] (Figma `302:6303`);
/// kartu ini adalah versi ringkas yang dipasang di setiap fitur. Ketuk bagian
/// utama untuk memilih tanggal dan gunakan panah bulan bila disediakan.
class DateFilterCard extends StatelessWidget {
  const DateFilterCard({
    super.key,
    required this.scale,
    required this.label,
    required this.onTap,
    this.caption = 'Tanggal',
    this.onPreviousMonth,
    this.onNextMonth,
  });

  final double scale;
  final String caption;
  final String label;
  final VoidCallback onTap;

  /// Navigasi bulan cepat; bila keduanya null, kartu menampilkan chevron.
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  bool get _hasMonthArrows => onPreviousMonth != null && onNextMonth != null;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      key: const Key('date_filter_card'),
      padding: EdgeInsets.fromLTRB(12 * s, 10 * s, 8 * s, 10 * s),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(15 * s),
        border: Border.all(color: SojuColors.hairline),
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 36 * s,
              height: 36 * s,
              decoration: BoxDecoration(
                color: SojuColors.calendarRange,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 20 * s,
                color: SojuColors.calendarSelected,
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 10.5 * s,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: SojuColors.analyticsMuted,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 14 * s,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: SojuColors.calendarInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_hasMonthArrows) ...<Widget>[
            _Arrow(
              scale: s,
              icon: Icons.chevron_left,
              tooltip: 'Bulan sebelumnya',
              onTap: onPreviousMonth!,
            ),
            SizedBox(width: 4 * s),
            _Arrow(
              scale: s,
              icon: Icons.chevron_right,
              tooltip: 'Bulan berikutnya',
              onTap: onNextMonth!,
            ),
          ] else
            Icon(
              Icons.keyboard_arrow_down,
              size: 20 * s,
              color: SojuColors.calendarMuted,
            ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.scale,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final double scale;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26 * scale,
          height: 26 * scale,
          decoration: const BoxDecoration(
            color: SojuColors.field,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18 * scale,
            color: SojuColors.calendarInk,
          ),
        ),
      ),
    );
  }
}
