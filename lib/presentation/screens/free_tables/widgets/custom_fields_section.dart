// lib/presentation/screens/free_tables/widgets/custom_fields_section.dart
//
// Panel "Kolom Pendataan Tambahan" (frame `546:5163`,
// node `546:5216`–`546:5295`).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/free_table_entity.dart';
import '../free_table_copy.dart';
import 'custom_field_tile.dart';
import 'field_type_grid.dart';

/// Panel berisi daftar kolom kustom, tombol tambah, dan pemilih tipe.
class CustomFieldsSection extends StatelessWidget {
  const CustomFieldsSection({
    super.key,
    required this.scale,
    required this.cashflowType,
    required this.fields,
    required this.selectedFieldType,
    required this.onAddField,
    required this.onRemoveField,
    required this.onSelectFieldType,
    this.fieldsError,
    this.enabled = true,
  });

  final double scale;
  final FreeTableCashflowType cashflowType;
  final List<FreeTableFieldEntity> fields;
  final FreeTableFieldType selectedFieldType;
  final VoidCallback onAddField;
  final ValueChanged<String> onRemoveField;
  final ValueChanged<FreeTableFieldType> onSelectFieldType;
  final String? fieldsError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final String? error = fieldsError;

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: SojuColors.freeTableCustomBg,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: SojuColors.freeTableCustomBorder,
          width: 2 * scale,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 24 * scale,
                height: 24 * scale,
                decoration: BoxDecoration(
                  color: SojuColors.freeTableAccent,
                  borderRadius: BorderRadius.circular(6 * scale),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x1A2563EB),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 14 * scale,
                  color: SojuColors.surface,
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Kolom Pendataan Tambahan',
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12 * scale,
                        height: 16 / 12,
                        fontWeight: FontWeight.w700,
                        color: SojuColors.freeTableInk,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * scale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  color: SojuColors.freeTableBadgeBg,
                  borderRadius: BorderRadius.circular(6 * scale),
                ),
                child: Text(
                  'FR-4 Custom Field',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 10 * scale,
                    height: 16 / 10,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.freeTableAccent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 13.4 * scale),
          Text(
            cashflowType.customFieldsDescription,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 11 * scale,
              height: 17.88 / 11,
              fontWeight: FontWeight.w400,
              color: SojuColors.freeTableBody,
            ),
          ),
          if (error != null) ...<Widget>[
            SizedBox(height: 8 * scale),
            Text(
              error,
              key: const Key('free_table_fields_error'),
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 11 * scale,
                height: 16 / 11,
                fontWeight: FontWeight.w500,
                color: SojuColors.freeTableRequired,
              ),
            ),
          ],
          if (fields.isNotEmpty) ...<Widget>[
            SizedBox(height: 13.4 * scale),
            for (int i = 0; i < fields.length; i++) ...<Widget>[
              CustomFieldTile(
                scale: scale,
                field: fields[i],
                enabled: enabled,
                onDelete: () => onRemoveField(fields[i].id),
              ),
              if (i < fields.length - 1) SizedBox(height: 8 * scale),
            ],
          ],
          SizedBox(height: 13.4 * scale),
          _AddFieldButton(
            scale: scale,
            enabled: enabled,
            onTap: onAddField,
          ),
          SizedBox(height: 13.4 * scale),
          FieldTypeGrid(
            scale: scale,
            selected: selectedFieldType,
            enabled: enabled,
            onSelected: onSelectFieldType,
          ),
        ],
      ),
    );
  }
}

class _AddFieldButton extends StatelessWidget {
  const _AddFieldButton({
    required this.scale,
    required this.enabled,
    required this.onTap,
  });

  final double scale;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Tambah Kolom Kustom',
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: GestureDetector(
          key: const Key('free_table_add_field'),
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: Container(
            height: 38.6 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SojuColors.freeTableWhite70,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: SojuColors.freeTableAddBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '+ Tambah Kolom Kustom',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12 * scale,
                    height: 16 / 12,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.freeTableAccent,
                  ),
                ),
                SizedBox(width: 6 * scale),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14 * scale,
                  color: SojuColors.freeTableAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
