# Soju — Onboarding Slicing

Proyek Flutter ini men-slice layar **Onboarding** dari file Figma
[`UI-UX-Soju`](https://www.figma.com/design/oMHkmtfYQJtJm2Z32QR6IS/UI-UX-Soju)
menjadi widget Flutter lengkap dengan **animasi masuk (entrance)**.

## Cara menjalankan

```bash
cd "sojuFe"
flutter pub get
flutter run            # pilih device iPhone / Android
flutter test           # smoke test
```

Entry point: `lib/main.dart` → `OnboardingScreen`.

## Struktur kode

```
lib/
├─ main.dart                              # entry point
├─ theme/
│  └─ soju_colors.dart                    # design token hasil ekstrak Figma
└─ screens/onboarding/
   ├─ onboarding_screen.dart              # PageView + orkestrasi animasi & navigasi
   ├─ widgets/
   │  ├─ entrance.dart                    # staggered Fade + Slide (per elemen)
   │  ├─ ui.dart                          # FeaturePill, SlideDots, PrimaryButton, GlassCard, dll
   │  ├─ charts.dart                      # MiniBars, AreaChart, WaveDivider (CustomPaint)
   │  └─ on_nav.dart                      # InheritedWidget penghubung tombol → PageController
   └─ pages/
      ├─ onboarding_page_one.dart
      ├─ onboarding_page_two.dart
      ├─ onboarding_page_three.dart
      ├─ onboarding_page_four.dart
      ├─ onboarding_page_five.dart
      └─ onboarding_page_six.dart
```

## Mapping ke Figma

| Halaman | Sumber | Frame Figma | Ukuran |
|---|---|---|---|
| Onboarding 1 – Kelola Keuangan Bisnis Lebih Mudah | Figma | `798:1765` | 390×738 |
| Onboarding 2 – Asisten AI & Kategorisasi Otomatis | Figma | `798:1882` | 390×762 |
| Onboarding 3 – Kembangkan Bisnis dengan Penuh Percaya Diri | Figma | `798:1991` | 390×754 |
| Onboarding 4 – Obrolan AI untuk Rekap Lebih Cepat | Desain tambahan\* | — | 390 |
| Onboarding 5 – Kontrol Stok & Alert Tepat Waktu | Desain tambahan\* | — | 390 |
| Onboarding 6 – Laporan Lengkap untuk Ambil Keputusan | Desain tambahan\* | — | 390 |

\* File Figma hanya berisi **3 frame onboarding**. Halaman 4–6 dibuat mengikuti
gaya visual yang sama (kartu gradient, chips, tipografi) memakai fitur aplikasi
yang sudah ada di desain (AI Chat, stok, laporan).

Screenshot referensi ada di `design/figma/`.

## Palet & tipografi

Diekstrak dari Figma (`lib/theme/soju_colors.dart`):

| Token | Warna |
|---|---|
| Primary | `#1969FF` |
| Primary dark | `#0051D2` |
| Primary light | `#DBE1FF` |
| Green (sukses) | `#00855C` / `#85F8C4` |
| Amber | `#F59E0B` / `#FBBF24` / `#FEF3C7` |
| Ink / teks | `#191C1E` / `#424655` |
| Chip netral | `#ECEEF0` / `#F2F4F6` |

Font: **Inter** (Regular / Medium / Semi Bold / Bold). Karena belum di-bundle,
`fontFamily: 'Inter'` akan memakai fallback sistem bila font tidak tersedia —
tambahkan Inter ke `pubspec.yaml` bila ingin persis sesuai Figma.

## Animasi

1. **Transisi antar-halaman** — `PageView` dengan `easeOutCubic` (560ms).
2. **Entrance per halaman** — `AnimationController` 1400ms dimulai ulang setiap
   halaman menjadi aktif (`_onPageChanged` → `forward(from: 0)`).
   Setiap elemen dibungkus `Entrance` dengan interval berurutan:
   - kartu ilustrasi (0.0–0.5)
   - judul + deskripsi (0.35–0.7)
   - pills fitur (0.55–0.85)
   - dots + tombol (0.75–1.0)
3. **Dots indicator** — melebar (`AnimatedContainer`) mengikuti halaman aktif.
4. **Pulsing dot** — indikator "AI ENGINE ACTIVE" berdenyut di halaman 2.

## Tombol

- **Lanjutkan / Mulai Sekarang** → halaman berikutnya (via `OnNav`).
- **Langkah Sebelumnya** → halaman sebelumnya.
- Di halaman terakhir, tombol menampilkan SnackBar "Onboarding selesai!" sebagai
  placeholder menuju layar Login yang belum di-slice.