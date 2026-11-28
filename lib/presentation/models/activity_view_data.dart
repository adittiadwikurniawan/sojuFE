import 'package:flutter/foundation.dart';

/// Satu baris riwayat catatan kas yang dipakai bersama oleh Beranda,
/// Analytics, dan halaman "Lihat Semua".
///
/// Model ini hanya berisi data tampilan. Saat lapisan data tersedia, DTO
/// transaksi dipetakan ke model ini tanpa mengubah widget.
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

  /// Judul transaksi / catatan kas (mis. "Penjualan Sosis Bakar").
  final String name;

  /// Kategori & metode bayar (mis. "Penjualan • QRIS Midtrans").
  final String variant;

  /// Waktu atau referensi transaksi (mis. "Hari ini, 10:15 WIB").
  final String sku;

  /// Nominal mutasi kas (mis. "+Rp 75.000" atau "-Rp 25.000").
  final String pack;

  /// Jenis arus kas: "Pemasukan" atau "Pengeluaran".
  final String badge;

  /// Asset opsional (dipertahankan untuk kompatibilitas backward model).
  final String imageAsset;

  /// Menentukan apakah transaksi ini berupa pengeluaran / kas keluar.
  bool get isExpense {
    final String lower = badge.toLowerCase();
    return lower.contains('keluar') || lower.contains('beban');
  }
}

/// Data contoh catatan kas harian usaha mandiri (menggantikan dummy SKU lama).
abstract final class ActivityViewData {
  static const List<ActivityData> sample = <ActivityData>[
    ActivityData(
      name: 'Penjualan Sosis Bakar (5 Porsi)',
      variant: 'Penjualan • QRIS Midtrans',
      sku: 'Hari ini, 10:15 WIB',
      pack: '+Rp 75.000',
      badge: 'Pemasukan',
      imageAsset: '',
    ),
    ActivityData(
      name: 'Belanja Saus & Mayonaise',
      variant: 'Bahan Baku • Tunai',
      sku: 'Hari ini, 09:30 WIB',
      pack: '-Rp 25.000',
      badge: 'Pengeluaran',
      imageAsset: '',
    ),
    ActivityData(
      name: 'Penjualan Nugget & Minuman',
      variant: 'Penjualan • Tunai',
      sku: 'Hari ini, 08:50 WIB',
      pack: '+Rp 60.000',
      badge: 'Pemasukan',
      imageAsset: '',
    ),
    ActivityData(
      name: 'Beli Gas 3kg & Es Batu',
      variant: 'Operasional • Tunai',
      sku: 'Hari ini, 08:10 WIB',
      pack: '-Rp 32.000',
      badge: 'Pengeluaran',
      imageAsset: '',
    ),
  ];
}
