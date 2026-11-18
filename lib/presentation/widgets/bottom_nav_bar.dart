// lib/presentation/widgets/bottom_nav_bar.dart
//
// Navbar bawah Buku Dapur — salinan node Figma `801:4265` (instance Navbar)
// yang dipakai pada slicing Analytics. Bentuk, warna, dan proporsi mengikuti
// node tersebut; tidak ada penyesuaian label/ikon selain yang ada di Figma.

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';

/// Tinggi area navbar Figma tanpa safe area bawah.
const double kBottomNavBarHeight = 114;

/// Empat tab berlabel pada navbar Figma `801:4265`.
///
/// Tombol `+` di tengah bukan bagian dari enum ini karena tidak memiliki
/// keadaan aktif.
enum BottomNavTab {
  home(label: 'Home', icon: Icons.home_outlined),
  analytics(label: 'Analytics', icon: Icons.bar_chart),
  aiAssistant(label: 'Ai Asistant', icon: Icons.chat_bubble_outline),
  audit(label: 'Audit & Stok', icon: Icons.inventory_2_outlined);

  const BottomNavTab({required this.label, required this.icon});

  /// Teks persis seperti pada node Figma (termasuk ejaan "Asistant").
  final String label;

  /// Ikon garis besar sesuai bentuk pada node Figma.
  final IconData icon;
}

/// Navbar bawah tetap, rata tengah, dan mengikuti safe area perangkat.
///
/// Dipasang oleh shell GoRouter sebagai `bottomNavigationBar` Scaffold. Widget
/// ini tidak mengetahui rute: pilihan tab dan tombol `+` diteruskan lewat
/// callback agar tetap reusable.
class BukuDapurBottomNavBar extends StatelessWidget {
  const BukuDapurBottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    required this.onAddTap,
    this.glassEnabled = true,
  });

  final BottomNavTab activeTab;
  final ValueChanged<BottomNavTab> onTabSelected;

  /// Tombol `+` di tengah navbar Figma. Tidak melakukan aksi tulis: rute
  /// menampilkan informasi bahwa pencatatan belum tersedia.
  final VoidCallback onAddTap;

  /// Mematikan blur kaca pada tab tertentu (dipakai area chat Ai Asistant).
  final bool glassEnabled;

  /// Lebar desain acuan node Figma.
  static const double _designWidth = 430;

  /// Jarak sebelum slot mulai (tempat tombol `+` mengambang).
  static const double _topSpacing = 30;

  /// Diameter lingkaran gradien tombol `+`.
  static const double _addSize = 60;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double scale = (width > 480 ? 480 : width) / _designWidth;

    // SafeArea ada di dalam komponen agar setiap pemakai otomatis menghormati
    // gesture bar / home indicator perangkat.
    return SafeArea(
      top: false,
      maintainBottomViewPadding: true,
      child: SizedBox(
        key: const Key('bottom_nav_content'),
        height: kBottomNavBarHeight * scale,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            // Bar putih dengan lekukan setengah lingkaran di tengah, seperti
            // boolean "Subtract" pada node Figma.
            Positioned.fill(
              child: ClipPath(
                clipper: _NavbarBarClipper(
                  barTop: _topSpacing * scale,
                  notchRadius: 43 * scale,
                ),
                child: glassEnabled
                    ? BackdropFilter(
                        key: const Key('bottom_nav_glass'),
                        filter: ImageFilter.blur(
                          sigmaX: 18 * scale,
                          sigmaY: 18 * scale,
                        ),
                        child: ColoredBox(
                          color: SojuColors.surface.withOpacity(0.88),
                        ),
                      )
                    : const ColoredBox(color: SojuColors.surface),
              ),
            ),
            Column(
              children: <Widget>[
                SizedBox(height: _topSpacing * scale),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      _slot(BottomNavTab.home, scale),
                      _slot(BottomNavTab.analytics, scale),
                      const Expanded(child: SizedBox()),
                      _slot(BottomNavTab.aiAssistant, scale),
                      _slot(BottomNavTab.audit, scale),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              child: _AddButton(scale: scale, onTap: onAddTap),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(BottomNavTab tab, double scale) {
    return Expanded(
      child: _BottomNavItem(
        scale: scale,
        tab: tab,
        active: tab == activeTab,
        onTap: () => onTabSelected(tab),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.scale,
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final double scale;
  final BottomNavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? SojuColors.primary : SojuColors.navInactive;

    return Semantics(
      button: true,
      selected: active,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (active)
              Positioned(
                top: 0,
                child: Container(
                  width: 28 * scale,
                  height: 3 * scale,
                  decoration: BoxDecoration(
                    color: SojuColors.primary,
                    borderRadius: BorderRadius.circular(17.45 * scale),
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(tab.icon, size: 28 * scale, color: color),
                SizedBox(height: 2.3 * scale),
                Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11.63 * scale,
                    fontWeight: FontWeight.w400,
                    color: color,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tambah',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          key: const Key('bottom_nav_add'),
          width: BukuDapurBottomNavBar._addSize * scale,
          height: BukuDapurBottomNavBar._addSize * scale,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[SojuColors.sky, SojuColors.primary],
            ),
          ),
          child: Icon(Icons.add, size: 23 * scale, color: Colors.white),
        ),
      ),
    );
  }
}

/// Memotong lekukan setengah lingkaran di tengah bar putih navbar.
class _NavbarBarClipper extends CustomClipper<Path> {
  const _NavbarBarClipper({required this.barTop, required this.notchRadius});

  final double barTop;
  final double notchRadius;

  @override
  Path getClip(Size size) {
    final Rect bar = Rect.fromLTRB(0, barTop, size.width, size.height);
    final Path notch = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width / 2, barTop),
          radius: notchRadius,
        ),
      );

    return Path.combine(
      PathOperation.difference,
      Path()..addRect(bar),
      notch,
    );
  }

  @override
  bool shouldReclip(covariant _NavbarBarClipper oldClipper) =>
      oldClipper.barTop != barTop || oldClipper.notchRadius != notchRadius;
}
