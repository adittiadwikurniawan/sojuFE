// lib/data/datasources/interfaces/customer_order_datasource.dart
//
// Antarmuka datasource pesanan pelanggan (TASK-025).

abstract class CustomerOrderDataSource {
  /// Melakukan checkout pesanan baru (`POST /api/customer/checkout`).
  Future<Map<String, Object?>> checkout(Map<String, Object?> payload);

  /// Mengambil daftar pesanan pelanggan (`GET /api/customer/pesanan`).
  Future<Map<String, Object?>> fetchOrders();

  /// Mengambil detail pesanan pelanggan (`GET /api/customer/pesanan/:id`).
  Future<Map<String, Object?>> fetchOrderDetail(int id);
}
