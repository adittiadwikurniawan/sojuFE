// lib/data/datasources/interfaces/admin_crm_datasource.dart
//
// Kontrak datasource Pelanggan & Kampanye CRM (`SUPER_ADMIN`).

import '../../../domain/entities/admin_crm_entity.dart';

abstract interface class AdminCrmDataSource {
  Future<Map<String, Object?>> fetchCustomerSummaryRaw();

  Future<Map<String, Object?>> fetchCustomersRaw({
    String? query,
    String status = 'semua',
  });

  Future<Map<String, Object?>> updateCustomerStatusRaw({
    required int id,
    required bool isActive,
  });

  Future<Map<String, Object?>> fetchCampaignsRaw();

  Future<Map<String, Object?>> previewCampaignRaw({
    required CrmCampaignSegment segment,
    int? inactiveDays,
  });

  Future<Map<String, Object?>> saveCampaignRaw({
    required CrmCampaignDraft draft,
    int? existingId,
  });

  Future<Map<String, Object?>> deleteCampaignRaw({required int id});
}
