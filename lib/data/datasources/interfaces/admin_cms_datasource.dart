// lib/data/datasources/interfaces/admin_cms_datasource.dart
//
// Kontrak datasource Konten CMS & Produk Admin.

import '../../../domain/entities/admin_cms_entity.dart';

abstract interface class AdminCmsDataSource {
  Future<Map<String, Object?>> fetchCmsContentsRaw();

  Future<Map<String, Object?>> saveCmsContentRaw({
    required CmsContentDraft draft,
    required bool isCreate,
  });

  Future<Map<String, Object?>> deleteCmsContentRaw({required String key});

  Future<Map<String, Object?>> fetchProductsRaw({String? search});

  Future<Map<String, Object?>> createProductRaw({
    required AdminProductDraft draft,
  });

  Future<Map<String, Object?>> updateProductRaw({
    required int id,
    required AdminProductDraft draft,
  });

  Future<Map<String, Object?>> deleteProductRaw({required int id});
}
