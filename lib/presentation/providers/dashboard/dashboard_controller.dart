// lib/presentation/providers/dashboard/dashboard_controller.dart
//
// Controller untuk Beranda / Dashboard Operasional Admin.
// Menangani state: loading, data, empty, error, dan retry.

import 'dart:math' as math;

import 'package:flutter/material.dart' show DateTimeRange, ChangeNotifier;

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/dashboard_entity.dart';
import '../../../domain/usecases/dashboard_usecases.dart';
import '../../screens/dashboard/models/dashboard_view_data.dart';
import '../../utils/format.dart';

enum DashboardStatus { loading, data, empty, error }

class DashboardState {
  const DashboardState({
    required this.status,
    this.summary,
    this.viewData,
    this.errorMessage,
    this.period = '7d',
  });

  const DashboardState.initial()
      : this(status: DashboardStatus.loading, period: '7d');

  final DashboardStatus status;
  final DashboardSummaryEntity? summary;
  final DashboardViewData? viewData;
  final String? errorMessage;
  final String period;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSummaryEntity? summary,
    DashboardViewData? viewData,
    String? errorMessage,
    String? period,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      viewData: viewData ?? this.viewData,
      errorMessage: errorMessage ?? this.errorMessage,
      period: period ?? this.period,
    );
  }
}

class DashboardController extends ChangeNotifier {
  DashboardController({required GetDashboardSummary getDashboardSummary})
      : _getDashboardSummary = getDashboardSummary;

  final GetDashboardSummary _getDashboardSummary;

  DashboardState _state = const DashboardState.initial();
  DashboardState get state => _state;

  static RevenueSummary _buildFallbackLiveChart(DashboardSummaryEntity summary) {
    final DateTime today = dateOnly(DateTime.now());
    final DateTime start = today.subtract(const Duration(days: 6));
    final List<RevenueDayData> zeroDays = <RevenueDayData>[
      for (int i = 0; i < 7; i++)
        RevenueDayData(
          label: weekdayShort(start.add(Duration(days: i))),
          thisWeek: 0,
          lastWeek: 0,
        ),
    ];

    final int headline = summary.periodIncome > 0
        ? summary.periodIncome
        : math.max(0, summary.cashBalance);

    return RevenueSummary(
      title: 'Total Penghasilan',
      dateLabel: formatDateRange(DateTimeRange(start: start, end: today)),
      total: formatRupiah(headline),
      growth: '0%',
      axisMax: 500,
      days: zeroDays,
      lastWeekLegend: 'Pengeluaran',
      thisWeekLegend: 'Pemasukan',
    );
  }

  Future<void> load({String? period}) async {
    final String targetPeriod = period ?? _state.period;
    _state = _state.copyWith(
      status: DashboardStatus.loading,
      period: targetPeriod,
      errorMessage: null,
    );
    notifyListeners();

    final Result<DashboardSummaryEntity> result =
        await _getDashboardSummary(period: targetPeriod);

    result.fold(
      onFailure: (AppFailure failure) {
        _state = _state.copyWith(
          status: DashboardStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (DashboardSummaryEntity summary) {
        final bool isChartEmpty = summary.revenueSummary == null ||
            summary.revenueSummary!.days.isEmpty ||
            summary.revenueSummary!.days.every(
              (RevenueDayData d) => d.thisWeek == 0 && d.lastWeek == 0,
            );
        final bool isActivityEmpty = summary.recentActivities.isEmpty;
        final bool isZeroOperational = summary.cashBalance == 0 &&
            summary.newOrdersCount == 0 &&
            summary.todayIncome == 0 &&
            summary.periodIncome == 0 &&
            summary.periodExpense == 0 &&
            isChartEmpty &&
            isActivityEmpty;

        final RevenueSummary effectiveRevenue =
            (summary.revenueSummary != null &&
                    summary.revenueSummary!.days.isNotEmpty)
                ? summary.revenueSummary!
                : _buildFallbackLiveChart(summary);

        final int displayedIncome = summary.periodIncome > 0
            ? summary.periodIncome
            : summary.todayIncome;
        final int displayedExpense = summary.periodExpense > 0
            ? summary.periodExpense
            : summary.todayExpense;

        final DashboardViewData mappedViewData = DashboardViewData(
          avatarAsset: 'assets/images/avatar_profil.png',
          searchHint: 'Cari Kas Mu',
          metrics: <DashboardMetricData>[
            DashboardMetricData(
              title: 'Saldo Kas',
              value: formatRupiah(summary.cashBalance),
              note: 'Pemasukan − Pengeluaran',
              titleSize: 13.4,
            ),
            DashboardMetricData(
              title: 'Pemasukan',
              value: formatRupiah(displayedIncome),
              note: 'Total Uang Masuk',
              titleSize: 13.4,
            ),
            DashboardMetricData(
              title: 'Pengeluaran',
              value: formatRupiah(displayedExpense),
              note: 'Belanja Bahan / Operasional',
              titleSize: 13.4,
            ),
            DashboardMetricData(
              title: 'Total Transaksi',
              value: summary.totalTransactions > 0
                  ? '${summary.totalTransactions} Transaksi'
                  : '${summary.newOrdersCount} Pesanan',
              note: summary.totalTransactions > 0
                  ? '${summary.newOrdersCount} Pesanan Pelanggan'
                  : 'Menunggu konfirmasi / proses',
            ),
          ],
          revenue: effectiveRevenue,
          assistant: DashboardViewData.sample.assistant,
          activities: summary.recentActivities,
        );

        _state = _state.copyWith(
          status:
              isZeroOperational ? DashboardStatus.empty : DashboardStatus.data,
          summary: summary,
          viewData: mappedViewData,
        );
      },
    );
    notifyListeners();
  }
}
