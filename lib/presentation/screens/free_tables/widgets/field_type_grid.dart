// lib/presentation/screens/free_tables/widgets/field_type_grid.dart
//
// Grid pemilih tipe kolom baru (frame `546:5163`,
// node `546:5275`–`546:5295`).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/free_table_entity.dart';

/// Grid 2 kolom untuk memilih tipe kolom kustom berikutnya.
class FieldTypeGrid extends StatelessWidget {
  const FieldTypeGrid({
    super.key,
    required this.scale,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final double scale;
  final FreeTableFieldType selected;
  final ValueChanged<FreeTableFieldType> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double gap = 8 * scale;
        final double itemWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: 13 * scale,
          children: <Widget>[
            for (final FreeTableFieldType type in FreeTableFieldType.values)
              SizedBox(
                width: itemWidth,
                child: _FieldTypePill(
                  scale: scale,
                  type: type,
                  isActive: selected == type,
                  enabled: enabled,
                  onTap: onSelected,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FieldTypePill extends StatelessWidget {
  const _FieldTypePill({
    required this.scale,
    required this.type,
    required this.isActive,
    required this.enabled,
    required this.onTap,
  });

  final double scale;
  final FreeTableFieldType type;
  final bool isActive;
  final bool enabled;
  final ValueChanged<FreeTableFieldType> onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      selected: isActive,
      label: type.pickerLabel,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: GestureDetector(
          key: Key('free_table_field_type_${type.name}'),
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? () => onTap(type) : null,
          child: Container(
            height: 34 * scale,
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            decoration: BoxDecoration(
              color: isActive
                  ? SojuColors.freeTableBlueSoft70
                  : SojuColors.surface,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: isActive
                    ? SojuColors.freeTableBlueBorder60
                    : SojuColors.freeTableDivider,
              ),
            ),
            child: Row(
              children: <Widget>[
                _TypeIcon(scale: scale, type: type),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: Text(
                    type.pickerLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 11 * scale,
                      height: 16 / 11,
                      fontWeight: FontWeight.w700,
                      color: SojuColors.freeTableTypeText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.scale, required this.type});

  final double scale;
  final FreeTableFieldType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case FreeTableFieldType.shortText:
        return SizedBox(
          width: 12 * scale,
          child: Text(
            'A',
            textAlign: TextAlign.center,
            style: _textStyle(
              scale,
              color: SojuColors.freeTableAccent,
            ),
          ),
        );
      case FreeTableFieldType.number:
        return SizedBox(
          width: 12 * scale,
          child: Text(
            '#',
            textAlign: TextAlign.center,
            style: _textStyle(
              scale,
              color: SojuColors.freeTableGreen,
            ),
          ),
        );
      case FreeTableFieldType.date:
        return Icon(
          Icons.calendar_month_outlined,
          size: 14 * scale,
          color: SojuColors.freeTableAmber,
        );
      case FreeTableFieldType.multipleChoice:
        return Icon(
          Icons.checklist_rounded,
          size: 14 * scale,
          color: SojuColors.freeTablePurple,
        );
    }
  }

  TextStyle _textStyle(double scale, {required Color color}) {
    return TextStyle(
      fontFamily: AppTypography.family,
      fontSize: 12 * scale,
      height: 1,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }
}
