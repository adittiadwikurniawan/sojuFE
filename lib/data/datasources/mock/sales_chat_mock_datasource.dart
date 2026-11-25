// lib/data/datasources/mock/sales_chat_mock_datasource.dart
//
// Mock datasource prototype chat penjualan harian/shift.
//
// Semua isi adalah data contoh lokal. Tidak ada HTTP, tidak ada penulisan
// transaksi, dan tidak ada klaim bahwa backend AI sudah tersedia.

import '../../../domain/entities/sales_chat_entity.dart';
import '../../models/sales_chat/sales_chat_draft_model.dart';
import '../interfaces/sales_chat_datasource.dart';

/// Mock sumber data draft penjualan.
class SalesChatMockDataSource implements SalesChatDataSource {
  const SalesChatMockDataSource();

  /// Teks contoh yang cocok dengan fixture utama.
  static const String sampleInput =
      'Input hasil penjualan shift siang: Bento Ayam Bakar 30 porsi total '
      '1.050.000, Sosis Keju 15 porsi 225.000, Es Teh Manis 20 gelas '
      '100.000. Pembayaran via QRIS dan Cash.';

  /// Teks contoh yang sengaja tidak memuat metode pembayaran dan shift.
  static const String incompleteSampleInput =
      'Input hasil penjualan shift siang tanpa pembayaran: Bento Ayam Bakar '
      '30 porsi total 1.050.000, Sosis Keju 15 porsi 225.000, Es Teh Manis '
      '20 gelas 100.000.';

  static const Map<String, Object?> _sampleJson = <String, Object?>{
    'id': 'draft-demo-penjualan-1',
    'tanggal': '2026-11-19',
    'shift': 'Siang',
    'total': 1375000,
    'items': <Object?>[
      <String, Object?>{
        'nama': 'Bento Ayam Bakar',
        'jumlah': 30,
        'satuan': 'porsi',
        'harga_satuan': 35000,
        'metode': 'QRIS',
      },
      <String, Object?>{
        'nama': 'Sosis Keju',
        'jumlah': 15,
        'satuan': 'porsi',
        'harga_satuan': 15000,
        'metode': 'QRIS',
      },
      <String, Object?>{
        'nama': 'Es Teh Manis',
        'jumlah': 20,
        'satuan': 'gelas',
        'harga_satuan': 5000,
        'metode': 'CASH',
      },
    ],
    'payments': <Object?>[
      <String, Object?>{'metode': 'QRIS', 'nominal': 1275000},
      <String, Object?>{'metode': 'CASH', 'nominal': 100000},
    ],
    'catatan': 'Data contoh rekap shift siang — draft belum disimpan.',
  };

  static const Map<String, Object?> _incompleteJson = <String, Object?>{
    'id': 'draft-demo-penjualan-2',
    'tanggal': '2026-11-19',
    'shift': null,
    'total': 1375000,
    'items': <Object?>[
      <String, Object?>{
        'nama': 'Bento Ayam Bakar',
        'jumlah': 30,
        'satuan': 'porsi',
        'harga_satuan': 35000,
        'metode': 'QRIS',
      },
      <String, Object?>{
        'nama': 'Sosis Keju',
        'jumlah': 15,
        'satuan': 'porsi',
        'harga_satuan': 15000,
        'metode': 'QRIS',
      },
      <String, Object?>{
        'nama': 'Es Teh Manis',
        'jumlah': 20,
        'satuan': 'gelas',
        'harga_satuan': 5000,
        'metode': 'CASH',
      },
    ],
    'payments': <Object?>[],
    'catatan': 'Data contoh — shift dan metode pembayaran belum diisi.',
  };

  /// Draft contoh untuk percakapan awal.
  static final SalesChatDraft sampleDraft =
      SalesChatDraftModel.fromJson(_sampleJson).toEntity();

  /// Draft contoh yang belum lengkap, dipakai untuk menguji validasi.
  static final SalesChatDraft incompleteSampleDraft =
      SalesChatDraftModel.fromJson(_incompleteJson).toEntity();

  @override
  Future<Map<String, Object?>> parseRecapRaw(String input) async {
    // Jeda kecil agar indikator "menyusun draft" terlihat pada demo.
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final String normalized = input.toLowerCase();
    if (normalized.contains('tanpa pembayaran') ||
        normalized.contains('tanpa metode') ||
        normalized.contains('belum ada pembayaran')) {
      return <String, Object?>{'success': true, 'data': _incompleteJson};
    }
    if (normalized.contains('bento') ||
        normalized.contains('sosis') ||
        normalized.contains('contoh') ||
        normalized.contains('shift siang')) {
      return <String, Object?>{'success': true, 'data': _sampleJson};
    }

    // Mode demo tidak berpura-pura bisa membaca input bebas.
    return <String, Object?>{'success': true, 'data': null};
  }
}
