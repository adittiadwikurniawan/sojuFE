// lib/domain/entities/transaction_entity.dart
//
// Entity domain transaksi operasional.

import 'package:flutter/foundation.dart';
import '../../presentation/screens/analytics/models/analytics_transaction.dart';

/// Entity model untuk transaksi operasional.
@immutable
class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.date,
    required this.type,
    required this.amount,
    this.source = 'MANUAL',
    this.businessUnit,
    this.detail,
  });

  final int id;
  final String code;
  final String title;
  final String category;
  final DateTime date;
  final TransactionType type;
  final int amount;
  final String source;
  final String? businessUnit;
  final String? detail;

  AnalyticsTransaction toAnalyticsTransaction() {
    return AnalyticsTransaction(
      id: code,
      date: date,
      title: title,
      category: category,
      type: type,
      amount: amount.toDouble(),
      party: businessUnit ?? 'Buku Dapur',
      note: detail,
    );
  }
}
