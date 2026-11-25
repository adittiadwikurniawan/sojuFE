// lib/domain/entities/dashboard_entity.dart
//
// Entity domain ringkasan dashboard operasional admin.

import 'package:flutter/foundation.dart';
import '../../presentation/screens/dashboard/models/dashboard_view_data.dart';

/// Entity ringkasan dashboard operasional.
@immutable
class DashboardSummaryEntity {
  const DashboardSummaryEntity({
    required this.cashBalance,
    required this.newOrdersCount,
    this.todayIncome = 0,
    this.todayExpense = 0,
    this.periodIncome = 0,
    this.periodExpense = 0,
    this.totalTransactions = 0,
    this.revenueSummary,
    this.recentActivities = const <DashboardActivityData>[],
  });

  /// Saldo kas operasional saat ini.
  final int cashBalance;

  /// Jumlah pesanan baru / masuk.
  final int newOrdersCount;

  /// Penghasilan hari ini.
  final int todayIncome;

  /// Pengeluaran hari ini.
  final int todayExpense;

  /// Total pemasukan pada periode grafik aktif.
  final int periodIncome;

  /// Total pengeluaran pada periode grafik aktif.
  final int periodExpense;

  /// Total transaksi pada periode.
  final int totalTransactions;

  /// Ringkasan pendapatan & grafik.
  final RevenueSummary? revenueSummary;

  /// Aktivitas audit/transaksi terbaru.
  final List<DashboardActivityData> recentActivities;
}
