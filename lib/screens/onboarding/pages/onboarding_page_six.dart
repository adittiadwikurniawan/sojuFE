import 'package:flutter/material.dart';
import '../../../theme/soju_colors.dart';
import '../widgets/entrance.dart';
import '../widgets/on_nav.dart';
import '../widgets/ui.dart';

/// Onboarding 6 — Screen tambahan (laporan lengkap & bagikan ke tim)
class OnboardingPageSix extends StatelessWidget {
  const OnboardingPageSix({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
      child: Column(
        children: [
          Entrance(
            animation: animation,
            begin: 0.0,
            end: 0.5,
            dy: 0.15,
            child: const _ReportCard(),
          ),
          const SizedBox(height: 22),
          Entrance(
            animation: animation,
            begin: 0.35,
            end: 0.7,
            dy: 0.1,
            child: const Column(
              children: [
                Text(
                  'Laporan Lengkap untuk Ambil Keputusan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Akses Laba/Rugi, Arus Kas, Persediaan, Hutang-Piutang dalam '
                  'satu klik. Ekspor PDF/Excel siap untuk diskusi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: SojuColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Entrance(
            animation: animation,
            begin: 0.55,
            end: 0.85,
            dy: 0.08,
            child: const Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FeaturePill(
                  icon: Icons.assignment_outlined,
                  label: 'Laba/Rugi',
                  background: SojuColors.chip,
                  iconColor: SojuColors.greenDark,
                ),
                FeaturePill(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Arus Kas',
                  background: SojuColors.chip,
                  iconColor: SojuColors.primaryDark,
                ),
                FeaturePill(
                  icon: Icons.file_download_outlined,
                  label: 'Ekspor PDF/Excel',
                  background: SojuColors.chip,
                  iconColor: Color(0xFF4059AA),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Entrance(
            animation: animation,
            begin: 0.75,
            end: 1.0,
            dy: 0.12,
            child: const _Bottom(dotsActive: 5),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: sojuCardGradient(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: SojuColors.primaryLight,
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 16,
                    color: SojuColors.primaryDark,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Laporan Keuangan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.ink,
                  ),
                ),
                Spacer(),
                Text(
                  'Okt 2026',
                  style: TextStyle(
                    fontSize: 10,
                    color: SojuColors.inkSoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _ReportRow(
              label: 'Pendapatan',
              value: 'Rp 48.950.000',
              valueColor: SojuColors.greenDark,
            ),
            const Divider(height: 12),
            const _ReportRow(
              label: 'HPP & Biaya',
              value: 'Rp 32.410.000',
              valueColor: SojuColors.ink,
            ),
            const Divider(height: 12),
            const _ReportRow(
              label: 'Laba Bersih',
              value: 'Rp 16.540.000',
              valueColor: SojuColors.primaryDark,
              bold: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: SojuColors.chipSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 12,
                          color: SojuColors.inkSoft,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'PDF',
                          style: TextStyle(
                            fontSize: 10,
                            color: SojuColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: SojuColors.chipSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.table_chart_outlined,
                          size: 12,
                          color: SojuColors.inkSoft,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Excel',
                          style: TextStyle(
                            fontSize: 10,
                            color: SojuColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: SojuColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share_outlined,
                          size: 12,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Bagikan',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: SojuColors.inkSoft,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _Bottom extends StatelessWidget {
  const _Bottom({required this.dotsActive});

  final int dotsActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlideDots(length: 6, active: dotsActive),
        const SizedBox(height: 18),
        Builder(
          builder: (context) {
            final nav = context.findAncestorWidgetOfExactType<OnNav>();
            return PrimaryButton(label: 'Mulai Sekarang', onTap: nav?.onNext);
          },
        ),
        const SizedBox(height: 6),
        Builder(
          builder: (context) {
            final nav = context.findAncestorWidgetOfExactType<OnNav>();
            return TextLink(label: 'Langkah Sebelumnya', onTap: nav?.onPrev);
          },
        ),
      ],
    );
  }
}