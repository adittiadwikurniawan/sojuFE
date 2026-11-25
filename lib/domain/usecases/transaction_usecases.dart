// lib/domain/usecases/transaction_usecases.dart
//
// Usecase pembacaan daftar transaksi operasional.

import '../../core/common/result.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  const GetTransactions(this._repository);

  final TransactionRepository _repository;

  Future<Result<List<TransactionEntity>>> call({
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) {
    return _repository.fetchTransactions(
      search: search,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
  }
}
