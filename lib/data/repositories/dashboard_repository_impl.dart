// lib/data/repositories/dashboard_repository_impl.dart
//
// Implementasi DashboardRepository dengan pemetaan DTO ke entity domain.

import 'dart:math' as math;

import 'package:flutter/material.dart' show DateTimeRange;

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../presentation/screens/analytics/models/analytics_summary.dart'
    show niceAxisMax;
import '../../presentation/screens/dashboard/models/dashboard_view_data.dart';
import '../../presentation/utils/format.dart';
import '../datasources/interfaces/dashboard_datasource.dart';
import '../models/api_envelope_model.dart';

int _asInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._dataSource);

  final DashboardDataSource _dataSource;

  @override
  Future<Result<DashboardSummaryEntity>> fetchDashboardSummary({
    String period = '7d',
  }) async {
    try {
      final Map<String, Object?> summaryRaw =
          await _dataSource.fetchSummary(period: period);
      final ApiEnvelopeModel summaryEnvelope =
          ApiEnvelopeModel.fromRaw(summaryRaw);

      if (!summaryEnvelope.success || summaryEnvelope.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: summaryEnvelope.message ?? 'Respon summary tidak valid.',
          ),
        );
      }

      final Map<String, Object?> data = summaryEnvelope.data is Map
          ? summaryEnvelope.data as Map<String, Object?>
          : <String, Object?>{};

      final int cashBalance = _asInt(data['saldo_kas']);
      final Object? orderBaru = data['order_baru'];
      final int newOrdersCount =
          orderBaru is Map ? _asInt(orderBaru['total']) : 0;

      RevenueSummary? revenueSummary;
      int todayIncome = 0;
      int todayExpense = 0;
      int periodIncome = 0;
      int periodExpense = 0;
      int totalTransactions = 0;

      try {
        final Map<String, Object?> chartRaw =
            await _dataSource.fetchCashChart(period: period);
        final ApiEnvelopeModel chartEnvelope =
            ApiEnvelopeModel.fromRaw(chartRaw);
        if (chartEnvelope.success && chartEnvelope.data is List) {
          final List<Object?> list = chartEnvelope.data as List<Object?>;
          final List<RevenueDayData> days = <RevenueDayData>[];
          int maxThousands = 0;
          DateTime? firstDate;
          DateTime? lastDate;

          for (int i = 0; i < list.length; i++) {
            final Object? item = list[i];
            if (item is Map) {
              final String tanggal = item['tanggal']?.toString() ?? '';
              final DateTime? parsedDate = DateTime.tryParse(tanggal);
              if (parsedDate != null) {
                firstDate ??= parsedDate;
                lastDate = parsedDate;
              }

              final int income = _asInt(item['pemasukan']);
              final int expense = _asInt(item['pengeluaran']);
              final Object? trxList = item['transaksi'];
              if (trxList is List) {
                totalTransactions += trxList.length;
              }

              periodIncome += income;
              periodExpense += expense;
              if (i == list.length - 1) {
                todayIncome = income;
                todayExpense = expense;
              }

              final int incomeThousands = (income / 1000).ceil();
              final int expenseThousands = (expense / 1000).ceil();
              maxThousands = math.max(
                maxThousands,
                math.max(incomeThousands, expenseThousands),
              );

              final String dayLabel = parsedDate != null
                  ? (list.length <= 4
                      ? weekdayName(parsedDate)
                      : weekdayShort(parsedDate))
                  : (tanggal.length >= 5 ? tanggal.substring(5) : tanggal);

              days.add(
                RevenueDayData(
                  label: dayLabel,
                  thisWeek: incomeThousands,
                  lastWeek: expenseThousands,
                ),
              );
            }
          }

          final String dateLabel = firstDate != null && lastDate != null
              ? formatDateRange(DateTimeRange(start: firstDate, end: lastDate))
              : '7 Hari Terakhir';

          final int headlineTotal =
              periodIncome > 0 ? periodIncome : math.max(0, cashBalance);
          final double netGrowth = periodIncome == 0 && periodExpense == 0
              ? 0
              : periodExpense == 0
                  ? 100
                  : ((periodIncome - periodExpense) / periodExpense) * 100;

          revenueSummary = RevenueSummary(
            title: 'Total Penghasilan',
            dateLabel: dateLabel,
            total: formatRupiah(headlineTotal),
            growth: formatPercentChange(netGrowth),
            axisMax: niceAxisMax(maxThousands),
            days: days,
            lastWeekLegend: 'Pengeluaran',
            thisWeekLegend: 'Pemasukan',
          );
        }
      } catch (_) {
        // Biarkan controller membangun kerangka grafik default Rp 0 / saldo kas.
      }

      // Ambil riwayat transaksi terbaru (penjualan online frozen food & offline/manual)
      final List<DashboardActivityData> activities = <DashboardActivityData>[];
      try {
        final List<Map<String, Object?>> acts =
            await _dataSource.fetchRecentActivities(limit: 5);
        for (final Map<String, Object?> act in acts) {
          final String title = act['recordLabel']?.toString() ??
              act['labelRecord']?.toString() ??
              act['sheet']?.toString() ??
              'Catatan Transaksi';
          final String action =
              act['action']?.toString() ?? act['aksi']?.toString() ?? '';
          final String detail = act['detail']?.toString() ?? '';
          final bool isExpense = action.toLowerCase().contains('hapus') ||
              action.toLowerCase().contains('keluar') ||
              detail.toLowerCase().contains('pengeluaran');
          activities.add(
            DashboardActivityData(
              name: title,
              variant: detail.isNotEmpty
                  ? detail
                  : (isExpense ? 'Catatan Pengeluaran' : 'Penjualan Frozen Food'),
              sku: 'Ref: ${act['id'] ?? 'KAS'}',
              pack: action.isNotEmpty ? action.toUpperCase() : 'TERCATAT',
              badge: isExpense ? 'Pengeluaran' : 'Pemasukan',
              imageAsset: '',
            ),
          );
        }
      } catch (_) {
        // Abaikan bila gagal memuat aktivitas tambahan.
      }

      return Result.success(
        DashboardSummaryEntity(
          cashBalance: cashBalance,
          newOrdersCount: newOrdersCount,
          todayIncome: todayIncome,
          todayExpense: todayExpense,
          periodIncome: periodIncome,
          periodExpense: periodExpense,
          totalTransactions: totalTransactions,
          revenueSummary: revenueSummary,
          recentActivities: activities,
        ),
      );
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
