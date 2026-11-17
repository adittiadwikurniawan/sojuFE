// lib/presentation/screens/free_tables/widgets/free_table_notice_card.dart
//
// Kartu catatan di bawah panel kolom kustom (frame `546:5163`,
// node `546:5296`). Container di Figma tidak memuat teks; copy di sini
// merangkum aturan badge "Wajib" yang tampil pada desain.

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Kartu catatan aturan kolom pendataan.
class FreeTableNoticeCard extends StatelessWidget {
  const FreeTableNoticeCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: SojuColors.freeTableNoticeBg,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: SojuColors.freeTableDivider70),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 2 * scale),
            child: Icon(
              Icons.info_outline,
              size: 16 * scale,
              color: SojuColors.freeTableAccent,
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              'Kolom bertanda Wajib harus diisi setiap kali menambah baris '
              'baru. Kolom kustom dapat dihapus sebelum tabel disimpan.',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 11 * scale,
                height: 17.88 / 11,
                fontWeight: FontWeight.w400,
                color: SojuColors.freeTableBody,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
