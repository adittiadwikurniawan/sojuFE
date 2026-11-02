import 'package:flutter/material.dart';
import '../../../theme/soju_colors.dart';
import '../widgets/charts.dart';
import '../widgets/entrance.dart';
import '../widgets/on_nav.dart';
import '../widgets/ui.dart';

/// Onboarding 3 — "Kembangkan Bisnis dengan Penuh Percaya Diri"
/// Frame Figma: 798:1991 (390x754)
class OnboardingPageThree extends StatelessWidget {
  const OnboardingPageThree({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Column(
        children: [
          Entrance(
            animation: animation,
            begin: 0.0,
            end: 0.5,
            dy: 0.15,
            child: const _GrowthDashboardCard(),
          ),
          const SizedBox(height: 20),
          Entrance(
            animation: animation,
            begin: 0.35,
            end: 0.7,
            dy: 0.1,
            child: const Column(
              children: [
                Text(
                  'Kembangkan Bisnis dengan Penuh Percaya Diri',
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
                  'Kolaborasi bersama tim kasir dan pantau performa laba '
                  'bersih UMKM Anda kapan pun, di mana pun dengan rekap '
                  'otomatis.',
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
                  icon: Icons.groups_rounded,
                  label: 'Multi-Kasir',
                  background: SojuColors.chip,
                  iconColor: SojuColors.primaryDark,
                ),
                FeaturePill(
                  icon: Icons.pie_chart_outline_rounded,
                  label: 'Pajak & P&L',
                  background: SojuColors.chip,
                  iconColor: SojuColors.greenDark,
                ),
                FeaturePill(
                  icon: Icons.cloud_done_outlined,
                  label: 'Backup Otomatis',
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
            child: const _BottomSection3(dotsActive: 2),
          ),
        ],
      ),
    );
  }
}

class _GrowthDashboardCard extends StatelessWidget {
  const _GrowthDashboardCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient backdrop
          Container(
            width: double.infinity,
            height: 320,
            decoration: BoxDecoration(
              gradient: sojuCardGradient(),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            top: -30,
            left: -10,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SojuColors.primaryLight.withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SojuColors.greenLight.withOpacity(0.3),
              ),
            ),
          ),
          // Omzet chart card
          Positioned(
            left: 14,
            right: 14,
            top: 10,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    offset: Offset(0, 6),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Omzet Real-Time',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.ink,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: SojuColors.greenLight.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '+28.4%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.greenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const AreaChart(),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _WeekDay('Sen'),
                      _WeekDay('Sel'),
                      _WeekDay('Rab'),
                      _WeekDay('Kam'),
                      _WeekDay('Jum', bold: true),
                      _WeekDay('Sab'),
                      _WeekDay('Min'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Phone-like "Laba Bersih" card
          Positioned(
            left: 4,
            top: 128,
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    offset: Offset(0, 6),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 34,
                      height: 4,
                      decoration: BoxDecoration(
                        color: SojuColors.glass,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Laba Bersih',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.inkSoft,
                        ),
                      ),
                      Icon(
                        Icons.trending_up_rounded,
                        size: 12,
                        color: SojuColors.primaryDark,
                      ),
                    ],
                  ),
                  const Text(
                    'Rp 48,2 Jt',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: SojuColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SizedBox(
                    height: 34,
                    child: CustomPaint(
                      size: Size(120, 34),
                      painter: _MiniLinePainter(),
                    ),
                  ),
                  Container(
                    height: 26,
                    decoration: BoxDecoration(
                      color: SojuColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Tutup Kasir',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Laporan Bulanan + 256-bit TLS + +34% pill
          Positioned(
            right: 10,
            top: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const _SmallFeatureCard(
                  iconTileBg: SojuColors.roseSoft,
                  iconTileColor: SojuColors.roseDark,
                  icon: Icons.receipt_outlined,
                  title: 'Laporan Bulanan',
                  subtitleRow: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 11,
                        color: SojuColors.greenDark,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Siap Unduh',
                        style: TextStyle(
                          fontSize: 10,
                          color: SojuColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const _SmallFeatureCard(
                  iconTileBg: SojuColors.primaryLight,
                  iconTileColor: SojuColors.primaryDark,
                  icon: Icons.shield_outlined,
                  title: '256-Bit TLS',
                  subtitleRow: Column(
                    children: [
                      Text(
                        'Data Terproteksi',
                        style: TextStyle(
                          fontSize: 10,
                          color: SojuColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: SojuColors.green,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 11,
                        color: Color(0xFFF4FFF6),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '+34% Efisiensi',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF4FFF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  const _WeekDay(this.label, {this.bold = false});

  final String label;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: SojuColors.inkSoft,
      ),
    );
  }
}

class _SmallFeatureCard extends StatelessWidget {
  const _SmallFeatureCard({
    required this.iconTileBg,
    required this.iconTileColor,
    required this.icon,
    required this.title,
    required this.subtitleRow,
  });

  final Color iconTileBg;
  final Color iconTileColor;
  final IconData icon;
  final String title;
  final Widget subtitleRow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          IconTile(
            icon: icon,
            background: iconTileBg,
            iconColor: iconTileColor,
            size: 28,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.ink,
                  ),
                ),
                subtitleRow,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLinePainter extends CustomPainter {
  const _MiniLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SojuColors.orangeLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.85)
      ..lineTo(size.width * 0.25, size.height * 0.6)
      ..lineTo(size.width * 0.45, size.height * 0.7)
      ..lineTo(size.width * 0.68, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.1);
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(size.width, size.height * 0.1),
      4,
      Paint()..color = SojuColors.orangeLine,
    );
    canvas.drawCircle(
      Offset(size.width, size.height * 0.1),
      1.6,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniLinePainter old) => false;
}

class _BottomSection3 extends StatelessWidget {
  const _BottomSection3({required this.dotsActive});

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sudah memiliki akun? ',
              style: TextStyle(fontSize: 13, color: SojuColors.inkSoft),
            ),
            Builder(
              builder: (context) {
                final nav = context.findAncestorWidgetOfExactType<OnNav>();
                return TextLink(
                  label: 'Masuk di sini',
                  bold: true,
                  color: SojuColors.primaryDark,
                  onTap: nav?.onPrev,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}