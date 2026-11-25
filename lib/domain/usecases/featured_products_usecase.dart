import '../../core/common/result.dart';
import '../entities/storefront_entity.dart';
import '../repositories/featured_products_repository.dart';

/// Memuat produk aktif yang dipilih pada konten CMS `produk_unggulan`.
class GetFeaturedProducts {
  const GetFeaturedProducts(this._repository);

  final FeaturedProductsRepository _repository;

  Future<Result<List<CatalogProduct>>> call() =>
      _repository.fetchFeaturedProducts();
}
