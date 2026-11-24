// lib/presentation/providers/dashboard/dashboard_controller.dart
//
// Controller untuk Beranda / Dashboard Operasional Admin.
// Menangani state: loading, data, error, dan retry.

import 'package:flutter/foundation.dart';
import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/dashboard_entity.dart';
import '../../../domain/usecases/dashboard_usecases.dart';
import '../../screens/dashboard/models/dashboard_view_data.dart';

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
            isChartEmpty &&
            isActivityEmpty;

        final DashboardViewData mappedViewData = DashboardViewData(
          avatarAsset: 'assets/images/avatar_profil.png',
          searchHint: 'Cari Kas Mu',
          metrics: <DashboardMetricData>[
            DashboardMetricData(
              title: 'Saldo Kas',
              value: 'Rp ${summary.cashBalance}',
              note: 'Kas Operasional',
              titleSize: 15.4,
            ),
            DashboardMetricData(
              title: 'Pesanan Baru',
              value: '${summary.newOrdersCount} Pesanan',
              note: 'Menunggu konfirmasi / proses',
            ),
            const DashboardMetricData(
              title: 'Status Sinkronisasi',
              value: 'Live REST',
              note: 'Terhubung ke server',
            ),
          ],
          revenue: summary.revenueSummary ?? DashboardViewData.sample.revenue,
          assistant: DashboardViewData.sample.assistant,
          activities: summary.recentActivities.isNotEmpty
              ? summary.recentActivities
              : (isZeroOperational
                  ? const <DashboardActivityData>[]
                  : DashboardViewData.sample.activities),
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
