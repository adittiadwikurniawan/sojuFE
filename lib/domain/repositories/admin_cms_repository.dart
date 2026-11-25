// lib/domain/repositories/admin_cms_repository.dart
//
// Kontrak repository pengelolaan Konten CMS & Produk (`SUPER_ADMIN`).

import '../../core/common/result.dart';
import '../entities/admin_cms_entity.dart';

abstract interface class AdminCmsRepository {
  Future<Result<List<CmsContentItem>>> fetchCmsContents();

  Future<Result<CmsContentItem>> saveCmsContent({
    required CmsContentDraft draft,
    required bool isCreate,
  });

  Future<Result<void>> deleteCmsContent({required String key});

  Future<Result<List<AdminProductItem>>> fetchProducts({String? search});

  Future<Result<AdminProductItem>> createProduct({
    required AdminProductDraft draft,
  });

  Future<Result<AdminProductItem>> updateProduct({
    required int id,
    required AdminProductDraft draft,
  });

  Future<Result<void>> deleteProduct({required int id});
}
