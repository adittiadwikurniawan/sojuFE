// lib/data/datasources/mock/admin_order_mock_datasource.dart
//
// Mock data pesanan pelanggan untuk admin in-memory (Phase A fallback / test).

import '../interfaces/admin_order_datasource.dart';

class AdminOrderMockDataSource implements AdminOrderDataSource {
  AdminOrderMockDataSource({List<Map<String, Object?>>? initialOrders})
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
              ];

  final List<Map<String, Object?>> _orders;

  @override
  Future<Map<String, Object?>> fetchOrdersRaw({String? status}) async {
    final List<Map<String, Object?>> filtered = status != null && status.isNotEmpty
        ? _orders.where((Map<String, Object?> o) => o['status'] == status).toList()
        : List<Map<String, Object?>>.from(_orders);

    return <String, Object?>{
      'success': true,
      'data': filtered,
    };
  }

  @override
  Future<Map<String, Object?>> updateOrderStatusRaw({
    required int id,
    required String status,
  }) async {
    final int idx = _orders.indexWhere((Map<String, Object?> o) => o['id'] == id);
    if (idx != -1) {
      _orders[idx]['status'] = status;
      _orders[idx]['diperbaruiPada'] = DateTime.now().toIso8601String();
      return <String, Object?>{
        'success': true,
        'message': 'Status pesanan diperbarui',
        'data': _orders[idx],
      };
    }
    return <String, Object?>{
      'success': false,
      'message': 'Pesanan tidak ditemukan',
    };
  }
}
