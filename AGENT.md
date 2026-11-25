# AGENT.md — Panduan Agent & Kontributor `sojuFe`

Dokumen ini menjadi panduan utama bagi AI coding agent dan developer yang bekerja di repositori Flutter **Buku Dapur SOJU** (`sojuFe`).

---

## 1. Path Kanonik & Lingkungan Build

- **Canonical Git Repo**: `/Users/mymac/KULIAH/SEMESTER 3/sojuFe`
  - **Selalu** apit path dengan tanda kutip ganda (`"..."`) di shell karena path mengandung spasi (`SEMESTER 3`).
  - Verifikasi status git sebelum & sesudah mengedit: `git -C "/Users/mymac/KULIAH/SEMESTER 3/sojuFe" status`.
- **Android / Gradle**:
  - Project memakai Gradle `8.3` + AGP `8.1.0` + `flutter_secure_storage: 8.1.0` + `google_sign_in_android: 6.1.26`.
  - **Wajib menggunakan Java 17 LTS** (`JAVA_HOME` / `flutter config --jdk-dir`). Jangan gunakan JDK 21+ atau JDK 25 bawaan Android Studio terbaru karena akan memicu `Unsupported class file major version 69`.
- **Backend Origin**:
  - Default lokal: `http://localhost:4000` (macOS/iOS/Web) dan `http://10.0.2.2:4000` (Android Emulator).
  - Untuk perangkat fisik atau produksi, override lewat `--dart-define=API_BASE_URL=http://<LAN_IP_OR_DOMAIN>:4000/api/v1`.
  - Dalam lingkungan sandbox yang tidak bisa menulis ke `~/.config/flutter`, jalankan dengan `env HOME=/tmp`.

---

## 2. Arsitektur Clean Architecture & State Management

Ikuti pemisahan layer ketat sesuai `ARCHITECTURE.md`:

- `lib/domain/` — Entity murni (`@immutable`), kontrak repository (`abstract interface class`), dan usecase single-purpose. Bebas dari Flutter/HTTP.
- `lib/data/` — Datasource interface, implementasi remote (`ApiClient`) & mock fallback, DTO model parsing envelope `{success, data, message?}`, dan `RepositoryImpl` yang selalu mengembalikan `Result<T>` (`SuccessResult` / `FailureResult` dengan `AppFailure`).
- `lib/presentation/providers/` — `ChangeNotifier` controllers yang menerima usecase lewat konstruktor/factory dan mengelola state (`loading`, `empty`, `error`, `loaded`).
- `lib/presentation/screens/` & `lib/presentation/widgets/` — UI memakai `ListenableBuilder`, mendukung `controllerFactory` (untuk menjaga state saat `GoRouter` rebuild ketika route anak di-pop).
- `lib/data/data_providers.dart` — Composition root & fallback ke mock datasource saat unit/widget test berjalan tanpa `DataProviders.configure(...)`.

---

## 3. Sistem Multi-Peran & Guard Navigasi (`AD-08`, `AD-11`)

Tiga peran terisolasi ketat pada `AppRouter` (`lib/app/routes/app_routes.dart`):

1. **Pelanggan (`UserRole.customer`)** — Portal masuk `/api/customer/*`, etalase publik `/api/public/*`:
   - Shell 5-tab: Beranda (`/customer`), Menu (`/customer/menu`), Keranjang (`/customer/keranjang`), Pesanan (`/customer/pesanan`), Akun (`/customer/akun`), plus Checkout (`/customer/checkout`).
   - Diblokir dari seluruh rute Admin/Super Admin.
2. **Admin (`UserRole.admin`)** — Portal masuk `/api/v1/auth/login`:
   - Shell 5-tab: Home (`/dashboard`), Pesanan (`/orders`), Data (`/analytics` & `/data`), AI Chatbot (`/chatbot`), Akun (`/profile`), serta Drawer Operasional (Pesanan, Log Audit `/audit`, Akun).
   - Diblokir dari rute Pelanggan dan rute eksklusif Super Admin.
3. **Super Admin (`UserRole.superAdmin`)**:
   - Seluruh akses Admin ditambah modul Drawer eksklusif (`superAdminOnly: true`): Kelola Pengguna (`/admin/users`), Konten CMS & Produk (`/admin/cms`), Pelanggan & CRM (`/admin/crm`).

---

## 4. Standar UI/UX, Copy, & AI Chatbot

- **Design Tokens**: Selalu gunakan `SojuColors` (`lib/core/themes/soju_colors.dart`), `AppTypography`, dan helper format `formatRupiah` (`lib/presentation/utils/format.dart`). Jangan hardcode palet warna baru di luar token jika token sudah tersedia.
- **Bahasa**: Seluruh label UI, pesan error/sukses, dan tombol wajib berbahasa **Indonesia** yang konsisten.
- **Customer Storefront (Mobile E-Commerce)**:
  - Beranda menampilkan header sapaan + avatar, banner promo hero, kategori horizontal, dan ringkasan pesanan.
  - Katalog Menu memakai grid responsif (2 kolom di mobile, 3–4 kolom di layar lebar) dengan toggle favorit, filter kategori, pencarian, dan **Product Detail Bottom Sheet** (hero image, info produk, varian, stepper jumlah `1..99`, catatan maks 255 karakter).
- **Admin & Super Admin Product Editor**:
  - Layar `AdminProductEditorScreen` responsif: 2 panel berdampingan di layar lebar (`>= 840px`) dan 1 kolom + bottom action bar di mobile (`< 840px`), mencakup panel Media Cover, Visibilitas (`aktif`), Pratinjau langsung ke `ProductDetailSheet`, serta tab Detail Produk (`Umum` & `Lanjutan`).
- **AI Chatbot Hybrid RAG**:
  - Draf penjualan yang dihasilkan AI **tidak boleh auto-commit** ke database tanpa konfirmasi eksplisit pengguna; sitasi sumber harus dapat ditinjau di `AiCitationsSheet`.

---

## 5. Aturan Pengujian & Verifikasi Wajib

Setiap perubahan kode **wajib** diverifikasi sebelum commit:

```bash
cd "/Users/mymac/KULIAH/SEMESTER 3/sojuFe"
env HOME=/tmp flutter analyze
env HOME=/tmp flutter test
```

- **Jaga stabilitas Widget `Key`**: Jangan mengubah atau menghapus `Key(...)` yang sudah dipakai test suite (`customer_home_screen`, `customer_menu_screen`, `customer_catalog_list`, `product_detail_sheet`, `customer_checkout_button`, `admin_cms_screen`, `halo` greeting text, dsb.).
- Note `AGENTS.md` (dengan `S`) dikelola otomatis oleh `figma-cli`; jangan hapus blok `figma-cli rules` di dalamnya.
