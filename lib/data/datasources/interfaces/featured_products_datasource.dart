import 'storefront_datasource.dart';

/// Data source untuk konfigurasi CMS dan katalog Produk Unggulan.
abstract interface class FeaturedProductsDataSource
    implements StorefrontDataSource {
  Future<Map<String, Object?>> fetchRawFeaturedContent();
}
