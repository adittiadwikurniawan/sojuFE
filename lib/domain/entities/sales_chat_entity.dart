// lib/domain/entities/sales_chat_entity.dart
//
// Entity draft percakapan input penjualan harian/shift.
//
// Prototype ini **tidak** menulis transaksi. Entity hanya memodelkan draft
// yang bisa diperiksa, dikoreksi, dan disimulasikan di UI. Semua nominal
// diturunkan dari rincian item/pembayaran; tidak ada total yang di-hardcode.

import 'package:flutter/foundation.dart';

/// Metode pembayaran yang dikenal pada draft prototype.
enum SalesPaymentMethod { qris, cash, transfer }

/// Label tampilan dan nilai API untuk [SalesPaymentMethod].
extension SalesPaymentMethodX on SalesPaymentMethod {
  /// Label singkat Bahasa Indonesia.
  String get label {
    switch (this) {
      case SalesPaymentMethod.qris:
        return 'QRIS';
      case SalesPaymentMethod.cash:
        return 'Tunai';
      case SalesPaymentMethod.transfer:
        return 'Transfer';
    }
  }

  /// Nilai yang dipakai fixture/mock datasource.
  String get apiValue {
    switch (this) {
      case SalesPaymentMethod.qris:
        return 'QRIS';
      case SalesPaymentMethod.cash:
        return 'CASH';
      case SalesPaymentMethod.transfer:
        return 'TRANSFER';
    }
  }

  /// Memetakan nilai fixture/API; nilai tak dikenal menjadi `null` agar UI
  /// menampilkannya sebagai field yang belum diisi, bukan menebak metode.
  static SalesPaymentMethod? fromApi(Object? raw) {
    switch (raw?.toString().trim().toLowerCase()) {
      case 'qris':
        return SalesPaymentMethod.qris;
      case 'cash':
      case 'tunai':
        return SalesPaymentMethod.cash;
      case 'transfer':
      case 'bank':
        return SalesPaymentMethod.transfer;
      default:
        return null;
    }
  }
}

/// Satu produk pada draft penjualan.
@immutable
class SalesChatItem {
  const SalesChatItem({
    this.name,
    this.quantity,
    this.unit,
    this.unitPrice,
    this.method,
  });

  final String? name;
  final int? quantity;
  final String? unit;
  final int? unitPrice;
  final SalesPaymentMethod? method;

  /// Subtotal hanya dihitung bila jumlah dan harga satuan diketahui.
  int? get subtotal {
    final int? qty = quantity;
    final int? price = unitPrice;
    if (qty == null || price == null) {
      return null;
    }
    return qty * price;
  }

  bool get isComplete =>
      (name?.trim().isNotEmpty ?? false) &&
      quantity != null &&
      quantity! > 0 &&
      (unit?.trim().isNotEmpty ?? false) &&
      unitPrice != null &&
      unitPrice! >= 0 &&
      method != null;

  SalesChatItem copyWith({
    String? name,
    int? quantity,
    String? unit,
    int? unitPrice,
    SalesPaymentMethod? method,
    bool clearName = false,
    bool clearQuantity = false,
    bool clearUnit = false,
    bool clearUnitPrice = false,
    bool clearMethod = false,
  }) {
    return SalesChatItem(
      name: clearName ? null : (name ?? this.name),
      quantity: clearQuantity ? null : (quantity ?? this.quantity),
      unit: clearUnit ? null : (unit ?? this.unit),
      unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
      method: clearMethod ? null : (method ?? this.method),
    );
  }
}

/// Satu baris rincian pembayaran pada draft.
@immutable
class SalesPaymentEntry {
  const SalesPaymentEntry({this.method, this.amount});

  final SalesPaymentMethod? method;
  final int? amount;

  bool get isComplete => method != null && amount != null && amount! >= 0;

  SalesPaymentEntry copyWith({
    SalesPaymentMethod? method,
    int? amount,
    bool clearMethod = false,
    bool clearAmount = false,
  }) {
    return SalesPaymentEntry(
      method: clearMethod ? null : (method ?? this.method),
      amount: clearAmount ? null : (amount ?? this.amount),
    );
  }
}

/// Draft hasil percakapan yang belum disimpan ke pembukuan.
@immutable
class SalesChatDraft {
  const SalesChatDraft({
    required this.id,
    required this.items,
    required this.payments,
    this.date,
    this.shift,
    this.declaredTotal,
    this.note = 'Data contoh — draft belum disimpan ke pembukuan.',
  });

  final String id;
  final DateTime? date;
  final String? shift;

  /// Total pemasukan yang tertulis pada input/draft.
  final int? declaredTotal;

  final List<SalesChatItem> items;
  final List<SalesPaymentEntry> payments;
  final String note;

  /// Jumlah seluruh subtotal item. `null` bila ada item yang belum lengkap.
  int? get itemTotal {
    if (items.isEmpty) {
      return null;
    }
    int total = 0;
    for (final SalesChatItem item in items) {
      final int? subtotal = item.subtotal;
      if (subtotal == null) {
        return null;
      }
      total += subtotal;
    }
    return total;
  }

  /// Jumlah rincian pembayaran. `null` bila rincian belum lengkap.
  int? get paymentTotal {
    if (payments.isEmpty) {
      return null;
    }
    int total = 0;
    for (final SalesPaymentEntry payment in payments) {
      final int? amount = payment.amount;
      if (payment.method == null || amount == null || amount < 0) {
        return null;
      }
      total += amount;
    }
    return total;
  }

  /// Selisih total pemasukan terhadap jumlah subtotal item.
  int? get itemDifference {
    final int? total = declaredTotal;
    final int? itemsTotal = itemTotal;
    if (total == null || itemsTotal == null) {
      return null;
    }
    return total - itemsTotal;
  }

  /// Selisih total pemasukan terhadap jumlah rincian pembayaran.
  int? get paymentDifference {
    final int? total = declaredTotal;
    final int? paymentsTotal = paymentTotal;
    if (total == null || paymentsTotal == null) {
      return null;
    }
    return total - paymentsTotal;
  }

  bool get hasItemMismatch => itemDifference != null && itemDifference != 0;

  bool get hasPaymentMismatch =>
      paymentDifference != null && paymentDifference != 0;

  /// Field yang wajib dilengkapi sebelum konfirmasi simulasi.
  List<String> get missingFields {
    final Set<String> missing = <String>{};
    if (date == null) {
      missing.add('Tanggal');
    }
    if (shift == null || shift!.trim().isEmpty) {
      missing.add('Shift');
    }
    if (declaredTotal == null) {
      missing.add('Total pemasukan');
    }
    if (items.isEmpty) {
      missing.add('Produk terjual');
    }
    for (final SalesChatItem item in items) {
      final String label =
          item.name?.trim().isNotEmpty ?? false ? item.name!.trim() : 'produk';
      if (item.name == null || item.name!.trim().isEmpty) {
        missing.add('Nama produk');
      }
      if (item.quantity == null || item.quantity! <= 0) {
        missing.add('Jumlah $label');
      }
      if (item.unit == null || item.unit!.trim().isEmpty) {
        missing.add('Satuan $label');
      }
      if (item.unitPrice == null || item.unitPrice! < 0) {
        missing.add('Harga $label');
      }
      if (item.method == null) {
        missing.add('Metode $label');
      }
    }
    if (payments.isEmpty) {
      missing.add('Metode pembayaran');
    }
    for (final SalesPaymentEntry payment in payments) {
      if (payment.method == null) {
        missing.add('Metode pembayaran');
      }
      if (payment.amount == null || payment.amount! < 0) {
        missing.add('Nominal pembayaran');
      }
    }
    return List<String>.unmodifiable(missing);
  }

  /// `true` bila seluruh field wajib terisi dan totalnya konsisten.
  bool get canConfirm {
    return missingFields.isEmpty &&
        declaredTotal != null &&
        itemTotal != null &&
        paymentTotal != null &&
        !hasItemMismatch &&
        !hasPaymentMismatch &&
        items.isNotEmpty &&
        payments.isNotEmpty;
  }

  SalesChatDraft copyWith({
    DateTime? date,
    String? shift,
    int? declaredTotal,
    List<SalesChatItem>? items,
    List<SalesPaymentEntry>? payments,
    String? note,
    bool clearDate = false,
    bool clearShift = false,
    bool clearDeclaredTotal = false,
  }) {
    return SalesChatDraft(
      id: id,
      date: clearDate ? null : (date ?? this.date),
      shift: clearShift ? null : (shift ?? this.shift),
      declaredTotal:
          clearDeclaredTotal ? null : (declaredTotal ?? this.declaredTotal),
      items: items ?? this.items,
      payments: payments ?? this.payments,
      note: note ?? this.note,
    );
  }
}
