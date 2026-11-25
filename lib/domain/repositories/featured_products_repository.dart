import '../../core/common/result.dart';
import '../entities/storefront_entity.dart';

/// Repository untuk produk yang dipilih sebagai Produk Unggulan.
abstract interface class FeaturedProductsRepository {
  Future<Result<List<CatalogProduct>>> fetchFeaturedProducts();
}
