// lib/presentation/widgets/role_shell_screens.dart
//
// Kerangka tampilan Bahasa Indonesia untuk rute shell Pelanggan, Pesanan Admin,
// serta halaman Drawer khusus Super Admin (`Users`, `CMS`, `CRM`) pada TASK-023.
// Slice domain/data live masing-masing disambungkan pada TASK-024..TASK-027.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';
import '../../domain/entities/auth_session_entity.dart';
import 'bottom_glass_overlay.dart';

/// Kerangka layar tab Beranda Pelanggan (`/customer`).
class CustomerHomeShellScreen extends StatelessWidget {
  const CustomerHomeShellScreen({
    super.key,
    this.user,
    this.onBrowseMenu,
    this.onViewOrders,
    this.onOpenCart,
    this.cartCount = 0,
  });

  final AuthUser? user;
  final VoidCallback? onBrowseMenu;
  final VoidCallback? onViewOrders;
  final VoidCallback? onOpenCart;
  final int cartCount;

  String _initials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String greetingName =
        (user?.name.trim().isNotEmpty ?? false) ? user!.name : 'Pelanggan';
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      key: const Key('customer_home_screen'),
      backgroundColor: SojuColors.homeBackground,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxWidth = math.min(constraints.maxWidth, 640);
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: maxWidth,
              height: constraints.maxHeight,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  18,
                  topInset + 16,
                  18,
                  kBottomContentInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: SojuColors.infoSoft,
                          child: Text(
                            _initials(greetingName),
                            style: const TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: SojuColors.primaryDeep,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Selamat datang,',
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 12,
                                  color: SojuColors.inkMuted,
                                ),
                              ),
                              Text(
                                'Halo, $greetingName!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: SojuColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _HeaderSquareAction(
                          icon: Icons.shopping_cart_outlined,
                          tooltip: 'Keranjang',
                          badgeCount: cartCount,
                          onTap: onOpenCart ?? onBrowseMenu,
                        ),
                        const SizedBox(width: 8),
                        _HeaderSquareAction(
                          icon: Icons.receipt_long_outlined,
                          tooltip: 'Pesanan',
                          onTap: onViewOrders,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Color(0xFFEAF2FF),
                            Color(0xFFD6E6FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: SojuColors.freeTableBlueBorder60),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: SojuColors.ink,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: 'Hemat hingga '),
                                      TextSpan(
                                        text: '50%',
                                        style: TextStyle(
                                          color: SojuColors.expense,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Penawaran terbatas untuk menu pilihan SOJU hari ini.',
                                  style: TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: SojuColors.inkMuted,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  key: const Key('customer_home_open_menu'),
                                  onPressed: onBrowseMenu,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: SojuColors.primary,
                                    foregroundColor: SojuColors.surface,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Pesan Sekarang',
                                    style: TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: SojuColors.surface.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.fastfood_rounded,
                              size: 42,
                              color: SojuColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Kategori',
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.ink,
                          ),
                        ),
                        TextButton(
                          onPressed: onBrowseMenu,
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: SojuColors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          for (final (String label, bool active) in <(String, bool)>[
                            ('Semua', true),
                            ('Minuman', false),
                            ('Makanan', false),
                            ('Camilan', false),
                            ('Paket', false),
                          ]) ...<Widget>[
                            InkWell(
                              onTap: onBrowseMenu,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? SojuColors.primary
                                      : SojuColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: active
                                        ? SojuColors.primary
                                        : SojuColors.hairline,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: active
                                        ? SojuColors.surface
                                        : SojuColors.ink,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Menu Pilihan untuk Kamu',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: SojuColors.ink,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: onBrowseMenu,
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: SojuColors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _HomeHighlightCard(
                            title: 'Menu Minuman',
                            subtitle: 'Segar & favorit',
                            icon: Icons.local_bar_rounded,
                            onTap: onBrowseMenu,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HomeHighlightCard(
                            title: 'Menu Makanan',
                            subtitle: 'Siap santap',
                            icon: Icons.rice_bowl_rounded,
                            onTap: onBrowseMenu,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoActionCard(
                      icon: Icons.receipt_long_rounded,
                      title: 'Status Pesanan',
                      description:
                          'Pantau progres pesanan yang sedang diproses hingga selesai.',
                      actionKey: const Key('customer_home_open_orders'),
                      actionLabel: 'Lihat Pesanan',
                      onAction: onViewOrders,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderSquareAction extends StatelessWidget {
  const _HeaderSquareAction({
    required this.icon,
    required this.tooltip,
    this.badgeCount = 0,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final int badgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SojuColors.hairline),
          ),
          alignment: Alignment.center,
          child: Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            child: Icon(icon, size: 20, color: SojuColors.ink),
          ),
        ),
      ),
    );
  }
}

class _HomeHighlightCard extends StatelessWidget {
  const _HomeHighlightCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SojuColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 76,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: SojuColors.infoSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 34, color: SojuColors.primary),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12,
                  color: SojuColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kerangka layar tab Menu Pelanggan (`/customer/menu`).
class CustomerMenuShellScreen extends StatelessWidget {
  const CustomerMenuShellScreen({
    super.key,
    this.onOpenCart,
  });

  final VoidCallback? onOpenCart;

  @override
  Widget build(BuildContext context) {
    return _SojuShellPageScaffold(
      key: const Key('customer_menu_screen'),
      title: 'Menu SOJU',
      subtitle: 'Pilih menu favorit dan tambahkan ke keranjang belanja.',
      children: <Widget>[
        _InfoActionCard(
          icon: Icons.storefront_outlined,
          title: 'Daftar Produk & Varian',
          description:
              'Katalog produk publik SOJU siap dipilih lengkap dengan varian '
              'dan catatan pesanan.',
          actionKey: const Key('customer_menu_open_cart'),
          actionLabel: 'Buka Keranjang',
          onAction: onOpenCart,
        ),
      ],
    );
  }
}

/// Kerangka layar tab Keranjang Pelanggan (`/customer/keranjang`).
class CustomerCartShellScreen extends StatelessWidget {
  const CustomerCartShellScreen({
    super.key,
    this.onCheckout,
    this.onBrowseMenu,
  });

  final VoidCallback? onCheckout;
  final VoidCallback? onBrowseMenu;

  @override
  Widget build(BuildContext context) {
    return _SojuShellPageScaffold(
      key: const Key('customer_cart_screen'),
      title: 'Keranjang Belanja',
      subtitle: 'Periksa kembali item pilihanmu sebelum melakukan checkout.',
      children: <Widget>[
        _InfoActionCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Ringkasan Keranjang',
          description:
              'Atur jumlah item atau lanjutkan pengiriman pesanan ke dapur SOJU.',
          actionKey: const Key('customer_checkout_button'),
          actionLabel: 'Lanjut ke Checkout',
          onAction: onCheckout,
          secondaryActionLabel: 'Tambah Menu',
          onSecondaryAction: onBrowseMenu,
        ),
      ],
    );
  }
}

/// Kerangka layar Checkout Pelanggan (`/customer/checkout`).
class CustomerCheckoutShellScreen extends StatelessWidget {
  const CustomerCheckoutShellScreen({
    super.key,
    this.onBack,
    this.onViewOrders,
  });

  final VoidCallback? onBack;
  final VoidCallback? onViewOrders;

  @override
  Widget build(BuildContext context) {
    return _SojuShellPageScaffold(
      key: const Key('customer_checkout_screen'),
      title: 'Checkout Pesanan',
      subtitle: 'Konfirmasi alamat pengiriman dan rincian pesanan Anda.',
      onBack: onBack,
      backButtonKey: const Key('customer_checkout_back'),
      children: <Widget>[
        _InfoActionCard(
          icon: Icons.local_shipping_outlined,
          title: 'Pengiriman & Konfirmasi',
          description: 'Pastikan alamat tujuan dan nomor telepon aktif sebelum '
              'mengirim pesanan.',
          actionKey: const Key('customer_checkout_orders_button'),
          actionLabel: 'Lihat Riwayat Pesanan',
          onAction: onViewOrders,
        ),
      ],
    );
  }
}

/// Kerangka layar tab Pesanan Pelanggan (`/customer/pesanan`).
class CustomerOrdersShellScreen extends StatelessWidget {
  const CustomerOrdersShellScreen({
    super.key,
    this.onBrowseMenu,
  });

  final VoidCallback? onBrowseMenu;

  @override
  Widget build(BuildContext context) {
    return _SojuShellPageScaffold(
      key: const Key('customer_orders_screen'),
      title: 'Pesanan Saya',
      subtitle: 'Riwayat dan status pesanan Anda di SOJU.',
      children: <Widget>[
        _InfoActionCard(
          icon: Icons.assignment_outlined,
          title: 'Riwayat Pesanan Pelanggan',
          description:
              'Status menunggu konfirmasi, diproses, selesai, dan dibatalkan '
              'ditampilkan di halaman ini.',
          actionLabel: 'Pesan Lagi',
          onAction: onBrowseMenu,
        ),
      ],
    );
  }
}

/// Kerangka layar tab Akun Pelanggan (`/customer/akun`).
class CustomerAccountShellScreen extends StatelessWidget {
  const CustomerAccountShellScreen({
    super.key,
    this.user,
    this.onLogout,
  });

  final AuthUser? user;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final String name =
        (user?.name.trim().isNotEmpty ?? false) ? user!.name : 'Pelanggan SOJU';
    final String email = (user?.email.trim().isNotEmpty ?? false)
        ? user!.email
        : 'pelanggan@sojucorp.com';

    return _SojuShellPageScaffold(
      key: const Key('customer_account_screen'),
      title: 'Akun Pelanggan',
      subtitle: 'Kelola profil pengiriman dan keamanan akun Anda.',
      badgeLabel: UserRole.customer.label,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SojuColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13.5,
                  color: SojuColors.inkMuted,
                ),
              ),
              if (user?.phone != null &&
                  user!.phone!.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Telepon: ${user!.phone}',
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 13,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
              if (user?.address != null &&
                  user!.address!.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  'Alamat: ${user!.address}',
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 13,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
              if (onLogout != null) ...<Widget>[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('customer_logout_button'),
                    onPressed: onLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SojuColors.expense,
                      side: const BorderSide(
                        color: SojuColors.profileCardBorder,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 19),
                    label: const Text(
                      'Keluar Akun',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Kerangka layar tab Pesanan pada Shell Admin & Super Admin (`/orders`).
class AdminOrdersShellScreen extends StatelessWidget {
  const AdminOrdersShellScreen({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return _SojuShellPageScaffold(
      key: const Key('admin_orders_screen'),
      title: 'Pesanan Pelanggan',
      subtitle: 'Pantau dan perbarui status pesanan masuk dari pelanggan.',
      onMenuTap: onMenuTap,
      onNotificationTap: onNotificationTap,
      reserveBottomGlassSpace: true,
      children: const <Widget>[
        _InfoActionCard(
          icon: Icons.assignment_turned_in_outlined,
          title: 'Antrean Pesanan Masuk',
          description:
              'Kelola pesanan berstatus Menunggu Konfirmasi, Diproses, '
              'Selesai, atau Dibatalkan secara terpusat.',
        ),
      ],
    );
  }
}

/// Kerangka layar Drawer khusus `SUPER_ADMIN` (`/admin/users`, `/admin/cms`, `/admin/crm`).
class SuperAdminModuleScreen extends StatelessWidget {
  const SuperAdminModuleScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cardTitle,
    required this.cardDescription,
    required this.icon,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final String cardTitle;
  final String cardDescription;
  final IconData icon;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return _SojuShellPageScaffold(
      title: title,
      subtitle: subtitle,
      badgeLabel: UserRole.superAdmin.label,
      onBack: onBack,
      backButtonKey: const Key('super_admin_module_back'),
      children: <Widget>[
        _InfoActionCard(
          icon: icon,
          title: cardTitle,
          description: cardDescription,
        ),
      ],
    );
  }
}

class _SojuShellPageScaffold extends StatelessWidget {
  const _SojuShellPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.badgeLabel,
    this.onBack,
    this.backButtonKey,
    this.onMenuTap,
    this.onNotificationTap,
    this.reserveBottomGlassSpace = false,
  });

  final String title;
  final String subtitle;
  final String? badgeLabel;
  final VoidCallback? onBack;
  final Key? backButtonKey;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final bool reserveBottomGlassSpace;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: SojuColors.homeBackground,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = math.min(constraints.maxWidth, 480);
          final double scale = width / 430;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: SojuColors.surface,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28 * scale),
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x18000000),
                          offset: Offset(0, 2),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                      18 * scale,
                      topInset + 18 * scale,
                      18 * scale,
                      20 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            if (onBack != null) ...<Widget>[
                              Semantics(
                                button: true,
                                label: 'Kembali',
                                child: GestureDetector(
                                  key: backButtonKey,
                                  onTap: onBack,
                                  child: Container(
                                    width: 44 * scale,
                                    height: 44 * scale,
                                    decoration: const BoxDecoration(
                                      color: SojuColors.surfaceMuted,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 18 * scale,
                                      color: SojuColors.ink,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                            ] else if (onMenuTap != null) ...<Widget>[
                              Semantics(
                                button: true,
                                label: 'Menu Admin',
                                child: GestureDetector(
                                  key: const Key('admin_drawer_button'),
                                  onTap: onMenuTap,
                                  child: Container(
                                    width: 44 * scale,
                                    height: 44 * scale,
                                    decoration: const BoxDecoration(
                                      color: SojuColors.field,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.menu_rounded,
                                      size: 22 * scale,
                                      color: SojuColors.ink,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                            ],
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 20 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: SojuColors.ink,
                                ),
                              ),
                            ),
                            if (badgeLabel != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10 * scale,
                                  vertical: 4 * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: SojuColors.infoSoft,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  badgeLabel!,
                                  style: TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 11.5 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: SojuColors.primaryDeep,
                                  ),
                                ),
                              ),
                            if (onNotificationTap != null) ...<Widget>[
                              SizedBox(width: 10 * scale),
                              GestureDetector(
                                onTap: onNotificationTap,
                                child: Container(
                                  width: 44 * scale,
                                  height: 44 * scale,
                                  decoration: const BoxDecoration(
                                    color: SojuColors.field,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications_none,
                                    size: 22 * scale,
                                    color: SojuColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 13.5 * scale,
                            height: 1.4,
                            color: SojuColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16 * scale,
                        18 * scale,
                        16 * scale,
                        reserveBottomGlassSpace
                            ? kBottomContentInset * scale
                            : 28 * scale,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoActionCard extends StatelessWidget {
  const _InfoActionCard({
    required this.icon,
    required this.title,
    required this.description,
    this.actionKey,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final Key? actionKey;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SojuColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: SojuColors.infoSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: SojuColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13.5,
              height: 1.45,
              color: SojuColors.inkMuted,
            ),
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  key: actionKey,
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: SojuColors.primary,
                    foregroundColor: SojuColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontFamily: AppTypography.family,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (secondaryActionLabel != null && onSecondaryAction != null)
                  OutlinedButton(
                    onPressed: onSecondaryAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SojuColors.primaryDeep,
                      side: const BorderSide(color: SojuColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      secondaryActionLabel!,
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
