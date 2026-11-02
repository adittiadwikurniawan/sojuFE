import 'package:flutter/material.dart';
import '../../../theme/soju_colors.dart';
import '../widgets/entrance.dart';
import '../widgets/on_nav.dart';
import '../widgets/ui.dart';

/// Onboarding 5 — Screen tambahan (kontrol stok & notifikasi kritis)
class OnboardingPageFive extends StatelessWidget {
  const OnboardingPageFive({super.key, required this.animation});

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
            child: const _StockAlertCard(),
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
                  'Kontrol Stok & Alert Tepat Waktu',
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
                  'Dapat notifikasi saat stok hampir habis, kadaluarsa mendekat, '
                  'atau PO perlu dibuat — tidak sampai kehabisan bahan.',
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
                  icon: Icons.notification_important_outlined,
                  label: 'Alert Stok',
                  background: SojuColors.chip,
                  iconColor: SojuColors.roseDark,
                ),
                FeaturePill(
                  icon: Icons.date_range_outlined,
                  label: 'Kadaluarsa',
                  background: SojuColors.chip,
                  iconColor: SojuColors.amberDark,
                ),
                FeaturePill(
                  icon: Icons.shopping_cart_outlined,
                  label: 'PO Otomatis',
                  background: SojuColors.chip,
                  iconColor: SojuColors.primaryDark,
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
            child: const _Bottom(dotsActive: 4),
          ),
        ],
      ),
    );
  }
}

class _StockAlertCard extends StatelessWidget {
  const _StockAlertCard();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: SojuColors.roseSoft,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: SojuColors.roseDark,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Stok Kritis',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AlertTile(
              title: 'Saus Tomat',
              subtitle: 'Tersisa 4 • Exp 24 Okt 2026',
              trailingColor: Colors.white,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: SojuColors.roseDark,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Kritis',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _AlertTile(
              title: 'Minyak Goreng',
              subtitle: 'Tersisa 3 • Exp 28 Okt 2026',
              trailingColor: Colors.white,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: SojuColors.amberDark,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Hampir Habis',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SojuColors.greenLight.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: SojuColors.greenLight,
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: SojuColors.greenDark,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Saran: Buat PO ke supplier dalam 1 klik',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: SojuColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: SojuColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Buat PO',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
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

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.trailingColor,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SojuColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trailingColor.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 14,
              color: SojuColors.inkSoft,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: SojuColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          trailing,
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