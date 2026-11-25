// Unit test: entity draft penjualan prototype.
//
// Memastikan total diturunkan dari item/pembayaran, field kosong tidak
// diisi otomatis, dan selisih tidak pernah diperbaiki diam-diam.

import 'package:flutter_test/flutter_test.dart';

import 'package:soju_fe/domain/entities/sales_chat_entity.dart';

SalesChatDraft completeDraft() {
  return SalesChatDraft(
    id: 'draft-test',
    date: DateTime(2026, 11, 19),
    shift: 'Siang',
    declaredTotal: 1375000,
    items: const <SalesChatItem>[
      SalesChatItem(
        name: 'Bento Ayam Bakar',
        quantity: 30,
        unit: 'porsi',
        unitPrice: 35000,
        method: SalesPaymentMethod.qris,
      ),
      SalesChatItem(
        name: 'Sosis Keju',
        quantity: 15,
        unit: 'porsi',
        unitPrice: 15000,
        method: SalesPaymentMethod.qris,
      ),
      SalesChatItem(
        name: 'Es Teh Manis',
        quantity: 20,
        unit: 'gelas',
        unitPrice: 5000,
        method: SalesPaymentMethod.cash,
      ),
    ],
    payments: const <SalesPaymentEntry>[
      SalesPaymentEntry(method: SalesPaymentMethod.qris, amount: 1275000),
      SalesPaymentEntry(method: SalesPaymentMethod.cash, amount: 100000),
    ],
  );
}

void main() {
  test('menghitung total item dan pembayaran dari rincian', () {
    final SalesChatDraft draft = completeDraft();

    expect(draft.itemTotal, 1375000);
    expect(draft.paymentTotal, 1375000);
    expect(draft.itemDifference, 0);
    expect(draft.paymentDifference, 0);
    expect(draft.hasItemMismatch, isFalse);
    expect(draft.hasPaymentMismatch, isFalse);
    expect(draft.missingFields, isEmpty);
    expect(draft.canConfirm, isTrue);
  });

  test('field yang belum diketahui tetap kosong dan masuk daftar missing', () {
    const SalesChatDraft draft = SalesChatDraft(
      id: 'draft-kosong',
      declaredTotal: 100000,
      items: <SalesChatItem>[
        SalesChatItem(name: 'Kopi', method: SalesPaymentMethod.cash),
      ],
      payments: <SalesPaymentEntry>[
        SalesPaymentEntry(method: SalesPaymentMethod.cash),
      ],
    );

    expect(draft.itemTotal, isNull);
    expect(draft.paymentTotal, isNull);
    expect(draft.itemDifference, isNull);
    expect(draft.paymentDifference, isNull);
    expect(draft.missingFields, contains('Tanggal'));
    expect(draft.missingFields, contains('Shift'));
    expect(draft.missingFields, contains('Jumlah Kopi'));
    expect(draft.missingFields, contains('Satuan Kopi'));
    expect(draft.missingFields, contains('Harga Kopi'));
    expect(draft.missingFields, contains('Nominal pembayaran'));
    expect(draft.canConfirm, isFalse);
  });

  test('selisih total item ditandai, bukan disesuaikan otomatis', () {
    final SalesChatDraft draft =
        completeDraft().copyWith(declaredTotal: 1400000);

    expect(draft.itemTotal, 1375000);
    expect(draft.itemDifference, 25000);
    expect(draft.hasItemMismatch, isTrue);
    expect(draft.canConfirm, isFalse);
  });

  test('selisih rincian pembayaran ditandai', () {
    final SalesChatDraft draft = completeDraft().copyWith(
      payments: const <SalesPaymentEntry>[
        SalesPaymentEntry(method: SalesPaymentMethod.qris, amount: 1275000),
      ],
    );

    expect(draft.paymentTotal, 1275000);
    expect(draft.paymentDifference, 100000);
    expect(draft.hasPaymentMismatch, isTrue);
    expect(draft.canConfirm, isFalse);
  });

  test('pembayaran kosong tidak dianggap nol', () {
    final SalesChatDraft draft = completeDraft().copyWith(
      payments: const <SalesPaymentEntry>[],
    );

    expect(draft.paymentTotal, isNull);
    expect(draft.missingFields, contains('Metode pembayaran'));
    expect(draft.canConfirm, isFalse);
  });

  test('copyWith dapat mengosongkan field', () {
    final SalesChatDraft draft = completeDraft().copyWith(
      clearDate: true,
      clearShift: true,
      clearDeclaredTotal: true,
    );

    expect(draft.date, isNull);
    expect(draft.shift, isNull);
    expect(draft.declaredTotal, isNull);
    expect(draft.missingFields, contains('Tanggal'));
    expect(draft.missingFields, contains('Shift'));
    expect(draft.missingFields, contains('Total pemasukan'));
  });
}
