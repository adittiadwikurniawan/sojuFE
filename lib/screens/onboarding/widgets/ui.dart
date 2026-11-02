import 'package:flutter/material.dart';
import '../../../theme/soju_colors.dart';

/// Kumpulan widget kecil yang dipakai berulang di seluruh onboarding,
/// meniru komponen di Figma (pill tags, dots carousel, tombol, dll).

/// Pill tag dengan ikon + label (mis. "Catat Instan", "Didukung AI").
class FeaturePill extends StatelessWidget {
  const FeaturePill({
    super.key,
    required this.icon,
    required this.label,
    required this.background,
    this.iconColor = SojuColors.ink,
    this.labelColor = SojuColors.ink,
    this.bold = false,
    this.iconSize = 12,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;
  final Color labelColor;
  final bool bold;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              color: labelColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Indikator dots carousel ("Langkah 1/2/3") — dot aktif melebar seperti Figma.
class SlideDots extends StatelessWidget {
  const SlideDots({
    super.key,
    required this.length,
    required this.active,
    this.size = 8,
    this.gap = 6,
  });

  final int length;
  final int active;
  final double size;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: gap / 2),
          width: isActive ? size * 3.5 : size,
          height: size,
          decoration: BoxDecoration(
            color: isActive ? SojuColors.primary : SojuColors.dotInactive,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

/// Tombol CTA utama (biru, radius 16) + ikon panah.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.icon = Icons.arrow_forward_rounded,
    this.iconSize = 16,
    this.onTap,
    this.height = 46,
  });

  final String label;
  final IconData icon;
  final double iconSize;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x331969FF),
                offset: Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: iconSize, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// Link "Langkah Sebelumnya" / "Masuk di sini".
class TextLink extends StatelessWidget {
  const TextLink({
    super.key,
    required this.label,
    this.color = SojuColors.inkSoft,
    this.onTap,
    this.bold = false,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Kartu putih dengan shadow yang menyerupai "Background+Shadow" di Figma.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.radius = 16,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(14),
    this.shadowOpacity = 0.08,
    this.spread = 0,
  });

  final Widget child;
  final double radius;
  final Color color;
  final EdgeInsets padding;
  final double shadowOpacity;
  final double spread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: SojuColors.ink.withOpacity(shadowOpacity),
            offset: const Offset(0, 6),
            blurRadius: 24,
            spreadRadius: spread,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Kotak ikon dengan background lembut (mimic "Overlay" di Figma).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.background,
    required this.iconColor,
    this.size = 32,
    this.radius = 8,
    this.iconSize = 16,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}

/// Sepasang teks kecil (label + value) dalam satu kolom.
class MiniStat extends StatelessWidget {
  const MiniStat({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = SojuColors.ink,
    this.labelColor = SojuColors.inkSoft,
    this.boldValue = true,
    this.valueSize = 12,
  });

  final String label;
  final String value;
  final Color valueColor;
  final Color labelColor;
  final bool boldValue;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            height: 1.2,
            fontWeight: boldValue ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}