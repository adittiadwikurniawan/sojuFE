// lib/presentation/screens/free_tables/widgets/target_department_field.dart
//
// Medan opsional "Target Departemen / Lokasi" (frame `546:5163`,
// node `546:5202`–`546:5215`).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Input target departemen/lokasi.
class TargetDepartmentField extends StatelessWidget {
  const TargetDepartmentField({
    super.key,
    required this.scale,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
  });

  final double scale;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Target Departemen / Lokasi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12 * scale,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.freeTableLabel,
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            Text(
              '(Opsional) Label area kerja',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 10 * scale,
                height: 16 / 10,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                color: SojuColors.freeTableHint,
              ),
            ),
          ],
        ),
        SizedBox(height: 6 * scale),
        TextField(
          key: const Key('free_table_department_field'),
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: SojuColors.freeTableAccent,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 12 * scale,
            height: 16 / 12,
            fontWeight: FontWeight.w400,
            color: SojuColors.freeTableLabel,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: SojuColors.surface,
            hintText: 'Misal: Area Dapur Utama, Chiller Gudang, Barista',
            hintStyle: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12 * scale,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: SojuColors.freeTableHint,
            ),
            contentPadding: EdgeInsets.fromLTRB(
              14 * scale,
              11 * scale,
              14 * scale,
              11 * scale,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: const BorderSide(
                color: SojuColors.freeTableFieldBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide(
                color: SojuColors.freeTableAccent,
                width: 2 * scale,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: const BorderSide(
                color: SojuColors.freeTableDivider,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
