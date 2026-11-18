// Copy form kategori per tipe arus kas. Dipisah dari widget agar teks
// tetap konsisten saat varian Pemasukan / Pengeluaran / Tabel Bebas dipakai.

import '../../../domain/entities/free_table_entity.dart';

extension FreeTableCashflowCopy on FreeTableCashflowType {
  String get sheetSubtitle {
    return switch (this) {
      FreeTableCashflowType.income =>
        'Atur pos pembukuan pemasukan & custom field',
      FreeTableCashflowType.expense =>
        'Atur pos pembukuan pengeluaran & custom field',
      FreeTableCashflowType.freeTable =>
        'Pendataan operasional fleksibel & non-keuangan',
    };
  }

  String get nameHelper {
    return switch (this) {
      FreeTableCashflowType.income =>
        'Gunakan nama yang mudah dikenali kasir saat mencatat '
            'omzet/penjualan masuk.',
      FreeTableCashflowType.expense =>
        'Gunakan nama yang mudah dikenali kasir saat mencatat '
            'pengeluaran usaha.',
      FreeTableCashflowType.freeTable =>
        'Format tabel bebas tanpa rumus uang, cocok untuk inventaris, aset, '
            'suhu, atau piket.',
    };
  }

  String get noteLabel {
    return switch (this) {
      FreeTableCashflowType.income ||
      FreeTableCashflowType.expense =>
        'Rekomendasi Akun / Tagar',
      FreeTableCashflowType.freeTable => 'Target Departemen / Lokasi',
    };
  }

  String get noteOptionalHint {
    return switch (this) {
      FreeTableCashflowType.income ||
      FreeTableCashflowType.expense =>
        '(Opsional) Label catatan khusus',
      FreeTableCashflowType.freeTable => '(Opsional) Label area kerja',
    };
  }

  String get noteHintText {
    return switch (this) {
      FreeTableCashflowType.income =>
        'Misal: Omzet Harian, DP Katering, Pendapatan QRIS',
      FreeTableCashflowType.expense =>
        'Misal: Belanja Bahan, Operasional Harian, Gaji',
      FreeTableCashflowType.freeTable =>
        'Misal: Area Dapur Utama, Chiller Gudang, Barista',
    };
  }

  String get customFieldsDescription {
    return switch (this) {
      FreeTableCashflowType.income =>
        'Butuh catat nama pemesan, metode bayar, atau nomor invoice? '
            'Tambahkan kolom khusus untuk kategori pemasukan ini agar '
            'tersusun rapi.',
      FreeTableCashflowType.expense =>
        'Butuh catat nama supplier, metode bayar, atau nomor invoice? '
            'Tambahkan kolom khusus untuk kategori pengeluaran ini agar '
            'tersusun rapi.',
      FreeTableCashflowType.freeTable =>
        'Tentukan kolom data yang ingin dicatat setiap kali mengisi baris '
            'tabel ini.',
    };
  }

  String get saveLabel {
    return switch (this) {
      FreeTableCashflowType.income => 'Simpan & Gunakan Kategori Pemasukan',
      FreeTableCashflowType.expense => 'Simpan & Gunakan Kategori Pengeluaran',
      FreeTableCashflowType.freeTable => 'Simpan & Buat Tabel Bebas',
    };
  }

  String get footerNote {
    return switch (this) {
      FreeTableCashflowType.income =>
        'Modal akan menutup & kolom kustom otomatis terpasang di form '
            'transaksi masuk.',
      FreeTableCashflowType.expense =>
        'Modal akan menutup & kolom kustom otomatis terpasang di form '
            'transaksi keluar.',
      FreeTableCashflowType.freeTable =>
        'Tabel baru akan langsung aktif di menu Data Pembukuan.',
    };
  }
}
