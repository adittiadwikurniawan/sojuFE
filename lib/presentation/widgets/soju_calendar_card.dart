import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';
import '../utils/format.dart';

/// Kartu kalender bulanan dari Figma `302:6303` (`Calender`).
///
/// Desain asli berukuran 335x347 px: judul "Pilih Tanggal", garis pemisah,
/// baris nama hari, lalu grid tanggal 7 kolom. Varian `Selected` memakai
/// ungu `#2C14DD` untuk tanggal awal/akhir dan `#EEECFD` untuk rentang.
///
/// Widget ini controlled: pemilihan tanggal, perpindahan bulan, dan data
/// ditangani pemanggil agar mudah dipakai ulang di Beranda, Analytics, dan
/// Audit.
class SojuCalendarCard extends StatelessWidget {
  const SojuCalendarCard({
    super.key,
    required this.month,
    required this.onDayTap,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.range,
    this.scale = 1,
    this.title = 'Pilih Tanggal',
  });

  /// Bulan yang ditampilkan (hanya tahun & bulan yang dipakai).
  final DateTime month;

  /// Rentang tanggal terpilih. `null` berarti belum ada pilihan.
  final DateTimeRange? range;

  final ValueChanged<DateTime> onDayTap;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  /// Skala dari lebar desain 335 px.
  final double scale;

  final String title;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final DateTime firstDay = DateTime(month.year, month.month, 1);
    final int leading = firstDay.weekday - 1; // Senin = kolom pertama.
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final int rowCount = ((leading + daysInMonth) / 7).ceil();

    final DateTime? start = range == null ? null : dateOnly(range!.start);
    final DateTime? end = range == null ? null : dateOnly(range!.end);
    final DateTime? rangeStart =
        start != null && end != null && end.isBefore(start) ? end : start;
    final DateTime? rangeEnd =
        start != null && end != null && end.isBefore(start) ? start : end;

    return Container(
      width: 335 * s,
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(15 * s),
        border: Border.all(color: SojuColors.calendarDivider),
      ),
      padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 17 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 17 * s,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 14 * s,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.33 * s,
                      color: SojuColors.calendarInk,
                    ),
                  ),
                ),
                _MonthArrow(
                  scale: s,
                  icon: Icons.chevron_left,
                  tooltip: 'Bulan sebelumnya',
                  onTap: onPreviousMonth,
                ),
                SizedBox(width: 4 * s),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 96 * s),
                  child: Text(
                    formatMonthYear(month),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 10.5 * s,
                      fontWeight: FontWeight.w600,
                      color: SojuColors.calendarMuted,
                    ),
                  ),
                ),
                SizedBox(width: 4 * s),
                _MonthArrow(
                  scale: s,
                  icon: Icons.chevron_right,
                  tooltip: 'Bulan berikutnya',
                  onTap: onNextMonth,
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * s),
          Container(height: 1, color: SojuColors.calendarDivider),
          SizedBox(height: 24 * s),
          SizedBox(
            height: 19 * s,
            child: Row(
              children: <Widget>[
                for (int index = 0; index < 7; index++)
                  Expanded(
                    child: Center(
                      child: Text(
                        weekdayShort(DateTime(2024, 1, 1 + index)),
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 10.5 * s,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.calendarMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 18 * s),
          for (int row = 0; row < rowCount; row++) ...<Widget>[
            if (row > 0) SizedBox(height: 11 * s),
            SizedBox(
              height: 35 * s,
              child: Row(
                children: <Widget>[
                  for (int column = 0; column < 7; column++)
                    Expanded(
                      child: Center(
                        child: _buildCell(
                          row: row,
                          column: column,
                          leading: leading,
                          daysInMonth: daysInMonth,
                          rangeStart: rangeStart,
                          rangeEnd: rangeEnd,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCell({
    required int row,
    required int column,
    required int leading,
    required int daysInMonth,
    required DateTime? rangeStart,
    required DateTime? rangeEnd,
  }) {
    final int cellIndex = row * 7 + column;
    final int day = cellIndex - leading + 1;
    if (day < 1 || day > daysInMonth) {
      return SizedBox(width: 35 * scale, height: 35 * scale);
    }

    final DateTime date = DateTime(month.year, month.month, day);
    final DateTime normalized = dateOnly(date);
    final bool isStart =
        rangeStart != null && dateOnly(rangeStart) == normalized;
    final bool isEnd = rangeEnd != null && dateOnly(rangeEnd) == normalized;
    final bool selected = isStart || isEnd;
    final bool inRange = rangeStart != null &&
        rangeEnd != null &&
        normalized.isAfter(dateOnly(rangeStart)) &&
        normalized.isBefore(dateOnly(rangeEnd));

    final Color? background = selected
        ? SojuColors.calendarSelected
        : inRange
            ? SojuColors.calendarRange
            : null;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Pilih ${formatDateRange(DateTimeRange(start: date, end: date))}',
      child: GestureDetector(
        key: Key(
          'soju_calendar_day_${date.year}_${date.month}_${date.day}',
        ),
        behavior: HitTestBehavior.opaque,
        onTap: () => onDayTap(date),
        child: Container(
          width: 35 * scale,
          height: 35 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(5 * scale),
          ),
          child: Text(
            '$day',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 14 * scale,
              height: 1.2,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: -0.33 * scale,
              color: selected ? SojuColors.surface : SojuColors.calendarInk,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({
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
        child: SizedBox(
          width: 17 * scale,
          height: 17 * scale,
          child: Icon(
            icon,
            size: 16 * scale,
            color: SojuColors.calendarMuted,
          ),
        ),
      ),
    );
  }
}
