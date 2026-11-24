// lib/domain/usecases/sales_chat_usecases.dart
//
// Usecase prototype chat penjualan harian/shift.

import '../../core/common/result.dart';
import '../entities/sales_chat_entity.dart';
import '../repositories/sales_chat_repository.dart';

/// Menyusun draft penjualan dari input percakapan (mock Phase A).
class ParseSalesChatRecap {
  const ParseSalesChatRecap(this._repository);

  final SalesChatRepository _repository;

  Future<Result<SalesChatDraft?>> call(String input) {
    return _repository.parseRecap(input);
  }
}
