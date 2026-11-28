import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';
import '../utils/format.dart';
import 'soju_calendar_card.dart';

/// Hasil pemilihan tanggal dari [showSojuDateCalendarSheet].
///
/// [range] bernilai `null` ketika pengguna menekan "Hapus".
@immutable
class SojuDateSelection {
  const SojuDateSelection(this.range);

  final DateTimeRange? range;
}

/// Menampilkan kartu kalender Figma `302:6303` di dalam bottom sheet.
Future<SojuDateSelection?> showSojuDateCalendarSheet(
  BuildContext context, {
  required DateTime initialMonth,
  DateTimeRange? initialRange,
}) {
  return showModalBottomSheet<SojuDateSelection>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => _SojuDateCalendarSheet(
      initialMonth: initialRange?.start ?? initialMonth,
      initialRange: initialRange,
    ),
  );
}

class _SojuDateCalendarSheet extends StatefulWidget {
  const _SojuDateCalendarSheet({
    required this.initialMonth,
    required this.initialRange,
  });

  final DateTime initialMonth;
  final DateTimeRange? initialRange;

  @override
  State<_SojuDateCalendarSheet> createState() => _SojuDateCalendarSheetState();
}

class _SojuDateCalendarSheetState extends State<_SojuDateCalendarSheet> {
  late DateTime _month = DateTime(
    widget.initialMonth.year,
    widget.initialMonth.month,
  );
  late DateTime? _start = widget.initialRange?.start;
  late DateTime? _end = widget.initialRange?.end;

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      final DateTime normalized = dateOnly(day);
      if (_start == null || _end != null) {
        _start = normalized;
        _end = null;
        return;
      }
      if (normalized.isBefore(_start!)) {
        _end = _start;
        _start = normalized;
        return;
      }
      _end = normalized;
    });
  }

  void _apply() {
    final DateTime? start = _start;
    if (start == null) {
      return;
    }
    Navigator.of(context).pop(
      SojuDateSelection(
        DateTimeRange(start: start, end: _end ?? start),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: SojuColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: SojuColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width = math.min(constraints.maxWidth, 335);
                  final double scale = width / 335;
                  return Center(
                    child: SojuCalendarCard(
                      month: _month,
                      range: _range,
                      scale: scale,
                      onDayTap: _selectDay,
                      onPreviousMonth: () => _shiftMonth(-1),
                      onNextMonth: () => _shiftMonth(1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                _range == null
                    ? 'Pilih tanggal mulai dan akhir'
                    : formatDateRange(_range!),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.analyticsMuted,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('soju_calendar_clear'),
                      onPressed: () => Navigator.of(context).pop(
                        const SojuDateSelection(null),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: SojuColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const Key('soju_calendar_apply'),
                      onPressed: _start == null ? null : _apply,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: SojuColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Terapkan',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: SojuColors.surface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTimeRange? get _range {
    final DateTime? start = _start;
    if (start == null) {
      return null;
    }
    return DateTimeRange(start: start, end: _end ?? start);
  }
}
