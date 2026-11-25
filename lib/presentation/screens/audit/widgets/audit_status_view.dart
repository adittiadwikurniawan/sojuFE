// lib/presentation/screens/audit/widgets/audit_status_view.dart
//
// Keadaan status layar log audit: loading, kosong, dan error (MFR-8).
//
// Pesan memakai Bahasa Indonesia dengan teks besar dan jelas; error
// menyediakan tombol "Coba lagi" untuk memuat ulang dari halaman 1.

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

/// Tampilan tengah layar saat memuat.
class AuditLoadingView extends StatelessWidget {
  const AuditLoadingView({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 40 * scale,
            height: 40 * scale,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(SojuColors.primary),
            ),
          ),
          SizedBox(height: 14 * scale),
          Text(
            'Memuat log audit…',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.analyticsLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tampilan tengah saat daftar kosong (hasil sukses, bukan galat).
class AuditEmptyView extends StatelessWidget {
  const AuditEmptyView({
    super.key,
    required this.scale,
    required this.rangeLabel,
  });

  final double scale;
  final String rangeLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72 * scale,
              height: 72 * scale,
              decoration: const BoxDecoration(
                color: SojuColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 32 * scale,
                color: SojuColors.analyticsMuted,
              ),
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Belum ada aktivitas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 17 * scale,
                fontWeight: FontWeight.w800,
                color: SojuColors.ink,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              'Tidak ada log audit pada $rangeLabel. '
              'Coba pilih rentang waktu yang lebih panjang.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: SojuColors.analyticsMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan tengah saat gagal memuat, dengan tombol "Coba lagi".
class AuditErrorView extends StatelessWidget {
  const AuditErrorView({
    super.key,
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72 * scale,
              height: 72 * scale,
              decoration: const BoxDecoration(
                color: SojuColors.expenseSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 32 * scale,
                color: SojuColors.expense,
              ),
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Gagal memuat log audit',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 17 * scale,
                fontWeight: FontWeight.w800,
                color: SojuColors.ink,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: SojuColors.analyticsMuted,
              ),
            ),
            SizedBox(height: 18 * scale),
            SizedBox(
              height: 44 * scale,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SojuColors.primary,
                  foregroundColor: SojuColors.surface,
                  padding: EdgeInsets.symmetric(horizontal: 28 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22 * scale),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Coba lagi',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 14.5 * scale,
                    fontWeight: FontWeight.w700,
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
