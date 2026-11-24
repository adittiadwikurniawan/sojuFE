// lib/data/datasources/interfaces/dashboard_datasource.dart
//
// Kontrak datasource dashboard operasional.

abstract interface class DashboardDataSource {
  Future<Map<String, Object?>> fetchSummary({String period = '7d'});
  Future<Map<String, Object?>> fetchCashChart({String period = '7d'});
  Future<List<Map<String, Object?>>> fetchRecentActivities({int limit = 5});
}
