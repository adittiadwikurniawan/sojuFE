import 'package:flutter/material.dart';
import '../../../theme/soju_colors.dart';
import '../widgets/entrance.dart';
import '../widgets/on_nav.dart';
import '../widgets/ui.dart';

/// Onboarding 4 — Screen tambahan (fitur AI Assistant, laporan, dan rekap cepat)
class OnboardingPageFour extends StatelessWidget {
  const OnboardingPageFour({super.key, required this.animation});

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
            child: const _ChatAssistCard(),
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
                  'Obrolan AI untuk Rekap Lebih Cepat',
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
                  'Kamu bisa chat "tambah penjualan 2x sosis keju", dan AI '
                  'langsung mencatat ke laporan tanpa buka banyak form.',
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
                  icon: Icons.chat_outlined,
                  label: 'Chat Otomatis',
                  background: SojuColors.chip,
                  iconColor: SojuColors.primaryDark,
                ),
                FeaturePill(
                  icon: Icons.brush_outlined,
                  label: 'Rapi Otomatis',
                  background: SojuColors.chip,
                  iconColor: Color(0xFF4059AA),
                ),
                FeaturePill(
                  icon: Icons.mic_none_rounded,
                  label: 'Siap Suara',
                  background: SojuColors.chip,
                  iconColor: SojuColors.greenDark,
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
            child: const _Bottom(dotsActive: 3),
          ),
        ],
      ),
    );
  }
}

class _ChatAssistCard extends StatelessWidget {
  const _ChatAssistCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: sojuCardGradient(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: SojuColors.primaryLight,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: SojuColors.primaryDark,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tanya BukuKita AI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: SojuColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: SojuColors.chipSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '"/add Catat penjualan sosis keju @2 porsi via QRIS"',
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.4,
                      color: SojuColors.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: SojuColors.border,
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Berhasil dicatat!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.ink,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sosis Keju • 2 porsi • Rp 450.000 • QRIS',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: SojuColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SojuColors.green,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Langsung tercatat',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: SojuColors.primaryLight,
                  ),
                  child: const Icon(
                    Icons.mic_none_rounded,
                    size: 16,
                    color: SojuColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ketik perintah atau pakai suara',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: SojuColors.inkSoft,
                    ),
                  ),
                ),
                const Icon(
                  Icons.send_rounded,
                  size: 16,
                  color: SojuColors.primaryDark,
                ),
              ],
            ),
          ),
        ],
      ),
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
            return PrimaryButton(label: 'Lanjutkan', onTap: nav?.onNext);
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