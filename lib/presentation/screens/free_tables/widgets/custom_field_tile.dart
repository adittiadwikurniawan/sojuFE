// lib/presentation/screens/free_tables/widgets/custom_field_tile.dart
//
// Satu baris kolom pendataan tambahan (frame `546:5163`,
// node `546:5223`–`546:5295`).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/free_table_entity.dart';

/// Kartu satu kolom kustom beserta badge tipe dan aksi hapus.
class CustomFieldTile extends StatelessWidget {
  const CustomFieldTile({
    super.key,
    required this.scale,
    required this.field,
    required this.onDelete,
    this.enabled = true,
  });

  final double scale;
  final FreeTableFieldEntity field;
  final VoidCallback onDelete;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final String typeLabel = field.type == FreeTableFieldType.multipleChoice &&
            field.options.isNotEmpty
        ? 'Pilihan: ${field.options.join(', ')}'
        : field.type.label;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        constraints: BoxConstraints(minHeight: 42 * scale),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 10 * scale,
        ),
        decoration: BoxDecoration(
          color: SojuColors.surface,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: SojuColors.freeTableDivider80),
        ),
        child: Row(
          children: <Widget>[
            _FieldBadge(scale: scale, type: field.type),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          field.label,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 12 * scale,
                            height: 16 / 12,
                            fontWeight: FontWeight.w400,
                            color: SojuColors.freeTableLabel,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  Flexible(
                    child: Text(
                      '($typeLabel)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 11 * scale,
                        height: 16 / 11,
                        fontWeight: FontWeight.w400,
                        color: SojuColors.freeTableHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (field.isRequired) ...<Widget>[
              SizedBox(width: 8 * scale),
              _RequiredBadge(scale: scale),
            ],
            SizedBox(width: 8 * scale),
            Semantics(
              button: true,
              enabled: enabled,
              label: 'Hapus ${field.label}',
              child: Tooltip(
                message: 'Hapus ${field.label}',
                child: GestureDetector(
                  key: Key('free_table_field_delete_${field.id}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: enabled ? onDelete : null,
                  child: SizedBox(
                    width: 28 * scale,
                    height: 28 * scale,
                    child: Icon(
                      Icons.delete_outline,
                      size: 16 * scale,
                      color: SojuColors.freeTableHint,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldBadge extends StatelessWidget {
  const _FieldBadge({required this.scale, required this.type});

  final double scale;
  final FreeTableFieldType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case FreeTableFieldType.shortText:
        return _BadgeBox(
          scale: scale,
          background: SojuColors.freeTableBlueSoft,
          child: Text(
            'A',
            style: _badgeTextStyle(
              scale,
              color: SojuColors.freeTableAccent,
            ),
          ),
        );
      case FreeTableFieldType.number:
        return _BadgeBox(
          scale: scale,
          background: SojuColors.freeTableGreenSoft,
          child: Text(
            '#',
            style: _badgeTextStyle(
              scale,
              color: SojuColors.freeTableGreen,
            ),
          ),
        );
      case FreeTableFieldType.date:
        return SizedBox(
          width: 20 * scale,
          height: 20 * scale,
          child: Icon(
            Icons.calendar_today_outlined,
            size: 14 * scale,
            color: SojuColors.freeTableBody,
          ),
        );
      case FreeTableFieldType.multipleChoice:
        return _BadgeBox(
          scale: scale,
          background: SojuColors.freeTablePurpleSoft,
          child: Text(
            'PIC',
            style: _badgeTextStyle(
              scale,
              color: SojuColors.freeTablePurple,
            ),
          ),
        );
    }
  }

  TextStyle _badgeTextStyle(
    double scale, {
    required Color color,
    double fontSize = 11,
  }) {
    return TextStyle(
      fontFamily: AppTypography.family,
      fontSize: fontSize * scale,
      height: 1,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }
}

class _BadgeBox extends StatelessWidget {
  const _BadgeBox({
    required this.scale,
    required this.background,
    required this.child,
  });

  final double scale;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20 * scale,
      height: 20 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: child,
      ),
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
        vertical: 2 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.freeTableRequiredBg,
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Text(
        'Wajib',
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 10 * scale,
          height: 16 / 10,
          fontWeight: FontWeight.w700,
          color: SojuColors.freeTableRequired,
        ),
      ),
    );
  }
}
