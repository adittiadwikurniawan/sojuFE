import 'package:flutter/material.dart';

/// Token warna & gradien hasil ekstraksi dari Figma.
///
/// Sumber: file `SOJU-CORP`, page `UI v2`, section `Onboardeng`
/// (frame `546:867`, `546:904`, `546:964`, `546:1010`).
abstract final class SojuColors {
  // --- Brand ---

  /// Biru utama (tombol primer, aksen).
  static const Color primary = Color(0xFF1969FF);

  /// Biru tua untuk pil indikator langkah yang aktif.
  static const Color primaryDeep = Color(0xFF1E3A8A);

  /// Biru langit muda (titik awal gradien latar).
  static const Color sky = Color(0xFF8ED1E4);

  /// Biru terang pada gradien kartu AI.
  static const Color aiBlue = Color(0xFF0579FF);

  /// Biru tengah pada gradien kotak input kartu AI.
  static const Color aiBlueMid = Color(0xFF287EE2);

  // --- Teks ---

  /// Warna teks judul.
  static const Color ink = Color(0xFF131B2E);

  /// Warna teks deskripsi / sekunder.
  static const Color inkMuted = Color(0xFF505F76);

  // --- Indikator langkah ---

  /// Titik indikator langkah yang tidak aktif.
  static const Color dotInactive = Color(0xFFD2D9F4);

  // --- Permukaan ---

  /// Permukaan putih (kartu, tombol splash).
  static const Color surface = Color(0xFFFFFFFF);

  /// Permukaan abu sangat muda (tombol kembali).
  static const Color surfaceMuted = Color(0xFFF5F5F5);

  /// Garis tepi halus.
  static const Color border = Color(0xFFD9D9D9);

  // --- Aksen ilustrasi ---

  /// Hijau centang pada ilustrasi daftar fitur.
  static const Color success = Color(0xFF14AE5C);

  /// Slate gelap pada ilustrasi daftar fitur.
  static const Color slate = Color(0xFF324054);

  // --- Beranda (frame `546:1616`) ---

  /// Latar halaman beranda.
  static const Color homeBackground = Color(0xFFF2F2F7);

  /// Isian medan pencarian & tombol bulat notifikasi.
  static const Color field = Color(0xFFEEEEEE);

  /// Teks hint pada medan pencarian.
  static const Color hint = Color(0xFFA1A1A1);

  /// Judul kartu metrik.
  static const Color metricTitle = Color(0xFF45464D);

  /// Angka utama pada kartu metrik.
  static const Color metricValue = Color(0xFF1B1B1D);

  /// Teks catatan positif (margin sehat, pertumbuhan).
  static const Color positive = Color(0xFF006C4A);

  /// Batang grafik "Minggu Terakhir".
  static const Color chartGreen = Color(0xFF059669);

  /// Biru badge "Pemasukkan" & tautan "Lihat Semua".
  static const Color badgeBlue = Color(0xFF0058BE);

  /// Teks metadata produk (varian, SKU).
  static const Color textMuted = Color(0xFFC1C1C1);

  /// Pil perintah cepat pada kartu AI.
  static const Color pill = Color(0xFFE4E2E4);

  /// Titik notifikasi merah.
  static const Color alert = Color(0xFFFF0000);

  // --- Auth (frame `546:1547`) ---

  /// Teks hint pada medan isian formulir auth.
  static const Color inputHint = Color(0xFF6B7280);

  /// Ikon di dalam medan isian formulir auth.
  static const Color fieldIcon = Color(0xFF5F5E5E);

  /// Tab aktif pada header auth ("Daftar").
  static const Color tabActive = Color(0xFF0051D2);

  /// Tautan pada teks persetujuan (syarat & privasi).
  static const Color link = Color(0xFF2563EB);

  /// Aksen amplop pada keadaan "email terkirim" di layar Lupa Password.
  ///
  /// Berasal dari layer warna `lupa pasword.svg` (blend `color` di Figma);
  /// dipakai sebagai tint [BlendMode.color] di atas aset amplop.
  static const Color emailSent = Color(0xFF46BCAA);

  // --- Analytics (frame `546:2937`) ---

  /// Nilai pengeluaran, batang seri pengeluaran, dan progres kategori.
  static const Color expense = Color(0xFFBA1A1A);

  /// Latar lembut baris/kartu pemasukan.
  static const Color incomeSoft = Color(0xFFECFDF5);

  /// Latar lembut baris/kartu pengeluaran.
  static const Color expenseSoft = Color(0xFFFFF1F2);

  /// Ikon pengeluaran pada ringkasan.
  static const Color expenseAccent = Color(0xFFFF383C);

  /// Judul kartu analytics.
  static const Color analyticsTitle = Color(0xFF162454);

  /// Label pendamping pada kartu analytics.
  static const Color analyticsLabel = Color(0xFF424655);

  /// Metadata kecil pada kartu analytics.
  static const Color analyticsMuted = Color(0xFF737687);

  /// Latar lembut status informasi/perubahan (badge audit "Diubah").
  static const Color infoSoft = Color(0xFFEAF2FF);

  /// Garis pemisah halus pada kartu.
  static const Color hairline = Color(0xFFE6E8EA);

  /// Track progress bar kategori.
  static const Color track = Color(0xFFECEEF0);

  // --- Navbar bawah (frame `801:4265`) ---

  /// Ikon dan label tab navbar yang tidak aktif.
  static const Color navInactive = Color(0xFFB3B3B3);

  // --- Notifikasi (frame `546:1841`) ---

  /// Latar banner peringatan mendesak.
  static const Color notificationUrgentBg = Color(0xFFFFDAD6);

  /// Teks judul/isi banner peringatan mendesak.
  static const Color notificationUrgentInk = Color(0xFF93000A);

  /// Aksen ikon, badge, dan tombol pada banner peringatan.
  static const Color notificationUrgent = Color(0xFFBA1A1A);

  /// Judul kartu notifikasi.
  static const Color notificationTitle = Color(0xFF191C1E);

  /// Isi dan metadata kartu notifikasi.
  static const Color notificationBody = Color(0xFF424655);

  /// Titik pemisah metadata kartu notifikasi.
  static const Color notificationBullet = Color(0xFFC2C6D8);

  /// Tautan kategori dan jumlah belum dibaca.
  static const Color notificationBlue = Color(0xFF0051D2);

  /// Latar ikon notifikasi tagihan supplier.
  static const Color notificationSupplierBg = Color(0xFFDCE1FF);

  /// Ikon notifikasi tagihan supplier.
  static const Color notificationSupplierInk = Color(0xFF263F91);

  /// Latar tombol sekunder "Abaikan".
  static const Color notificationSecondaryBg = Color(0xFFECEEF0);

  /// Bayangan halus kartu notifikasi.
  static const Color notificationCardShadow = Color(0x14000000);

  // --- Audit (frame `546:4741`) ---

  /// Latar lembut badge aksi "Diubah" pada log audit.
  static const Color auditUpdateSoft = Color(0xFFEAF2FF);

  // --- Kalender tanggal (frame `302:6303`) ---

  /// Tanggal awal/akhir terpilih pada kartu kalender.
  static const Color calendarSelected = Color(0xFF2C14DD);

  /// Latar rentang tanggal terpilih.
  static const Color calendarRange = Color(0xFFEEECFD);

  /// Teks tanggal pada kartu kalender.
  static const Color calendarInk = Color(0xFF0D1028);

  /// Nama hari dan kontrol bulan pada kartu kalender.
  static const Color calendarMuted = Color(0xFF61697D);

  /// Garis pemisah kartu kalender.
  static const Color calendarDivider = Color(0xFFECEFF6);

  // --- Profil / Menu Akun (frame `622:1156`) ---

  /// Garis tepi kartu menu profil.
  static const Color profileCardBorder = Color(0xFFE3E8F0);

  /// Garis pemisah di dalam menu profil.
  static const Color profileDivider = Color(0xFFE5EBF0);

  /// Latar badge role pada menu profil.
  static const Color profileRoleBadge = Color(0xFFC1C1C1);

  // --- Chatbot Soju (frame `546:3687`) ---

  /// Latar baris riwayat percakapan.
  static const Color chatRow = Color(0xFFD9D9D9);

  /// Latar kartu draft dan kotak isian composer.
  static const Color chatSurface = Color(0xFFF2F4F6);

  /// Latar baris rincian item draft.
  static const Color draftRow = Color(0xFFF7F9FB);

  /// Badge "Belum disimpan" pada draft.
  static const Color draftBadge = Color(0xFFFDE68A);

  /// Teks badge "Belum disimpan".
  static const Color draftBadgeInk = Color(0xFF6B4400);

  /// Aksen pembayaran QRIS.
  static const Color qris = Color(0xFF4059AA);

  /// Aksen pembayaran tunai dan nominal pemasukan draft.
  static const Color cash = Color(0xFF006948);

  /// Latar catatan mode demo AI.
  static const Color demoSoft = Color(0xFFFFF7E6);

  /// Garis tepi catatan mode demo AI.
  static const Color demoBorder = Color(0xFFF5D48A);

  /// Teks catatan mode demo AI.
  static const Color demoInk = Color(0xFF7A4B00);

  // --- Tabel Bebas: Buat Kategori Baru (frame `546:5163`) ---

  /// Judul dan label utama form kategori.
  static const Color freeTableInk = Color(0xFF0F172A);

  /// Teks isian dan label sekunder yang lebih tegas.
  static const Color freeTableLabel = Color(0xFF1E293B);

  /// Teks deskripsi dan catatan form.
  static const Color freeTableMuted = Color(0xFF64748B);

  /// Teks hint / placeholder.
  static const Color freeTableHint = Color(0xFF94A3B8);

  /// Teks body pada panel kolom pendataan.
  static const Color freeTableBody = Color(0xFF475569);

  /// Teks label pill tipe kolom pada grid.
  static const Color freeTableTypeText = Color(0xFF334155);

  /// Biru aksi form (tombol simpan, border fokus, ikon).
  static const Color freeTableAccent = Color(0xFF2563EB);

  /// Border tombol tambah kolom kustom.
  static const Color freeTableAddBorder = Color(0xFF3B82F6);

  /// Border medan opsional.
  static const Color freeTableFieldBorder = Color(0xFFCBD5E1);

  /// Garis pemisah umum.
  static const Color freeTableDivider = Color(0xFFE2E8F0);

  /// Border kartu kolom (@80%).
  static const Color freeTableDivider80 = Color(0xCCE2E8F0);

  /// Border kartu catatan (@70%).
  static const Color freeTableDivider70 = Color(0xB3E2E8F0);

  /// Latar segmented control (@90%).
  static const Color freeTableSegmentBg = Color(0xE6F1F5F9);

  /// Border segmented control (@60%).
  static const Color freeTableSegmentBorder = Color(0x99E2E8F0);

  /// Latar panel kolom pendataan (@40%).
  static const Color freeTableCustomBg = Color(0x66F0F9FF);

  /// Border panel kolom pendataan.
  static const Color freeTableCustomBorder = Color(0xFF7DD3FC);

  /// Latar kartu catatan.
  static const Color freeTableNoticeBg = Color(0xFFF8FAFC);

  /// Latar badge "FR-4 Custom Field".
  static const Color freeTableBadgeBg = Color(0xFFDBEAFE);

  /// Latar badge "Wajib".
  static const Color freeTableRequiredBg = Color(0xFFFEF2F2);

  /// Teks badge "Wajib".
  static const Color freeTableRequired = Color(0xFFDC2626);

  /// Aksen tipe angka dan status sukses.
  static const Color freeTableGreen = Color(0xFF059669);

  /// Titik opsi Pemasukan pada segmented control.
  static const Color freeTableIncome = Color(0xFF10B981);

  /// Titik opsi Pengeluaran pada segmented control.
  static const Color freeTableExpense = Color(0xFFEF4444);

  /// Ikon kalender pada grid tipe kolom.
  static const Color freeTableAmber = Color(0xFFF59E0B);

  /// Latar lembut tipe angka.
  static const Color freeTableGreenSoft = Color(0xFFECFDF5);

  /// Aksen tipe pilihan ganda.
  static const Color freeTablePurple = Color(0xFF9333EA);

  /// Latar lembut tipe pilihan ganda.
  static const Color freeTablePurpleSoft = Color(0xFFFAF5FF);

  /// Latar lembut tipe teks.
  static const Color freeTableBlueSoft = Color(0xFFEFF6FF);

  /// Latar lembut tipe teks pada pill aktif (@70%).
  static const Color freeTableBlueSoft70 = Color(0xB3EFF6FF);

  /// Border pill tipe aktif (@60%).
  static const Color freeTableBlueBorder60 = Color(0x99BFDBFE);

  /// Garis atas footer lengket.
  static const Color freeTableFooterBorder = Color(0xFFF1F5F9);

  /// Latar tombol tambah kolom (@70%).
  static const Color freeTableWhite70 = Color(0xB3FFFFFF);

  // --- Gradien ---

  /// Gradien latar halaman onboarding (langit -> putih).
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[sky, surface],
  );

  /// Gradien latar splash (langit -> biru utama).
  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[sky, primary],
  );

  /// Gradien untuk wordmark "Buku Kita".
  static const LinearGradient wordmark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[sky, primary],
  );

  /// Gradien teks judul kartu AI (biru - langit - biru).
  static const LinearGradient aiTitle = LinearGradient(
    colors: <Color>[aiBlue, sky, aiBlue],
    stops: <double>[0, 0.5, 1],
  );

  /// Gradien kotak input kartu AI.
  static const LinearGradient aiInput = LinearGradient(
    colors: <Color>[aiBlueMid, sky, aiBlue],
    stops: <double>[0, 0.56, 1],
  );
}
