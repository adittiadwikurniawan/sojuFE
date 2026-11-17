import 'package:flutter/material.dart';

import '../models/analytics_transaction.dart';

/// Ikon per kategori transaksi, dipakai kartu rincian dan daftar transaksi.
IconData categoryIconFor(String category, TransactionType type) {
  final String name = category.toLowerCase();
  if (name.contains('bahan') || name.contains('bumbu')) {
    return Icons.shopping_basket_outlined;
  }
  if (name.contains('kemasan')) {
    return Icons.inventory_2_outlined;
  }
  if (name.contains('gas') || name.contains('listrik')) {
    return Icons.bolt;
  }
  if (name.contains('frozen')) {
    return Icons.ac_unit;
  }
  if (name.contains('jual') ||
      name.contains('katering') ||
      name.contains('makan') ||
      name.contains('saji')) {
    return Icons.storefront_outlined;
  }
  if (name.contains('sewa')) {
    return Icons.home_work_outlined;
  }
  if (name.contains('gaji')) {
    return Icons.groups_outlined;
  }
  if (name.contains('transport') || name.contains('kirim')) {
    return Icons.local_shipping_outlined;
  }
  return type == TransactionType.income ? Icons.south_west : Icons.north_east;
}
