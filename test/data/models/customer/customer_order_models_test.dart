// test/data/models/customer/customer_order_models_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/data/models/customer/customer_order_models.dart';
import 'package:soju_fe/domain/entities/customer_order_entity.dart';

void main() {
  group('CustomerOrderModel & CustomerOrderItemModel', () {
    test('parses full backend order json into CustomerOrder entity correctly', () {
      final Map<String, Object?> json = <String, Object?>{
        'id': 101,
        'kode': 'PSN-1700000000-123456',
        'pelangganId': 5,
        'namaPenerima': 'Budi Santoso',
        'emailPenerima': 'budi@example.com',
        'noTelepon': '081234567890',
        'alamat': 'Jl. Kemang Raya No. 10',
        'total': '95000',
        'status': 'MENUNGGU_KONFIRMASI',
        'dibuatPada': '2026-11-25T01:30:00.000Z',
        'diperbaruiPada': '2026-11-25T01:35:00.000Z',
        'item': <Map<String, Object?>>[
          <String, Object?>{
            'id': 201,
            'pesananId': 101,
            'produkId': 10,
            'namaProduk': 'Soju Peach',
            'varian': 'Dingin',
            'satuan': 'Botol',
            'harga': 45000,
            'jumlah': 2,
            'catatan': 'Dingin ekstra',
            'subtotal': 90000,
          },
          <String, Object?>{
            'id': 202,
            'pesananId': 101,
            'produkId': 11,
            'namaProduk': 'Kimchi',
            'varian': null,
            'satuan': 'Porsi',
            'harga': 5000,
            'jumlah': 1,
            'catatan': null,
            'subtotal': 5000,
          },
        ],
      };

      final CustomerOrderModel model = CustomerOrderModel.fromJson(json);
      final CustomerOrder entity = model.toEntity();

      expect(entity.id, 101);
      expect(entity.code, 'PSN-1700000000-123456');
      expect(entity.customerId, 5);
      expect(entity.recipientName, 'Budi Santoso');
      expect(entity.recipientEmail, 'budi@example.com');
      expect(entity.recipientPhone, '081234567890');
      expect(entity.recipientAddress, 'Jl. Kemang Raya No. 10');
      expect(entity.total, 95000);
      expect(entity.status, CustomerOrderStatus.menungguKonfirmasi);
      expect(entity.status.label, 'Menunggu Konfirmasi');
      expect(entity.createdAt, DateTime.parse('2026-11-25T01:30:00.000Z'));
      expect(entity.items.length, 2);
      expect(entity.totalItems, 3);

      final CustomerOrderItem item1 = entity.items[0];
      expect(item1.id, 201);
      expect(item1.productName, 'Soju Peach');
      expect(item1.variant, 'Dingin');
      expect(item1.hasVariant, isTrue);
      expect(item1.note, 'Dingin ekstra');
      expect(item1.hasNote, isTrue);
      expect(item1.price, 45000);
      expect(item1.quantity, 2);
      expect(item1.subtotal, 90000);

      final CustomerOrderItem item2 = entity.items[1];
      expect(item2.id, 202);
      expect(item2.productName, 'Kimchi');
      expect(item2.variant, isNull);
      expect(item2.hasVariant, isFalse);
      expect(item2.note, isNull);
      expect(item2.hasNote, isFalse);
      expect(item2.price, 5000);
      expect(item2.quantity, 1);
      expect(item2.subtotal, 5000);
    });

    test('parses CustomerOrderStatus enum from raw strings correctly', () {
      expect(
        CustomerOrderStatus.fromRaw('MENUNGGU_KONFIRMASI'),
        CustomerOrderStatus.menungguKonfirmasi,
      );
      expect(
        CustomerOrderStatus.fromRaw('DIPROSES'),
        CustomerOrderStatus.diproses,
      );
      expect(
        CustomerOrderStatus.fromRaw('SELESAI'),
        CustomerOrderStatus.selesai,
      );
      expect(
        CustomerOrderStatus.fromRaw('DIBATALKAN'),
        CustomerOrderStatus.dibatalkan,
      );
      expect(
        CustomerOrderStatus.fromRaw('unknown_status'),
        CustomerOrderStatus.menungguKonfirmasi,
      );
      expect(
        CustomerOrderStatus.fromRaw(null),
        CustomerOrderStatus.menungguKonfirmasi,
      );
    });
  });
}
