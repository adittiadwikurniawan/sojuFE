// lib/domain/entities/audit_log_entity.dart
//
// Entity domain log audit (Buku Dapur, FR-15 / MFR-7).
//
// Entity hanya memuat informasi untuk pembacaan: waktu, aksi, nama record,
// detail, dan pengguna bila tersedia. Tidak ada operasi mutasi — aplikasi
// mobile Buku Dapur bersifat baca-saja (MFR-9).

/// Kategori aksi untuk penampilan badge/ikon pada UI.
///
/// Dipetakan dari teks `aksi` mentah API sehingga aksi tidak dikenal tetap
/// tampil (fallback `other`), sesuai risiko #4 `ARCHITECTURE.md`.
enum AuditActionKind { created, updated, deleted, other }

/// Satu baris log audit.
class AuditLogEntryEntity {
  const AuditLogEntryEntity({
    required this.waktu,
    required this.aksi,
    this.id,
    this.recordTipe,
    this.recordNama,
    this.detail,
    this.pengguna,
  });

  /// Identitas log (bila dikirim API; boleh absen).
  final String? id;

  /// Waktu kejadian (ISO 8601 dari API, sudah menjadi [DateTime]).
  final DateTime waktu;

  /// Label aksi mentah dari API, mis. `tambah`, `ubah`, `hapus`.
  final String aksi;

  /// Tipe record yang berubah, mis. `transaksi`, `produk`.
  final String? recordTipe;

  /// Nama record yang berubah (jika tersedia).
  final String? recordNama;

  /// Rincian perubahan (jika tersedia).
  final String? detail;

  /// Nama pengguna pelaku perubahan (jika tersedia).
  final String? pengguna;

  /// Kategori aksi untuk tampilan (ikon/warna badge).
  AuditActionKind get actionKind {
    final String text = aksi.toLowerCase();
    if (text.contains('tambah') || text.contains('create')) {
      return AuditActionKind.created;
    }
    if (text.contains('ubah') ||
        text.contains('update') ||
        text.contains('edit')) {
      return AuditActionKind.updated;
    }
    if (text.contains('hapus') || text.contains('delete')) {
      return AuditActionKind.deleted;
    }
    return AuditActionKind.other;
  }
}

/// Satu halaman daftar log audit beserta info pagination.
class AuditLogPageEntity {
  const AuditLogPageEntity({
    required this.logs,
    required this.page,
    required this.hasNext,
    this.perPage,
    this.total,
    this.totalPages,
  });

  /// Log satu halaman.
  final List<AuditLogEntryEntity> logs;

  /// Nomor halaman yang diminta.
  final int page;

  /// Ukuran halaman menurut API (bila dikirim).
  final int? perPage;

  /// Total seluruh log pada filter aktif (bila dikirim).
  final int? total;

  /// Jumlah seluruh halaman (bila dikirim).
  final int? totalPages;

  /// `true` bila masih ada halaman berikutnya.
  final bool hasNext;
}

/// Parameter pembacaan log audit.
///
/// [days] adalah panjang rentang dalam hari (`null` = seluruh waktu).
/// [startDate] dan [endDate] dipakai untuk rentang kustom dari kartu tanggal;
/// bila keduanya terisi, keduanya mengalahkan [days].
class AuditLogQuery {
  const AuditLogQuery({
    this.days,
    this.startDate,
    this.endDate,
    this.page = 1,
  });

  /// Rentang waktu dalam hari; `null` berarti tanpa batas waktu.
  final int? days;

  /// Awal rentang kustom (inklusif), tanpa komponen jam.
  final DateTime? startDate;

  /// Akhir rentang kustom (inklusif), tanpa komponen jam.
  final DateTime? endDate;

  /// Nomor halaman (mulai 1).
  final int page;
}
