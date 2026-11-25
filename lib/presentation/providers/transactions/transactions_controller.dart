// lib/presentation/providers/transactions/transactions_controller.dart
//
// Controller untuk Transaksi/Data Operasional Admin.
// Menangani state: loading, data, empty, error, dan retry.

import 'package:flutter/foundation.dart';
import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import '../../screens/analytics/models/analytics_transaction.dart';
import '../../screens/analytics/models/analytics_view_data.dart';

enum TransactionsStatus { loading, data, empty, error }

class TransactionsState {
  const TransactionsState({
    required this.status,
    this.transactions = const <TransactionEntity>[],
    this.viewData,
    this.errorMessage,
    this.searchQuery,
  });

  const TransactionsState.initial()
      : this(status: TransactionsStatus.loading);

  final TransactionsStatus status;
  final List<TransactionEntity> transactions;
  final AnalyticsViewData? viewData;
  final String? errorMessage;
  final String? searchQuery;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<TransactionEntity>? transactions,
    AnalyticsViewData? viewData,
    String? errorMessage,
    String? searchQuery,
    bool clearSearch = false,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      viewData: viewData ?? this.viewData,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

class TransactionsController extends ChangeNotifier {
  TransactionsController({required GetTransactions getTransactions})
      : _getTransactions = getTransactions;

  final GetTransactions _getTransactions;

  TransactionsState _state = const TransactionsState.initial();
  TransactionsState get state => _state;

  Future<void> load({String? search, String? startDate, String? endDate}) async {
    _state = _state.copyWith(
      status: TransactionsStatus.loading,
      searchQuery: search,
      errorMessage: null,
    );
    notifyListeners();

    final Result<List<TransactionEntity>> result = await _getTransactions(
      search: search,
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: TransactionsStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (List<TransactionEntity> items) {
        if (items.isEmpty) {
          _state = _state.copyWith(
            status: TransactionsStatus.empty,
            transactions: const <TransactionEntity>[],
            viewData: AnalyticsViewData(
              avatarAsset: 'assets/images/avatar_profil.png',
              month: DateTime.now(),
              transactions: const <AnalyticsTransaction>[],
            ),
          );
        } else {
          final List<AnalyticsTransaction> analyticsItems = items
              .map((TransactionEntity e) => e.toAnalyticsTransaction())
              .toList();

          _state = _state.copyWith(
            status: TransactionsStatus.data,
            transactions: items,
            viewData: AnalyticsViewData(
              avatarAsset: 'assets/images/avatar_profil.png',
              month: items.first.date,
              transactions: analyticsItems,
            ),
          );
        }
      },
    );
    notifyListeners();
  }
}
