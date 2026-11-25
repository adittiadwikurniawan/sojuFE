import 'package:flutter/foundation.dart';

/// Satu baris aktivitas yang dipakai bersama oleh Beranda, Analytics, dan
/// halaman "Lihat Semua".
///
/// Model ini hanya berisi data tampilan. Saat lapisan data tersedia, DTO
/// aktivitas dipetakan ke model ini tanpa mengubah widget.
@immutable
class ActivityData {
  const ActivityData({
    required this.name,
    required this.variant,
    required this.sku,
    required this.pack,
    required this.badge,
    required this.imageAsset,
  });

  final String name;
  final String variant;
  final String sku;
  final String pack;
  final String badge;
  final String imageAsset;
}

const ActivityData _sampleActivity = ActivityData(
  name: 'Sosis',
  variant: 'Pedas/Sedang',
  sku: 'SKU: AYM - BKR -01',
  pack: '10 Pack',
  badge: 'Pemasukkan',
  imageAsset: 'assets/images/activity_sosis.png',
);

/// Data contoh aktivitas dari slicing Figma.
abstract final class ActivityViewData {
  static const List<ActivityData> sample = <ActivityData>[
    _sampleActivity,
    _sampleActivity,
    _sampleActivity,
    _sampleActivity,
  ];
}
