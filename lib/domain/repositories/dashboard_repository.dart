// lib/domain/repositories/dashboard_repository.dart
//
// Kontrak repository dashboard operasional.

import '../../core/common/result.dart';
import '../entities/dashboard_entity.dart';

abstract interface class DashboardRepository {
  /// Mengambil data ringkasan dashboard untuk periode tertentu.
  Future<Result<DashboardSummaryEntity>> fetchDashboardSummary({
    String period = '7d',
  });
}
