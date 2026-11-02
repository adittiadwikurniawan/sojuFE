import 'package:flutter/material.dart';
import '../../../theme/soju_colors.dart';
import '../widgets/charts.dart';
import '../widgets/entrance.dart';
import '../widgets/on_nav.dart';
import '../widgets/ui.dart';

/// Onboarding 1 — "Kelola Keuangan Bisnis Lebih Mudah"
/// Frame Figma: 798:1765 (390x738)
class OnboardingPageOne extends StatelessWidget {
  const OnboardingPageOne({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 8,
      ),
      child: Column(
        children: [
          // ---------- Top Visual Card (358x340) ----------
          Entrance(
            animation: animation,
            begin: 0.0,
            end: 0.55,
            dy: 0.15,
            child: _BalanceShowcaseCard(),
          ),
          const SizedBox(height: 24),

          // ---------- Middle Text ----------
          Entrance(
            animation: animation,
            begin: 0.35,
            end: 0.75,
            dy: 0.1,
            child: const Column(
              children: [
                Text(
                  'Kelola Keuangan Bisnis Lebih\nMudah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Pantau arus kas masuk dan keluar secara real-time, '
                  'catat otomatis lewat AI Chatbot, dan kelola laporan '
                  'operasional toko dengan praktis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: SojuColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---------- Feature Pills ----------
          Entrance(
            animation: animation,
            begin: 0.6,
            end: 0.9,
            dy: 0.08,
            child: _FeaturePillsRowOne(),
          ),
          const SizedBox(height: 20),

          // ---------- Bottom: dots + CTA ----------
          Entrance(
            animation: animation,
            begin: 0.75,
            end: 1.0,
            dy: 0.12,
            child: const _BottomSection(
              dotsActive: 0,
              buttonLabel: 'Lanjutkan',
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu saldo utama + elemen melayang (mimic "Top Visual Card Showcase").
class _BalanceShowcaseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient card
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              gradient: sojuCardGradient(),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Aura circles
          Positioned(
            left: -30,
            top: -28,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SojuColors.primaryLight.withOpacity(0.6),
              ),
            ),
          ),
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SojuColors.primarySoft.withOpacity(0.55),
              ),
            ),
          ),
          const Positioned(
            bottom: 14,
            left: 20,
            right: 20,
            child: WaveDivider(),
          ),
          // Master balance card
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    offset: Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconTile(
                        icon: Icons.account_balance_wallet_outlined,
                        background: SojuColors.primary
                            .withOpacity(0.15),
                        iconColor: SojuColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Master Asset Kas',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: SojuColors.ink,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Toko Berkah Sentosa',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: SojuColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: SojuColors.greenLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Aktif',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: SojuColors.greenOnLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SALDO TERKINI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: SojuColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Rp',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: SojuColors.ink,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '48.950.000',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: SojuColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SojuColors.primaryDark
                              .withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.south_west_rounded,
                          size: 13,
                          color: SojuColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: MiniStat(
                          label: 'Pemasukan Hari Ini',
                          value: '+Rp 3.420.000',
                          valueColor: SojuColors.greenDark,
                        ),
                      ),
                      const Spacer(),
                      // Mastercard-like circles
                      SizedBox(
                        width: 42,
                        height: 20,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: SojuColors.amberCircle
                                      .withOpacity(0.9),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: SojuColors.primary
                                      .withOpacity(0.9),
                                ),
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
          ),
          // Floating goal pill (top right)
          const Positioned(
            top: -14,
            right: 6,
            child: _GoalPill(),
          ),
          // Floating mini transaction (bottom left)
          const Positioned(
            bottom: -16,
            left: -6,
            child: _MiniTransactionPill(),
          ),
          // Floating AI badge (bottom right)
          const Positioned(
            bottom: -12,
            right: -4,
            child: _AiParseBadge(),
          ),
        ],
      ),
    );
  }
}

class _GoalPill extends StatelessWidget {
  const _GoalPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: SojuColors.amberSoft,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              size: 13,
              color: SojuColors.amberDark,
            ),
          ),
          const SizedBox(width: 6),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Target Bulanan',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.inkSoft,
                ),
              ),
              Text(
                '85% Tercapai',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.amberBrown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTransactionPill extends StatelessWidget {
  const _MiniTransactionPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: SojuColors.greenLight,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 14,
              color: SojuColors.greenDark,
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Penjualan Sosis Keju',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.ink,
                ),
              ),
              SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+Rp 450.000',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: SojuColors.greenDark,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'QRIS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: SojuColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiParseBadge extends StatelessWidget {
  const _AiParseBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: SojuColors.glass.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 12, color: SojuColors.primaryDark),
          SizedBox(width: 6),
          Text(
            'Tercatat Otomatis',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: SojuColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePillsRowOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        FeaturePill(
          icon: Icons.bolt_rounded,
          label: 'Catat Instan',
          background: SojuColors.chipSoft,
          iconColor: SojuColors.amber,
        ),
        FeaturePill(
          icon: Icons.auto_awesome_rounded,
          label: 'Didukung AI',
          background: SojuColors.primaryLight,
          iconColor: SojuColors.primaryDark,
          labelColor: SojuColors.inkOnBluePill,
        ),
        FeaturePill(
          icon: Icons.lock_outline_rounded,
          label: 'Enkripsi Aman',
          background: SojuColors.chipSoft,
          iconColor: SojuColors.greenDark,
        ),
      ],
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.dotsActive,
    required this.buttonLabel,
  });

  final int dotsActive;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final nav = context.findAncestorWidgetOfExactType<OnNav>();
    return Column(
      children: [
        SlideDots(length: 6, active: dotsActive),
        const SizedBox(height: 18),
        PrimaryButton(
          label: buttonLabel,
          onTap: nav?.onNext,
        ),
        if (dotsActive > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextLink(
              label: 'Langkah Sebelumnya',
              onTap: nav?.onPrev,
            ),
          ),
      ],
    );
  }
}