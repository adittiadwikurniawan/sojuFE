// lib/data/datasources/mock/customer_order_mock_datasource.dart
//
// Mock data pesanan pelanggan in-memory untuk pengujian terisolasi (TASK-025).

import '../../../core/errors/app_failure.dart';
import '../interfaces/customer_order_datasource.dart';

class CustomerOrderMockDataSource implements CustomerOrderDataSource {
  CustomerOrderMockDataSource({List<Map<String, Object?>>? initialOrders})
      : _orders = initialOrders != null
            ? List<Map<String, Object?>>.from(initialOrders)
            : <Map<String, Object?>>[
                <String, Object?>{
                  'id': 101,
                  'kode': 'PSN-1700000001-000101',
                  'pelangganId': 1,
                  'namaPenerima': 'Pelanggan SOJU',
                  'emailPenerima': 'pelanggan@sojucorp.com',
                  'noTelepon': '081234567890',
                  'alamat': 'Jl. Senopati No. 45, Jakarta Selatan',
                  'total': 90000,
                  'status': 'DIPROSES',
                  'paymentStatus': 'PAID',
                  'paymentMethod': 'qris',
                  'midtransOrderId': 'SOJU-PSN-101',
                  'dibuatPada': '2026-11-24T10:30:00.000Z',
                  'diperbaruiPada': '2026-11-24T10:35:00.000Z',
                  'item': <Map<String, Object?>>[
                    <String, Object?>{
                      'id': 201,
                      'pesananId': 101,
                      'produkId': 1,
                      'namaProduk': 'Soju Peach',
                      'varian': 'Dingin',
                      'satuan': 'Botol',
                      'harga': 45000,
                      'jumlah': 2,
                      'catatan': 'Packing rapi ya',
                      'subtotal': 90000,
                    },
                  ],
                },
                <String, Object?>{
                  'id': 100,
                  'kode': 'PSN-1700000000-000100',
                  'pelangganId': 1,
                  'namaPenerima': 'Pelanggan SOJU',
                  'emailPenerima': 'pelanggan@sojucorp.com',
                  'noTelepon': '081234567890',
                  'alamat': 'Jl. Senopati No. 45, Jakarta Selatan',
                  'total': 45000,
                  'status': 'SELESAI',
                  'dibuatPada': '2026-11-23T14:15:00.000Z',
                  'diperbaruiPada': '2026-11-23T15:00:00.000Z',
                  'item': <Map<String, Object?>>[
                    <String, Object?>{
                      'id': 200,
                      'pesananId': 100,
                      'produkId': 2,
                      'namaProduk': 'Soju Original',
                      'varian': 'Original',
                      'satuan': 'Botol',
                      'harga': 45000,
                      'jumlah': 1,
                      'catatan': null,
                      'subtotal': 45000,
                    },
                  ],
                },
              ];

  final List<Map<String, Object?>> _orders;

  @override
  Future<Map<String, Object?>> checkout(Map<String, Object?> payload) async {
    final String address = (payload['alamat'] as String?)?.trim() ??
        'Jl. Senopati No. 45, Jakarta Selatan';
    final int nextId = (_orders.isEmpty ? 100 : _orders.first['id'] as int) + 1;
    final Map<String, Object?> newOrder = <String, Object?>{
      'id': nextId,
      'kode': 'PSN-${DateTime.now().millisecondsSinceEpoch}-$nextId',
      'pelangganId': 1,
      'namaPenerima': 'Pelanggan SOJU',
      'emailPenerima': 'pelanggan@sojucorp.com',
      'noTelepon': '081234567890',
      'alamat': address,
      'total': 90000,
      'status': 'MENUNGGU_KONFIRMASI',
      'paymentStatus': 'PENDING',
      'midtransOrderId': 'SOJU-MOCK-$nextId',
      'snapToken': 'mock-snap-token-$nextId',
      'snapRedirectUrl':
          'https://app.sandbox.midtrans.com/snap/v4/redirection/mock-$nextId',
      'paymentExpiredAt':
          DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      'dibuatPada': DateTime.now().toIso8601String(),
      'item': <Map<String, Object?>>[
        <String, Object?>{
          'id': nextId * 10,
          'pesananId': nextId,
          'produkId': 1,
          'namaProduk': 'Soju Peach',
          'varian': 'Dingin',
          'satuan': 'Botol',
          'harga': 45000,
          'jumlah': 2,
          'catatan': 'Pesanan baru',
          'subtotal': 90000,
        },
      ],
    };

    _orders.insert(0, newOrder);
    return <String, Object?>{
      'status': 'success',
      'message': 'Pesanan berhasil dibuat',
      'data': newOrder,
    };
  }

  @override
  Future<Map<String, Object?>> fetchOrders() async {
    return <String, Object?>{
      'status': 'success',
      'data': List<Map<String, Object?>>.from(_orders),
    };
  }

  @override
  Future<Map<String, Object?>> fetchOrderDetail(int id) async {
    final Map<String, Object?>? match = _orders.cast<Map<String, Object?>?>().firstWhere(
          (Map<String, Object?>? o) => o != null && o['id'] == id,
          orElse: () => null,
        );
    if (match == null) {
      throw const ServerFailure(
        statusCode: 404,
        message: 'Pesanan tidak ditemukan',
      );
    }
    return <String, Object?>{
      'status': 'success',
      'data': match,
    };
  }
}
