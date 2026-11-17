// lib/presentation/screens/free_tables/widgets/free_table_sheet_footer.dart
//
// Footer lengket "Simpan & Buat Tabel Bebas" (frame `546:5163`,
// node `546:5301`–`546:5306`).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../providers/free_tables/free_table_category_controller.dart';

/// Footer aksi form Buat Kategori Baru.
class FreeTableSheetFooter extends StatelessWidget {
  const FreeTableSheetFooter({
    super.key,
    required this.scale,
    required this.bottomInset,
    required this.status,
    required this.onSave,
    this.errorMessage,
  });

  final double scale;
  final double bottomInset;
  final FreeTableCategoryStatus status;
  final String? errorMessage;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bool isSaving = status == FreeTableCategoryStatus.saving;
    final bool isSuccess = status == FreeTableCategoryStatus.success;
    final String? error = errorMessage;
    final bool hasMessage = error != null || isSuccess;
    final double bottomPadding =
        bottomInset > 24 * scale ? bottomInset : 24 * scale;

    return Container(
      decoration: const BoxDecoration(
        color: SojuColors.surface,
        border: Border(
          top: BorderSide(color: SojuColors.freeTableFooterBorder),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        12 * scale,
        24 * scale,
        bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (hasMessage) ...<Widget>[
            _FooterMessage(
              scale: scale,
              isSuccess: isSuccess,
              message: isSuccess ? 'Kategori berhasil dibuat.' : (error ?? ''),
            ),
            SizedBox(height: 8 * scale),
          ],
          SizedBox(
            height: 48 * scale,
            child: ElevatedButton(
              key: const Key('free_table_save_button'),
              onPressed: isSaving || isSuccess ? null : onSave,
              style: ElevatedButton.styleFrom(
                elevation: 2,
                shadowColor: isSuccess
                    ? const Color(0x33059669)
                    : const Color(0x332563EB),
                backgroundColor: isSuccess
                    ? SojuColors.freeTableGreen
                    : SojuColors.freeTableAccent,
                foregroundColor: SojuColors.surface,
                disabledBackgroundColor: isSuccess
                    ? SojuColors.freeTableGreen
                    : SojuColors.freeTableAccent.withOpacity(0.5),
                disabledForegroundColor: SojuColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              ),
              child: _ButtonContent(
                scale: scale,
                status: status,
              ),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Tabel baru akan langsung aktif di menu Data Pembukuan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 11 * scale,
              height: 13.75 / 11,
              fontWeight: FontWeight.w400,
              color: SojuColors.freeTableMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.scale, required this.status});

  final double scale;
  final FreeTableCategoryStatus status;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontFamily: AppTypography.family,
      fontSize: 14 * scale,
      height: 20 / 14,
      fontWeight: FontWeight.w700,
      color: SojuColors.surface,
    );

    switch (status) {
      case FreeTableCategoryStatus.saving:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 18 * scale,
              height: 18 * scale,
              child: CircularProgressIndicator(
                strokeWidth: 2 * scale,
                color: SojuColors.surface,
              ),
            ),
            SizedBox(width: 8 * scale),
            Text('Menyimpan...', style: textStyle),
          ],
        );
      case FreeTableCategoryStatus.success:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check_circle_outline_rounded,
              size: 18 * scale,
              color: SojuColors.surface,
            ),
            SizedBox(width: 8 * scale),
            Text('Tersimpan', style: textStyle),
          ],
        );
      case FreeTableCategoryStatus.error:
        return Text('Coba Simpan Lagi', style: textStyle);
      case FreeTableCategoryStatus.editing:
        return Text('Simpan & Buat Tabel Bebas', style: textStyle);
    }
  }
}

class _FooterMessage extends StatelessWidget {
  const _FooterMessage({
    required this.scale,
    required this.isSuccess,
    required this.message,
  });

  final double scale;
  final bool isSuccess;
  final String message;

  @override
  Widget build(BuildContext context) {
    final Color color =
        isSuccess ? SojuColors.freeTableGreen : SojuColors.freeTableRequired;

    return Row(
      key: isSuccess
          ? const Key('free_table_success_message')
          : const Key('free_table_footer_message'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          isSuccess
              ? Icons.check_circle_outline_rounded
              : Icons.error_outline_rounded,
          size: 15 * scale,
          color: color,
        ),
        SizedBox(width: 6 * scale),
        Expanded(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 11 * scale,
              height: 16 / 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
