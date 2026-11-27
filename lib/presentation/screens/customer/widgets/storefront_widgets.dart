// lib/presentation/screens/customer/widgets/storefront_widgets.dart
//
// Widget bersama etalase Pelanggan: gambar produk dengan placeholder,
// tampilan state (memuat / kosong / galat + Coba Lagi), dan stepper jumlah.

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../widgets/smart_auto_fit_image.dart';

/// Gambar produk dengan mode **Smart Auto-Fit Utuh** (tanpa terpotong + blur backdrop).
class StorefrontProductImage extends StatelessWidget {
  const StorefrontProductImage({
    super.key,
    required this.url,
    this.size = 64,
    this.radius = 14,
    this.enableLightbox = false,
  });

  final String? url;
  final double size;
  final double radius;
  final bool enableLightbox;

  @override
  Widget build(BuildContext context) {
    return SmartAutoFitImage(
      imageUrl: url,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(radius),
      enableLightbox: enableLightbox,
      placeholderIcon: Icons.restaurant_rounded,
    );
  }
}

/// Tampilan state penuh: memuat, kosong, atau galat dengan tombol retry.
class StorefrontStateView extends StatelessWidget {
  const StorefrontStateView.loading({super.key, required this.message})
      : icon = null,
        title = null,
        actionLabel = null,
        onAction = null,
        actionKey = null,
        secondaryActionLabel = null,
        onSecondaryAction = null,
        secondaryActionKey = null,
        isLoading = true;

  const StorefrontStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionKey,
  }) : isLoading = false;

  final IconData? icon;
  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Key? secondaryActionKey;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isLoading)
              const CircularProgressIndicator(color: SojuColors.primary)
            else
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: SojuColors.infoSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: SojuColors.primary),
              ),
            const SizedBox(height: 16),
            if (title != null) ...<Widget>[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 13.5,
                height: 1.4,
                color: SojuColors.inkMuted,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 18),
              if (secondaryActionLabel != null && onSecondaryAction != null)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    FilledButton(
                      key: actionKey,
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: SojuColors.primary,
                        foregroundColor: SojuColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        actionLabel!,
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      key: secondaryActionKey,
                      onPressed: onSecondaryAction,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SojuColors.expense,
                        side: const BorderSide(color: SojuColors.expense),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        secondaryActionLabel!,
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              else
                FilledButton(
                  key: actionKey,
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: SojuColors.primary,
                    foregroundColor: SojuColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontFamily: AppTypography.family,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Stepper jumlah `- n +`.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.decrementKey,
    this.incrementKey,
    this.valueKey,
  });

  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final Key? decrementKey;
  final Key? incrementKey;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surfaceMuted,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            key: decrementKey,
            tooltip: 'Kurangi',
            visualDensity: VisualDensity.compact,
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded, size: 18),
          ),
          Text(
            '$value',
            key: valueKey,
            style: const TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: SojuColors.ink,
            ),
          ),
          IconButton(
            key: incrementKey,
            tooltip: 'Tambah',
            visualDensity: VisualDensity.compact,
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

/// Header halaman etalase sederhana.
class StorefrontHeader extends StatelessWidget {
  const StorefrontHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x18000000),
            offset: Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.paddingOf(context).top + 18,
        18,
        20,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 13.5,
                    height: 1.4,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
