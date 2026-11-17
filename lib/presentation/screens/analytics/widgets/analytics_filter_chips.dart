import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/analytics_transaction.dart';

/// Baris chip filter transaksi (frame `546:2937`, instance `546:3204`).
///
/// Isi desain (Semua/Pemasukan/Pembeli/Pengeluaran/Suplier) disesuaikan
/// menjadi jenis arus kas + dua filter tambahan (Kategori & Tanggal) agar
/// daftar transaksi dapat difilter berdasarkan apa pun yang diinput.
///
/// Filter tanggal tidak lagi berupa chip; kontrolnya adalah `DateFilterCard`
/// yang membuka kalender Figma `302:6303`. [dateLabel] tetap dipakai untuk
/// memastikan chip "Semua" tidak tampil aktif saat rentang tanggal dipilih.
class AnalyticsFilterChips extends StatelessWidget {
  const AnalyticsFilterChips({
    super.key,
    required this.scale,
    required this.totalCount,
    required this.type,
    required this.category,
    required this.dateLabel,
    required this.onTypeChanged,
    required this.onCategoryTap,
    required this.onReset,
  });

  final double scale;

  /// Jumlah transaksi pada filter aktif, untuk label `Semua (n)`.
  final int totalCount;

  final TransactionType? type;
  final String? category;

  /// Label rentang aktif (mis. `25–31 Okt`); `null` bila memakai bulan penuh.
  final String? dateLabel;

  final ValueChanged<TransactionType?> onTypeChanged;
  final VoidCallback onCategoryTap;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final bool isAll = type == null && category == null && dateLabel == null;
    return Wrap(
      spacing: 12 * scale,
      runSpacing: 10 * scale,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _Chip(
          scale: scale,
          label: 'Semua ($totalCount)',
          active: isAll,
          onTap: onReset,
        ),
        _Chip(
          scale: scale,
          label: 'Pemasukan',
          active: type == TransactionType.income,
          onTap: () => onTypeChanged(
            type == TransactionType.income ? null : TransactionType.income,
          ),
        ),
        _Chip(
          scale: scale,
          label: 'Pengeluaran',
          active: type == TransactionType.expense,
          onTap: () => onTypeChanged(
            type == TransactionType.expense ? null : TransactionType.expense,
          ),
        ),
        _Chip(
          scale: scale,
          label: category == null ? 'Kategori' : 'Kategori: $category',
          active: category != null,
          trailing: Icons.keyboard_arrow_down,
          onTap: onCategoryTap,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.scale,
    required this.label,
    required this.active,
    required this.onTap,
    this.trailing,
  });

  final double scale;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36 * scale,
        padding: EdgeInsets.symmetric(horizontal: 14 * scale),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: <Color>[SojuColors.primary, SojuColors.badgeBlue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          borderRadius: BorderRadius.circular(active ? 15 * scale : 25 * scale),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 180 * scale),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: active ? SojuColors.surface : SojuColors.textMuted,
                ),
              ),
            ),
            if (trailing != null)
              Icon(
                trailing,
                size: 18 * scale,
                color: active ? SojuColors.surface : SojuColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
