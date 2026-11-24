// lib/data/repositories/transaction_repository_impl.dart
//
// Implementasi TransactionRepository.

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../presentation/screens/analytics/models/analytics_transaction.dart';
import '../datasources/interfaces/transaction_datasource.dart';
import '../models/api_envelope_model.dart';

int _asInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._dataSource);

  final TransactionDataSource _dataSource;

  @override
  Future<Result<List<TransactionEntity>>> fetchTransactions({
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.fetchTransactionsRaw(
        search: search,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );

      final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
      if (!envelope.success || envelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: envelope.message ?? 'Respon transaksi tidak valid.',
          ),
        );
      }

      final Object? dataContent = envelope.data;
      final List list;
      if (dataContent is Map && dataContent['data'] is List) {
        list = dataContent['data'] as List;
      } else if (dataContent is List) {
        list = dataContent;
      } else {
        list = const <Object?>[];
      }

      final List<TransactionEntity> result = <TransactionEntity>[];
      for (final item in list) {
        if (item is Map) {
          final int id = _asInt(item['id']);
          final String code = item['kode']?.toString() ?? 'TRX-$id';
          final String title = item['namaTransaksi']?.toString() ??
              item['detail']?.toString() ??
              'Transaksi';
          final String detail = item['detail']?.toString() ?? '';
          final int amount = _asInt(item['nominal']);

          final Object? jenis = item['jenisTransaksi'];
          String category = 'Operasional';
          TransactionType type = TransactionType.income;

          if (jenis is Map) {
            category = jenis['namaTransaksi']?.toString() ?? category;
            final String arah = jenis['arah']?.toString() ?? '';
            if (arah.toUpperCase() == 'PENGELUARAN') {
              type = TransactionType.expense;
            } else {
              type = TransactionType.income;
            }
          }

          final String dateStr = item['tanggal']?.toString() ?? '';
          final DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();

          result.add(
            TransactionEntity(
              id: id,
              code: code,
              title: title,
              category: category,
              date: date,
              type: type,
              amount: amount,
              source: item['sumberInput']?.toString() ?? 'MANUAL',
              businessUnit: item['unitBisnis']?.toString(),
              detail: detail,
            ),
          );
        }
      }

      return Result.success(result);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
