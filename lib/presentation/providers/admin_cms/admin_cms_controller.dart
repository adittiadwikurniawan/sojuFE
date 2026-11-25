// lib/presentation/providers/admin_cms/admin_cms_controller.dart
//
// Controller manajemen Konten CMS Publik & Katalog Produk (`SUPER_ADMIN`).

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/admin_cms_entity.dart';
import '../../../domain/usecases/admin_cms_usecases.dart';

enum AdminCmsTab { content, products }

class AdminCmsState {
  const AdminCmsState({
    this.activeTab = AdminCmsTab.content,
    this.isLoading = false,
    this.isSubmitting = false,
    this.contents = const <CmsContentItem>[],
    this.products = const <AdminProductItem>[],
    this.productSearch = '',
    this.errorMessage,
  });

  final AdminCmsTab activeTab;
  final bool isLoading;
  final bool isSubmitting;
  final List<CmsContentItem> contents;
  final List<AdminProductItem> products;
  final String productSearch;
  final String? errorMessage;

  AdminCmsState copyWith({
    AdminCmsTab? activeTab,
    bool? isLoading,
    bool? isSubmitting,
    List<CmsContentItem>? contents,
    List<AdminProductItem>? products,
    String? productSearch,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminCmsState(
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      contents: contents ?? this.contents,
      products: products ?? this.products,
      productSearch: productSearch ?? this.productSearch,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AdminCmsController extends ChangeNotifier {
  AdminCmsController({
    required GetCmsContents getCmsContents,
    required SaveCmsContent saveCmsContent,
    required DeleteCmsContent deleteCmsContent,
    required GetAdminProducts getAdminProducts,
    required CreateAdminProduct createAdminProduct,
    required UpdateAdminProduct updateAdminProduct,
    required DeleteAdminProduct deleteAdminProduct,
  })  : _getCmsContents = getCmsContents,
        _saveCmsContent = saveCmsContent,
        _deleteCmsContent = deleteCmsContent,
        _getAdminProducts = getAdminProducts,
        _createAdminProduct = createAdminProduct,
        _updateAdminProduct = updateAdminProduct,
        _deleteAdminProduct = deleteAdminProduct;

  final GetCmsContents _getCmsContents;
  final SaveCmsContent _saveCmsContent;
  final DeleteCmsContent _deleteCmsContent;
  final GetAdminProducts _getAdminProducts;
  final CreateAdminProduct _createAdminProduct;
  final UpdateAdminProduct _updateAdminProduct;
  final DeleteAdminProduct _deleteAdminProduct;

  AdminCmsState _state = const AdminCmsState(isLoading: true);
  AdminCmsState get state => _state;

  void selectTab(AdminCmsTab tab) {
    if (_state.activeTab == tab) return;
    _state = _state.copyWith(activeTab: tab, clearError: true);
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  Future<void> loadAll({String? productSearch}) async {
    final String search = productSearch ?? _state.productSearch;
    _state = _state.copyWith(
      isLoading: true,
      productSearch: search,
      clearError: true,
    );
    notifyListeners();

    final Future<Result<List<CmsContentItem>>> contentsFuture =
        _getCmsContents();
    final Future<Result<List<AdminProductItem>>> productsFuture =
        _getAdminProducts(search: search.isEmpty ? null : search);

    final Result<List<CmsContentItem>> contentsResult = await contentsFuture;
    final Result<List<AdminProductItem>> productsResult = await productsFuture;

    String? errorMsg;
    List<CmsContentItem> nextContents = _state.contents;
    List<AdminProductItem> nextProducts = _state.products;

    contentsResult.fold(
      onFailure: (AppFailure f) => errorMsg = f.message,
      onSuccess: (List<CmsContentItem> items) => nextContents = items,
    );
    productsResult.fold(
      onFailure: (AppFailure f) => errorMsg ??= f.message,
      onSuccess: (List<AdminProductItem> items) => nextProducts = items,
    );

    _state = _state.copyWith(
      isLoading: false,
      contents: nextContents,
      products: nextProducts,
      errorMessage: errorMsg,
    );
    notifyListeners();
  }

  Future<bool> saveContent({
    required CmsContentDraft draft,
    required bool isCreate,
  }) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    final Result<CmsContentItem> res = await _saveCmsContent(
      draft: draft,
      isCreate: isCreate,
    );

    bool ok = false;
    res.fold(
      onFailure: (AppFailure f) {
        _state = _state.copyWith(isSubmitting: false, errorMessage: f.message);
      },
      onSuccess: (CmsContentItem saved) {
        ok = true;
        final List<CmsContentItem> updated = List<CmsContentItem>.of(
          _state.contents,
        );
        final int idx = updated.indexWhere(
          (CmsContentItem c) => c.key == saved.key,
        );
        if (idx >= 0) {
          updated[idx] = saved;
        } else {
          updated.add(saved);
        }
        _state = _state.copyWith(isSubmitting: false, contents: updated);
      },
    );
    notifyListeners();
    return ok;
  }

  Future<bool> deleteContent(String key) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    final Result<void> res = await _deleteCmsContent(key: key);
    bool ok = false;
    res.fold(
      onFailure: (AppFailure f) {
        _state = _state.copyWith(isSubmitting: false, errorMessage: f.message);
      },
      onSuccess: (_) {
        ok = true;
        _state = _state.copyWith(
          isSubmitting: false,
          contents: _state.contents
              .where((CmsContentItem c) => c.key != key)
              .toList(growable: false),
        );
      },
    );
    notifyListeners();
    return ok;
  }

  Future<bool> saveProduct({
    required AdminProductDraft draft,
    int? existingId,
  }) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    final Result<AdminProductItem> res = existingId == null
        ? await _createAdminProduct(draft: draft)
        : await _updateAdminProduct(id: existingId, draft: draft);

    bool ok = false;
    res.fold(
      onFailure: (AppFailure f) {
        _state = _state.copyWith(isSubmitting: false, errorMessage: f.message);
      },
      onSuccess: (AdminProductItem saved) {
        ok = true;
        final List<AdminProductItem> updated = List<AdminProductItem>.of(
          _state.products,
        );
        final int idx = updated.indexWhere(
          (AdminProductItem p) => p.id == saved.id,
        );
        if (idx >= 0) {
          updated[idx] = saved;
        } else {
          updated.insert(0, saved);
        }
        _state = _state.copyWith(isSubmitting: false, products: updated);
      },
    );
    notifyListeners();
    return ok;
  }

  Future<bool> deactivateProduct(int id) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    final Result<void> res = await _deleteAdminProduct(id: id);
    bool ok = false;
    res.fold(
      onFailure: (AppFailure f) {
        _state = _state.copyWith(isSubmitting: false, errorMessage: f.message);
      },
      onSuccess: (_) {
        ok = true;
        _state = _state.copyWith(
          isSubmitting: false,
          products: _state.products
              .map(
                (AdminProductItem p) => p.id == id
                    ? AdminProductItem(
                        id: p.id,
                        code: p.code,
                        name: p.name,
                        variant: p.variant,
                        unit: p.unit,
                        price: p.price,
                        description: p.description,
                        imageUrl: p.imageUrl,
                        isActive: false,
                      )
                    : p,
              )
              .toList(growable: false),
        );
      },
    );
    notifyListeners();
    return ok;
  }
}
