// lib/domain/usecases/dashboard_usecases.dart
//
// Usecase pembacaan ringkasan dashboard.

import '../../core/common/result.dart';
import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummary {
  const GetDashboardSummary(this._repository);

  final DashboardRepository _repository;

  Future<Result<DashboardSummaryEntity>> call({String period = '7d'}) {
    return _repository.fetchDashboardSummary(period: period);
  }
}
