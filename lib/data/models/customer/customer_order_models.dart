// lib/data/models/customer/customer_order_models.dart
//
// Model serialisasi pesanan pelanggan dari API (`GET /api/customer/pesanan`,
// `GET /api/customer/pesanan/:id`, `POST /api/customer/checkout`).

import '../../../domain/entities/customer_order_entity.dart';

int _asInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
  return fallback;
}

String _asString(Object? value, [String fallback = '']) {
  if (value is String) return value;
  if (value == null) return fallback;
  return value.toString();
}

/// Model data untuk baris item pesanan.
class CustomerOrderItemModel {
  const CustomerOrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.variant,
    required this.unit,
    required this.price,
    required this.quantity,
    this.note,
    required this.subtotal,
  });

  factory CustomerOrderItemModel.fromJson(Map<String, Object?> json) {
    return CustomerOrderItemModel(
      id: _asInt(json['id']),
      orderId: _asInt(json['pesananId'] ?? json['orderId']),
      productId: _asInt(json['produkId'] ?? json['productId']),
      productName: _asString(json['namaProduk'] ?? json['productName']),
      variant: json['varian'] as String? ?? json['variant'] as String?,
      unit: _asString(json['satuan'] ?? json['unit'], 'Porsi'),
      price: _asInt(json['harga'] ?? json['price']),
      quantity: _asInt(json['jumlah'] ?? json['quantity'], 1),
      note: json['catatan'] as String? ?? json['note'] as String?,
      subtotal: _asInt(json['subtotal']),
    );
  }

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

  CustomerOrderItem toEntity() {
    return CustomerOrderItem(
      id: id,
      orderId: orderId,
      productId: productId,
      productName: productName,
      variant: variant,
      unit: unit,
      price: price,
      quantity: quantity,
      note: note,
      subtotal: subtotal == 0 ? price * quantity : subtotal,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'pesananId': orderId,
      'produkId': productId,
      'namaProduk': productName,
      'varian': variant,
      'satuan': unit,
      'harga': price,
      'jumlah': quantity,
      'catatan': note,
      'subtotal': subtotal,
    };
  }
}

/// Model data pesanan pelanggan dari API backend.
class CustomerOrderModel {
  const CustomerOrderModel({
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
    this.items = const <CustomerOrderItemModel>[],
    this.paymentStatus = CustomerPaymentStatus.pending,
    this.paymentMethod,
    this.midtransOrderId,
    this.snapToken,
    this.snapRedirectUrl,
    this.paymentExpiredAt,
    this.paidAt,
  });

  factory CustomerOrderModel.fromJson(Map<String, Object?> json) {
    final Object? rawItems = json['item'] ?? json['items'];
    final List<CustomerOrderItemModel> parsedItems;
    if (rawItems is List) {
      parsedItems = rawItems
          .whereType<Map<String, Object?>>()
          .map(CustomerOrderItemModel.fromJson)
          .toList(growable: false);
    } else {
      parsedItems = const <CustomerOrderItemModel>[];
    }

    final String rawDate = _asString(json['dibuatPada'] ?? json['createdAt']);
    final DateTime createdAt =
        DateTime.tryParse(rawDate) ?? DateTime.now();

    final String rawUpdate =
        _asString(json['diperbaruiPada'] ?? json['updatedAt']);
    final DateTime? updatedAt =
        rawUpdate.isNotEmpty ? DateTime.tryParse(rawUpdate) : null;

    final String rawExpired = _asString(
      json['paymentExpiredAt'] ?? json['payment_expired_at'],
    );
    final DateTime? paymentExpiredAt =
        rawExpired.isNotEmpty ? DateTime.tryParse(rawExpired) : null;

    final String rawPaidAt = _asString(json['paidAt'] ?? json['paid_at']);
    final DateTime? paidAt =
        rawPaidAt.isNotEmpty ? DateTime.tryParse(rawPaidAt) : null;

    final String? paymentMethodRaw =
        (json['paymentMethod'] ?? json['payment_method']) as String?;
    final String? midtransOrderIdRaw =
        (json['midtransOrderId'] ?? json['midtrans_order_id']) as String?;
    final String? snapTokenRaw =
        (json['snapToken'] ?? json['snap_token']) as String?;
    final String? snapRedirectUrlRaw = (json['snapRedirectUrl'] ??
        json['snap_redirect_url'] ??
        json['redirectUrl']) as String?;

    return CustomerOrderModel(
      id: _asInt(json['id']),
      code: _asString(json['kode'] ?? json['code']),
      customerId: _asInt(json['pelangganId'] ?? json['customerId']),
      recipientName:
          _asString(json['namaPenerima'] ?? json['recipientName']),
      recipientEmail:
          _asString(json['emailPenerima'] ?? json['recipientEmail']),
      recipientPhone:
          _asString(json['noTelepon'] ?? json['recipientPhone']),
      recipientAddress:
          _asString(json['alamat'] ?? json['recipientAddress']),
      total: _asInt(json['total']),
      status: CustomerOrderStatus.fromRaw(
        _asString(json['status']),
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: parsedItems,
      paymentStatus: CustomerPaymentStatus.fromRaw(
        _asString(json['paymentStatus'] ?? json['payment_status']),
      ),
      paymentMethod: paymentMethodRaw,
      midtransOrderId: midtransOrderIdRaw,
      snapToken: snapTokenRaw,
      snapRedirectUrl: snapRedirectUrlRaw,
      paymentExpiredAt: paymentExpiredAt,
      paidAt: paidAt,
    );
  }

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
  final List<CustomerOrderItemModel> items;
  final CustomerPaymentStatus paymentStatus;
  final String? paymentMethod;
  final String? midtransOrderId;
  final String? snapToken;
  final String? snapRedirectUrl;
  final DateTime? paymentExpiredAt;
  final DateTime? paidAt;

  CustomerOrder toEntity() {
    return CustomerOrder(
      id: id,
      code: code,
      customerId: customerId,
      recipientName: recipientName,
      recipientEmail: recipientEmail,
      recipientPhone: recipientPhone,
      recipientAddress: recipientAddress,
      total: total,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items.map((CustomerOrderItemModel i) => i.toEntity()).toList(),
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      midtransOrderId: midtransOrderId,
      snapToken: snapToken,
      snapRedirectUrl: snapRedirectUrl,
      paymentExpiredAt: paymentExpiredAt,
      paidAt: paidAt,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'kode': code,
      'pelangganId': customerId,
      'namaPenerima': recipientName,
      'emailPenerima': recipientEmail,
      'noTelepon': recipientPhone,
      'alamat': recipientAddress,
      'total': total,
      'status': status.raw,
      'dibuatPada': createdAt.toIso8601String(),
      'diperbaruiPada': updatedAt?.toIso8601String(),
      'paymentStatus': paymentStatus.raw,
      'paymentMethod': paymentMethod,
      'midtransOrderId': midtransOrderId,
      'snapToken': snapToken,
      'snapRedirectUrl': snapRedirectUrl,
      'paymentExpiredAt': paymentExpiredAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'item': items.map((CustomerOrderItemModel i) => i.toJson()).toList(),
    };
  }
}
