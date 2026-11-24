// lib/presentation/screens/customer/customer_catalog_screen.dart
//
// Tab Menu Pelanggan (`/customer/menu`): katalog `/api/public/products`,
// membuka Product Detail Bottom Sheet lalu menambah item ke keranjang.

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/storefront_entity.dart';
import '../../../data/data_providers.dart';
import '../../providers/storefront/customer_cart_controller.dart';
import '../../providers/storefront/customer_catalog_controller.dart';
import '../../utils/format.dart';
import '../../widgets/bottom_glass_overlay.dart';
import 'widgets/product_detail_sheet.dart';
import 'widgets/storefront_widgets.dart';

class CustomerCatalogScreen extends StatefulWidget {
  const CustomerCatalogScreen({
    super.key,
    this.catalogController,
    this.cartController,
    this.catalogControllerFactory,
    this.cartControllerFactory,
    this.onOpenCart,
  });

  final CustomerCatalogController? catalogController;
  final CustomerCartController? cartController;
  final CustomerCatalogController Function()? catalogControllerFactory;
  final CustomerCartController Function()? cartControllerFactory;
  final VoidCallback? onOpenCart;

  @override
  State<CustomerCatalogScreen> createState() => _CustomerCatalogScreenState();
}

class _CustomerCatalogScreenState extends State<CustomerCatalogScreen> {
  CustomerCatalogController? _internalCatalogController;
  CustomerCartController? _internalCartController;

  CustomerCatalogController get _catalogController =>
      widget.catalogController ?? _internalCatalogController!;

  CustomerCartController get _cartController =>
      widget.cartController ?? _internalCartController!;

  @override
  void initState() {
    super.initState();
    if (widget.catalogController == null) {
      _internalCatalogController = widget.catalogControllerFactory?.call() ??
          CustomerCatalogController(
            getProducts: DataProviders.getCatalogProducts(),
          );
    }
    if (widget.cartController == null) {
      _internalCartController = widget.cartControllerFactory?.call() ??
          CustomerCartController(
            getCart: DataProviders.getCart(),
            saveCart: DataProviders.saveCart(),
          );
    }
    if (_catalogController.status == CatalogStatus.initial) {
      _catalogController.load();
    }
    if (_cartController.status == CartStatus.initial) {
      _cartController.load();
    }
  }

  @override
  void didUpdateWidget(CustomerCatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.catalogController != null &&
        widget.catalogController != oldWidget.catalogController) {
      if (widget.catalogController!.status == CatalogStatus.initial) {
        widget.catalogController!.load();
      }
    }
    if (widget.cartController != null &&
        widget.cartController != oldWidget.cartController) {
      if (widget.cartController!.status == CartStatus.initial) {
        widget.cartController!.load();
      }
    }
  }

  @override
  void dispose() {
    _internalCatalogController?.dispose();
    _internalCartController?.dispose();
    super.dispose();
  }

  Future<void> _openProduct(CatalogProduct product) async {
    final ProductSelection? selection =
        await showProductDetailSheet(context, product);
    if (selection == null || !mounted) return;
    final bool ok = await _cartController.addProduct(
      product,
      variant: selection.variant,
      quantity: selection.quantity,
      note: selection.note,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? '${product.name} ditambahkan ke keranjang.'
                : (_cartController.syncError ??
                    'Gagal menambahkan ke keranjang.'),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('customer_menu_screen'),
      backgroundColor: SojuColors.homeBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          StorefrontHeader(
            title: 'Menu SOJU',
            subtitle: 'Pilih menu favorit dan tambahkan ke keranjang.',
            trailing: ListenableBuilder(
              listenable: _cartController,
              builder: (BuildContext context, _) => IconButton(
                key: const Key('customer_menu_open_cart'),
                tooltip: 'Buka Keranjang',
                onPressed: widget.onOpenCart,
                icon: Badge(
                  isLabelVisible: _cartController.totalQuantity > 0,
                  label: Text('${_cartController.totalQuantity}'),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _catalogController,
              builder: (BuildContext context, _) => _body(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    final CustomerCatalogController c = _catalogController;
    switch (c.status) {
      case CatalogStatus.initial:
      case CatalogStatus.loading:
        return const StorefrontStateView.loading(message: 'Memuat menu...');
      case CatalogStatus.error:
        return StorefrontStateView(
          icon: Icons.cloud_off_rounded,
          title: 'Menu gagal dimuat',
          message: c.errorMessage ?? 'Terjadi kesalahan. Coba lagi.',
          actionLabel: 'Coba Lagi',
          actionKey: const Key('customer_catalog_retry'),
          onAction: c.load,
        );
      case CatalogStatus.empty:
        return StorefrontStateView(
          icon: Icons.storefront_outlined,
          title: 'Belum ada menu tersedia',
          message: 'Menu SOJU akan tampil di sini setelah tersedia.',
          actionLabel: 'Muat Ulang',
          actionKey: const Key('customer_catalog_retry'),
          onAction: c.load,
        );
      case CatalogStatus.loaded:
        return RefreshIndicator(
          onRefresh: c.load,
          child: ListView.separated(
            key: const Key('customer_catalog_list'),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, kBottomContentInset),
            itemCount: c.products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int i) {
              final CatalogProduct p = c.products[i];
              return _ProductCard(product: p, onTap: () => _openProduct(p));
            },
          ),
        );
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final CatalogProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SojuColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: Key('customer_product_${product.id}'),
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SojuColors.hairline),
          ),
          child: Row(
            children: <Widget>[
              StorefrontProductImage(url: product.imageUrl, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: SojuColors.ink,
                      ),
                    ),
                    if (product.hasVariants) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        product.variants.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12.5,
                          color: SojuColors.inkMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      formatRupiah(product.price),
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SojuColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add_circle_rounded, color: SojuColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
