// lib/data/datasources/remote/admin_crm_remote_datasource.dart
//
// Remote datasource Pelanggan (`/api/v1/customers`) & Kampanye CRM (`/api/v1/customer-campaigns`).

import '../../../core/errors/app_failure.dart';
import '../../../core/services/api_client/api_client.dart';
import '../../../core/services/api_client/api_response.dart';
import '../../../domain/entities/admin_crm_entity.dart';
import '../interfaces/admin_crm_datasource.dart';

class AdminCrmRemoteDataSource implements AdminCrmDataSource {
  const AdminCrmRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, Object?>> fetchCustomerSummaryRaw() {
    return _map(_apiClient.get('/api/v1/customers/summary'));
  }

  @override
  Future<Map<String, Object?>> fetchCustomersRaw({
    String? query,
    String status = 'semua',
  }) {
    final Map<String, String> params = <String, String>{'status': status};
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    return _map(_apiClient.get('/api/v1/customers', queryParameters: params));
  }

  @override
  Future<Map<String, Object?>> updateCustomerStatusRaw({
    required int id,
    required bool isActive,
  }) {
    return _map(
      _apiClient.patch(
        '/api/v1/customers/$id/status',
        body: <String, Object?>{'aktif': isActive},
      ),
    );
  }

  @override
  Future<Map<String, Object?>> fetchCampaignsRaw() {
    return _map(_apiClient.get('/api/v1/customer-campaigns'));
  }

  @override
  Future<Map<String, Object?>> previewCampaignRaw({
    required CrmCampaignSegment segment,
    int? inactiveDays,
  }) {
    final Map<String, String> params = <String, String>{
      'segmen': segment.apiValue,
      if (segment == CrmCampaignSegment.tidakMemesanLagi &&
          inactiveDays != null)
        'hariTidakMemesan': inactiveDays.toString(),
    };
    return _map(
      _apiClient.get(
        '/api/v1/customer-campaigns/preview',
        queryParameters: params,
      ),
    );
  }

  @override
  Future<Map<String, Object?>> saveCampaignRaw({
    required CrmCampaignDraft draft,
    int? existingId,
  }) {
    final Map<String, Object?> payload = <String, Object?>{
      'judul': draft.title,
      'subjek': draft.subject,
      'isi': draft.body,
      'segmen': draft.segment.apiValue,
      if (draft.segment == CrmCampaignSegment.tidakMemesanLagi &&
          draft.inactiveDays != null)
        'hariTidakMemesan': draft.inactiveDays,
    };
    if (existingId == null) {
      return _map(_apiClient.post('/api/v1/customer-campaigns', body: payload));
    }
    return _map(
      _apiClient.put('/api/v1/customer-campaigns/$existingId', body: payload),
    );
  }

  @override
  Future<Map<String, Object?>> deleteCampaignRaw({required int id}) {
    return _map(_apiClient.delete('/api/v1/customer-campaigns/$id'));
  }

  Future<Map<String, Object?>> _map(Future<ApiResponse> request) async {
    final ApiResponse response;
    try {
      response = await request;
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure();
    }

    final Object? raw = response.body;
    final Map<String, Object?>? body = raw is Map
        ? <String, Object?>{
            for (final MapEntry<Object?, Object?> e in raw.entries)
              e.key.toString(): e.value,
          }
        : null;

    final Object? message = body?['message'];
    final String? text =
        message is String && message.trim().isNotEmpty ? message.trim() : null;

    if (response.statusCode == 401) {
      throw UnauthorizedFailure(message: text);
    }
    if (response.statusCode == 403) {
      throw ServerFailure(
        statusCode: 403,
        message: text ?? 'Akses khusus Super Admin diperlukan.',
      );
    }
    if (!response.isSuccess) {
      throw ServerFailure(statusCode: response.statusCode, message: text);
    }
    if (body == null) {
      throw const ParsingFailure();
    }

    return body;
  }
}
