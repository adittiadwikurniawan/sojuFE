// lib/presentation/screens/profile/terms_screen.dart
//
// Layar Syarat & Ketentuan (tautan dari Pengaturan).
//
// Teks masih statis karena kontrak endpoint legal belum tersedia. Struktur
// layar sudah siap diganti konten dari API bila diperlukan.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../widgets/profile/profile_top_bar.dart';

/// Layar syarat dan ketentuan.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('terms_screen'),
      backgroundColor: SojuColors.profileBackground,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = math.min(constraints.maxWidth, 480);
          final double scale = width / 430;
          final double topInset = MediaQuery.paddingOf(context).top;
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: Column(
                children: <Widget>[
                  ProfileTopBar(
                    scale: scale,
                    topInset: topInset,
                    title: 'Syarat & Ketentuan',
                    onBack: onBack,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        22 * scale,
                        26 * scale,
                        22 * scale,
                        32 * scale + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Terakhir diperbarui: November 2026',
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 12 * scale,
                              color: SojuColors.profileMuted,
                            ),
                          ),
                          SizedBox(height: 18 * scale),
                          _section(
                            scale,
                            '1. Penggunaan Aplikasi',
                            'Buku Kita digunakan untuk mencatat dan memantau '
                                'kegiatan usaha Anda. Anda bertanggung jawab '
                                'atas kebenaran data yang dimasukkan.',
                          ),
                          _section(
                            scale,
                            '2. Akun dan Keamanan',
                            'Jaga kerahasiaan password dan akses perangkat '
                                'Anda. Segera hubungi tim dukungan jika '
                                'mencurigai penggunaan akun tanpa izin.',
                          ),
                          _section(
                            scale,
                            '3. Data Usaha',
                            'Data transaksi, stok, dan laporan usaha disimpan '
                                'untuk mendukung operasional aplikasi. Kami '
                                'tidak menjual data usaha Anda kepada pihak '
                                'ketiga.',
                          ),
                          _section(
                            scale,
                            '4. Perubahan Ketentuan',
                            'Ketentuan dapat diperbarui sewaktu-waktu. '
                                'Perubahan penting akan diinformasikan melalui '
                                'aplikasi atau email terdaftar.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _section(double scale, String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 15 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.profileHelpTitle,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            body,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13.5 * scale,
              height: 1.55,
              color: SojuColors.profileHelpBody,
            ),
          ),
        ],
      ),
    );
  }
}
