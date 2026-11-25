// lib/data/datasources/mock/admin_crm_mock_datasource.dart
//
// Mock datasource Pelanggan & Kampanye CRM untuk pengujian tanpa server.

import '../../../domain/entities/admin_crm_entity.dart';
import '../interfaces/admin_crm_datasource.dart';

class AdminCrmMockDataSource implements AdminCrmDataSource {
  final List<Map<String, Object?>> _customers = <Map<String, Object?>>[
    <String, Object?>{
      'id': 1,
      'nama': 'Siti Rahma',
      'email': 'siti@example.com',
      'noTelepon': '081234567890',
      'aktif': true,
      'promosiDiizinkan': true,
      '_count': <String, Object?>{'pesanan': 3},
    },
  ];

  final List<Map<String, Object?>> _campaigns = <Map<String, Object?>>[
    <String, Object?>{
      'id': 1,
      'judul': 'Promo Akhir Pekan SOJU',
      'subjek': 'Diskon Spesial Paket Frozen Food!',
      'isi': 'Nikmati potongan khusus untuk pemesanan akhir pekan ini.',
      'segmen': 'SEMUA_BERIZIN',
      'hariTidakMemesan': null,
    },
  ];

  int _nextCampaignId = 2;

  @override
  Future<Map<String, Object?>> fetchCustomerSummaryRaw() async {
    final int total = _customers.length;
    final int aktif =
        _customers.where((Map<String, Object?> c) => c['aktif'] == true).length;
    final int promo = _customers
        .where(
          (Map<String, Object?> c) =>
              c['aktif'] == true && c['promosiDiizinkan'] == true,
        )
        .length;
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'total': total,
        'aktif': aktif,
        'nonaktif': total - aktif,
        'promosiDiizinkan': promo,
      },
    };
  }

  @override
  Future<Map<String, Object?>> fetchCustomersRaw({
    String? query,
    String status = 'semua',
  }) async {
    final String q = (query ?? '').trim().toLowerCase();
    final List<Map<String, Object?>> filtered = _customers.where((
      Map<String, Object?> c,
    ) {
      if (status == 'aktif' && c['aktif'] != true) return false;
      if (status == 'nonaktif' && c['aktif'] == true) return false;
      if (q.isEmpty) return true;
      final String name = (c['nama']?.toString() ?? '').toLowerCase();
      final String email = (c['email']?.toString() ?? '').toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList(growable: false);

    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{'customers': filtered},
    };
  }

  @override
  Future<Map<String, Object?>> updateCustomerStatusRaw({
    required int id,
    required bool isActive,
  }) async {
    final int idx =
        _customers.indexWhere((Map<String, Object?> c) => c['id'] == id);
    if (idx >= 0) {
      _customers[idx] = <String, Object?>{..._customers[idx], 'aktif': isActive};
      return <String, Object?>{'success': true, 'data': _customers[idx]};
    }
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'id': id,
        'nama': 'Pelanggan',
        'email': 'pelanggan@example.com',
        'aktif': isActive,
      },
    };
  }

  @override
  Future<Map<String, Object?>> fetchCampaignsRaw() async {
    return <String, Object?>{
      'success': true,
      'data': List<Map<String, Object?>>.of(_campaigns),
    };
  }

  @override
  Future<Map<String, Object?>> previewCampaignRaw({
    required CrmCampaignSegment segment,
    int? inactiveDays,
  }) async {
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{'total': _customers.length},
    };
  }

  @override
  Future<Map<String, Object?>> saveCampaignRaw({
    required CrmCampaignDraft draft,
    int? existingId,
  }) async {
    final Map<String, Object?> item = <String, Object?>{
      'id': existingId ?? _nextCampaignId++,
      'judul': draft.title,
      'subjek': draft.subject,
      'isi': draft.body,
      'segmen': draft.segment.apiValue,
      'hariTidakMemesan': draft.inactiveDays,
    };
    if (existingId != null) {
      final int idx = _campaigns
          .indexWhere((Map<String, Object?> c) => c['id'] == existingId);
      if (idx >= 0) {
        _campaigns[idx] = item;
      } else {
        _campaigns.insert(0, item);
      }
    } else {
      _campaigns.insert(0, item);
    }
    return <String, Object?>{'success': true, 'data': item};
  }

  @override
  Future<Map<String, Object?>> deleteCampaignRaw({required int id}) async {
    _campaigns.removeWhere((Map<String, Object?> c) => c['id'] == id);
    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{'id': id},
    };
  }
}
