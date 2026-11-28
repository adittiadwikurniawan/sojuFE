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
import '../../domain/entities/customer_order_entity.dart';
import '../../domain/entities/storefront_entity.dart';
import '../providers/customer/customer_orders_controller.dart';
import '../providers/storefront/customer_catalog_controller.dart';
import '../utils/format.dart';
import 'bottom_glass_overlay.dart';
import 'smart_auto_fit_image.dart';

/// Layar tab Beranda Pelanggan (`/customer`) dengan **Menu Unggulan ★ live**,
/// **Ringkasan 4 Status Pesanan live**, dan **Ikon Lonceng Notifikasi**.
class CustomerHomeShellScreen extends StatefulWidget {
  const CustomerHomeShellScreen({
    super.key,
    this.user,
    this.onBrowseMenu,
    this.onViewOrders,
    this.onOpenCart,
    this.onLoginTap,
    this.onNotificationTap,
    this.catalogControllerFactory,
    this.ordersControllerFactory,
    this.cartCount = 0,
  });

  final AuthUser? user;
  final VoidCallback? onBrowseMenu;
  final VoidCallback? onViewOrders;
  final VoidCallback? onOpenCart;
  final VoidCallback? onLoginTap;
  final VoidCallback? onNotificationTap;
  final CustomerCatalogController Function()? catalogControllerFactory;
  final CustomerOrdersController Function()? ordersControllerFactory;
  final int cartCount;

  @override
  State<CustomerHomeShellScreen> createState() =>
      _CustomerHomeShellScreenState();
}

class _CustomerHomeShellScreenState extends State<CustomerHomeShellScreen> {
  CustomerCatalogController? _catalogController;
  CustomerOrdersController? _ordersController;

  @override
  void initState() {
    super.initState();
    if (widget.catalogControllerFactory != null) {
      _catalogController = widget.catalogControllerFactory!();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _catalogController?.status == CatalogStatus.initial) {
          _catalogController?.load();
        }
      });
    }
    if (widget.user != null && widget.ordersControllerFactory != null) {
      _ordersController = widget.ordersControllerFactory!();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _ordersController != null &&
            _ordersController!.orders.isEmpty &&
            !_ordersController!.isLoading) {
          _ordersController?.loadOrders();
        }
      });
    }
  }

  @override
  void dispose() {
    _catalogController?.dispose();
    _ordersController?.dispose();
    super.dispose();
  }

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
    final List<Listenable> listenables = <Listenable>[
      if (_catalogController != null) _catalogController!,
      if (_ordersController != null) _ordersController!,
    ];

    if (listenables.isEmpty) {
      return _buildBody(context);
    }

    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (BuildContext context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final AuthUser? user = widget.user;
    final String greetingName =
        (user?.name.trim().isNotEmpty ?? false) ? user!.name : 'Pelanggan';
    final double topInset = MediaQuery.paddingOf(context).top;

    final List<CatalogProduct> featuredProducts =
        (_catalogController?.products ?? const <CatalogProduct>[])
            .take(4)
            .toList(growable: false);
    final List<CustomerOrder> orders =
        _ordersController?.orders ?? const <CustomerOrder>[];
    final int pendingCount = orders
        .where(
            (CustomerOrder o) => o.status == CustomerOrderStatus.menungguKonfirmasi)
        .length;
    final int processingCount = orders
        .where((CustomerOrder o) => o.status == CustomerOrderStatus.diproses)
        .length;
    final int completedCount = orders
        .where((CustomerOrder o) => o.status == CustomerOrderStatus.selesai)
        .length;
    final int cancelledCount = orders
        .where((CustomerOrder o) => o.status == CustomerOrderStatus.dibatalkan)
        .length;
    final CustomerOrder? latestOrder = orders.isNotEmpty ? orders.first : null;

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
                        if (user == null && widget.onLoginTap != null) ...<Widget>[
                          FilledButton.icon(
                            key: const Key('customer_guest_login_button'),
                            onPressed: widget.onLoginTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: SojuColors.brandNavy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.login_rounded, size: 16),
                            label: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (widget.onNotificationTap != null) ...<Widget>[
                          _HeaderSquareAction(
                            icon: Icons.notifications_none_rounded,
                            tooltip: 'Notifikasi',
                            onTap: widget.onNotificationTap,
                          ),
                          const SizedBox(width: 8),
                        ],
                        _HeaderSquareAction(
                          icon: Icons.shopping_cart_outlined,
                          tooltip: 'Keranjang',
                          badgeCount: widget.cartCount,
                          onTap: widget.onOpenCart ?? widget.onBrowseMenu,
                        ),
                        const SizedBox(width: 8),
                        _HeaderSquareAction(
                          icon: Icons.receipt_long_outlined,
                          tooltip: 'Pesanan',
                          onTap: widget.onViewOrders,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Search Bar cepat menuju katalog menu
                    InkWell(
                      onTap: widget.onBrowseMenu,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: SojuColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: SojuColors.cardBorder),
                        ),
                        child: const Row(
                          children: <Widget>[
                            Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: SojuColors.inkMuted,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Cari menu unggulan SOJU...',
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 13.5,
                                  color: SojuColors.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Hero Banner (disamakan dengan prototype index.html)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              SojuColors.brandNavy,
                              Color(0xFF1E40AF),
                              Color(0xFF0284C7),
                            ],
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Color(0x1A0F172A),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              right: -28,
                              top: -28,
                              child: Container(
                                width: 136,
                                height: 136,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF8ED1E4)
                                      .withOpacity(0.20),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 24,
                              bottom: 14,
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.10),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          Icons.verified_user_outlined,
                                          size: 13,
                                          color: SojuColors.brandNavy,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Buku Dapur SOJU',
                                          style: TextStyle(
                                            fontFamily: AppTypography.family,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: SojuColors.brandNavy,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Frozen Food & Siap Saji SOJU',
                                    style: TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pesan aneka frozen food segar langsung dari dapur kami.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 12,
                                      height: 1.35,
                                      color: Colors.white.withOpacity(0.90),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  FilledButton(
                                    key: const Key('customer_home_open_menu'),
                                    onPressed: widget.onBrowseMenu,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: SojuColors.brandEmerald,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Pesan Sekarang →',
                                      style: TextStyle(
                                        fontFamily: AppTypography.family,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Ringkasan 4 Status Pesanan
                    const Text(
                      'Ringkasan Pesanan',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: SojuColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _OrderMiniStatusBox(
                            label: 'Menunggu',
                            count: user != null ? pendingCount : null,
                            icon: Icons.schedule_rounded,
                            color: SojuColors.amberInk,
                            bg: SojuColors.amberSoft,
                            onTap: widget.onViewOrders,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _OrderMiniStatusBox(
                            label: 'Diproses',
                            count: user != null ? processingCount : null,
                            icon: Icons.local_fire_department_rounded,
                            color: SojuColors.brandBlue,
                            bg: SojuColors.blueSoft,
                            onTap: widget.onViewOrders,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _OrderMiniStatusBox(
                            label: 'Selesai',
                            count: user != null ? completedCount : null,
                            icon: Icons.check_circle_rounded,
                            color: SojuColors.brandEmerald,
                            bg: SojuColors.incomeSoft,
                            onTap: widget.onViewOrders,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _OrderMiniStatusBox(
                            label: 'Batal',
                            count: user != null ? cancelledCount : null,
                            icon: Icons.cancel_rounded,
                            color: SojuColors.brandDanger,
                            bg: SojuColors.expenseSoft,
                            onTap: widget.onViewOrders,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Expanded(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.star_rounded,
                                size: 20,
                                color: Color(0xFFF59E0B),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Menu Unggulan ★',
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
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onBrowseMenu,
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
                    if (featuredProducts.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: featuredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        itemBuilder: (BuildContext context, int idx) {
                          final CatalogProduct p = featuredProducts[idx];
                          return _FeaturedProductCard(
                            product: p,
                            onTap: widget.onBrowseMenu,
                          );
                        },
                      )
                    else
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _HomeHighlightCard(
                              title: 'Menu Minuman ★',
                              subtitle: 'Segar & favorit',
                              icon: Icons.local_bar_rounded,
                              onTap: widget.onBrowseMenu,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _HomeHighlightCard(
                              title: 'Menu Makanan ★',
                              subtitle: 'Pilihan terbaik',
                              icon: Icons.rice_bowl_rounded,
                              onTap: widget.onBrowseMenu,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    _InfoActionCard(
                      icon: Icons.receipt_long_rounded,
                      title: latestOrder != null
                          ? 'Pesanan Terbaru • ${latestOrder.code}'
                          : 'Pesanan Terbaru',
                      description: latestOrder != null
                          ? '${latestOrder.status.label} • ${formatRupiah(latestOrder.total)} (${latestOrder.paymentStatus.label})'
                          : 'Lihat struk digital, bayar via Midtrans, atau konfirmasi langsung ke WhatsApp.',
                      actionKey: const Key('customer_home_open_orders'),
                      actionLabel: 'Lihat Pesanan',
                      onAction: widget.onViewOrders,
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

class _OrderMiniStatusBox extends StatelessWidget {
  const _OrderMiniStatusBox({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    this.count,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final int? count;
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SojuColors.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              if (count != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  const _FeaturedProductCard({
    required this.product,
    this.onTap,
  });

  final CatalogProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SojuColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    SmartAutoFitImage(
                      imageUrl: product.imageUrl,
                      borderRadius: BorderRadius.circular(12),
                      placeholderIcon: Icons.fastfood_rounded,
                    ),
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          '★ Unggulan',
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: SojuColors.amberInk,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatRupiah(product.price),
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: SojuColors.brandNavy,
                ),
              ),
            ],
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

class _InfoActionCard extends StatelessWidget {
  const _InfoActionCard({
    required this.icon,
    required this.title,
    required this.description,
    this.actionKey,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final Key? actionKey;
  final String? actionLabel;
  final VoidCallback? onAction;

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
              ],
            ),
          ],
        ],
      ),
    );
  }
}
