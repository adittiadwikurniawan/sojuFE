// lib/domain/usecases/admin_crm_usecases.dart
//
// Usecase Pelanggan & Kampanye CRM (`SUPER_ADMIN`).

import '../../core/common/result.dart';
import '../entities/admin_crm_entity.dart';
import '../repositories/admin_crm_repository.dart';

class GetAdminCustomerSummary {
  const GetAdminCustomerSummary(this._repository);
  final AdminCrmRepository _repository;

  Future<Result<AdminCustomerSummary>> call() =>
      _repository.fetchCustomerSummary();
}

class GetAdminCustomers {
  const GetAdminCustomers(this._repository);
  final AdminCrmRepository _repository;

  Future<Result<List<AdminCustomerItem>>> call({
    String? query,
    String status = 'semua',
  }) {
    return _repository.fetchCustomers(query: query, status: status);
  }
}

class UpdateAdminCustomerStatus {
  const UpdateAdminCustomerStatus(this._repository);
  final AdminCrmRepository _repository;

  Future<Result<AdminCustomerItem>> call({
    required int id,
    required bool isActive,
  }) {
    return _repository.updateCustomerStatus(id: id, isActive: isActive);
  }
}

class GetCrmCampaigns {
  const GetCrmCampaigns(this._repository);
  final AdminCrmRepository _repository;

  Future<Result<List<CrmCampaignItem>>> call() => _repository.fetchCampaigns();
}

class PreviewCrmCampaignTarget {
  const PreviewCrmCampaignTarget(this._repository);
  final AdminCrmRepository _repository;

  Future<Result<int>> call({
    required CrmCampaignSegment segment,
    int? inactiveDays,
  }) {
    return _repository.previewCampaignTargetCount(
      segment: segment,
      inactiveDays: inactiveDays,
    );
  }
}

class SaveCrmCampaign {
  const SaveCrmCampaign(this._repository);
  final AdminCrmRepository _repository;

  Future<Result<CrmCampaignItem>> call({
    required CrmCampaignDraft draft,
    int? existingId,
  }) {
    return _repository.saveCampaign(draft: draft, existingId: existingId);
  }
}

class DeleteCrmCampaign {
  const DeleteCrmCampaign(this._repository);
  final AdminCrmRepository _repository;

  Future<Result<void>> call({required int id}) =>
      _repository.deleteCampaign(id: id);
}
