// lib/presentation/screens/customer/customer_cart_screen.dart
//
// Tab Keranjang Pelanggan (`/customer/keranjang`) tersinkron dengan
// `GET/PUT /api/customer/keranjang`: ubah jumlah, hapus item, total.

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/storefront_entity.dart';
import '../../../data/data_providers.dart';
import '../../providers/storefront/customer_cart_controller.dart';
import '../../utils/format.dart';
import '../../widgets/bottom_glass_overlay.dart';
import 'widgets/storefront_widgets.dart';

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({
    super.key,
    this.controller,
    this.controllerFactory,
    this.onCheckout,
    this.onBrowseMenu,
  });

  final CustomerCartController? controller;
  final CustomerCartController Function()? controllerFactory;
  final VoidCallback? onCheckout;
  final VoidCallback? onBrowseMenu;

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  CustomerCartController? _internalController;

  CustomerCartController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = widget.controllerFactory?.call() ??
          CustomerCartController(
            getCart: DataProviders.getCart(),
            saveCart: DataProviders.saveCart(),
          );
      _internalController!.load();
    } else {
      if (widget.controller!.status == CartStatus.initial) {
        widget.controller!.load();
      }
    }
  }

  @override
  void didUpdateWidget(CustomerCartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != oldWidget.controller) {
      if (widget.controller!.status == CartStatus.initial) {
        widget.controller!.load();
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('customer_cart_screen'),
      backgroundColor: SojuColors.homeBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const StorefrontHeader(
            title: 'Keranjang Belanja',
            subtitle: 'Periksa kembali item pilihanmu sebelum checkout.',
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _effectiveController,
              builder: (BuildContext context, _) => _body(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    final CustomerCartController c = _effectiveController;
    if (c.status == CartStatus.initial ||
        (c.status == CartStatus.loading && c.isEmpty)) {
      return const StorefrontStateView.loading(
        message: 'Memuat keranjang...',
      );
    }
    if (c.status == CartStatus.error) {
      return StorefrontStateView(
        icon: Icons.cloud_off_rounded,
        title: 'Keranjang gagal dimuat',
        message: c.errorMessage ?? 'Terjadi kesalahan. Coba lagi.',
        actionLabel: 'Coba Lagi',
        actionKey: const Key('customer_cart_retry'),
        onAction: c.load,
        secondaryActionLabel:
            c.isStaleCartError ? 'Kosongkan Keranjang' : null,
        secondaryActionKey:
            c.isStaleCartError ? const Key('customer_cart_clear') : null,
        onSecondaryAction: c.isStaleCartError
            ? () async {
                final bool ok = await c.clearCart();
                if (!mounted) return;
                if (!ok && c.syncError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(c.syncError!)),
                  );
                }
              }
            : null,
      );
    }
    if (c.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const StorefrontStateView(
                key: Key('customer_cart_empty'),
                icon: Icons.shopping_bag_outlined,
                title: 'Keranjang masih kosong',
                message: 'Yuk pilih menu favoritmu terlebih dahulu.',
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  OutlinedButton(
                    key: const Key('customer_cart_browse_menu'),
                    onPressed: widget.onBrowseMenu,
                    child: const Text('Lihat Menu'),
                  ),
                  if (widget.onCheckout != null)
                    FilledButton(
                      key: const Key('customer_checkout_button'),
                      onPressed: widget.onCheckout,
                      style: FilledButton.styleFrom(
                        backgroundColor: SojuColors.primary,
                        foregroundColor: SojuColors.surface,
                      ),
                      child: const Text('Lanjut ke Checkout'),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (c.syncError != null)
          MaterialBanner(
            key: const Key('customer_cart_sync_error'),
            backgroundColor: SojuColors.surface,
            content: Text(c.syncError!),
            actions: <Widget>[
              TextButton(
                onPressed: c.clearSyncError,
                child: const Text('Tutup'),
              ),
            ],
          ),
        if (c.isSyncing) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView.separated(
            key: const Key('customer_cart_list'),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            itemCount: c.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int i) =>
                _CartRow(index: i, item: c.items[i], controller: c),
          ),
        ),
        Container(
          padding:
              const EdgeInsets.fromLTRB(18, 16, 18, kBottomContentInset - 40),
          decoration: const BoxDecoration(
            color: SojuColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Total (${c.totalQuantity} item)',
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 14,
                        color: SojuColors.inkMuted,
                      ),
                    ),
                  ),
                  Text(
                    formatRupiah(c.totalPrice),
                    key: const Key('customer_cart_total'),
                    style: const TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: SojuColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('customer_checkout_button'),
                onPressed: c.isSyncing ? null : widget.onCheckout,
                style: FilledButton.styleFrom(
                  backgroundColor: SojuColors.primary,
                  foregroundColor: SojuColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Lanjut ke Checkout',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({
    required this.index,
    required this.item,
    required this.controller,
  });

  final int index;
  final CartItem item;
  final CustomerCartController controller;

  @override
  Widget build(BuildContext context) {
    final bool busy = controller.isSyncing;
    const TextStyle muted = TextStyle(
      fontFamily: AppTypography.family,
      fontSize: 12.5,
      color: SojuColors.inkMuted,
    );
    return Container(
      key: Key('customer_cart_item_$index'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SojuColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StorefrontProductImage(url: item.imageUrl, size: 60),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                if (item.variant.isNotEmpty)
                  Text('Varian: ${item.variant}', style: muted),
                if (item.note.isNotEmpty)
                  Text('Catatan: ${item.note}', style: muted),
                const SizedBox(height: 6),
                Text(
                  formatRupiah(item.subtotal),
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                QuantityStepper(
                  value: item.quantity,
                  valueKey: Key('customer_cart_qty_$index'),
                  decrementKey: Key('customer_cart_decrement_$index'),
                  incrementKey: Key('customer_cart_increment_$index'),
                  onDecrement: busy || item.quantity <= kCartMinQuantity
                      ? null
                      : () =>
                          controller.updateQuantity(index, item.quantity - 1),
                  onIncrement: busy || item.quantity >= kCartMaxQuantity
                      ? null
                      : () =>
                          controller.updateQuantity(index, item.quantity + 1),
                ),
              ],
            ),
          ),
          IconButton(
            key: Key('customer_cart_remove_$index'),
            tooltip: 'Hapus item',
            onPressed: busy ? null : () => controller.removeAt(index),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: SojuColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}
