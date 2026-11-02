import 'package:flutter/material.dart';
import '../../../theme/soju_colors.dart';
import '../widgets/charts.dart';
import '../widgets/entrance.dart';
import '../widgets/on_nav.dart';
import '../widgets/ui.dart';

/// Onboarding 2 — "Asisten AI Pintar & Kategorisasi Otomatis"
/// Frame Figma: 798:1882 (390x762)
class OnboardingPageTwo extends StatelessWidget {
  const OnboardingPageTwo({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 8),
      child: Column(
        children: [
          Entrance(
            animation: animation,
            begin: 0.0,
            end: 0.5,
            dy: 0.15,
            child: const _AiAssistantCard(),
          ),
          const SizedBox(height: 24),
          Entrance(
            animation: animation,
            begin: 0.35,
            end: 0.7,
            dy: 0.1,
            child: const Column(
              children: [
                Text(
                  'Asisten AI Pintar & Kategorisasi Otomatis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Cukup ketik atau unggah struk di ruang obrolan, nota '
                  'belanja, stok inventaris, dan tagihan supplier langsung '
                  'dirapikan dalam hitungan detik tanpa repot.',
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
                  icon: Icons.bar_chart_rounded,
                  label: 'Analisis Kas',
                  background: SojuColors.chip,
                  iconColor: SojuColors.primaryDark,
                ),
                FeaturePill(
                  icon: Icons.document_scanner_outlined,
                  label: 'Deteksi Nota',
                  background: SojuColors.chip,
                  iconColor: Color(0xFF4059AA),
                ),
                FeaturePill(
                  icon: Icons.bolt_rounded,
                  label: 'Respons Cepat',
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
            child: const _BottomSection2(dotsActive: 1),
          ),
        ],
      ),
    );
  }
}

class _AiAssistantCard extends StatelessWidget {
  const _AiAssistantCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC6D1FF), Color(0xFFE8EEFF), Color(0xFFDFFFEC)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SojuColors.purpleSoft.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SojuColors.greenLight.withOpacity(0.35),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PulsingDot(),
                        SizedBox(width: 6),
                        Text(
                          'AI ENGINE ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: SojuColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 17,
                      color: SojuColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Invoice card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      offset: Offset(0, 4),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            IconTile(
                              icon: Icons.receipt_long_outlined,
                              background: SojuColors.primaryLight,
                              iconColor: SojuColors.primaryDark,
                              size: 32,
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sysco Food Supplies',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: SojuColors.ink,
                                  ),
                                ),
                                Text(
                                  'INV-84920 • Hari ini, 09:41',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: SojuColors.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: SojuColors.roseSoft.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Rp 1.250.000',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: SojuColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: SojuColors.chipSoft.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 13,
                            color: SojuColors.primaryDark,
                          ),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Text(
                              'Auto-Categorized',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: SojuColors.ink,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SojuColors.primarySoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Bahan Baku',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: SojuColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: SojuColors.greenDark,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"3 transaksi nota supplier baru berhasil '
                              'diverifikasi!"',
                              style: TextStyle(
                                fontSize: 10.5,
                                height: 1.4,
                                color: SojuColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Run-Rate
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Run-Rate',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: SojuColors.inkSoft,
                                  ),
                                ),
                                Text(
                                  '+18.4%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: SojuColors.greenDark,
                                  ),
                                ),
                                SizedBox(height: 6),
                                MiniBars(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // AI Akurasi
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
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
                                SizedBox(height: 6),
                                Text(
                                  'AI Akurasi',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: SojuColors.inkSoft,
                                  ),
                                ),
                                Text(
                                  '99.8% Match',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: SojuColors.ink,
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
            ],
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SojuColors.greenDark,
        boxShadow: [
          BoxShadow(
            color: SojuColors.greenDark.withOpacity(0.5 * _c.value + 0.1,
            ),
            blurRadius: 4 + _c.value * 4,
            spreadRadius: _c.value * 2,
          ),
        ],
      ),
    );
  }
}

class _BottomSection2 extends StatelessWidget {
  const _BottomSection2({required this.dotsActive});

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
        const SizedBox(height: 8),
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