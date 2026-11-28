import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Baris pencarian + tombol ekspor Excel (frame `546:2937`, node `546:3205`).
///
/// Tombol ekspor tidak membuat berkas sendiri; aksi diteruskan ke
/// [onExport] agar lapisan data/API yang menyiapkan berkas Excel.
class AnalyticsSearchBar extends StatelessWidget {
  const AnalyticsSearchBar({
    super.key,
    required this.scale,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onExport,
    this.onClear,
    this.showClear = false,
    this.isExporting = false,
    this.showExportButton = true,
  });

  final double scale;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onExport;
  final VoidCallback? onClear;
  final bool showClear;
  final bool isExporting;
  final bool showExportButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 47 * scale,
            padding: EdgeInsets.symmetric(horizontal: 14 * scale),
            decoration: BoxDecoration(
              color: SojuColors.surface,
              borderRadius: BorderRadius.circular(15 * scale),
              border: Border.all(color: SojuColors.hint, width: 1 * scale),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search,
                  size: 20 * scale,
                  color: SojuColors.hint,
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    textInputAction: TextInputAction.search,
                    cursorColor: SojuColors.primary,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w500,
                      color: SojuColors.ink,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w400,
                        color: SojuColors.hint,
                      ),
                    ),
                  ),
                ),
                if (showClear)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close,
                      size: 17 * scale,
                      color: SojuColors.hint,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showExportButton) ...<Widget>[
          SizedBox(width: 8 * scale),
          Tooltip(
            message: 'Ekspor Spreadsheet',
            child: GestureDetector(
              onTap: isExporting ? null : onExport,
              child: Container(
                width: 47 * scale,
                height: 47 * scale,
                decoration: BoxDecoration(
                  color: SojuColors.surface,
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: SojuColors.hint, width: 1 * scale),
                ),
                alignment: Alignment.center,
                child: isExporting
                    ? SizedBox(
                        width: 18 * scale,
                        height: 18 * scale,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SojuColors.primary,
                        ),
                      )
                    : Icon(
                        Icons.file_download_outlined,
                        size: 22 * scale,
                        color: SojuColors.ink,
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
