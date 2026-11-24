// lib/data/datasources/interfaces/transaction_datasource.dart
//
// Kontrak datasource transaksi operasional.

abstract interface class TransactionDataSource {
  Future<Map<String, Object?>> fetchTransactionsRaw({
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  });
}
