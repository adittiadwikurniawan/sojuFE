import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/analytics_format.dart';

/// Strip kalender 5-hari bergaya Schedule untuk memilih tanggal cepat
/// di halaman Analytics / Data Pembukuan.
class ScheduleFiveDayStrip extends StatelessWidget {
  const ScheduleFiveDayStrip({
    super.key,
    required this.scale,
    required this.anchorDate,
    required this.selectedDay,
    required this.onSelectDay,
    required this.onClearDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onOpenFullCalendar,
  });

  final double scale;
  final DateTime anchorDate;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onClearDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onOpenFullCalendar;

  @override
  Widget build(BuildContext context) {
    final DateTime center = selectedDay ?? anchorDate;
    final List<DateTime> days = List<DateTime>.generate(
      5,
      (int i) => DateTime(center.year, center.month, center.day + (i - 2)),
    );

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: SojuColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              InkWell(
                onTap: onPreviousMonth,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 20 * scale,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onOpenFullCalendar,
                  child: Text(
                    formatMonthYear(center),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 13.5 * scale,
                      fontWeight: FontWeight.w700,
                      color: SojuColors.ink,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: onNextMonth,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20 * scale,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: selectedDay != null ? onClearDay : onOpenFullCalendar,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  selectedDay != null ? 'Semua Tanggal ›' : 'Kalender ›',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11.5 * scale,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.brandNavy,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          Row(
            children: <Widget>[
              for (int i = 0; i < days.length; i++) ...<Widget>[
                if (i > 0) SizedBox(width: 6 * scale),
                Expanded(
                  child: _DayTile(
                    scale: scale,
                    date: days[i],
                    isSelected: selectedDay != null &&
                        dateOnly(days[i]) == dateOnly(selectedDay!),
                    isToday: dateOnly(days[i]) == dateOnly(DateTime.now()),
                    onTap: () => onSelectDay(days[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.scale,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final double scale;
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? SojuColors.brandNavy
          : isToday
              ? SojuColors.blueSoft
              : SojuColors.canvas,
      borderRadius: BorderRadius.circular(12 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8 * scale, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: isSelected
                  ? SojuColors.brandNavy
                  : isToday
                      ? SojuColors.freeTableBlueBorder60
                      : SojuColors.cardBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                weekdayShort(date),
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 10.5 * scale,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white70 : SojuColors.inkMuted,
                ),
              ),
              SizedBox(height: 3 * scale),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 14.5 * scale,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : SojuColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
