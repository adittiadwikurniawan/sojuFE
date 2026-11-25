// lib/data/datasources/mock/admin_cms_mock_datasource.dart
//
// Mock datasource Konten CMS & Produk untuk pengujian terisolasi tanpa server.

import '../../../domain/entities/admin_cms_entity.dart';
import '../interfaces/admin_cms_datasource.dart';

class AdminCmsMockDataSource implements AdminCmsDataSource {
  final List<Map<String, Object?>> _contents = <Map<String, Object?>>[
    <String, Object?>{
      'id': 1,
      'key': 'headline_beranda',
      'judul': 'Selamat Datang di Buku Dapur SOJU',
      'subJudul': 'Frozen Food & Siap Saji Terbaik',
      'konten':
          'Kami menyediakan berbagai makanan frozen food dan siap saji berkualitas tinggi.',
      'aktif': true,
    },
  ];

  final List<Map<String, Object?>> _products = <Map<String, Object?>>[
    <String, Object?>{
      'id': 1,
      'kode': 'PRD-001',
      'namaBarang': 'Sosis Solo Ayam',
      'varian': 'Original',
      'satuan': 'pack',
      'hargaDefault': 35000,
      'deskripsi': 'Sosis solo isi ayam gurih siap goreng.',
      'aktif': true,
    },
  ];

  int _nextContentId = 2;
  int _nextProductId = 2;

  @override
  Future<Map<String, Object?>> fetchCmsContentsRaw() async {
    return <String, Object?>{
      'success': true,
      'data': List<Map<String, Object?>>.of(_contents),
    };
  }

  @override
  Future<Map<String, Object?>> saveCmsContentRaw({
    required CmsContentDraft draft,
    required bool isCreate,
  }) async {
    final int idx = _contents.indexWhere(
      (Map<String, Object?> e) => e['key'] == draft.key,
    );
    final Map<String, Object?> item = <String, Object?>{
      'id': idx >= 0 ? _contents[idx]['id'] : _nextContentId++,
      'key': draft.key,
      'judul': draft.title,
      'subJudul': draft.subtitle,
      'konten': draft.content,
      'aktif': draft.isActive,
    };
    if (idx >= 0) {
      _contents[idx] = item;
    } else {
      _contents.add(item);
    }
    return <String, Object?>{'success': true, 'data': item};
  }

  @override
  Future<Map<String, Object?>> deleteCmsContentRaw({required String key}) async {
    _contents.removeWhere((Map<String, Object?> e) => e['key'] == key);
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{'message': 'Konten dihapus'},
    };
  }

  @override
  Future<Map<String, Object?>> fetchProductsRaw({String? search}) async {
    final String q = (search ?? '').trim().toLowerCase();
    final List<Map<String, Object?>> filtered = q.isEmpty
        ? List<Map<String, Object?>>.of(_products)
        : _products
            .where((Map<String, Object?> p) {
              final String name =
                  (p['namaBarang']?.toString() ?? '').toLowerCase();
              final String code = (p['kode']?.toString() ?? '').toLowerCase();
              return name.contains(q) || code.contains(q);
            })
            .toList(growable: false);
    return <String, Object?>{'success': true, 'data': filtered};
  }

  @override
  Future<Map<String, Object?>> createProductRaw({
    required AdminProductDraft draft,
  }) async {
    final Map<String, Object?> created = <String, Object?>{
      'id': _nextProductId++,
      'kode': draft.code,
      'namaBarang': draft.name,
      'varian': draft.variant,
      'satuan': draft.unit,
      'hargaDefault': draft.price,
      'deskripsi': draft.description,
      'gambarUrl': draft.imageUrl,
      'aktif': draft.isActive,
    };
    _products.insert(0, created);
    return <String, Object?>{'success': true, 'data': created};
  }

  @override
  Future<Map<String, Object?>> updateProductRaw({
    required int id,
    required AdminProductDraft draft,
  }) async {
    final int idx =
        _products.indexWhere((Map<String, Object?> p) => p['id'] == id);
    final Map<String, Object?> updated = <String, Object?>{
      'id': id,
      'kode': draft.code,
      'namaBarang': draft.name,
      'varian': draft.variant,
      'satuan': draft.unit,
      'hargaDefault': draft.price,
      'deskripsi': draft.description,
      'gambarUrl': draft.imageUrl,
      'aktif': draft.isActive,
    };
    if (idx >= 0) {
      _products[idx] = updated;
    } else {
      _products.insert(0, updated);
    }
    return <String, Object?>{'success': true, 'data': updated};
  }

  @override
  Future<Map<String, Object?>> deleteProductRaw({required int id}) async {
    final int idx =
        _products.indexWhere((Map<String, Object?> p) => p['id'] == id);
    if (idx >= 0) {
      _products[idx] = <String, Object?>{
        ..._products[idx],
        'aktif': false,
      };
    }
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{'message': 'Produk dinonaktifkan'},
    };
  }
}
