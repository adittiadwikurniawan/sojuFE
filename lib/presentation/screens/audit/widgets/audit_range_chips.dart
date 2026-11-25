// lib/presentation/screens/audit/widgets/audit_range_chips.dart
//
// Baris chip rentang waktu log audit (default 7 hari, MFR-7).
//
// Gaya mengikuti chip filter Analytics (`analytics_filter_chips.dart`);
// kontrol ini hanya memilih filter baca, bukan mutasi data.

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../providers/audit/audit_log_controller.dart';

/// Chip pilihan rentang waktu log audit.
class AuditRangeChips extends StatelessWidget {
  const AuditRangeChips({
    super.key,
    required this.scale,
    required this.selected,
    required this.onChanged,
    this.customActive = false,
  });

  final double scale;
  final AuditRangeOption selected;
  final ValueChanged<AuditRangeOption> onChanged;

  /// Bila `true`, tidak ada chip preset yang tampil aktif karena pengguna
  /// sedang memakai rentang kustom dari kartu tanggal.
  final bool customActive;

  static const List<AuditRangeOption> _options = <AuditRangeOption>[
    AuditRangeOption.days7,
    AuditRangeOption.days30,
    AuditRangeOption.days90,
    AuditRangeOption.all,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      clipBehavior: Clip.none,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < _options.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: 10 * scale),
            _RangeChip(
              scale: scale,
              label: _options[i].label,
              active: !customActive && _options[i] == selected,
              onTap: () => onChanged(_options[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.scale,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final double scale;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36 * scale,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: <Color>[SojuColors.primary, SojuColors.badgeBlue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: active ? null : SojuColors.surface,
          borderRadius: BorderRadius.circular(18 * scale),
          border:
              active ? null : Border.all(color: SojuColors.border, width: 1),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 13.5 * scale,
            fontWeight: FontWeight.w700,
            color: active ? SojuColors.surface : SojuColors.analyticsLabel,
          ),
        ),
      ),
    );
  }
}
