// lib/data/repositories/admin_crm_repository_impl.dart
//
// Implementasi AdminCrmRepository.

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/admin_crm_entity.dart';
import '../../domain/repositories/admin_crm_repository.dart';
import '../datasources/interfaces/admin_crm_datasource.dart';
import '../models/api_envelope_model.dart';

int _asInt(Object? v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

bool _asBool(Object? v, [bool fallback = false]) {
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  return fallback;
}

String? _asOptString(Object? v) {
  if (v == null) return null;
  final String s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class AdminCrmRepositoryImpl implements AdminCrmRepository {
  const AdminCrmRepositoryImpl(this._dataSource);

  final AdminCrmDataSource _dataSource;

  AdminCustomerItem _parseCustomer(Map<Object?, Object?> m) {
    final Object? countObj = m['_count'];
    final int orderCount =
        countObj is Map ? _asInt(countObj['pesanan']) : _asInt(m['orderCount']);
    return AdminCustomerItem(
      id: _asInt(m['id']),
      name: m['nama']?.toString() ?? m['name']?.toString() ?? '',
      email: m['email']?.toString() ?? '',
      phone: _asOptString(m['noTelepon'] ?? m['no_telepon']),
      isActive: _asBool(m['aktif'], true),
      promoOptIn: _asBool(m['promosiDiizinkan']),
      orderCount: orderCount,
    );
  }

  CrmCampaignItem _parseCampaign(Map<Object?, Object?> m) {
    final Object? userObj = m['pengguna'];
    final String? authorName =
        userObj is Map ? _asOptString(userObj['nama']) : null;
    final Object? rawDays = m['hariTidakMemesan'];
    return CrmCampaignItem(
      id: _asInt(m['id']),
      title: m['judul']?.toString() ?? '',
      subject: m['subjek']?.toString() ?? '',
      body: m['isi']?.toString() ?? '',
      segment: CrmCampaignSegment.fromApi(m['segmen']),
      inactiveDays: rawDays == null ? null : _asInt(rawDays),
      authorName: authorName,
    );
  }

  @override
  Future<Result<AdminCustomerSummary>> fetchCustomerSummary() async {
    try {
      final Map<String, Object?> raw =
          await _dataSource.fetchCustomerSummaryRaw();
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data is! Map) {
        return Result.failure(
          EnvelopeFailure(
            message: env.message ?? 'Respon ringkasan pelanggan tidak valid.',
          ),
        );
      }
      final Map<Object?, Object?> d = env.data as Map<Object?, Object?>;
      return Result.success(
        AdminCustomerSummary(
          total: _asInt(d['total']),
          active: _asInt(d['aktif']),
          inactive: _asInt(d['nonaktif']),
          promoOptIn: _asInt(d['promosiDiizinkan']),
        ),
      );
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<AdminCustomerItem>>> fetchCustomers({
    String? query,
    String status = 'semua',
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.fetchCustomersRaw(
        query: query,
        status: status,
      );
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data == null) {
        return Result.failure(
          EnvelopeFailure(
            message: env.message ?? 'Respon pelanggan tidak valid.',
          ),
        );
      }
      final Object? content = env.data;
      final List<Object?> list = content is Map && content['customers'] is List
          ? content['customers'] as List<Object?>
          : content is List
              ? content
              : const <Object?>[];
      return Result.success(
        list
            .whereType<Map<Object?, Object?>>()
            .map(_parseCustomer)
            .toList(growable: false),
      );
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AdminCustomerItem>> updateCustomerStatus({
    required int id,
    required bool isActive,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.updateCustomerStatusRaw(
        id: id,
        isActive: isActive,
      );
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data is! Map) {
        return Result.failure(
          EnvelopeFailure(
            message: env.message ?? 'Gagal memperbarui status pelanggan.',
          ),
        );
      }
      return Result.success(_parseCustomer(env.data as Map<Object?, Object?>));
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<CrmCampaignItem>>> fetchCampaigns() async {
    try {
      final Map<String, Object?> raw = await _dataSource.fetchCampaignsRaw();
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data is! List) {
        return Result.failure(
          EnvelopeFailure(
            message: env.message ?? 'Respon kampanye CRM tidak valid.',
          ),
        );
      }
      return Result.success(
        (env.data as List<Object?>)
            .whereType<Map<Object?, Object?>>()
            .map(_parseCampaign)
            .toList(growable: false),
      );
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<int>> previewCampaignTargetCount({
    required CrmCampaignSegment segment,
    int? inactiveDays,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.previewCampaignRaw(
        segment: segment,
        inactiveDays: inactiveDays,
      );
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data is! Map) {
        return Result.failure(
          EnvelopeFailure(message: env.message ?? 'Gagal memuat pratinjau.'),
        );
      }
      final Map<Object?, Object?> d = env.data as Map<Object?, Object?>;
      return Result.success(_asInt(d['total']));
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<CrmCampaignItem>> saveCampaign({
    required CrmCampaignDraft draft,
    int? existingId,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.saveCampaignRaw(
        draft: draft,
        existingId: existingId,
      );
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data is! Map) {
        return Result.failure(
          EnvelopeFailure(message: env.message ?? 'Gagal menyimpan kampanye.'),
        );
      }
      return Result.success(_parseCampaign(env.data as Map<Object?, Object?>));
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> deleteCampaign({required int id}) async {
    try {
      final Map<String, Object?> raw =
          await _dataSource.deleteCampaignRaw(id: id);
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success) {
        return Result.failure(
          EnvelopeFailure(message: env.message ?? 'Gagal menghapus kampanye.'),
        );
      }
      return Result.success(null);
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
