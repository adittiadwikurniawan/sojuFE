# Buku Dapur (Soju) — Flutter Mobile

Aplikasi mobile internal untuk Admin Utama & Co-Operator. Repo ini berisi hasil
slicing UI Figma dan alur data Phase A (mock) dengan clean architecture.

## Fitur yang sudah ada

- Splash, onboarding, login, daftar, dan lupa password
- Dashboard dan bottom navigation
- Analytics dengan filter tanggal dan ekspor Excel (mock)
- Chatbot Soju (mock)
- Audit log dan manajemen stok (baca-saja, mock)
- Profil dan menu akun (mock)
- Tabel Bebas — modal **Buat Kategori Baru** (mock create)
- Date picker / filter tanggal bersama

## Prasyarat

- Flutter **3.24.5 stable** (Dart **3.5.4**)
- Android Studio + Android SDK (untuk emulator/perangkat Android)
- Git

Cek versi:

```bash
flutter --version
flutter doctor
```

## Menjalankan aplikasi

```bash
git clone https://github.com/adittiadwikurniawan/sojuFE.git
cd sojuFE
flutter pub get
flutter devices
flutter run -d <device-id>
```

Contoh untuk Android:

```bash
flutter emulators
flutter emulators --launch <emulator-id>
flutter run
```

Opsional di browser:

```bash
flutter run -d chrome
```

Tidak perlu backend atau file `.env`. Semua data Phase A berasal dari mock
datasource di `lib/data/`.

## Menjalankan pemeriksaan

```bash
dart format .
flutter analyze
flutter test
```

Untuk menjalankan test tertentu:

```bash
flutter test test/presentation/screens/free_tables/free_table_category_screen_test.dart
```

## Struktur singkat

```text
lib/
├── app/            # app, config, DI, routes, error handling
├── core/           # common, errors, services, themes, utilities
├── data/           # datasources (mock/remote), models, repositories
├── domain/         # entities, failures, repositories, usecases
├── presentation/   # providers, screens, widgets
└── main.dart
test/               # mirror struktur lib/
assets/
├── fonts/          # Plus Jakarta Sans & Inter
└── images/         # aset hasil slicing Figma
```

Arah dependency: `presentation → domain ← data`. Domain tidak boleh bergantung
pada Flutter UI.

## Catatan Phase A (mock)

- Datasource mock dan remote dipilih di `lib/data/data_providers.dart`.
- Form **Buat Kategori Baru** hanya mengembalikan draft yang dikirim; belum ada
  kontrak API final. Saat endpoint tersedia, ganti mock dengan implementasi REST
  di layer `data` tanpa mengubah presentation.
- Route `/free-tables/create` sudah tersedia, tetapi belum dipasang entry point
  dari halaman lain.
- Beberapa aksi (chatbot, ekspor, profil) masih berupa UI/mock.

## Troubleshooting

- **`flutter pub get` gagal** — pastikan Flutter 3.24.5 dan Dart 3.5.4.
- **Font tidak muncul** — jalankan `flutter pub get`, lalu restart aplikasi
  (hot reload tidak memuat font baru).
- **Android license** — jalankan `flutter doctor --android-licenses`.
- **Build kotor** — `flutter clean && flutter pub get`.

## Konvensi commit

- `feat(scope): ...` untuk fitur baru
- `fix(scope): ...` untuk perbaikan
- `test(scope): ...` untuk test
- `docs: ...` untuk dokumentasi
- `refactor(scope): ...` untuk perubahan struktur tanpa mengubah perilaku
