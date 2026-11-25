// lib/data/datasources/interfaces/admin_order_datasource.dart
//
// Kontrak datasource pesanan pelanggan di sisi Admin.

abstract interface class AdminOrderDataSource {
  Future<Map<String, Object?>> fetchOrdersRaw({String? status});

  Future<Map<String, Object?>> updateOrderStatusRaw({
    required int id,
    required String status,
  });
}
