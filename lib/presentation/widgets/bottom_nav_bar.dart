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
                          color: SojuColors.surface.withValues(alpha: 0.88),
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

/// Tinggi navbar 5-tab Admin / Super Admin tanpa safe area bawah.
const double kAdminBottomNavBarHeight = 84;

/// Lima tab berlabel pada Shell Admin & Super Admin (AD-11, TASK-023):
/// `Home | Pesanan | Data | AI | Akun`.
enum AdminNavTab {
  home(
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  orders(
    label: 'Pesanan',
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
  ),
  data(
    label: 'Data',
    icon: Icons.table_chart_outlined,
    activeIcon: Icons.table_chart_rounded,
  ),
  ai(
    label: 'AI',
    icon: Icons.auto_awesome_outlined,
    activeIcon: Icons.auto_awesome_rounded,
  ),
  account(
    label: 'Akun',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  );

  const AdminNavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  /// Label navigasi pada bilah bawah Admin.
  final String label;

  /// Ikon saat tab tidak aktif.
  final IconData icon;

  /// Ikon saat tab sedang aktif.
  final IconData activeIcon;
}

/// Navbar bawah 5-tab untuk Shell `ADMIN` dan `SUPER_ADMIN`.
///
/// Mempertahankan efek kaca SOJU ([SojuColors.surface] + blur) pada tab
/// selain percakapan AI, serta menghormati safe area bawah perangkat.
class AdminBottomNavBar extends StatelessWidget {
  const AdminBottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    this.glassEnabled = true,
  });

  final AdminNavTab activeTab;
  final ValueChanged<AdminNavTab> onTabSelected;
  final bool glassEnabled;

  static const double _designWidth = 430;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double scale = (width > 480 ? 480 : width) / _designWidth;

    final Widget barSurface = DecoratedBox(
      decoration: BoxDecoration(
        color: glassEnabled
            ? SojuColors.surface.withValues(alpha: 0.90)
            : SojuColors.surface,
        border: const Border(
          top: BorderSide(color: SojuColors.hairline),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            offset: Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        maintainBottomViewPadding: true,
        child: SizedBox(
          key: const Key('admin_bottom_nav_content'),
          height: kAdminBottomNavBarHeight * scale,
          child: Row(
            children: <Widget>[
              for (final AdminNavTab tab in AdminNavTab.values)
                Expanded(
                  child: _AdminBottomNavItem(
                    scale: scale,
                    tab: tab,
                    active: tab == activeTab,
                    onTap: () => onTabSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!glassEnabled) {
      return barSurface;
    }

    return ClipRect(
      child: BackdropFilter(
        key: const Key('bottom_nav_glass'),
        filter: ImageFilter.blur(
          sigmaX: 18 * scale,
          sigmaY: 18 * scale,
        ),
        child: barSurface,
      ),
    );
  }
}

class _AdminBottomNavItem extends StatelessWidget {
  const _AdminBottomNavItem({
    required this.scale,
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final double scale;
  final AdminNavTab tab;
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
        key: Key('admin_nav_${tab.name}'),
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
                Icon(
                  active ? tab.activeIcon : tab.icon,
                  size: 25 * scale,
                  color: color,
                ),
                SizedBox(height: 4 * scale),
                Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11.5 * scale,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
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
