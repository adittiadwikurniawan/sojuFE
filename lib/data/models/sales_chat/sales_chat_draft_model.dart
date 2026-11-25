// lib/data/models/sales_chat/sales_chat_draft_model.dart
//
// DTO draft chat penjualan harian/shift.
//
// Bentuk `data` pada envelope mock:
//
// ```json
// {
//   "id": "draft-demo-1",
//   "tanggal": "2026-11-19",
//   "shift": "Siang",
//   "total": 1375000,
//   "items": [
//     {
//       "nama": "Bento Ayam Bakar",
//       "jumlah": 30,
//       "satuan": "porsi",
//       "harga_satuan": 35000,
//       "metode": "QRIS"
//     }
//   ],
//   "payments": [
//     { "metode": "QRIS", "nominal": 1275000 }
//   ]
// }
// ```
//
// Datasource REST Phase B (bila kontrak tersedia) cukup mengembalikan bentuk
// yang sama; model ini yang memetakan ke entity domain. Tidak ada field
// order-item/payment yang dikirim ke backend pada prototype ini.

import '../../../domain/entities/sales_chat_entity.dart';

/// DTO satu produk pada draft.
class SalesChatItemModel {
  const SalesChatItemModel({
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

  factory SalesChatItemModel.fromJson(Object? raw, {required int index}) {
    final Map<String, Object?> json = _asMap(raw, 'items[$index]');
    return SalesChatItemModel(
      name: _asString(json['nama'] ?? json['name']),
      quantity: _asInt(json['jumlah'] ?? json['quantity']),
      unit: _asString(json['satuan'] ?? json['unit']),
      unitPrice: _asInt(json['harga_satuan'] ?? json['unit_price']),
      method: SalesPaymentMethodX.fromApi(json['metode'] ?? json['method']),
    );
  }

  SalesChatItem toEntity() {
    return SalesChatItem(
      name: name,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      method: method,
    );
  }
}

/// DTO satu rincian pembayaran.
class SalesPaymentEntryModel {
  const SalesPaymentEntryModel({this.method, this.amount});

  final SalesPaymentMethod? method;
  final int? amount;

  factory SalesPaymentEntryModel.fromJson(Object? raw, {required int index}) {
    final Map<String, Object?> json = _asMap(raw, 'payments[$index]');
    return SalesPaymentEntryModel(
      method: SalesPaymentMethodX.fromApi(json['metode'] ?? json['method']),
      amount: _asInt(json['nominal'] ?? json['amount']),
    );
  }

  SalesPaymentEntry toEntity() {
    return SalesPaymentEntry(method: method, amount: amount);
  }
}

/// DTO draft penjualan pada isi `data` envelope.
class SalesChatDraftModel {
  const SalesChatDraftModel({
    required this.id,
    required this.items,
    required this.payments,
    this.date,
    this.shift,
    this.declaredTotal,
    this.note,
  });

  final String id;
  final DateTime? date;
  final String? shift;
  final int? declaredTotal;
  final List<SalesChatItemModel> items;
  final List<SalesPaymentEntryModel> payments;
  final String? note;

  factory SalesChatDraftModel.fromJson(Object? raw) {
    final Map<String, Object?> json = _asMap(raw, 'data');
    final Object? rawItems = json['items'] ?? json['produk'];
    final Object? rawPayments = json['payments'] ?? json['pembayaran'];
    if (rawItems != null && rawItems is! List) {
      throw const FormatException('Field `items` bukan list.');
    }
    if (rawPayments != null && rawPayments is! List) {
      throw const FormatException('Field `payments` bukan list.');
    }

    final List<Object?> itemItems =
        rawItems is List ? rawItems : const <Object?>[];
    final List<Object?> paymentItems =
        rawPayments is List ? rawPayments : const <Object?>[];

    return SalesChatDraftModel(
      id: _asString(json['id']) ?? 'draft-demo',
      date: _asDate(json['tanggal'] ?? json['date']),
      shift: _asString(json['shift']),
      declaredTotal: _asInt(json['total'] ?? json['declared_total']),
      items: <SalesChatItemModel>[
        for (int i = 0; i < itemItems.length; i++)
          SalesChatItemModel.fromJson(itemItems[i], index: i),
      ],
      payments: <SalesPaymentEntryModel>[
        for (int i = 0; i < paymentItems.length; i++)
          SalesPaymentEntryModel.fromJson(paymentItems[i], index: i),
      ],
      note: _asString(json['catatan'] ?? json['note']),
    );
  }

  SalesChatDraft toEntity() {
    return SalesChatDraft(
      id: id,
      date: date,
      shift: shift,
      declaredTotal: declaredTotal,
      items: <SalesChatItem>[
        for (final SalesChatItemModel item in items) item.toEntity(),
      ],
      payments: <SalesPaymentEntry>[
        for (final SalesPaymentEntryModel payment in payments)
          payment.toEntity(),
      ],
      note: note ?? 'Data contoh — draft belum disimpan ke pembukuan.',
    );
  }
}

Map<String, Object?> _asMap(Object? raw, String field) {
  if (raw is Map) {
    return <String, Object?>{
      for (final MapEntry<Object?, Object?> entry in raw.entries)
        entry.key.toString(): entry.value,
    };
  }
  throw FormatException('Field `$field` bukan objek JSON.');
}

String? _asString(Object? raw) {
  if (raw is String) {
    final String value = raw.trim();
    return value.isEmpty ? null : value;
  }
  return null;
}

int? _asInt(Object? raw) {
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.round();
  }
  if (raw is String) {
    final String normalized = raw.replaceAll(RegExp(r'[^0-9-]'), '');
    return int.tryParse(normalized);
  }
  return null;
}

DateTime? _asDate(Object? raw) {
  if (raw is! String || raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw.trim());
}
