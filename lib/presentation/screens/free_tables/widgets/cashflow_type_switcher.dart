// lib/presentation/screens/free_tables/widgets/cashflow_type_switcher.dart
//
// Segmented control "Tipe Arus Kas *" (frame `546:5163`,
// node `546:5184`–`546:5201`).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/free_table_entity.dart';

/// Pemilih Pemasukan / Pengeluaran / Tabel Bebas.
class CashflowTypeSwitcher extends StatelessWidget {
  const CashflowTypeSwitcher({
    super.key,
    required this.scale,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final double scale;
  final FreeTableCashflowType selected;
  final ValueChanged<FreeTableCashflowType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Tipe Arus Kas *',
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 12 * scale,
            height: 16 / 12,
            fontWeight: FontWeight.w700,
            color: SojuColors.freeTableLabel,
          ),
        ),
        SizedBox(height: 8 * scale),
        Opacity(
          opacity: enabled ? 1 : 0.55,
          child: Container(
            height: 42 * scale,
            padding: EdgeInsets.all(4 * scale),
            decoration: BoxDecoration(
              color: SojuColors.freeTableSegmentBg,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: SojuColors.freeTableSegmentBorder),
            ),
            child: Row(
              children: <Widget>[
                for (int i = 0;
                    i < FreeTableCashflowType.values.length;
                    i++) ...<Widget>[
                  if (i > 0) SizedBox(width: 4 * scale),
                  Expanded(
                    child: _Option(
                      scale: scale,
                      type: FreeTableCashflowType.values[i],
                      isActive: selected == FreeTableCashflowType.values[i],
                      enabled: enabled,
                      onTap: onChanged,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.scale,
    required this.type,
    required this.isActive,
    required this.enabled,
    required this.onTap,
  });

  final double scale;
  final FreeTableCashflowType type;
  final bool isActive;
  final bool enabled;
  final ValueChanged<FreeTableCashflowType> onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      selected: isActive,
      label: type.label,
      child: GestureDetector(
        key: Key('free_table_cashflow_${type.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onTap(type) : null,
        child: Container(
          height: 32 * scale,
          padding: EdgeInsets.symmetric(horizontal: 8 * scale),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8 * scale),
            boxShadow: isActive
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x0D000000),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dotColor(type, isActive),
                ),
              ),
              SizedBox(width: 6 * scale),
              Flexible(
                child: Text(
                  type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12 * scale,
                    height: 16 / 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: SojuColors.freeTableBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _dotColor(FreeTableCashflowType type, bool isActive) {
    if (!isActive) {
      return SojuColors.freeTableFieldBorder;
    }
    switch (type) {
      case FreeTableCashflowType.income:
        return SojuColors.freeTableIncome;
      case FreeTableCashflowType.expense:
        return SojuColors.freeTableExpense;
      case FreeTableCashflowType.freeTable:
        return SojuColors.freeTableBody;
    }
  }
}
