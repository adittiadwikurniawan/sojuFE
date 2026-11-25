// lib/domain/repositories/admin_crm_repository.dart
//
// Kontrak repository Pelanggan & Kampanye CRM (`SUPER_ADMIN`).

import '../../core/common/result.dart';
import '../entities/admin_crm_entity.dart';

abstract interface class AdminCrmRepository {
  Future<Result<AdminCustomerSummary>> fetchCustomerSummary();

  Future<Result<List<AdminCustomerItem>>> fetchCustomers({
    String? query,
    String status = 'semua',
  });

  Future<Result<AdminCustomerItem>> updateCustomerStatus({
    required int id,
    required bool isActive,
  });

  Future<Result<List<CrmCampaignItem>>> fetchCampaigns();

  Future<Result<int>> previewCampaignTargetCount({
    required CrmCampaignSegment segment,
    int? inactiveDays,
  });

  Future<Result<CrmCampaignItem>> saveCampaign({
    required CrmCampaignDraft draft,
    int? existingId,
  });

  Future<Result<void>> deleteCampaign({required int id});
}
