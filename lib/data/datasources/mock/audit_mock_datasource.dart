// lib/data/datasources/mock/audit_mock_datasource.dart
//
// Sumber data mock log audit (Phase A).
//
// Menghasilkan map envelope dengan bentuk yang sama persis dengan kontrak
// `GET /api/v1/audit-log` supaya jalur parsing dan pemetaan Phase B (REST)
// dapat memakai implementasi repository yang sama tanpa perubahan.

import '../../../domain/entities/audit_log_entity.dart';
import '../interfaces/audit_datasource.dart';

/// Mock datasource audit: menghasilkan log contoh Buku Dapur.
class AuditMockDataSource implements AuditDataSource {
  AuditMockDataSource({DateTime Function()? now, this.perPage = 12})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// Ukuran halaman mock.
  final int perPage;

  List<Map<String, Object?>>? _cache;

  @override
  Future<Map<String, Object?>> fetchRawAuditLogs({
    required AuditLogQuery query,
  }) async {
    final DateTime current = _now();
    final List<Map<String, Object?>> all = _entries(current);

    // Meniru perilaku server: filter rentang (dihitung per tanggal,
    // bukan jam) lalu paginasi. Rentang kustom dari kartu tanggal
    // mengalahkan preset `days`.
    final DateTime? startDate = query.startDate;
    final DateTime? endDate = query.endDate;
    final int? days = query.days;
    final List<Map<String, Object?>> filtered;
    if (startDate != null && endDate != null) {
      final DateTime start =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);
      filtered = all.where((Map<String, Object?> entry) {
        final DateTime waktu =
            DateTime.parse(entry['waktu']! as String).toLocal();
        final DateTime day = DateTime(waktu.year, waktu.month, waktu.day);
        return !day.isBefore(start) && !day.isAfter(end);
      }).toList();
    } else if (days == null) {
      filtered = all;
    } else {
      final DateTime midnight =
          DateTime(current.year, current.month, current.day);
      final DateTime cutoff = midnight.subtract(Duration(days: days));
      filtered = all
          .where(
            (Map<String, Object?> entry) =>
                DateTime.parse(
                  entry['waktu']! as String,
                ).toLocal().isAfter(cutoff) ||
                DateTime.parse(entry['waktu']! as String)
                    .toLocal()
                    .isAtSameMomentAs(cutoff),
          )
          .toList();
    }

    final int page = query.page < 1 ? 1 : query.page;
    final int start = (page - 1) * perPage;
    final int end = start + perPage;
    final bool hasNext = end < filtered.length;
    final List<Map<String, Object?>> slice = filtered.sublist(
      start.clamp(0, filtered.length),
      end.clamp(0, filtered.length),
    );

    return <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'logs': slice,
        'pagination': <String, Object?>{
          'page': page,
          'per_page': perPage,
          'total': filtered.length,
          'total_pages': (filtered.length / perPage).ceil(),
          'has_next': hasNext,
        },
      },
    };
  }

  /// Seluruh log contoh, terurut terbaru lebih dulu.
  List<Map<String, Object?>> _entries(DateTime now) {
    final List<Map<String, Object?>>? cached = _cache;
    if (cached != null) {
      return cached;
    }

    final List<String> users = <String>['Rina', 'Dimas'];
    final List<String> actions = <String>['tambah', 'ubah', 'hapus'];
    final List<String> types = <String>[
      'transaksi',
      'produk',
      'tabel_bebas',
      'jenis_transaksi',
      'pembayaran',
    ];
    final List<String> transaksiNames = <String>[
      'Penjualan Sosis Solo #1023',
      'Penjualan Es Teh #1024',
      'Pembelian Ayam Segar',
      'Penjualan Nasi Kotak #1025',
      'Pembelian Minyak Goreng 2L',
      'Biaya Listrik Nov',
      'Penjualan Risol Mayo #1026',
    ];
    final List<String> produkNames = <String>[
      'Sosis Solo',
      'Es Teh Manis',
      'Risol Mayo',
      'Nasi Kotak Bungkus',
    ];
    final List<String> details = <String>[
      'Jumlah 2 porsi, total Rp 36.000.',
      'Stok dikoreksi dari 12 menjadi 10 pcs.',
      'Harga jual diubah Rp 18.000 menjadi Rp 20.000.',
      'Status pembayaran dilunasi via QRIS.',
      'Kolom catatan kustom diperbarui.',
      'Entri dibatalkan karena salah input.',
    ];

    // Pola deterministik: 0–2 log per hari, mundur 120 hari, sehingga hasil
    // mock stabil untuk filter 7/30/90 hari maupun semua waktu.
    final List<Map<String, Object?>> entries = <Map<String, Object?>>[];
    for (int dayBack = 0; dayBack <= 120; dayBack++) {
      final DateTime day = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: dayBack),
      );
      final int count = ((dayBack * 13 + 5) % 3) + 1; // 1..3 log per hari.
      for (int i = 0; i < count; i++) {
        final int seed = dayBack * 8 + i * 3;
        final String aksi = actions[seed % actions.length];
        final String type = types[seed % types.length];
        final DateTime waktu = day.add(
          Duration(hours: 8 + (seed * 2) % 12, minutes: (seed * 17) % 60),
        );
        // Waktu tidak boleh melebihi "sekarang".
        final DateTime safeTime = waktu.isAfter(now) ? now : waktu;
        final String recordNama = type == 'transaksi'
            ? transaksiNames[seed % transaksiNames.length]
            : type == 'produk'
                ? produkNames[seed % produkNames.length]
                : type == 'tabel_bebas'
                    ? 'Tabel Keuangan — kolom "Biaya Bahan"'
                    : type == 'jenis_transaksi'
                        ? 'Jenis: Pemasukan Operasional'
                        : 'Pembayaran QRIS #2043';
        entries.add(<String, Object?>{
          'id': 'log-${safeTime.millisecondsSinceEpoch}-$i',
          'waktu': safeTime.toUtc().toIso8601String(),
          'aksi': aksi,
          'record_type': type,
          'record_nama': recordNama,
          'detail': details[(seed + 2) % details.length],
          'pengguna': users[seed % users.length],
        });
      }
    }

    // Log tua (audit bersifat permanen) agar opsi "Semua Waktu" tetap berisi.
    final DateTime old = DateTime(now.year, now.month, now.day).subtract(
      const Duration(days: 180),
    );
    entries.add(<String, Object?>{
      'id': 'log-seed-old-1',
      'waktu': old.toUtc().toIso8601String(),
      'aksi': 'tambah',
      'record_type': 'jenis_transaksi',
      'record_nama': 'Jenis: Pemasukan Operasional',
      'detail': 'Jenis transaksi pertama dibuat dari web.',
      'pengguna': 'Rina',
    });

    entries.sort(
      (Map<String, Object?> a, Map<String, Object?> b) =>
          DateTime.parse(b['waktu']! as String)
              .compareTo(DateTime.parse(a['waktu']! as String)),
    );
    _cache = entries;
    return entries;
  }
}
