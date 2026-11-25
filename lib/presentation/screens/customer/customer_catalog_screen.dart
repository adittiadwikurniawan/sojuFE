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
  static const List<String> _categories = <String>[
    'Semua',
    'Minuman',
    'Makanan',
    'Camilan',
    'Paket',
  ];

  CustomerCatalogController? _internalCatalogController;
  CustomerCartController? _internalCartController;
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _favorites = <int>{};
  String _selectedCategory = 'Semua';

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
    _searchController.dispose();
    _internalCatalogController?.dispose();
    _internalCartController?.dispose();
    super.dispose();
  }

  List<CatalogProduct> _filteredProducts(List<CatalogProduct> all) {
    if (_selectedCategory == 'Semua') return all;
    final String key = _selectedCategory.toLowerCase();
    final List<CatalogProduct> matched = all.where((CatalogProduct p) {
      final String haystack =
          '${p.name} ${p.unit} ${p.variants.join(' ')} ${p.description ?? ''}'
              .toLowerCase();
      return haystack.contains(key);
    }).toList(growable: false);
    return matched.isEmpty ? all : matched;
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
        final List<CatalogProduct> items = _filteredProducts(c.products);
        return RefreshIndicator(
          onRefresh: c.load,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextField(
                        key: const Key('customer_catalog_search'),
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (String value) => c.load(search: value),
                        decoration: InputDecoration(
                          hintText: 'Cari menu, varian, atau kode...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    c.load(search: '');
                                  },
                                ),
                          filled: true,
                          fillColor: SojuColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: SojuColors.hairline,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: SojuColors.hairline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            for (final String category in _categories) ...<Widget>[
                              ChoiceChip(
                                label: Text(category),
                                selected: _selectedCategory == category,
                                selectedColor: SojuColors.primary,
                                backgroundColor: SojuColors.surface,
                                labelStyle: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedCategory == category
                                      ? SojuColors.surface
                                      : SojuColors.ink,
                                ),
                                side: BorderSide(
                                  color: _selectedCategory == category
                                      ? SojuColors.primary
                                      : SojuColors.hairline,
                                ),
                                onSelected: (_) => setState(
                                  () => _selectedCategory = category,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  kBottomContentInset,
                ),
                sliver: SliverLayoutBuilder(
                  builder: (BuildContext context, dynamic constraints) {
                    final double width = constraints.crossAxisExtent;
                    final int columns = width >= 1080
                        ? 4
                        : width >= 720
                            ? 3
                            : 2;
                    return SliverGrid(
                      key: const Key('customer_catalog_list'),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int i) {
                          final CatalogProduct p = items[i];
                          final bool isFav = _favorites.contains(p.id);
                          return _ProductGridCard(
                            product: p,
                            isFavorite: isFav,
                            onToggleFavorite: () {
                              setState(() {
                                if (!isFav) {
                                  _favorites.add(p.id);
                                } else {
                                  _favorites.remove(p.id);
                                }
                              });
                            },
                            onTap: () => _openProduct(p),
                          );
                        },
                        childCount: items.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final CatalogProduct product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SojuColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: SojuColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.unit.isNotEmpty
                            ? product.unit
                            : (product.code.isNotEmpty ? product.code : 'Menu'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.inkMuted,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onToggleFavorite,
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 19,
                      color: isFavorite
                          ? SojuColors.expense
                          : SojuColors.inkMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: SojuColors.infoSoft.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: StorefrontProductImage(
                    url: product.imageUrl,
                    size: 86,
                    radius: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                ),
              ),
              if (product.hasVariants) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  product.variants.join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11.5,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      formatRupiah(product.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: SojuColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: SojuColors.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Text(
                      'Tambah',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: SojuColors.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
