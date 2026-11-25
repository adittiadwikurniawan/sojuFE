// lib/presentation/screens/free_tables/widgets/category_name_field.dart
//
// Medan "Nama Kategori *" + helper (frame `546:5163`,
// node `546:5172`–`546:5183`).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/free_table_entity.dart';
import '../free_table_copy.dart';

/// Input nama kategori pada form Tabel Bebas.
class CategoryNameField extends StatelessWidget {
  const CategoryNameField({
    super.key,
    required this.scale,
    required this.cashflowType,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final double scale;
  final FreeTableCashflowType cashflowType;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final String? error = errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Nama Kategori *',
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 12 * scale,
            height: 16 / 12,
            fontWeight: FontWeight.w700,
            color: SojuColors.freeTableLabel,
          ),
        ),
        SizedBox(height: 5.4 * scale),
        TextField(
          key: const Key('free_table_category_name_field'),
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: SojuColors.freeTableAccent,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 14 * scale,
            height: 20 / 14,
            fontWeight: FontWeight.w700,
            color: SojuColors.freeTableLabel,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: SojuColors.surface,
            contentPadding: EdgeInsets.fromLTRB(
              14 * scale,
              10 * scale,
              40 * scale,
              10 * scale,
            ),
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 14 * scale),
              child: Icon(
                Icons.edit_outlined,
                size: 16 * scale,
                color: SojuColors.freeTableAccent,
              ),
            ),
            suffixIconConstraints: BoxConstraints(
              minWidth: 40 * scale,
              minHeight: 44 * scale,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide(
                color: SojuColors.freeTableAccent,
                width: 2 * scale,
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
              borderSide: BorderSide(
                color: SojuColors.freeTableDivider,
                width: 2 * scale,
              ),
            ),
          ),
        ),
        if (error != null) ...<Widget>[
          SizedBox(height: 5.4 * scale),
          Text(
            error,
            key: const Key('free_table_name_error'),
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 11 * scale,
              height: 16 / 11,
              fontWeight: FontWeight.w500,
              color: SojuColors.freeTableRequired,
            ),
          ),
        ],
        SizedBox(height: 5.4 * scale),
        Text(
          cashflowType.nameHelper,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 11 * scale,
            height: 17.88 / 11,
            fontWeight: FontWeight.w400,
            color: SojuColors.freeTableMuted,
          ),
        ),
      ],
    );
  }
}
