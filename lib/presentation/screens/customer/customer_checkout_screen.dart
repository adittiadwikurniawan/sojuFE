// lib/presentation/screens/customer/customer_checkout_screen.dart
//
// Layar checkout pesanan pelanggan SOJU (TASK-025).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/auth_session_entity.dart';
import '../../../../domain/entities/storefront_entity.dart';
import '../../../../data/data_providers.dart';
import '../../providers/customer/customer_checkout_controller.dart';
import '../../providers/storefront/customer_cart_controller.dart';
import '../../utils/format.dart';

class CustomerCheckoutScreen extends StatefulWidget {
  const CustomerCheckoutScreen({
    super.key,
    required this.cartController,
    this.checkoutController,
    this.checkoutControllerFactory,
    this.user,
    this.onBack,
    this.onViewOrders,
    this.onBrowseMenu,
  });

  final CustomerCartController cartController;
  final CustomerCheckoutController? checkoutController;
  final CustomerCheckoutController Function()? checkoutControllerFactory;
  final AuthUser? user;
  final VoidCallback? onBack;
  final VoidCallback? onViewOrders;
  final VoidCallback? onBrowseMenu;

  @override
  State<CustomerCheckoutScreen> createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  CustomerCheckoutController? _internalController;
  late final TextEditingController _addressTextController;

  CustomerCheckoutController get _controller =>
      widget.checkoutController ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.checkoutController == null) {
      _internalController = widget.checkoutControllerFactory?.call() ??
          CustomerCheckoutController(
            checkoutOrder: DataProviders.checkoutCustomerOrder(),
          );
    }

    final String initialAddr =
        _controller.deliveryAddress.isNotEmpty
            ? _controller.deliveryAddress
            : (widget.user?.address ?? '');
    _addressTextController = TextEditingController(text: initialAddr);
    if (_controller.deliveryAddress.isEmpty && initialAddr.isNotEmpty) {
      _controller.setDeliveryAddress(initialAddr);
    }
  }

  @override
  void dispose() {
    _addressTextController.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    final bool success = await _controller.submitCheckout(
      cartController: widget.cartController,
      addressOverride: _addressTextController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dibuat!'),
          backgroundColor: SojuColors.success,
        ),
      );
      widget.onViewOrders?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        _controller,
        widget.cartController,
      ]),
      builder: (BuildContext context, _) {
        final CustomerCheckoutController checkout = _controller;
        final CustomerCartController cart = widget.cartController;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final double scale = (width > 480 ? 480 : width) / 430;

            return Scaffold(
              key: const Key('customer_checkout_screen'),
              backgroundColor: SojuColors.homeBackground,
              appBar: AppBar(
                backgroundColor: SojuColors.surface,
                elevation: 0,
                scrolledUnderElevation: 1,
                leading: IconButton(
                  key: const Key('customer_checkout_back'),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: SojuColors.ink,
                  ),
                  onPressed: widget.onBack,
                ),
                title: const Text(
                  'Checkout Pesanan',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: cart.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: SojuColors.field,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 34,
                                  color: SojuColors.inkMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Keranjang Kosong',
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: SojuColors.ink,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Pilih menu favorit Anda terlebih dahulu sebelum melakukan checkout.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 13,
                                  color: SojuColors.inkMuted,
                                ),
                              ),
                              if (widget.onBrowseMenu != null) ...<Widget>[
                                const SizedBox(height: 20),
                                FilledButton(
                                  key: const Key('customer_checkout_empty_browse'),
                                  onPressed: widget.onBrowseMenu,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: SojuColors.primary,
                                    foregroundColor: SojuColors.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Lihat Menu'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          20 * scale,
                          16 * scale,
                          20 * scale,
                          24 * scale,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Banner Galat jika ada
                            if (checkout.errorMessage != null) ...<Widget>[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: SojuColors.expense,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        checkout.errorMessage!,
                                        style: const TextStyle(
                                          fontFamily: AppTypography.family,
                                          fontSize: 12.5,
                                          color: SojuColors.expense,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Bagian 1: Data Penerima & Alamat Pengiriman
                            _buildSectionHeader('Alamat Pengiriman'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: SojuColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: SojuColors.hairline),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (widget.user != null) ...<Widget>[
                                    Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.person_outline_rounded,
                                          size: 18,
                                          color: SojuColors.inkMuted,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${widget.user!.name} • ${widget.user!.phone ?? '-'}',
                                            style: const TextStyle(
                                              fontFamily: AppTypography.family,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: SojuColors.ink,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(
                                      height: 1,
                                      color: SojuColors.hairline,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  const Text(
                                    'Alamat Lengkap Tujuan:',
                                    style: TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: SojuColors.inkMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    key: const Key(
                                      'customer_checkout_address_input',
                                    ),
                                    controller: _addressTextController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Masukkan alamat jalan, RT/RW, nomor rumah, patokan...',
                                      hintStyle: const TextStyle(
                                        fontFamily: AppTypography.family,
                                        fontSize: 13,
                                        color: SojuColors.inkMuted,
                                      ),
                                      errorText: checkout.addressError,
                                      filled: true,
                                      fillColor: SojuColors.field,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                    onChanged: checkout.setDeliveryAddress,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Bagian 2: Ringkasan Menu
                            _buildSectionHeader('Rincian Pesanan'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: SojuColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: SojuColors.hairline),
                              ),
                              child: Column(
                                children: <Widget>[
                                  ...cart.items.map((CartItem item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        AppTypography.family,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: SojuColors.ink,
                                                  ),
                                                ),
                                                if (item.variant.isNotEmpty) ...<Widget>[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Varian: ${item.variant}',
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          AppTypography.family,
                                                      fontSize: 12,
                                                      color:
                                                          SojuColors.primaryDeep,
                                                    ),
                                                  ),
                                                ],
                                                if (item.note.isNotEmpty) ...<Widget>[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Catatan: "${item.note}"',
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          AppTypography.family,
                                                      fontSize: 12,
                                                      fontStyle: FontStyle.italic,
                                                      color: SojuColors.inkMuted,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${item.quantity} × ${formatRupiah(item.price)}',
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        AppTypography.family,
                                                    fontSize: 12,
                                                    color: SojuColors.inkMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            formatRupiah(item.subtotal),
                                            style: const TextStyle(
                                              fontFamily: AppTypography.family,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: SojuColors.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const Divider(
                                    height: 1,
                                    color: SojuColors.hairline,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          'Subtotal (${cart.totalQuantity} item)',
                                          style: const TextStyle(
                                            fontFamily: AppTypography.family,
                                            fontSize: 13,
                                            color: SojuColors.inkMuted,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formatRupiah(cart.totalPrice),
                                        style: const TextStyle(
                                          fontFamily: AppTypography.family,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: SojuColors.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Bagian 3: Ringkasan Pembayaran
                            _buildSectionHeader('Ringkasan Pembayaran'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: SojuColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: SojuColors.hairline),
                              ),
                              child: Column(
                                children: <Widget>[
                                  _buildPriceRow(
                                    'Subtotal Menu',
                                    formatRupiah(cart.totalPrice),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPriceRow(
                                    'Biaya Pengiriman',
                                    'Gratis',
                                    valueColor: SojuColors.success,
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(
                                    height: 1,
                                    color: SojuColors.hairline,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Expanded(
                                        child: Text(
                                          'Total Pembayaran',
                                          style: TextStyle(
                                            fontFamily: AppTypography.family,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: SojuColors.ink,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formatRupiah(cart.totalPrice),
                                        style: const TextStyle(
                                          fontFamily: AppTypography.family,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: SojuColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Tombol Submit Checkout
                            SizedBox(
                              height: 52,
                              child: FilledButton(
                                key: const Key('customer_checkout_button'),
                                onPressed: checkout.isLoading
                                    ? null
                                    : _handleCheckout,
                                style: FilledButton.styleFrom(
                                  backgroundColor: SojuColors.primary,
                                  foregroundColor: SojuColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: checkout.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: SojuColors.surface,
                                        ),
                                      )
                                    : const Text(
                                        'Konfirmasi & Buat Pesanan',
                                        style: TextStyle(
                                          fontFamily: AppTypography.family,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: AppTypography.family,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: SojuColors.ink,
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color valueColor = SojuColors.ink,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13,
              color: SojuColors.inkMuted,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
