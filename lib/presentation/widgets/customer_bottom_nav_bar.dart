// lib/presentation/widgets/customer_bottom_nav_bar.dart
//
// Navbar bawah 5-tab untuk Shell Pelanggan (`UserRole.customer`, AD-11):
// `Beranda | Menu | Keranjang | Pesanan | Akun`.

import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';

/// Tinggi area navbar Pelanggan tanpa safe area bawah.
const double kCustomerBottomNavBarHeight = 84;

/// Lima tab berlabel pada Shell Pelanggan (`Beranda | Menu | Keranjang | Pesanan | Akun`).
enum CustomerNavTab {
  beranda(
    label: 'Beranda',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  menu(
    label: 'Menu',
    icon: Icons.restaurant_menu_outlined,
    activeIcon: Icons.restaurant_menu_rounded,
  ),
  keranjang(
    label: 'Keranjang',
    icon: Icons.shopping_bag_outlined,
    activeIcon: Icons.shopping_bag_rounded,
  ),
  pesanan(
    label: 'Pesanan',
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
  ),
  akun(
    label: 'Akun',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  );

  const CustomerNavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  /// Label navigasi Bahasa Indonesia pada bilah bawah Pelanggan.
  final String label;

  /// Ikon saat tab tidak aktif.
  final IconData icon;

  /// Ikon saat tab aktif.
  final IconData activeIcon;
}

/// Navbar bawah 5-tab untuk akun Pelanggan (`CUSTOMER`).
class CustomerBottomNavBar extends StatelessWidget {
  const CustomerBottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    this.cartBadgeCount = 0,
  });

  final CustomerNavTab activeTab;
  final ValueChanged<CustomerNavTab> onTabSelected;

  /// Jumlah item aktif di keranjang (opsional untuk badge tab Keranjang).
  final int cartBadgeCount;

  static const double _designWidth = 430;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double scale = (width > 480 ? 480 : width) / _designWidth;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: SojuColors.surface,
        border: Border(
          top: BorderSide(color: SojuColors.hairline),
        ),
        boxShadow: <BoxShadow>[
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
          key: const Key('customer_bottom_nav_content'),
          height: kCustomerBottomNavBarHeight * scale,
          child: Row(
            children: <Widget>[
              for (final CustomerNavTab tab in CustomerNavTab.values)
                Expanded(
                  child: _CustomerBottomNavItem(
                    scale: scale,
                    tab: tab,
                    active: tab == activeTab,
                    badgeCount:
                        tab == CustomerNavTab.keranjang ? cartBadgeCount : 0,
                    onTap: () => onTabSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerBottomNavItem extends StatelessWidget {
  const _CustomerBottomNavItem({
    required this.scale,
    required this.tab,
    required this.active,
    required this.badgeCount,
    required this.onTap,
  });

  final double scale;
  final CustomerNavTab tab;
  final bool active;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? SojuColors.brandNavy : SojuColors.navInactive;

    return Semantics(
      button: true,
      selected: active,
      label: tab.label,
      child: InkWell(
        key: Key('customer_nav_${tab.name}'),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (active)
              Positioned(
                top: 0,
                child: Container(
                  width: 30 * scale,
                  height: 3 * scale,
                  decoration: BoxDecoration(
                    color: SojuColors.brandNavy,
                    borderRadius: BorderRadius.circular(17.45 * scale),
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Icon(
                      active ? tab.activeIcon : tab.icon,
                      size: 25 * scale,
                      color: color,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        top: -5 * scale,
                        right: -8 * scale,
                        child: Container(
                          key: const Key('customer_cart_badge'),
                          padding: EdgeInsets.symmetric(
                            horizontal: 5 * scale,
                            vertical: 1.5 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: SojuColors.brandNavy,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 9.5 * scale,
                              fontWeight: FontWeight.w700,
                              color: SojuColors.surface,
                            ),
                          ),
                        ),
                      ),
                  ],
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
