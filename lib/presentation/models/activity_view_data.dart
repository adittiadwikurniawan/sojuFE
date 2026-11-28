import 'package:flutter/foundation.dart';

/// Satu baris riwayat catatan kas yang dipakai bersama oleh Beranda,
/// Analytics, dan halaman "Lihat Semua".
///
/// Model ini hanya berisi data tampilan. Saat lapisan data tersedia, DTO
/// transaksi penjualan frozen food (online maupun offline/manual) dipetakan
/// ke model ini tanpa mengubah widget.
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

  /// Judul transaksi / catatan kas (mis. "Order Online Frozen Food").
  final String name;

  /// Kategori & kanal transaksi (mis. "Penjualan Online • Midtrans QRIS").
  final String variant;

  /// Waktu atau referensi transaksi (mis. "Hari ini, 10:15 WIB").
  final String sku;

  /// Nominal mutasi kas (mis. "+Rp 85.000" atau "-Rp 120.000").
  final String pack;

  /// Jenis arus kas: "Pemasukan" atau "Pengeluaran".
  final String badge;

  /// Asset opsional (kosong karena menggunakan ikon arus kas modern).
  final String imageAsset;

  /// Menentukan apakah transaksi ini berupa pengeluaran / kas keluar.
  bool get isExpense {
    final String lower = badge.toLowerCase();
    return lower.contains('keluar') || lower.contains('beban');
  }
}

/// Data contoh transaksi frozen food (online + offline/manual) saat offline/mock.
abstract final class ActivityViewData {
  static const List<ActivityData> sample = <ActivityData>[
    ActivityData(
      name: 'Order Online #SOJU-108 (Sosis & Nugget Frozen)',
      variant: 'Penjualan Online • Midtrans QRIS',
      sku: 'Hari ini, 10:15 WIB',
      pack: '+Rp 85.000',
      badge: 'Pemasukan',
      imageAsset: '',
    ),
    ActivityData(
      name: 'Penjualan Offline (Dimsum & Sosis 3 Pack)',
      variant: 'Penjualan Offline • Tunai',
      sku: 'Hari ini, 09:40 WIB',
      pack: '+Rp 60.000',
      badge: 'Pemasukan',
      imageAsset: '',
    ),
    ActivityData(
      name: 'Restok Sosis & Nugget Frozen Supplier',
      variant: 'Bahan Baku • Tunai',
      sku: 'Hari ini, 08:30 WIB',
      pack: '-Rp 120.000',
      badge: 'Pengeluaran',
      imageAsset: '',
    ),
    ActivityData(
      name: 'Beli Plastik Vacuum & Ice Gel',
      variant: 'Kemasan • Tunai',
      sku: 'Hari ini, 08:05 WIB',
      pack: '-Rp 25.000',
      badge: 'Pengeluaran',
      imageAsset: '',
    ),
  ];
}
