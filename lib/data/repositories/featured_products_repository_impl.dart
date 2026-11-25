import 'dart:convert';

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/storefront_entity.dart';
import '../../domain/repositories/featured_products_repository.dart';
import '../datasources/interfaces/featured_products_datasource.dart';
import '../models/api_envelope_model.dart';
import '../models/storefront/storefront_models.dart';

/// Repository yang memuat konfigurasi CMS dan katalog secara paralel.
class FeaturedProductsRepositoryImpl implements FeaturedProductsRepository {
  const FeaturedProductsRepositoryImpl(
    this._dataSource, {
    this.apiOrigin = '',
  });

  final FeaturedProductsDataSource _dataSource;
  final String apiOrigin;

  @override
  Future<Result<List<CatalogProduct>>> fetchFeaturedProducts() {
    return _guard(() async {
      final List<Map<String, Object?>> responses =
          await Future.wait<Map<String, Object?>>(<Future<Map<String, Object?>>>[
        _dataSource.fetchRawFeaturedContent(),
        _dataSource.fetchRawCatalog(),
      ]);
      final Object? content =
          _unwrap(responses[0], 'Gagal memuat konfigurasi Produk Unggulan.');
      final Object? catalog = _unwrap(responses[1], 'Gagal memuat menu.');
      final List<int> featuredIds = _parseFeaturedIds(content);
      final List<Map<String, Object?>> products = _mapList(catalog);

      final Map<int, Map<String, Object?>> activeById =
          <int, Map<String, Object?>>{};
      for (final Map<String, Object?> product in products) {
        final Object? id = product['id'];
        if (product['aktif'] == true && id is num) {
          activeById.putIfAbsent(id.toInt(), () => product);
        }
      }

      return <CatalogProduct>[
        for (final int id in featuredIds)
          if (activeById[id] case final Map<String, Object?> product)
            CatalogProductModel.fromJson(
              product,
              origin: apiOrigin,
              allowBlobFallback: false,
            ).entity,
      ];
    }, 'Gagal memuat Produk Unggulan.');
  }

  Object? _unwrap(Map<String, Object?> raw, String failureMessage) {
    final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
    if (!envelope.success) {
      throw EnvelopeFailure(message: envelope.message ?? failureMessage);
    }
    return envelope.data;
  }

  List<int> _parseFeaturedIds(Object? content) {
    if (content == null) return const <int>[];
    if (content is! Map) {
      throw const FormatException('Konten Produk Unggulan tidak valid.');
    }
    final Object? rawContent = content['konten'];
    if (rawContent == null || (rawContent is String && rawContent.trim().isEmpty)) {
      return const <int>[];
    }
    if (rawContent is! String) {
      throw const FormatException('Field `konten` Produk Unggulan tidak valid.');
    }
    final Object? decoded = jsonDecode(rawContent);
    if (decoded is! List) {
      throw const FormatException('Konten Produk Unggulan bukan daftar.');
    }
    return decoded.map((Object? value) {
      if (value is! int) {
        throw const FormatException('ID Produk Unggulan tidak valid.');
      }
      return value;
    }).toList(growable: false);
  }

  List<Map<String, Object?>> _mapList(Object? data) {
    if (data is! List) {
      throw const FormatException('Data katalog bukan daftar.');
    }
    return data.whereType<Map>().map((Map item) {
      return <String, Object?>{
        for (final MapEntry<Object?, Object?> entry in item.entries)
          entry.key.toString(): entry.value,
      };
    }).toList(growable: false);
  }

  Future<Result<T>> _guard<T>(
    Future<T> Function() run,
    String fallbackMessage,
  ) async {
    try {
      return Result<T>.success(await run());
    } on AppFailure catch (failure) {
      return Result<T>.failure(failure);
    } on FormatException {
      return Result<T>.failure(const ParsingFailure());
    } catch (_) {
      return Result<T>.failure(ServerFailure(message: fallbackMessage));
    }
  }
}
