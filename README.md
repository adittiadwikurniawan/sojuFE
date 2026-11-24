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

Opsional di browser (port 3000 agar cocok dengan `CORS_ORIGIN` backend;
backend development juga mengizinkan port localhost/LAN lain):

```bash
flutter run -d chrome --web-port=3000
```

Fitur selain auth masih memakai mock Phase A di `lib/data/`; auth memakai
backend REST.

## Menghubungkan backend auth

Login email/password, daftar, dan login Google sudah memakai REST API backend
Dea. Backend tetap repo terpisah.

1. Jalankan backend (repo `-1Backend-kakdea-FnB`):

   ```bash
   npm install
   npx prisma generate
   npm run dev
   ```

   Pastikan `.env` backend berisi `DATABASE_URL`, `JWT_SECRET`, dan
   `GOOGLE_CLIENT_ID` (OAuth Web Client ID).

2. Jalankan Flutter:

   ```bash
   # Android emulator (default 10.0.2.2:4000/api/v1)
   flutter run

   # iOS simulator / desktop / web (default localhost:4000/api/v1)
   flutter run -d "iPhone 15"

   # Web (disarankan port 3000)
   flutter run -d chrome --web-port=3000

   # Perangkat fisik: ganti dengan IP LAN komputer, bukan localhost
   flutter run -d <device-id> \
     --dart-define=API_BASE_URL=http://192.168.1.10:4000/api/v1
   ```

   `flutter devices` menampilkan ID perangkat. Di perangkat fisik, `localhost`
   menunjuk ke perangkat itu sendiri sehingga login/daftar akan gagal jika
   `API_BASE_URL` tidak diarahkan ke komputer yang menjalankan backend.

   Untuk macOS, sandbox aplikasi sudah diberi izin
   `com.apple.security.network.client` dan `keychain-access-groups`. Tanpa
   keduanya, login bisa gagal walau backend dan URL API sudah benar.

3. Login Google (opsional, butuh Google Cloud Console):

   ```bash
   flutter run \
     --dart-define=GOOGLE_WEB_CLIENT_ID=<web-client-id>.apps.googleusercontent.com \
     --dart-define=GOOGLE_IOS_CLIENT_ID=<ios-client-id>.apps.googleusercontent.com
   ```

   - Android: daftarkan package `com.soju.soju_fe` + SHA-1 debug ke Google
     Cloud Console. SHA-1 debug bisa dilihat dengan:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore \
       -alias androiddebugkey -storepass android -keypass android
     ```
   - iOS: tambahkan reversed iOS Client ID ke `CFBundleURLSchemes` di
     `ios/Runner/Info.plist`. Bentuknya seperti
     `com.googleusercontent.apps.1234567890-abcdef`.
   - Web: tambahkan authorized JavaScript origin `http://localhost:3000` pada
     OAuth Web Client ID.
   - Backend: isi `GOOGLE_CLIENT_ID` dengan Web Client ID yang sama.

Tanpa konfigurasi Google, tombol Google menampilkan pesan bahwa login Google
belum dikonfigurasi. Token JWT disimpan di secure storage (Keychain/Keystore),
bukan SharedPreferences.

Lupa password memanggil `POST /auth/forgot-password`. Tautan di email memakai
`RESET_PASSWORD_URL` di backend (default
`http://localhost:3000/reset-password`); halaman reset password web belum
termasuk di repo Flutter ini.

Untuk perangkat iOS fisik yang memakai HTTP LAN:

- `Info.plist` sudah mengaktifkan `NSAllowsLocalNetworking` dan
  `NSLocalNetworkUsageDescription`.
- Disarankan memakai hostname `.local` komputer, misalnya
  `http://MacBook-Pro.local:4000/api/v1`.
- iOS 17+ memblokir HTTP ke alamat IP secara default. Jika memakai IP, tambahkan
  IP tersebut ke `NSExceptionDomains` dengan
  `NSExceptionAllowsInsecureHTTPLoads = true`, atau gunakan HTTPS.
- Android sudah diizinkan HTTP hanya untuk `10.0.2.2`, `localhost`, dan
  `127.0.0.1` lewat `network_security_config.xml`; perangkat Android fisik
  sebaiknya memakai HTTPS atau konfigurasi network security debug.

Akun seed backend: `admin@bukudapur.com` / `password123`.

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
