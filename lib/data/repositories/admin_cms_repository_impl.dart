// lib/data/repositories/admin_cms_repository_impl.dart
//
// Implementasi AdminCmsRepository.

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/admin_cms_entity.dart';
import '../../domain/repositories/admin_cms_repository.dart';
import '../datasources/interfaces/admin_cms_datasource.dart';
import '../models/api_envelope_model.dart';

int _asInt(Object? v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

bool _asBool(Object? v, [bool fallback = true]) {
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  return fallback;
}

String? _asOptString(Object? v) {
  if (v == null) return null;
  final String s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class AdminCmsRepositoryImpl implements AdminCmsRepository {
  const AdminCmsRepositoryImpl(this._dataSource);

  final AdminCmsDataSource _dataSource;

  CmsContentItem _parseCmsItem(Map<Object?, Object?> m) {
    return CmsContentItem(
      id: _asInt(m['id']),
      key: m['key']?.toString() ?? '',
      title: m['judul']?.toString() ?? m['title']?.toString() ?? '',
      subtitle: _asOptString(m['subJudul'] ?? m['sub_judul']),
      content: _asOptString(m['konten'] ?? m['content']),
      isActive: _asBool(m['aktif']),
    );
  }

  AdminProductItem _parseProductItem(Map<Object?, Object?> m) {
    return AdminProductItem(
      id: _asInt(m['id']),
      code: m['kode']?.toString() ?? '',
      name: m['namaBarang']?.toString() ?? m['nama_barang']?.toString() ?? '',
      variant: _asOptString(m['varian']),
      unit: _asOptString(m['satuan']) ?? 'pcs',
      price: _asInt(m['hargaDefault'] ?? m['harga_default']),
      description: _asOptString(m['deskripsi']),
      imageUrl: _asOptString(m['gambarUrl'] ?? m['gambar']),
      isActive: _asBool(m['aktif']),
    );
  }

  @override
  Future<Result<List<CmsContentItem>>> fetchCmsContents() async {
    try {
      final Map<String, Object?> raw = await _dataSource.fetchCmsContentsRaw();
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data is! List) {
        return Result.failure(
          EnvelopeFailure(message: env.message ?? 'Respon CMS tidak valid.'),
        );
      }
      final List<CmsContentItem> items = (env.data as List<Object?>)
          .whereType<Map<Object?, Object?>>()
          .map(_parseCmsItem)
          .toList(growable: false);
      return Result.success(items);
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<CmsContentItem>> saveCmsContent({
    required CmsContentDraft draft,
    required bool isCreate,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.saveCmsContentRaw(
        draft: draft,
        isCreate: isCreate,
      );
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data is! Map) {
        return Result.failure(
          EnvelopeFailure(message: env.message ?? 'Gagal menyimpan konten CMS.'),
        );
      }
      return Result.success(_parseCmsItem(env.data as Map<Object?, Object?>));
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> deleteCmsContent({required String key}) async {
    try {
      final Map<String, Object?> raw =
          await _dataSource.deleteCmsContentRaw(key: key);
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success) {
        return Result.failure(
          EnvelopeFailure(message: env.message ?? 'Gagal menghapus konten CMS.'),
        );
      }
      return Result.success(null);
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<AdminProductItem>>> fetchProducts({String? search}) async {
    try {
      final Map<String, Object?> raw =
          await _dataSource.fetchProductsRaw(search: search);
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data is! List) {
        return Result.failure(
          EnvelopeFailure(message: env.message ?? 'Respon produk tidak valid.'),
        );
      }
      final List<AdminProductItem> items = (env.data as List<Object?>)
          .whereType<Map<Object?, Object?>>()
          .map(_parseProductItem)
          .toList(growable: false);
      return Result.success(items);
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AdminProductItem>> createProduct({
    required AdminProductDraft draft,
  }) async {
    try {
      final Map<String, Object?> raw =
          await _dataSource.createProductRaw(draft: draft);
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data is! Map) {
        return Result.failure(
          EnvelopeFailure(message: env.message ?? 'Gagal membuat produk.'),
        );
      }
      return Result.success(
        _parseProductItem(env.data as Map<Object?, Object?>),
      );
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AdminProductItem>> updateProduct({
    required int id,
    required AdminProductDraft draft,
  }) async {
    try {
      final Map<String, Object?> raw = await _dataSource.updateProductRaw(
        id: id,
        draft: draft,
      );
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success || env.data is! Map) {
        return Result.failure(
          EnvelopeFailure(message: env.message ?? 'Gagal memperbarui produk.'),
        );
      }
      return Result.success(
        _parseProductItem(env.data as Map<Object?, Object?>),
      );
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> deleteProduct({required int id}) async {
    try {
      final Map<String, Object?> raw =
          await _dataSource.deleteProductRaw(id: id);
      final ApiEnvelopeModel env = ApiEnvelopeModel.fromRaw(raw);
      if (!env.success) {
        return Result.failure(
          EnvelopeFailure(message: env.message ?? 'Gagal menonaktifkan produk.'),
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
