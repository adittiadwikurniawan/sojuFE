// lib/domain/repositories/transaction_repository.dart
//
// Kontrak repository transaksi operasional.

import '../../core/common/result.dart';
import '../entities/transaction_entity.dart';

abstract interface class TransactionRepository {
  /// Mengambil daftar transaksi operasional dengan filter opsional.
  Future<Result<List<TransactionEntity>>> fetchTransactions({
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  });
}
