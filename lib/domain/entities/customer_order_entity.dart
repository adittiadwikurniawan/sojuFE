// lib/domain/entities/customer_order_entity.dart
//
// Entity domain untuk pesanan pelanggan (TASK-025), mencakup status pesanan,
// rincian item, dan model pesanan lengkap.

import 'package:flutter/foundation.dart';

/// Status pesanan pelanggan sesuai skema backend SOJU.
enum CustomerOrderStatus {
  menungguKonfirmasi('MENUNGGU_KONFIRMASI', 'Menunggu Konfirmasi'),
  diproses('DIPROSES', 'Diproses'),
  selesai('SELESAI', 'Selesai'),
  dibatalkan('DIBATALKAN', 'Dibatalkan');

  const CustomerOrderStatus(this.raw, this.label);

  final String raw;
  final String label;

  static CustomerOrderStatus fromRaw(String? raw) {
    final String normalized = (raw ?? '').trim().toUpperCase();
    for (final CustomerOrderStatus s in CustomerOrderStatus.values) {
      if (s.raw == normalized) {
        return s;
      }
    }
    return CustomerOrderStatus.menungguKonfirmasi;
  }
}

/// Satu baris rincian item dalam pesanan pelanggan.
@immutable
class CustomerOrderItem {
  const CustomerOrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.variant,
    this.unit = 'Porsi',
    required this.price,
    required this.quantity,
    this.note,
    required this.subtotal,
  });

  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final String? variant;
  final String unit;
  final int price;
  final int quantity;
  final String? note;
  final int subtotal;

  bool get hasVariant => variant != null && variant!.trim().isNotEmpty;
  bool get hasNote => note != null && note!.trim().isNotEmpty;
}

/// Status pembayaran Midtrans Snap sesuai skema backend SOJU.
enum CustomerPaymentStatus {
  pending('PENDING', 'Menunggu Pembayaran'),
  paid('PAID', 'Lunas'),
  expired('EXPIRED', 'Kedaluwarsa'),
  failed('FAILED', 'Gagal');

  const CustomerPaymentStatus(this.raw, this.label);

  final String raw;
  final String label;

  static CustomerPaymentStatus fromRaw(String? raw) {
    final String normalized = (raw ?? '').trim().toUpperCase();
    for (final CustomerPaymentStatus s in CustomerPaymentStatus.values) {
      if (s.raw == normalized) {
        return s;
      }
    }
    return CustomerPaymentStatus.pending;
  }
}

/// Entity pesanan pelanggan lengkap dengan item, data pengiriman, dan info pembayaran Midtrans.
@immutable
class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.code,
    required this.customerId,
    required this.recipientName,
    required this.recipientEmail,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.items = const <CustomerOrderItem>[],
    this.paymentStatus = CustomerPaymentStatus.pending,
    this.paymentMethod,
    this.midtransOrderId,
    this.snapToken,
    this.snapRedirectUrl,
    this.paymentExpiredAt,
    this.paidAt,
  });

  final int id;
  final String code;
  final int customerId;
  final String recipientName;
  final String recipientEmail;
  final String recipientPhone;
  final String recipientAddress;
  final int total;
  final CustomerOrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<CustomerOrderItem> items;
  final CustomerPaymentStatus paymentStatus;
  final String? paymentMethod;
  final String? midtransOrderId;
  final String? snapToken;
  final String? snapRedirectUrl;
  final DateTime? paymentExpiredAt;
  final DateTime? paidAt;

  int get totalItems =>
      items.fold(0, (int sum, CustomerOrderItem item) => sum + item.quantity);

  bool get isPaid => paymentStatus == CustomerPaymentStatus.paid;

  bool get hasSnapUrl =>
      snapRedirectUrl != null && snapRedirectUrl!.trim().isNotEmpty;

  bool get isActiveOrder =>
      status == CustomerOrderStatus.menungguKonfirmasi ||
      status == CustomerOrderStatus.diproses;
}

/// Draf pengajuan checkout pesanan.
@immutable
class CheckoutDraft {
  const CheckoutDraft({
    required this.deliveryAddress,
  });

  final String deliveryAddress;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'alamat': deliveryAddress.trim(),
    };
  }
}
