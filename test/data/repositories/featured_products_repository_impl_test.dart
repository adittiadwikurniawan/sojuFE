import 'package:flutter_test/flutter_test.dart';
import 'package:soju_fe/data/datasources/interfaces/featured_products_datasource.dart';
import 'package:soju_fe/data/repositories/featured_products_repository_impl.dart';

class _FakeFeaturedProductsDataSource implements FeaturedProductsDataSource {
  final List<String> startedRequests = <String>[];
  Map<String, Object?> featuredContent = <String, Object?>{
    'success': true,
    'data': <String, Object?>{'konten': '[3,1,2]'},
  };
  Map<String, Object?> catalog = <String, Object?>{
    'success': true,
    'data': <Map<String, Object?>>[
      <String, Object?>{
        'id': 1,
        'namaBarang': 'Menu Satu',
        'varian': 'Dingin',
        'hargaDefault': '1234567',
        'gambar': '/api/public/products/1/image',
        'aktif': true,
      },
      <String, Object?>{
        'id': 2,
        'namaBarang': 'Menu Nonaktif',
        'aktif': false,
      },
      <String, Object?>{
        'id': 3,
        'namaBarang': 'Menu Tiga',
        'varian': 'Original',
        'hargaDefault': 30000,
        'aktif': true,
      },
      <String, Object?>{'id': 4, 'namaBarang': 'Tidak Dipilih', 'aktif': true},
    ],
  };

  @override
  Future<Map<String, Object?>> fetchRawFeaturedContent() async {
    startedRequests.add('featured');
    await Future<void>.delayed(Duration.zero);
    return featuredContent;
  }

  @override
  Future<Map<String, Object?>> fetchRawCatalog({String? search}) async {
    startedRequests.add('catalog');
    await Future<void>.delayed(Duration.zero);
    return catalog;
  }

  @override
  Future<Map<String, Object?>> fetchRawCart() async => <String, Object?>{};

  @override
  Future<Map<String, Object?>> saveRawCart(
    List<Map<String, Object?>> items,
  ) async =>
      <String, Object?>{};
}

void main() {
  test('fetches both endpoints in parallel and filters in CMS order', () async {
    final _FakeFeaturedProductsDataSource dataSource =
        _FakeFeaturedProductsDataSource();
    final FeaturedProductsRepositoryImpl repository =
        FeaturedProductsRepositoryImpl(
      dataSource,
      apiOrigin: 'http://localhost:4000',
    );

    final result = await repository.fetchFeaturedProducts();

    expect(dataSource.startedRequests, <String>['featured', 'catalog']);
    expect(
      result.valueOrNull?.map((product) => product.id),
      <int>[3, 1],
    );
    expect(result.valueOrNull?.first.name, 'Menu Tiga');
    expect(result.valueOrNull?.last.imageUrl,
        'http://localhost:4000/api/public/products/1/image');
    expect(result.valueOrNull?.last.price, 1234567);
  });

  test('empty or null CMS content produces an empty product list', () async {
    final _FakeFeaturedProductsDataSource dataSource =
        _FakeFeaturedProductsDataSource()
          ..featuredContent = <String, Object?>{
            'success': true,
            'data': <String, Object?>{'konten': null},
          };
    final FeaturedProductsRepositoryImpl repository =
        FeaturedProductsRepositoryImpl(dataSource);

    final result = await repository.fetchFeaturedProducts();

    expect(result.valueOrNull, isEmpty);
  });

  test('does not request a fallback image when the featured product has none',
      () async {
    final _FakeFeaturedProductsDataSource dataSource =
        _FakeFeaturedProductsDataSource()
          ..featuredContent = <String, Object?>{
            'success': true,
            'data': <String, Object?>{'konten': '[4]'},
          };
    final FeaturedProductsRepositoryImpl repository =
        FeaturedProductsRepositoryImpl(
      dataSource,
      apiOrigin: 'http://localhost:4000',
    );

    final result = await repository.fetchFeaturedProducts();

    expect(result.valueOrNull?.single.imageUrl, isNull);
  });
}
