// lib/domain/usecases/admin_cms_usecases.dart
//
// Usecase pengelolaan Konten CMS & Katalog Produk (`SUPER_ADMIN`).

import '../../core/common/result.dart';
import '../entities/admin_cms_entity.dart';
import '../repositories/admin_cms_repository.dart';

class GetCmsContents {
  const GetCmsContents(this._repository);
  final AdminCmsRepository _repository;

  Future<Result<List<CmsContentItem>>> call() => _repository.fetchCmsContents();
}

class SaveCmsContent {
  const SaveCmsContent(this._repository);
  final AdminCmsRepository _repository;

  Future<Result<CmsContentItem>> call({
    required CmsContentDraft draft,
    required bool isCreate,
  }) {
    return _repository.saveCmsContent(draft: draft, isCreate: isCreate);
  }
}

class DeleteCmsContent {
  const DeleteCmsContent(this._repository);
  final AdminCmsRepository _repository;

  Future<Result<void>> call({required String key}) =>
      _repository.deleteCmsContent(key: key);
}

class GetAdminProducts {
  const GetAdminProducts(this._repository);
  final AdminCmsRepository _repository;

  Future<Result<List<AdminProductItem>>> call({String? search}) =>
      _repository.fetchProducts(search: search);
}

class CreateAdminProduct {
  const CreateAdminProduct(this._repository);
  final AdminCmsRepository _repository;

  Future<Result<AdminProductItem>> call({required AdminProductDraft draft}) =>
      _repository.createProduct(draft: draft);
}

class UpdateAdminProduct {
  const UpdateAdminProduct(this._repository);
  final AdminCmsRepository _repository;

  Future<Result<AdminProductItem>> call({
    required int id,
    required AdminProductDraft draft,
  }) {
    return _repository.updateProduct(id: id, draft: draft);
  }
}

class DeleteAdminProduct {
  const DeleteAdminProduct(this._repository);
  final AdminCmsRepository _repository;

  Future<Result<void>> call({required int id}) =>
      _repository.deleteProduct(id: id);
}
