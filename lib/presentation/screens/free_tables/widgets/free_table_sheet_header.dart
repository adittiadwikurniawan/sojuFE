// lib/presentation/screens/free_tables/widgets/free_table_sheet_header.dart
//
// Drag handle + judul modal "Buat Kategori Baru" (frame `546:5163`,
// node `546:5164`–`546:5170`).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/free_table_entity.dart';
import '../free_table_copy.dart';

/// Header modal sheet Tabel Bebas.
class FreeTableSheetHeader extends StatelessWidget {
  const FreeTableSheetHeader({
    super.key,
    required this.scale,
    required this.cashflowType,
    this.onClose,
  });

  final double scale;
  final FreeTableCashflowType cashflowType;

  /// Dipanggil saat drag handle diketuk; `null` membuat handle pasif.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Semantics(
          button: true,
          enabled: onClose != null,
          label: 'Tutup',
          child: Tooltip(
            message: 'Tutup',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: SizedBox(
                height: 26 * scale,
                child: Center(
                  child: Container(
                    width: 48 * scale,
                    height: 6 * scale,
                    decoration: BoxDecoration(
                      color: SojuColors.freeTableFieldBorder,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            24 * scale,
            7 * scale,
            24 * scale,
            12 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Buat Kategori Baru',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 20 * scale,
                  height: 27.5 / 20,
                  letterSpacing: -0.5 * scale,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.freeTableInk,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                cashflowType.sheetSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12 * scale,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: SojuColors.freeTableMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
