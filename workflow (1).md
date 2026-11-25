# DOKUMENTASI ALUR KERJA SISTEM (WORKFLOW.MD)
**Aplikasi Pembukuan & Storefront SOJU (Kuliner & Frozen Food Buku Dapur)**  
*Dokumentasi Lengkap Alur Kerja Tiap File, Hubungan Antar-Modul, Kode yang Digunakan, serta Audit Kode Beban (Dead/Burden Code)*

---

## DAFTAR ISI
1. [Ringkasan Arsitektur & Alur Kerja Utuh](#1-ringkasan-arsitektur--alur-kerja-utuh)
   - [1.1 Dashboard Customer, Pesanan, dan Role](#11-dashboard-customer-pesanan-dan-role)
2. [Peta Alur Kerja & Kode Backend (`backend/`)](#2-peta-alur-kerja--kode-backend-backendsrc)
   - [2.1 Bootstrap & Inisialisasi Server](#21-bootstrap--inisialisasi-server)
   - [2.2 Keamanan & Autentikasi (JWT)](#22-keamanan--autentikasi-jwt)
   - [2.3 Modul Transaksi Finansial & Master Jenis Dinamis](#23-modul-transaksi-finansial--master-jenis-dinamis)
   - [2.4 Modul Dashboard & Analisis Kas](#24-modul-dashboard--analisis-kas)
   - [2.5 Modul Order & Agregasi](#25-modul-order--agregasi)
   - [2.6 Modul Pendataan Bebas (`TabelBebas`)](#26-modul-pendataan-bebas-tabelbebas)
   - [2.7 Modul Katalog Produk (Admin & Public)](#27-modul-katalog-produk-admin--public)
   - [2.8 Modul Konten CMS (Admin & Public)](#28-modul-konten-cms-admin--public)
   - [2.9 Modul Audit Log & Riwayat Aktivitas](#29-modul-audit-log--riwayat-aktivitas)
   - [2.10 Modul Laporan & Ekspor Excel](#210-modul-laporan--ekspor-excel)
   - [2.11 Database ORM Prisma & Migrasi Data](#211-database-orm-prisma--migrasi-data)
3. [Peta Alur Kerja & Kode Frontend (`webf/`)](#3-peta-alur-kerja--kode-frontend-webf)
   - [3.1 Konfigurasi, Routing & Layout Global](#31-konfigurasi-routing--layout-global)
   - [3.2 Gateway Komunikasi API (`lib/api.ts` & `lib/whatsapp.ts`)](#32-gateway-komunikasi-api-libapits--libwhatsappts)
   - [3.3 Alur Storefront Customer (Publik)](#33-alur-storefront-customer-publik)
   - [3.4 Alur Autentikasi Admin (`/login`)](#34-alur-autentikasi-admin-login)
   - [3.5 Alur Dashboard Ringkasan (`/dashboard`)](#35-alur-dashboard-ringkasan-dashboard)
   - [3.6 Alur Master Transaksi & Pendataan Bebas (`/dashboard/data`)](#36-alur-master-transaksi--pendataan-bebas-dashboarddata)
   - [3.7 Alur Manajemen CMS & Produk (`/dashboard/cms`)](#37-alur-manajemen-cms--produk-dashboardcms)
   - [3.8 Alur Riwayat Aktivitas & Audit Log (`/dashboard/audit`)](#38-alur-riwayat-aktivitas--audit-log-dashboardaudit)
   - [3.9 Alur Simulasi Asisten AI (`/dashboard/ai`)](#39-alur-simulasi-asisten-ai-dashboardai)
   - [3.10 Alur Profil & Preferensi Toko (`/dashboard/profile`)](#310-alur-profil--preferensi-toko-dashboardprofile)
   - [3.11 Status System & Feedback Modals](#311-status-system--feedback-modals)
4. [Audit Terperinci Kode Beban / Peninggalan Sistem Lama (Burden & Dead Code)](#4-audit-terperinci-kode-beban--peninggalan-sistem-lama-burden--dead-code)
   - [4.1 Prisma & Database Legacy](#41-prisma--database-legacy)
   - [4.2 Backend Endpoints & Services yang Mati](#42-backend-endpoints--services-yang-mati)
   - [4.3 Frontend Dead Routes, Broken Imports & Zombie Code](#43-frontend-dead-routes-broken-imports--zombie-code)
   - [4.4 Frontend Dead Components](#44-frontend-dead-components)
   - [4.5 File Sampah & Arsip Fisik yang Membebani Workspace](#45-file-sampah--arsip-fisik-yang-membebani-workspace)
5. [Pemeriksaan Integritas Sambungan (Safety & Connection Check)](#5-pemeriksaan-integritas-sambungan-safety--connection-check)
6. [Tabel Matriks Hubungan Antar-File & Status Keaktifan](#6-tabel-matriks-hubungan-antar-file--status-keaktifan)

---

## 1. RINGKASAN ARSITEKTUR & ALUR KERJA UTUH

Sistem ini terbagi secara tegas menjadi dua antarmuka (portal) yang melayani kebutuhan bisnis kuliner dan frozen food **SOJU (Buku Dapur)**:

```
[ BROWSER / CLIENT ]
   │
   ├── (1) SISI PUBLIK (CUSTOMER) ───> Next.js (Port 3000: /customer, /customer/menu, dll)
   │        │                            │ (Fetch data publik tanpa token)
   │        │                            ▼
   │        │                     GET /api/public/products, /api/public/cms/content
   │        │                            │
   │        └── Transaksi Pesan ─────────┴─> WhatsApp Gateway (wa.me API langsung ke admin)
   │
   └── (2) SISI INTERNAL (ADMIN TOKO) ─> Next.js (Port 3000: /dashboard, /dashboard/data, dll)
            │                            │ (Menyertakan Bearer Token JWT)
            │                            ▼
            │                     Express.js Backend (Port 4000: /api/v1/*)
            │                            │
            │                     Auth Middleware (Verifikasi JWT)
            │                            │
            │                     Prisma ORM (src/utils/database.ts)
            │                            │
            │                     MySQL Database (`soju_1hustle`)
            │                            │
            └─ Setiap mutasi dicatat ────┴─> Tabel `log_audit` (Audit Trail otomatis)
```

### Dua Pilar Alur Kerja Utama:
1. **Pilar Customer (Storefront & Pemesanan):**
   - Customer mengakses katalog menu makanan dan varian secara publik tanpa perlu login.
   - Konten hero, promosi, profil "Tentang Kami", serta kontak diambil dari endpoint publik backend `/api/public/*`.
   - Customer dapat menjelajah dan mengisi keranjang tanpa login. Saat checkout, customer login/daftar lalu pesanan dan item disimpan di backend; WhatsApp bukan penyimpanan pesanan.
2. **Pilar Admin (Pembukuan, Transaksi Dinamis, Pendataan Bebas, & CMS):**
   - Admin login menggunakan email dan password melalui `POST /api/v1/auth/login`. Token JWT disimpan di `localStorage` (`auth_token`).
   - Admin mencatat transaksi keuangan secara dinamis berdasarkan jenis transaksi (`JenisTransaksi`). Kolom input tambahan (`KolomCustom`) dibuat bebas per jenis tanpa migrasi skema tabel database.
   - Admin mengelola spreadsheet internal independen (`TabelBebas`) untuk pendataan aset, inventaris dapur, atau catatan non-keuangan.
   - Setiap mutasi (create/update/delete) pada transaksi, jenis, produk, CMS, dan tabel bebas dicatat otomatis ke dalam `LogAudit` lengkap dengan snapshot data sebelum dan sesudahnya.

### 1.1 Dashboard Customer, Pesanan, dan Role

Status: implementasi tersedia pada backend dan webf. Migrasi customer/pesanan/role `20261119000000_customer_orders_roles` dan migrasi CRM `20261119010000_customer_crm_foundation` sudah diterapkan ke database lokal `soju_1hustle`. Akun `admin@bukudapur.com` adalah Super Admin. Pembayaran Midtrans dan pengiriman email belum diimplementasikan.

#### Area dan hak akses yang dituju

| Jenis akun | Area | Hak akses target |
|---|---|---|
| Customer | `/dashboard-customer` dan storefront `/customer` | Profil sendiri, keranjang sendiri, checkout, dan riwayat/status pesanannya sendiri. Bisa menjelajah katalog dan mengisi keranjang tanpa login; login/daftar diminta saat checkout atau membuka profil/pesanan. |
| Admin | `/dashboard` | Dashboard, Data, Riwayat & Audit, Asisten AI, Pengelola Pesanan, dan pengaturan profil milik sendiri. Tidak dapat mengelola CMS atau pengguna. |
| Super Admin | `/dashboard` dan semua modul admin | Seluruh hak Admin, CMS, pengelolaan pesanan customer, dan pembuatan akun Admin melalui Pengaturan Akun. |

Akun Customer disimpan terpisah dari model `Pengguna` admin. Model `Pengguna` memiliki role `ADMIN` atau `SUPER_ADMIN`. Pembatasan akses ditegakkan di backend dengan middleware otorisasi; menyembunyikan menu frontend saja tidak cukup. `admin@bukudapur.com` ditetapkan sebagai Super Admin.

#### Struktur database

Skema customer awal menambahkan **tiga tabel**. Fitur CRM menambah tabel keempat, `kampanye_pelanggan`, serta kolom aktivitas dan persetujuan promosi pada `pelanggan`. Kolom dan model menggunakan penamaan Indonesia; nama fisik tabel Prisma dipetakan ke snake_case Indonesia.

1. **`Pelanggan` (`pelanggan`)** — akun customer: nama, email unik, nomor telepon, alamat, hash password, waktu pembuatan/perubahan, dan keranjang JSON. Keranjang akun tersimpan terkait langsung ke ID pelanggan.
2. **`PesananPelanggan` (`pesanan_pelanggan`)** — ID pelanggan, kode pesanan, snapshot nama/telepon/alamat checkout, total, status, dan waktu pembuatan/perubahan.
3. **`ItemPesananPelanggan` (`item_pesanan_pelanggan`)** — relasi ke pesanan, referensi produk jika masih tersedia, serta snapshot nama produk, varian, satuan, harga saat checkout, jumlah, catatan, dan subtotal.

Model `Pengguna` yang sudah ada ditambah kolom role, bukan dibuat ulang. Belum ada tabel pembayaran atau tabel undangan pada tahap ini. Super Admin membuat akun Admin melalui Pengaturan Akun; mekanisme undangan email dapat ditambahkan kemudian tanpa mencampur akun admin dengan akun pelanggan.

#### Alur customer

1. Customer membuka storefront dan memilih menu, varian, jumlah, serta catatan tanpa login.
2. Keranjang tamu tetap di browser. Saat customer login/daftar, keranjang digabung ke kolom keranjang milik `Pelanggan`.
3. Checkout meminta login/daftar jika belum terautentikasi, lalu mengembalikan customer ke checkout dengan item tetap tersedia.
4. Form daftar meminta nama, email, nomor telepon, alamat, dan password. Login menggunakan email dan password. Alamat serta nomor telepon dapat diperbarui di profil.
5. Checkout menampilkan rincian item, alamat, total, lalu membuat `PesananPelanggan` beserta item snapshot di backend. Tanpa gateway pembayaran pada tahap awal, pesanan dimulai dengan status **MENUNGGU_KONFIRMASI**.
6. `/dashboard-customer` menampilkan profil, keranjang, dan pesanan. Status target pesanan: **MENUNGGU_KONFIRMASI**, **DIPROSES**, **SELESAI**, atau **DIBATALKAN**.

#### Backend customer dan pesanan

- Tambah autentikasi customer terpisah: daftar, login, profil, dan pembaruan profil. Token customer tidak boleh mengakses route admin.
- Tambah endpoint keranjang yang selalu membatasi data berdasarkan pelanggan yang sedang login.
- Tambah endpoint checkout, daftar/detail pesanan customer, serta endpoint pengelolaan status pesanan untuk Super Admin.
- Tambah role admin dan middleware otorisasi untuk memastikan Admin hanya dapat memakai Dashboard, Data, Audit, dan AI; CMS dan pengelolaan pengguna khusus Super Admin.
- Tambah endpoint pembuatan akun Admin yang hanya dapat dipanggil Super Admin. Akun baru menggunakan role `ADMIN`; perubahan role tidak boleh dilakukan Admin biasa.
- Pisahkan pesanan belanja customer dari route `/api/v1/orders` yang sekarang membaca transaksi keuangan.
- Migrasi Prisma customer/pesanan/role sudah diterapkan. Migrasi CRM menambahkan kolom aktivitas dan persetujuan promosi customer serta tabel `kampanye_pelanggan`.

#### Website `webf`

- Tambah ikon akun pada header storefront; customer tanpa sesi yang membuka profil/pesanan diminta login.
- Tambah halaman daftar/login customer dan rute `/dashboard-customer` untuk profil, keranjang, dan pesanan.
- Ubah checkout saat ini dari langsung membuka WhatsApp menjadi mengirim pesanan ke backend. WhatsApp tetap dapat tersedia sebagai kontak bantuan, bukan penyimpanan pesanan.
- Tampilkan navigasi admin sesuai role, dan tampilkan undangan pengguna hanya untuk Super Admin.
- Tampilan admin untuk melihat serta memperbarui status pesanan customer tersedia pada Pengelola Pesanan.

#### Pengelolaan customer dan CRM

Super Admin mengakses `/dashboard/customers` untuk melihat ringkasan jumlah akun, mencari/filter customer, melihat detail profil dan riwayat pesanan, serta menonaktifkan atau mengaktifkan akun. Akun dinonaktifkan secara lunak (`aktif=false`) agar relasi dan riwayat pesanan tetap tersimpan. Endpoint berada di `/api/v1/customers` dan hanya dapat digunakan Super Admin.

Customer dapat memberi atau mencabut persetujuan promosi dari halaman daftar/profil. Persetujuan default **tidak aktif**. Backend menyimpan `promosiDiizinkan`, waktu persetujuan/pencabutan, dan `terakhirMasukPada` pada tabel `pelanggan` untuk mendukung segmentasi. Super Admin dapat menyusun draft kampanye, memilih segmen customer yang aktif dan telah menyetujui promosi, melihat jumlah serta contoh penerima, dan mengubah/menghapus draft. Draft tersimpan di tabel `kampanye_pelanggan`; sistem **belum mengirim email** dan tidak menampilkan aksi kirim. Segmen yang tersedia: semua yang menyetujui, belum pernah memesan, dan tidak memiliki pesanan selesai dalam jumlah hari yang dipilih.

#### Status implementasi

1. Skema customer/pesanan, role, dan CRM beserta migrasi SQL aditif sudah diterapkan pada database lokal.
2. API autentikasi/profil customer, keranjang tersimpan, checkout, dan daftar/detail pesanan sudah ditambahkan.
3. Backend menerapkan role Admin dan Super Admin untuk route terkait; webf menyediakan storefront, checkout, dashboard customer, profil, dan riwayat pesanan.
4. Admin dan Super Admin dapat melihat pesanan customer serta memperbarui statusnya; pembuatan akun Admin tetap khusus Super Admin.
5. Pengelolaan akun customer dan draft CRM tersedia khusus Super Admin. Persetujuan promosi opt-in; draft hanya untuk persiapan dan pratinjau penerima.
6. Midtrans **tidak dikerjakan dulu**. Tabel/alur pembayaran ditambahkan pada tahap pembayaran nanti setelah provider dan status pembayaran diputuskan.
7. Email receipt dan pengiriman kampanye via EmailJS menjadi tahap integrasi berikutnya.

#### Perbaikan bug keranjang dan gambar menu

Status: perbaikan source sudah diterapkan; pemeriksaan TypeScript webf berhasil. Customer tetap dapat menggunakan keranjang tanpa login.

**Keranjang lintas akun:** keranjang tamu kini memakai key lokal tersendiri, sedangkan cache akun dipisahkan berdasarkan ID customer. Saat login, keranjang server akun dimuat dan keranjang tamu digabung satu kali saja; snapshot tamu baru dihapus setelah sinkronisasi berhasil. Saat logout, state aktif kembali ke keranjang tamu. Permintaan sinkronisasi membawa token sesi yang sesuai agar operasi tertunda dari akun sebelumnya tidak menulis ke akun yang baru.

Keranjang lama `soju_customer_cart` tidak punya identitas pemilik, jadi dibersihkan dan tidak diimpor ke akun mana pun untuk mencegah kebocoran lintas akun. Kuantitas yang mungkin telanjur berlipat pada keranjang server tidak dikurangi otomatis.

**Gambar menu dan audit:** penggantian gambar kini menyimpan URL versi baru agar browser meminta gambar terbaru. Endpoint gambar memakai `Cache-Control: no-cache, must-revalidate`. Nama file disimpan pada kolom tambahan `produk.gambar_nama` agar audit bisa merangkum `nama-lama.jpg menjadi nama-baru.jpeg`; nama file gambar lama yang sudah ada sebelum kolom ini ditambahkan memang tidak dapat dipulihkan. Snapshot audit produk setelah perubahan memakai data lengkap, sehingga field yang tidak berubah tidak ditampilkan. Nilai gambar kosong dikirim eksplisit sehingga tombol hapus membersihkan URL, BLOB, MIME, dan nama file.

---

## 2. PETA ALUR KERJA & KODE BACKEND (`backend/src/`)

Backend dibangun menggunakan **Node.js, Express.js (v5), TypeScript, Prisma ORM (v5), dan MySQL**.

### 2.1 Bootstrap & Inisialisasi Server
- **File:** `backend/src/index.ts`
- **Fungsi & Alur Kerja:**
  1. Membaca variabel environment melalui `dotenv.config()`.
  2. Menginisialisasi Express instance pada `PORT` (default `4000`).
  3. Memasang middleware `cors` (mengizinkan origin `http://localhost:3000` dengan credentials), JSON parser dengan batas payload `7mb` (mendukung Base64 upload gambar), dan URL-encoded parser.
  4. Mendaftarkan routing privat `/api/v1/*` dan routing publik `/api/public/*`.
  5. Menyediakan endpoint root `GET /` dan health check `GET /health`.
  6. Memasang centralized error handling middleware yang menangkap exception dan mengembalikan format konsisten `{ success: false, message }`.
- **Hubungan / Koneksi:** Menghubungkan seluruh router di `src/routes/*` ke server HTTP.

### 2.2 Keamanan & Autentikasi (JWT)
- **File:** `backend/src/middleware/auth.ts`
  - **Fungsi:** Middleware pemeriksa token `Authorization: Bearer <token>`. Menggunakan `jwt.verify` dengan secret `JWT_SECRET`.
  - **Alur Data:** Jika valid, mengekstrak payload `{ id, email }` ke dalam `req.user`. Jika tidak ada token atau kedaluwarsa, melempar error HTTP `401 Unauthorized`.
- **File:** `backend/src/services/authService.ts`
  - **Fungsi:** Logika bisnis otentikasi.
  - **Kode Utama:**
    - `login({ email, password })`: Mencari record di tabel `pengguna` berdasarkan email unik. Memverifikasi sandi menggunakan `bcrypt.compare(password, user.passwordHash)`. Menghasilkan JWT token beralgoritma HMAC-SHA256 dengan masa aktif 7 hari.
    - `hashPassword(password)`: Utility enkripsi bcrypt (salt round 10) untuk registrasi/seeding.
- **File:** `backend/src/routes/auth.ts`
  - **Endpoint:**
    - `POST /api/v1/auth/login`: Menerima JSON `{ email, password }`, memanggil `authService.login`, mengembalikan token dan profil user dasar.
    - `GET /api/v1/auth/me`: Dilindungi middleware `authenticate`. Mengambil data diri user aktif dari database (tanpa hash password).

### 2.3 Modul Transaksi Finansial & Master Jenis Dinamis
- **File:** `backend/src/routes/transactionTypes.ts` (Master Transaksi)
  - **Fungsi:** Pengelolaan kategori transaksi (`JenisTransaksi`) dan formulir kolom dinamis (`KolomCustom`).
  - **Alur Kerja & Endpoint:**
    - `GET /api/v1/transaction-types`: Mengambil daftar jenis transaksi aktif beserta definisi kolom kustomnya dan jumlah transaksi yang terkait.
    - `POST /api/v1/transaction-types`: Membuat jenis baru (`kode`, `namaTransaksi`, `arah`: `PEMASUKAN` | `PENGELUARAN`, `jenisAkun`, `unitBisnis`). Mencatat ke audit log.
    - `PUT /api/v1/transaction-types/:id`: Memperbarui atribut jenis transaksi.
    - `DELETE /api/v1/transaction-types/:id`: **Integritas Relasional:** Mengecek apakah jenis ini sudah pernah digunakan oleh tabel `transaksi`. Jika ada, server menolak penghapusan dengan status `409 Conflict` (menyarankan nonaktif). Jika belum pernah dipakai, dihapus permanen di dalam transaksi Prisma.
    - `POST /api/v1/transaction-types/:id/columns`: Menambahkan kolom kustom (`TEKS`, `ANGKA`, `TANGGAL`, `DROPDOWN`).
    - `DELETE /api/v1/transaction-types/:id/columns/:columnId`: **Perlindungan Data Historis:** Memeriksa apakah ID kolom ini ada di dalam kolom `custom_data` transaksi historis. Jika pernah dipakai, kolom di-soft-delete (`aktif: false`). Jika belum pernah, di-hard-delete.
- **File:** `backend/src/routes/transactions.ts` (Entri Transaksi Inti)
  - **Fungsi:** Pencatatan dan pembukuan transaksi operasional harian.
  - **Logika Kode Kunci:**
    - `generateKodeTransaksi(tx, prefixKode)`: Mengeksekusi raw query SQL `SELECT MAX(CAST(...))` untuk mencari nomor urut terakhir pada prefix jenis transaksi, lalu menyusun kode format: `${prefixKode}${nomorUrut}-${timestamp5Digit}`.
    - `createEntriTransaksi(params)`: Dijalankan di dalam `prisma.$transaction`. Memastikan jenis transaksi aktif, men-generate kode unik, menyimpan data finansial (`tanggal`, `nominal`, `detail`, `jenisKas`, `debit`, `kredit`, `customData`, `sumberInput`), dan mengikat ke user pembuat.
  - **Endpoint:**
    - `GET /api/v1/transactions`: Pencarian, pemfilteran rentang tanggal, unit bisnis, jenis transaksi, dan paginasi halaman.
    - `POST /api/v1/transactions`: Menyimpan transaksi baru dan otomatis menulis log aktivitas ke `LogAudit`.
    - `PUT /api/v1/transactions/:id`: Memperbarui data transaksi, merekam snapshot data lama vs data baru ke audit log.
    - `DELETE /api/v1/transactions/:id`: Menghapus permanen entri transaksi dan mencatat snapshot penghapusan ke audit log.

### 2.4 Modul Dashboard & Analisis Kas
- **File:** `backend/src/routes/dashboard.ts`
  - **Fungsi:** Menyajikan data agregasi statistik untuk antarmuka dashboard eksekutif.
  - **Endpoint & Alur:**
    - `GET /api/v1/dashboard/summary`: Menghitung Saldo Kas riil akumulatif (Total Pemasukan dikurangi Total Pengeluaran) menggunakan `prisma.transaksi.aggregate`. Menghitung jumlah order baru (transaksi bertipe DO1/DO2) berdasarkan filter periode.
    - `GET /api/v1/dashboard/grafik-kas`: Mengelompokkan transaksi per hari dalam format time-series (`pemasukan`, `pengeluaran`, `selisih`, dan rincian transaksi) untuk dirender pada diagram batang frontend.
    - `GET /api/v1/dashboard/sumber-input`: Menghitung rasio transaksi yang diinput oleh asisten `AI` vs `MANUAL`.
    - `GET /api/v1/dashboard/aktivitas-terbaru`: Mengambil 5 aktivitas terbaru dari tabel `log_audit`.
    - `GET /api/v1/dashboard/pemasukan-pengeluaran`: Rekapitulasi perbandingan total debit/kredit per rentang waktu 7/30/90 hari.

### 2.5 Modul Order & Agregasi
- **File:** `backend/src/routes/orders.ts`
  - **Fungsi:** Tampilan virtual transaksi finansial yang diklasifikasikan sebagai order penjualan makanan.
  - **Alur Kerja:** Mencari jenis transaksi bawaan bertipe penjualan frozen (`DO1`) dan makanan siap saji (`DO2`) melalui helper `orderJenisIds()`. Mengambil baris transaksi terkait dan memformat output dengan alias field order (`totalInvoice`, `jenisOrder`, `kodeOrder`).

### 2.6 Modul Pendataan Bebas (`TabelBebas`)
- **File:** `backend/src/routes/freeTables.ts`
  - **Fungsi:** Fasilitas pembuatan tabel spreadsheet dinamis yang berdiri sendiri (terisolasi total dari pembukuan finansial). Digunakan untuk mendata inventaris alat, stok bahan kasar, atau database operasional internal.
  - **Endpoint:**
    - `GET /api/v1/free-tables`: Mengambil seluruh daftar tabel bebas beserta definisinya.
    - `POST /api/v1/free-tables`: Membuat tabel baru lengkap dengan deklarasi kolom dan tipe data (TEKS, ANGKA, TANGGAL, DROPDOWN berserta opsi pilihannya).
    - `PUT /api/v1/free-tables/:id` & `DELETE /api/v1/free-tables/:id`: Edit metadata tabel atau hapus tabel secara cascade (menghapus baris dan kolom terkait).
    - `POST/PUT/DELETE /api/v1/free-tables/:id/rows`: Operasi CRUD baris data tabel bebas yang disimpan dalam format JSON dinamis.

### 2.7 Modul Katalog Produk (Admin & Public)
- **File:** `backend/src/routes/products.ts` (Admin)
  - **Fungsi:** Mengelola master produk/menu makanan.
  - **Fitur Khusus Upload Gambar:** Menerima string Base64 Data URI (`data:image/png;base64,...`). Fungsi `imageDataFrom` memvalidasi MIME type dan ukuran maksimal 5 MB, lalu menyimpannya langsung ke kolom MySQL `gambarData` bertipe `LongBlob` serta `gambarMime`.
  - Endpoint `GET /api/v1/products/:id/image` mengalirkan binary buffer gambar langsung dengan header `Cache-Control: public, max-age=3600`.
- **File:** `backend/src/routes/productsPublic.ts` (Customer Storefront)
  - **Fungsi:** Menyediakan daftar produk yang berstatus `aktif: true` kepada pengunjung publik tanpa perlu login atau menyertakan Bearer token. Mendukung pencarian instan nama produk atau varian.

### 2.8 Modul Konten CMS (Admin & Public)
- **File:** `backend/src/routes/cms.ts` (Admin)
  - **Fungsi:** Mengatur salinan teks (copywriting) pada halaman customer untuk key: `headline_beranda`, `tentang_kami`, `kontak`, dan array JSON ID `produk_unggulan`.
  - **Alur:** Setiap perubahan memperbarui tabel `cms_content` dan dicatat ke `LogAudit`.
- **File:** `backend/src/routes/cmsPublic.ts` (Public)
  - **Fungsi:** Menyajikan data teks landing page publik. Menyediakan hardcoded fallback response (graceful degradation) seandainya baris di database belum di-seed atau terhapus.

### 2.9 Modul Audit Log & Riwayat Aktivitas
- **File:** `backend/src/services/auditLogService.ts`
  - **Fungsi:** Service penyedia method `createAuditLog` dan `logManualAction` untuk menuliskan aksi `TAMBAH`, `UBAH`, `HAPUS` beserta data snapshot JSON sebelum dan sesudah mutasi.
- **File:** `backend/src/routes/auditLog.ts`
  - **Fungsi:** Menyajikan riwayat aktivitas kepada admin.
  - **Logika Cerdas:** Melakukan parsing snapshot JSON secara dinamis untuk menerjemahkan ID kolom kustom dan ID produk menjadi nama aslinya, sehingga admin di frontend dapat melihat label perubahan yang mudah dibaca manusia (human-readable diff).

### 2.10 Modul Laporan & Ekspor Excel
- **File:** `backend/src/routes/reports.ts`
  - **Fungsi:** Pengolahan laporan dan ekspor file spreadsheet.
  - **Endpoint Aktif:**
    - `GET /api/v1/reports/laba-rugi`: Menghitung total pemasukan, pengeluaran, dan laba bersih dari arah jenis transaksi (`PEMASUKAN` vs `PENGELUARAN`) dalam kurun waktu yang dipilih.
    - `GET /api/v1/reports/export/transactions`: Mengambil data transaksi beserta kolom kustomnya, merangkainya ke dalam workbook Excel menggunakan pustaka `xlsx`, dan mengirimkannya sebagai stream file binary `.xlsx`.
    - `GET /api/v1/reports/export/free-table/:id`: Mengekspor satu tabel bebas beserta baris datanya ke file `.xlsx`.
  - **Endpoint Nonaktif (501):** `/reports/neraca` dan `/reports/perubahan-modal` sengaja melempar status `501 Not Implemented` karena debit/kredit pada sistem saat ini bersifat teks bebas deskriptif dan bukan bagan akun berpasangan (double-entry COA).

### 2.11 Database ORM Prisma & Migrasi Data
- **File:** `backend/prisma/schema.prisma`
  - **Driver:** MySQL via `DATABASE_URL`.
  - **Model Aktif:**
    1. `Pengguna`: Identitas user dan kredensial admin.
    2. `JenisTransaksi`: Master kategori transaksi finansial (mendukung status bawaan / `isBawaan`).
    3. `KolomCustom`: Skema atribut formulir dinamis per jenis transaksi.
    4. `Transaksi`: Data pembukuan transaksi riil dengan nominal bertipe Decimal(15,2).
    5. `TabelBebas`, `KolomTabelBebas`, `BarisTabelBebas`: Struktur spreadsheet pendataan bebas.
    6. `Produk`: Master menu kuliner dengan dukungan penyimpanan gambar BLOB.
    7. `CmsContent`: Pengaturan konten teks halaman publik.
    8. `LogAudit`: Rekam jejak seluruh mutasi sistem.
- **File:** `backend/prisma/seed.ts`
  - Menginisialisasi akun admin default (`admin@bukudapur.com` / `password123`), 3 jenis transaksi bawaan (`DO1`, `DO2`, `MT1`), dan konten headline.
- **File:** `backend/prisma/seed-cms.ts`
  - Menginisialisasi konten CMS default: `headline_beranda`, `tentang_kami`, `kontak`, dan `produk_unggulan`.
- **File:** `backend/prisma/clean-db.ts`
  - Script pengosongan data transaksi, produk, audit log, dan tabel bebas untuk keperluan reset operasional tanpa menghapus user login.

---

## 3. PETA ALUR KERJA & KODE FRONTEND (`webf/`)

Frontend dibangun menggunakan **Next.js (v16 App Router), React 19, TypeScript, dan Tailwind CSS (v4)**.

### 3.1 Konfigurasi, Routing & Layout Global
- **`webf/next.config.ts` & `package.json`**: Konfigurasi App Router Next.js.
- **`webf/app/layout.tsx`**: Root layout membungkus seluruh aplikasi dengan font `Plus Jakarta Sans` dan stylesheet global `globals.css`.
- **`webf/app/page.tsx`**: Halaman akar (`/`) langsung mengalihkan (redirect) pengguna secara otomatis ke portal customer `/customer`.
- **`webf/app/error.tsx`, `loading.tsx`, `not-found.tsx`**: Menangani fallback error boundary, skeleton loading, dan halaman 404 aplikasi.

### 3.2 Gateway Komunikasi API (`lib/api.ts` & `lib/whatsapp.ts`)
- **File:** `webf/lib/api.ts`
  - **Fungsi:** Sentralisasi pemanggilan HTTP fetch ke backend (`http://localhost:4000/api/v1`).
  - **Interseptor Otomatis:**
    1. Mengambil token dari `localStorage.getItem('auth_token')` dan menyematkannya pada header `Authorization: Bearer <token>`.
    2. **Pencegahan Sesi Kadaluwarsa (401 Handler):** Jika backend merespons `401 Unauthorized`, fungsi secara otomatis menghapus token di storage dan me-redirect browser ke halaman `/login`.
    3. Mengelompokkan API ke objek terstruktur: `api.auth`, `api.dashboard`, `api.products`, `api.transactions`, `api.transactionTypes`, `api.freeTables`, `api.auditLog`, `api.cms`, `api.reports`, `api.publicProducts`, `api.publicCms`.
  - **Fungsi Pembantu:** `getImageUrl(path)`: Mengonversi path relatif gambar menjadi URL absolut mengarah ke backend port 4000 atau mempertahankan Data URI.
- **File:** `webf/lib/whatsapp.ts`
  - **Fungsi:** Engine pembuatan pesan order WhatsApp.
  - **Logika:** Mengambil nomor telepon resmi toko dari CMS `kontak` (dengan fallback cadangan `6281234567890`), menyusun format teks pemesanan rapi (`Halo kak, saya mau pesan: *Nama Produk*, Varian, Jumlah, Catatan`), dan meluncurkan link `https://wa.me/<nomor>?text=<encoded_text>`.

### 3.3 Alur Storefront Customer (Publik)
Folder: `webf/app/customer/`
1. **Layout Bersama (`app/customer/layout.tsx`):**
   - Header navigasi transparan/blur yang menempel saat di-scroll (*sticky blurred navbar*).
   - Tautan navigasi statis: `Home` (`/customer`), `Menu` (`/customer/menu`), `About` (`/customer/tentang`), dan `Contact` (`/customer/kontak`).
   - Drawer navigasi mobile yang responsif dan footer toko dengan info telepon/alamat dinamis.
2. **Beranda Customer (`app/customer/page.tsx`):**
   - Mengambil data headline CMS (`api.publicCms.getContentByKey('headline_beranda')`) dan daftar menu unggulan (`api.publicCms.getContentByKey('produk_unggulan')`).
   - Hero banner interaktif dengan auto-slide berganti setiap 5 detik (otomatis berhenti saat mouse hover atau modal terbuka).
   - Menampilkan kartu produk unggulan dengan tombol "Pesan Sekarang".
3. **Katalog Menu Lengkap (`app/customer/menu/page.tsx`):**
   - Mengambil seluruh daftar produk aktif melalui `api.publicProducts.getAll()`.
   - Fitur pencarian instan (real-time filtering) berdasarkan nama makanan atau varian rasa.
4. **Alur Modal Pesanan (`components/customer/OrderModal.tsx`):**
   - Ketika pelanggan memilih menu, modal pesanan terbuka.
   - Pelanggan memilih varian (jika ada), mengatur jumlah pesanan (tambah/kurang counter), dan menulis catatan tambahan.
   - Tombol "Kirim Pesanan via WhatsApp" langsung membuka WhatsApp Web atau aplikasi seluler WhatsApp untuk konfirmasi order langsung dengan penjual.
5. **Tentang Kami & Kontak (`customer/tentang/page.tsx` & `customer/kontak/page.tsx`):**
   - Memuat profil cerita usaha kuliner SOJU, penjaminan mutu rantai dingin (-18°C), sertifikasi keamanan pangan, serta detail alamat dan jam operasional dari CMS.

### 3.4 Alur Autentikasi Admin (`/login`)
Folder: `webf/app/(auth)/login/`
- **File:** `page.tsx`, `LoginView.tsx`, `LoginCard.tsx`, `BrandPanel.tsx`, `LoginField.tsx`
- **Alur Kerja:**
  1. Halaman menampilkan panel branding SOJU di kiri dan kartu login di kanan.
  2. Admin memasukkan email dan password, memanggil `authApi.login(email, password)`.
  3. Token JWT disimpan ke `localStorage`. Admin diarahkan ke `/dashboard`.
  4. Bila kredensial tidak cocok, sistem menampilkan pesan peringatan ramah tanpa membocorkan rincian teknis internal.

### 3.5 Alur Dashboard Ringkasan (`/dashboard`)
Folder: `webf/app/dashboard/`
- **Komponen Utama:** `DashboardView.tsx`, `WelcomeHeader.tsx`, `KpiGrid.tsx`, `CashflowChart.tsx`, `CashflowPlot.tsx`, `SourceRatioCard.tsx`, `AiCommandBox.tsx`
- **Alur Kerja:**
  1. Melakukan validasi awal ketersediaan token; jika kosong, langsung redirect ke `/login`.
  2. Menjalankan `Promise.all` paralel untuk mengambil ringkasan KPI kas, tren arus kas, dan rasio input AI.
  3. Merender indikator ringkasan kas (Saldo Kas, Pemasukan, Pengeluaran, Estimasi Laba Bersih).
  4. Merender diagram batang interaktif arus kas harian (`CashflowChart` & `CashflowPlot`) dengan pilihan rentang filter: Semua, Mingguan (7 Hari), dan Bulanan (30 Hari).
  5. Menampilkan rasio input data (berapa persen yang dibuat via Asisten AI vs input Manual).
  6. Menyediakan shortcut cepat ke asisten AI melalui `AiCommandBox`.

### 3.6 Alur Master Transaksi & Pendataan Bebas (`/dashboard/data`)
Folder: `webf/app/dashboard/data/`
- **Komponen Kunci:** `DataView.tsx`, `MasterTransaksiFeed.tsx`, `JenisEntriesTable.tsx`, `TabelBebasTab.tsx`, `TabelBebasDetail.tsx`, `TambahTransaksiModal.tsx`, `EditJenisModal.tsx`, `EditEntryModal.tsx`
- **Alur Kerja Tab Dinamis:**
  1. **Tab 1 ("Master Transaksi"):** Menampilkan feed gabungan seluruh transaksi dari semua jenis transaksi dengan filter tanggal, unit bisnis, pencarian keterangan/kode, serta paginasi.
  2. **Tab 2..N (Tab Spesifik per Jenis Transaksi):** Dibuat otomatis berdasarkan jenis transaksi yang ada di database (contoh: *DO1 - Pendapatan Frozen*, *DO2 - Pendapatan Siap Saji*, *MT1 - Cicilan Hutang*). Pada tab ini, tabel merender kolom-kolom formulir dinamis (`KolomCustom`). Admin dapat menambah/mengedit kolom langsung dari antarmuka modal.
  3. **Tab "Pendataan" (`TabelBebasTab`):** Antarmuka pendataan tabel kustom. Admin dapat membuat tabel baru, mendefinisikan kolom, memasukkan baris data baru, dan menghapus tabel.
  4. **Aksi Tombol Atas:**
     - `Tambah Transaksi`: Membuka modal tambah transaksi universal (`TambahTransaksiModal`) yang formulirnya beradaptasi sesuai jenis yang dipilih.
     - `Export ke Excel`: Memanggil `api.reports.exportTransactions({ jenis_transaksi_id })` untuk men-download file `.xlsx` resmi dari server backend.
     - `Edit Tabel`: Membuka pengaturan nama jenis transaksi dan struktur kolom dinamisnya.

### 3.7 Alur Manajemen CMS & Produk (`/dashboard/cms`)
Folder: `webf/app/dashboard/cms/`
- **Komponen:** `CmsView.tsx`, `ContentTab.tsx`, `MenuTab.tsx`, `HeadlineModal.tsx`, `AboutModal.tsx`, `ContactModal.tsx`, `ProductModal.tsx`, `ImageUpload.tsx`, `VarianEditor.tsx`
- **Alur Kerja:**
  1. **Tab "Konten Halaman" (`ContentTab`):** Admin dapat mengubah copywriting Headline Beranda, Profil Tentang Kami, dan Kontak Toko (No. WhatsApp, Email, Alamat).
  2. **Tab "Menu Makanan" (`MenuTab`):** Admin mengelola master katalog makanan (`Produk`).
  3. **Fitur Unggulan (Star ⭐):** Admin dapat menandai hingga 5 menu sebagai "Unggulan" untuk dimunculkan pada banner beranda customer. Tindakan ini memperbarui data JSON pada key `produk_unggulan` di backend.
  4. **Tambah/Edit Produk:** Membuka `ProductModal`. Admin dapat mengunggah gambar menu (diproses di browser menjadi Base64 FileReader), mengisi nama, harga, deskripsi, dan menambahkan tag varian rasa secara visual melalui `VarianEditor`.

### 3.8 Alur Riwayat Aktivitas & Audit Log (`/dashboard/audit`)
Folder: `webf/app/dashboard/audit/`
- **Komponen:** `AuditView.tsx`, `AuditHeader.tsx`, `FilterBar.tsx`, `StatCards.tsx`, `LogTimeline.tsx`, `LogItem.tsx`
- **Alur Kerja:**
  1. Memuat log aktivitas dari `GET /api/v1/audit-log`.
  2. Menyediakan filter instan berdasarkan Nama Tabel/Sheet (`transaksi`, `jenis_transaksi`, `produk`, `cms_content`, `tabel_bebas`), Sumber Input (`MANUAL` vs `AI`), dan Rentang Tanggal Spesifik (`dateFrom` - `dateTo`).
  3. Menyajikan visualisasi timeline mutasi dengan rincian *diff viewer*: membandingkan nilai kolom "Sebelum" dan "Sesudah" secara akurat dengan label bahasa Indonesia.

### 3.9 Alur Simulasi Asisten AI (`/dashboard/ai`)
Folder: `webf/app/dashboard/ai/`
- **Komponen:** `AiView.tsx`, `ChatComposer.tsx`, `ChatThread.tsx`, `CommandChips.tsx`, `QuickPrompts.tsx`, `DraftCard.tsx`
- **Alur Kerja:**
  - Antarmuka asisten virtual berbasis percakapan untuk simulasi input transaksi pintar bagi pemilik toko.
  - Menerima perintah instan seperti `/add jual`, `/add beli`, `/stock`, atau kalimat natural ("ringkasan penjualan minggu ini").
  - Menghasilkan respon cerdas dan kartu draft transaksi (`DraftCard`) yang merangkum data penjualan/pembelian sebelum dieksekusi.

### 3.10 Alur Profil & Preferensi Toko (`/dashboard/profile`)
Folder: `webf/app/dashboard/profile/`
- **Komponen:** `ProfileView.tsx`, `AkunTab.tsx`, `PengaturanTab.tsx`, `AkunCard.tsx`, `PreferensiCard.tsx`, `NotifikasiCard.tsx`, `UserListCard.tsx`
- **Alur Kerja:**
  - Menampilkan informasi akun admin aktif yang diambil dari `GET /api/v1/auth/me`.
  - Mengatur preferensi toko (format mata uang IDR, bahasa antarmuka, dan simulasi toggle notifikasi WhatsApp/Email).

### 3.11 Status System & Feedback Modals
Folder: `webf/components/feedback/` & `webf/components/status/`
- **Toast Notifications (`ToastProvider.tsx`):** Menampilkan floating toast pop-up di pojok layar untuk konfirmasi mutasi sukses atau gagal.
- **Konfirmasi Dialog (`ConfirmDialog.tsx`):** Modal konfirmasi tindakan destruktif (contoh: "Hapus transaksi ini?", "Hapus kolom ini?").
- **Layar Status Global (`app/status/[kode]/page.tsx` & `StatusScreen.tsx`):** Menangani tampilan status sistem (`404`, `500`, `503`, `offline`, `maintenance`) lengkap dengan ilustrasi maskot interaktif SOJU (`SojuMascot.tsx`).

---

## 4. AUDIT TERPERINCI KODE BEBAN / PENINGGALAN SISTEM LAMA (BURDEN & DEAD CODE)

Bagian ini mendokumentasikan secara rinci seluruh file, potongan kode, atau endpoint yang **merupakan peninggalan versi sistem terdahulu yang sudah tidak digunakan lagi (zombie/dead code)** namun masih tertinggal di dalam repositori.

### 4.1 Prisma & Database Legacy

#### 1. File: `backend/prisma/source-data/SOJU_CORP_FINANCE_MASTER.xlsx` (1.1 MB) & Duplikat Root `./SOJU_CORP_FINANCE_MASTER.xlsx` (1.1 MB)
- **Status:** **SANGAT BEBAN (DEAD FILE & STORAGE BURDEN)**
- **Analisis Sambungan:** 
  - Tidak ada satupun kode di `backend/src` atau `webf` yang membaca atau membuka file Excel ini saat runtime.
  - File ini adalah data mentah transaksi lama milik klien yang dulunya digunakan oleh skrip migrasi awal.
  - Membebani ukuran repositori git sebesar >2.2 MB tanpa memiliki fungsi aktif.

#### 2. File: `backend/prisma/import-excel.ts` (707 baris kode)
- **Status:** **DEAD SCRIPT (DEPRECATED SEJAK 27 SEP 2026)**
- **Analisis Sambungan:** 
  - Pada baris 9–12, skrip ini secara eksplisit diawali dengan instruksi penghentian paksa:
    ```ts
    throw new Error('import-excel.ts sudah deprecated - bulk import Excel tidak dipakai lagi...');
    ```
  - Masih menggunakan skema Prisma lama yang sudah tidak ada di `schema.prisma` saat ini (seperti `TipeTransaksi`, `JurnalEntri`, dll). Jika dipaksa jalan pun akan crash kompilasi.
  - Hanya dirujuk oleh baris skrip di `backend/package.json` (`"import:excel": "tsx prisma/import-excel.ts"`).
  - Tidak ada route backend maupun frontend yang memanggil file ini.

#### 3. File: `backend/local-backups/cms_menu-before-drop-20261112.json`
- **Status:** **DEAD BACKUP FILE**
- **Analisis Sambungan:** File arsip JSON berisi backup isi tabel `cms_menu` sesaat sebelum tabel tersebut di-drop pada migrasi 12 November 2026. Tidak pernah dibaca oleh sistem.

---

### 4.2 Backend Endpoints & Services yang Mati

#### 1. File: `backend/src/services/journalService.ts`
- **Status:** **DEAD FILE / EMPTY ZOMBIE**
- **Analisis Sambungan:**
  - File ini hanya berisi komentar deprecation dan satu baris kode: `export {};`.
  - Ditinggalkan saat pembukuan double-entry journal dihentikan demi sistem jenis transaksi dinamis.
  - Tidak diimpor oleh file manapun di seluruh backend.

#### 2. Fungsi: `getJenisBawaan(kode)` di `backend/src/utils/jenisBawaan.ts`
- **Status:** **DEAD FUNCTION**
- **Analisis Sambungan:**
  - Konstanta `KODE_JENIS_BAWAAN` (`DO1`, `DO2`, `MT1`) masih aktif digunakan oleh `orders.ts` dan `dashboard.ts`.
  - Namun, fungsi helper `export const getJenisBawaan = async (kode: string)` **sama sekali tidak pernah dipanggil di mana pun**. Route `orders.ts` dan `dashboard.ts` mencari record secara independen menggunakan query Prisma langsung.

#### 3. Endpoint: `GET /api/v1/reports/neraca` dan `GET /api/v1/reports/perubahan-modal` di `backend/src/routes/reports.ts`
- **Status:** **DEAD STUB ENDPOINTS (ALWAYS RETURN HTTP 501)**
- **Analisis Sambungan:**
  - Kedua route ini langsung melempar exception `501 Not Implemented`.
  - Frontend `webf` tidak memiliki halaman Laporan Neraca atau Perubahan Modal, dan tidak pernah memanggil endpoint ini dalam UI aktif.

#### 4. Seluruh Router `backend/src/routes/orders.ts` (`GET /api/v1/orders`)
- **Status:** **ORPHANED ROUTE**
- **Analisis Sambungan:**
  - Didaftarkan di `index.ts` pada `/api/v1/orders`.
  - Namun pada frontend `webf`:
    - Pemesanan oleh customer dialihkan langsung ke WhatsApp (`openWhatsApp`).
    - Dashboard ringkasan menghitung total order langsung dari tabel `transaksi` lewat `/dashboard/summary`.
    - Halaman Data (`/dashboard/data`) menampilkan transaksi order di tab jenis `DO1`/`DO2` dan tab `Master Transaksi`.
    - Fungsi `api.orders.getAll` dan `api.orders.getById` di `webf/lib/api.ts` tidak pernah dipanggil oleh komponen frontend manapun.

---

### 4.3 Frontend Dead Routes, Broken Imports & Zombie Code

#### 1. File: `webf/app/api/blob-upload/route.ts`
- **Status:** **KRITIS: BROKEN UNUSED ROUTE**
- **Analisis Sambungan:**
  - File ini mengimpor `@vercel/blob/client`:
    ```ts
    import { handleUpload, type HandleUploadBody } from "@vercel/blob/client";
    ```
  - **Masalah:** Paket `@vercel/blob` **TIDAK TERPASANG** di `package.json` dan tidak ada di folder `node_modules`!
  - **Mengapa aplikasi tidak error?** Karena tidak ada satupun komponen di `webf` yang memanggil rute API `/api/blob-upload`.
  - Upload gambar menu pada aplikasi yang sebenarnya ditangani oleh pembaca Base64 lokal di `useProductEditor.ts` (`FileReader.readAsDataURL`) yang kemudian dikirim via payload JSON langsung ke backend MySQL BLOB.
  - Konfigurasi `BLOB_READ_WRITE_TOKEN=` di `webf/.env.local` juga dibiarkan kosong.

#### 2. Fungsi Dead API di `webf/lib/api.ts`:
- **`cmsApi.getMenu`, `getMenuById`, `createMenu`, `updateMenu`, `deleteMenu`**
  - Mengirim request ke `/cms/menu`. Backend sudah tidak memiliki route ini (tabel `cms_menu` sudah di-drop). Tidak ada komponen UI yang memanggil fungsi ini.
- **`publicCmsApi.getMenu`**
  - Mengirim request ke `/api/public/cms/menu`. Route tidak ada di backend dan tidak dipanggil oleh `CustomerLayout` (navigasi customer sudah menggunakan array statis `NAV`).
- **`reportsApi.getBalanceSheet`, `getIncomeStatement`, `getEquityChanges`, `exportFreeTable`**
  - Dideklarasikan di `api.ts`, namun tidak ada satupun halaman UI yang mengonsumsi keempat method laporan ini. Hanya `api.reports.exportTransactions` yang aktif digunakan pada tombol "Export ke Excel" di `DataView.tsx`.
- **`ordersApi.getAll` dan `ordersApi.getById`**
  - Dideklarasikan di `api.ts`, tidak pernah dipanggil oleh komponen UI.

---

### 4.4 Frontend Dead Components

#### 1. File: `webf/app/dashboard/components/RecentOrders.tsx` & `OrderItem.tsx`
- **Status:** **DEAD UI COMPONENTS**
- **Analisis Sambungan:** Komponen widget daftar order lama yang digantikan oleh tampilan ringkasan kas. Keduanya tidak diimpor atau ditampilkan di dalam `DashboardView.tsx`.

#### 2. File: `webf/app/dashboard/components/SalesTrendChart.tsx` & `TrendPlot.tsx`
- **Status:** **DEAD UI COMPONENTS**
- **Analisis Sambungan:** Komponen grafik lama berbasis omset penjualan. Saat ini `DashboardView.tsx` menggunakan `CashflowChart.tsx` dan `CashflowPlot.tsx` yang berbasis data arus kas (pemasukan vs pengeluaran).

---

### 4.5 File Sampah & Arsip Fisik yang Membebani Workspace

1. **`webf/app.zip` (177 KB)**: File arsip zip cadangan folder `app` lama yang tertinggal di root folder `webf`.
2. **`webf/components.zip` (23 KB)**: File arsip zip cadangan folder `components` lama yang tertinggal di root folder `webf`.
3. **`webf/ddsd` (8.2 KB)**: File log sampah hasil pengalihan (redirect) output terminal Git CLI ke file sembarang.
4. **Dokumen Spesifikasi Usang di Root Workspace**:
   - `DOKUMENTASI_ALUR_KERJA.md`: Menjelaskan sistem akuntansi jurnal umum lama yang sudah di-drop.
   - `database.md`: Menjelaskan skema lama dengan tabel `jurnal_entri`, `data_pelanggan`, `data_pemasok`, `hutang`.
   - `api.md`: Menjelaskan endpoint CRUD pelanggan/supplier/stok yang tidak ada di source aktif.
   - `schema_baru_draft (2).prisma`, `cleanup.sql`, `schema.sql`: Draf skema lama yang tidak dipakai oleh Prisma.

---

## 5. PEMERIKSAAN INTEGRITAS SAMBUNGAN (SAFETY & CONNECTION CHECK)

Berdasarkan instruksi: *"pastikan tidak menyentuh alur yang sudah sesuai jelas?"*, telah dilakukan verifikasi komprehensif terhadap seluruh keterikatan file:

1. **Apakah sistem yang sedang berjalan di localhost:4000 dan localhost:3000 bergantung pada kode beban di atas?**
   - **TIDAK.** Seluruh alur aktif yang sedang berjalan saat ini (Customer browsing, WhatsApp order generation, Login admin, Dashboard kas, Transaksi Finansial, Kolom Kustom Dinamis, Pendataan Bebas, CMS Halaman & Menu, serta Audit Log) beroperasi secara independen dari file-file beban di atas.
2. **Status Database:**
   - Database `soju_1hustle` sudah berada pada kondisi migrasi terbaru (`20261112060000_drop_cms_menu`). Tidak ada ketergantungan asing ke file Excel master.
3. **Status Pustaka Build:**
   - Backend TypeScript dikompilasi dari `backend/src/` ke `backend/dist/`. File `import-excel.ts` dan `source-data` berada di folder `prisma/` di luar `src/`, sehingga tidak mengganggu kompilasi backend utama.
   - Frontend Next.js tidak mengalami crash kompilasi karena file bermasalah seperti `blob-upload/route.ts` tidak pernah diimpor oleh tree komponen React.

---

## 6. TABEL MATRIKS HUBUNGAN ANTAR-FILE & STATUS KEAKTIFAN

| Kategori | Nama File / Komponen | Peran & Alur Kerja | Hubungan Antar File | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Backend Core** | `backend/src/index.ts` | Bootstrap Express, CORS, port 4000, error handler | Mendaftarkan seluruh router di `src/routes/*` | **AKTIF** |
| **Backend Core** | `src/middleware/auth.ts` | Verifikasi Bearer Token JWT | Dipakai oleh semua router privat | **AKTIF** |
| **Backend Core** | `src/services/authService.ts` | Logika login bcrypt & JWT sign | Dipanggil oleh `routes/auth.ts` | **AKTIF** |
| **Backend Core** | `src/routes/auth.ts` | Endpoint `/auth/login` dan `/auth/me` | Dipanggil oleh `webf/lib/api.ts` (`authApi`) | **AKTIF** |
| **Backend Core** | `src/routes/transactions.ts` | CRUD transaksi, nomor urut atomic, audit trail | Berelasi ke `JenisTransaksi`, `LogAudit`, `Pengguna` | **AKTIF** |
| **Backend Core** | `src/routes/transactionTypes.ts` | Master jenis transaksi & formulir kolom kustom | Mengelola `JenisTransaksi` & `KolomCustom` | **AKTIF** |
| **Backend Core** | `src/routes/dashboard.ts` | Agregasi saldo kas, grafik kas harian, rasio AI | Dikonsumsi oleh `webf/app/dashboard` | **AKTIF** |
| **Backend Core** | `src/routes/products.ts` | CRUD produk, upload gambar Base64 ke BLOB | Menyimpan ke tabel `produk`, melayani binary gambar | **AKTIF** |
| **Backend Core** | `src/routes/productsPublic.ts` | API publik produk aktif (tanpa auth) | Dikonsumsi oleh `webf/app/customer` | **AKTIF** |
| **Backend Core** | `src/routes/cms.ts` | Admin CRUD konten headline, about, kontak, unggulan | Mengelola tabel `cms_content` | **AKTIF** |
| **Backend Core** | `src/routes/cmsPublic.ts` | API publik konten halaman (dengan fallback) | Dikonsumsi oleh `webf/app/customer` | **AKTIF** |
| **Backend Core** | `src/routes/freeTables.ts` | Spreadsheet bebas (kolom dinamis & JSON rows) | Mengelola `TabelBebas`, `KolomTabelBebas`, `BarisTabelBebas` | **AKTIF** |
| **Backend Core** | `src/routes/auditLog.ts` | Log audit aktivitas dengan visual diff parser | Mengolah tabel `log_audit` | **AKTIF** |
| **Backend Core** | `src/routes/reports.ts` | Ekspor Excel transaksi dan laba rugi | Menggunakan lib `xlsx`, dipanggil `DataView.tsx` | **AKTIF** |
| **Backend Core** | `src/utils/database.ts` | Singleton Prisma Client | Digunakan seluruh router & service | **AKTIF** |
| **Backend Core** | `src/utils/response.ts` | Standardisasi response JSON sukses/gagal | Digunakan seluruh router | **AKTIF** |
| **Backend Legacy** | `src/services/journalService.ts` | Sisa file jurnal umum double-entry | Dihapus (tidak diimpor oleh siapapun) | **TERHAPUS (BERSIH)** |
| **Backend Legacy** | `src/utils/jenisBawaan.ts` -> `getJenisBawaan` | Helper pencarian jenis bawaan | Dihapus (hanya konstanta yang dipertahankan) | **TERHAPUS (BERSIH)** |
| **Backend Legacy** | `src/routes/orders.ts` | Endpoint virtual order | Dipertahankan untuk kompatibilitas API | **AKTIF (STANDBY)** |
| **Prisma Legacy** | `prisma/import-excel.ts` | Skrip bulk import Excel lama | Dihapus beserta skrip package.json | **TERHAPUS (BERSIH)** |
| **Prisma Legacy** | `prisma/source-data/*.xlsx` | File binary Excel master keuangan lama (1.1 MB) | Dihapus beserta foldernya | **TERHAPUS (BERSIH)** |
| **Prisma Legacy** | `local-backups/*.json` | Backup tabel cms_menu sebelum di-drop | Dihapus beserta foldernya | **TERHAPUS (BERSIH)** |
| **Frontend Core** | `webf/lib/api.ts` | HTTP Fetcher terpusat + JWT interceptor | Dipakai di seluruh halaman admin dan publik | **AKTIF** |
| **Frontend Core** | `webf/lib/whatsapp.ts` | Generator teks pesanan dan link wa.me | Dipakai di seluruh halaman customer & modal | **AKTIF** |
| **Frontend Core** | `webf/app/customer/*` | Storefront customer (Home, Menu, About, Contact) | Membuka WhatsApp untuk pesanan | **AKTIF** |
| **Frontend Core** | `webf/app/dashboard/*` | Dashboard analitik kas eksekutif | Memanggil `api.dashboard` | **AKTIF** |
| **Frontend Core** | `webf/app/dashboard/data/*` | Master Transaksi, Jenis Tab, Pendataan Bebas | Memanggil `transactions`, `transactionTypes`, `freeTables` | **AKTIF** |
| **Frontend Core** | `webf/app/dashboard/cms/*` | CMS teks, upload gambar menu, produk unggulan | Memanggil `cms` dan `products` | **AKTIF** |
| **Frontend Core** | `webf/app/dashboard/audit/*` | Riwayat aktivitas dan diff viewer | Memanggil `auditLog` | **AKTIF** |
| **Frontend Core** | `webf/app/dashboard/ai/*` | Simulasi asisten AI chat & draft card | UI State interaktif asisten toko | **AKTIF** |
| **Frontend Core** | `webf/app/dashboard/profile/*` | Profil admin dan preferensi toko | Memanggil `auth.getMe` | **AKTIF** |
| **Frontend Legacy** | `webf/app/api/blob-upload/route.ts` | Endpoint upload Vercel blob (missing pkg) | Dihapus beserta folder `app/api` | **TERHAPUS (BERSIH)** |
| **Frontend Legacy** | `dashboard/components/RecentOrders.tsx` | Widget order lama | Dihapus (tidak dirender di Dashboard) | **TERHAPUS (BERSIH)** |
| **Frontend Legacy** | `dashboard/components/OrderItem.tsx` | Item list order lama | Dihapus | **TERHAPUS (BERSIH)** |
| **Frontend Legacy** | `dashboard/components/SalesTrendChart.tsx` | Grafik penjualan lama | Dihapus | **TERHAPUS (BERSIH)** |
| **Frontend Legacy** | `dashboard/components/TrendPlot.tsx` | Plot grafik penjualan lama | Dihapus | **TERHAPUS (BERSIH)** |
| **Frontend Legacy** | `webf/app.zip`, `components.zip`, `ddsd` | Arsip zip dan dump output git di root webf | Dihapus permanen | **TERHAPUS (BERSIH)** |
| **Frontend Legacy** | Method menu di `webf/lib/api.ts` | Method menu CRUD dan public menu lama | Dihapus dari `api.ts` | **TERHAPUS (BERSIH)** |

---

*Dokumen ini disusun sebagai panduan arsitektur definitif dan peta keamanan kode sebelum dilakukan refactoring atau pembersihan berkala.*
