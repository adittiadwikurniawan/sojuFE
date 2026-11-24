// lib/data/repositories/storefront_repository_impl.dart
//
// Repository etalase Pelanggan: parsing envelope, mapping DTO → entity,
// pemetaan kegagalan ke Result.

import '../../core/common/result.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/storefront_entity.dart';
import '../../domain/repositories/storefront_repository.dart';
import '../datasources/interfaces/storefront_datasource.dart';
import '../models/api_envelope_model.dart';
import '../models/storefront/storefront_models.dart';

/// Repository di atas [StorefrontDataSource].
class StorefrontRepositoryImpl implements StorefrontRepository {
  const StorefrontRepositoryImpl(this._dataSource, {this.apiOrigin = ''});

  final StorefrontDataSource _dataSource;

  /// Origin API untuk resolusi URL gambar relatif / BLOB.
  final String apiOrigin;

  @override
  Future<Result<List<CatalogProduct>>> fetchCatalog({String? search}) {
    return _guard(() async {
      final Object? data =
          _unwrap(await _dataSource.fetchRawCatalog(search: search));
      return _list(data)
          .map((Map<String, Object?> j) =>
              CatalogProductModel.fromJson(j, origin: apiOrigin).entity)
          .toList(growable: false);
    }, 'Gagal memuat menu.');
  }

  @override
  Future<Result<List<CartItem>>> fetchCart() {
    return _guard(() async {
      final Object? data = _unwrap(await _dataSource.fetchRawCart());
      return _list(data)
          .map((Map<String, Object?> j) =>
              CartItemModel.fromJson(j, origin: apiOrigin).entity)
          .toList(growable: false);
    }, 'Gagal memuat keranjang.');
  }

  @override
  Future<Result<int>> saveCart(List<CartItem> items) {
    return _guard(() async {
      final Object? data = _unwrap(
        await _dataSource
            .saveRawCart(items.map(CartItemModel.toPayload).toList()),
      );
      if (data is Map && data['jumlahItem'] is num) {
        return (data['jumlahItem'] as num).toInt();
      }
      return items.totalQuantity;
    }, 'Gagal menyimpan keranjang.');
  }

  Object? _unwrap(Map<String, Object?> raw) {
    final ApiEnvelopeModel envelope = ApiEnvelopeModel.fromRaw(raw);
    if (!envelope.success) {
      throw EnvelopeFailure(message: envelope.message);
    }
    return envelope.data;
  }

  List<Map<String, Object?>> _list(Object? data) {
    if (data is! List) {
      throw const FormatException('Data bukan daftar.');
    }
    return data.whereType<Map>().map((Map m) {
      return <String, Object?>{
        for (final MapEntry<Object?, Object?> e in m.entries)
          e.key.toString(): e.value,
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
