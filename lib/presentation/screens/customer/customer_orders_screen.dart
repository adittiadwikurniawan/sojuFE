// lib/presentation/screens/customer/customer_orders_screen.dart
//
// Layar riwayat pesanan pelanggan SOJU (TASK-025) dengan status badges & breakdown.

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/customer_order_entity.dart';
import '../../providers/customer/customer_orders_controller.dart';
import '../../widgets/bottom_glass_overlay.dart';
import '../../widgets/role_badge_pill.dart';
import 'widgets/order_item_card.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({
    super.key,
    this.controller,
    this.controllerFactory,
    this.onBrowseMenu,
  });

  final CustomerOrdersController? controller;
  final CustomerOrdersController Function()? controllerFactory;
  final VoidCallback? onBrowseMenu;

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  CustomerOrdersController? _internalController;

  CustomerOrdersController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = widget.controllerFactory?.call();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.orders.isEmpty && !_controller.isLoading) {
        _controller.loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, _) {
        final CustomerOrdersController controller = _controller;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final double scale = (width > 480 ? 480 : width) / 430;

            return Scaffold(
              key: const Key('customer_orders_screen'),
              backgroundColor: SojuColors.homeBackground,
              body: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: SojuColors.primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      // Header Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            20 * scale,
                            18 * scale,
                            20 * scale,
                            10 * scale,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Pesanan Saya',
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: SojuColors.ink,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Riwayat dan status pesanan Anda di SOJU.',
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 13.5,
                                  color: SojuColors.inkMuted,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Underline Status Tabs (user-friendly dengan jumlah live)
                              SojuUnderlineTabBar(
                                tabs: const <String>[
                                  'Semua',
                                  'Menunggu',
                                  'Diproses',
                                  'Selesai',
                                  'Batal',
                                ],
                                selectedIndex: controller.statusFilter == null
                                    ? 0
                                    : CustomerOrderStatus.values
                                            .indexOf(controller.statusFilter!) +
                                        1,
                                badges: <int?>[
                                  controller.orders.length,
                                  controller.orders
                                      .where((CustomerOrder o) =>
                                          o.status ==
                                          CustomerOrderStatus.menungguKonfirmasi)
                                      .length,
                                  controller.orders
                                      .where((CustomerOrder o) =>
                                          o.status ==
                                          CustomerOrderStatus.diproses)
                                      .length,
                                  controller.orders
                                      .where((CustomerOrder o) =>
                                          o.status ==
                                          CustomerOrderStatus.selesai)
                                      .length,
                                  controller.orders
                                      .where((CustomerOrder o) =>
                                          o.status ==
                                          CustomerOrderStatus.dibatalkan)
                                      .length,
                                ],
                                onSelected: (int index) {
                                  if (index == 0) {
                                    controller.setFilter(null);
                                  } else {
                                    controller.setFilter(
                                      CustomerOrderStatus.values[index - 1],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Content: Loading / Error / Empty / List
                      if (controller.isLoading && controller.orders.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: SojuColors.primary,
                            ),
                          ),
                        )
                      else if (controller.errorMessage != null &&
                          controller.orders.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: SojuColors.expense,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    controller.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 14,
                                      color: SojuColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: controller.loadOrders,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Coba Lagi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SojuColors.primary,
                                      foregroundColor: SojuColors.surface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else if (controller.filteredOrders.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      color: SojuColors.field,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_outlined,
                                      size: 38,
                                      color: SojuColors.inkMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Belum Ada Pesanan',
                                    style: TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: SojuColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Pesanan Anda akan ditampilkan lengkap dengan status terkini di sini.',
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
                                      key: const Key('customer_orders_empty_browse'),
                                      onPressed: widget.onBrowseMenu,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: SojuColors.primary,
                                        foregroundColor: SojuColors.surface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Lihat Menu'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            20 * scale,
                            8 * scale,
                            20 * scale,
                            kBottomContentInset * scale + 24,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                final CustomerOrder order =
                                    controller.filteredOrders[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: OrderItemCard(order: order),
                                );
                              },
                              childCount: controller.filteredOrders.length,
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
}
