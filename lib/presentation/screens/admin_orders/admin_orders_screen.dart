// lib/presentation/screens/admin_orders/admin_orders_screen.dart
//
// Layar Pengelola Pesanan Pelanggan untuk Admin & Super Admin.
// Menampilkan filter status, daftar pesanan pelanggan, rincian item, dan dropdown
// perubahan status pesanan (`PATCH /api/v1/customer-orders/:id/status`).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/customer_order_entity.dart';
import '../../providers/admin_orders/admin_orders_controller.dart';
import '../../utils/external_launcher.dart';
import '../../utils/format.dart';
import '../customer/widgets/order_status_badge.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({
    super.key,
    required this.controllerFactory,
    this.onBack,
    this.onMenuTap,
    this.onNotificationTap,
  });

  final AdminOrdersController Function() controllerFactory;
  final VoidCallback? onBack;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late final AdminOrdersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.load();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      key: const Key('admin_orders_screen'),
      backgroundColor: SojuColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double contentWidth = math.min(constraints.maxWidth, 480);
            final double scale = contentWidth / 430;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _AdminOrdersTopBar(
                      scale: scale,
                      topInset: topInset,
                      onBack: widget.onBack,
                      onMenuTap: widget.onMenuTap,
                      onNotificationTap: widget.onNotificationTap,
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (BuildContext context, Widget? _) {
                          return _buildContent(_controller.state, scale);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(AdminOrdersState state, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildStatusFilterChips(state, scale),
        Expanded(
          child: switch (state.status) {
            AdminOrdersStatus.loading => _buildLoading(scale),
            AdminOrdersStatus.error => _buildError(state, scale),
            AdminOrdersStatus.empty => _buildEmpty(scale),
            AdminOrdersStatus.data => _buildList(state, scale),
          },
        ),
      ],
    );
  }

  Widget _buildStatusFilterChips(AdminOrdersState state, double scale) {
    final List<({CustomerOrderStatus? status, String label})> options = <({
      CustomerOrderStatus? status,
      String label,
    })>[
      (status: null, label: 'Semua'),
      (
        status: CustomerOrderStatus.menungguKonfirmasi,
        label: 'Menunggu Konfirmasi',
      ),
      (status: CustomerOrderStatus.diproses, label: 'Diproses'),
      (status: CustomerOrderStatus.selesai, label: 'Selesai'),
      (status: CustomerOrderStatus.dibatalkan, label: 'Dibatalkan'),
    ];

    return Container(
      height: 48 * scale,
      margin: EdgeInsets.symmetric(vertical: 8 * scale),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        itemCount: options.length,
        separatorBuilder: (_, __) => SizedBox(width: 8 * scale),
        itemBuilder: (BuildContext context, int index) {
          final opt = options[index];
          final bool isSelected = state.filterStatus == opt.status;

          return ChoiceChip(
            key: Key('order_filter_${opt.status?.raw ?? 'ALL'}'),
            label: Text(
              opt.label,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12.5 * scale,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : SojuColors.ink,
              ),
            ),
            selected: isSelected,
            selectedColor: SojuColors.primary,
            backgroundColor: SojuColors.surface,
            side: BorderSide(
              color: isSelected ? SojuColors.primary : SojuColors.border,
            ),
            onSelected: (_) => _controller.load(status: opt.status),
          );
        },
      ),
    );
  }

  Widget _buildLoading(double scale) {
    return Center(
      key: const Key('admin_orders_loading'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(color: SojuColors.primary),
          SizedBox(height: 12 * scale),
          Text(
            'Memuat pesanan pelanggan...',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 14 * scale,
              color: SojuColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AdminOrdersState state, double scale) {
    return Center(
      key: const Key('admin_orders_error'),
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 48 * scale,
              color: SojuColors.expense,
            ),
            SizedBox(height: 12 * scale),
            Text(
              state.errorMessage ?? 'Gagal memuat pesanan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: SojuColors.ink,
              ),
            ),
            SizedBox(height: 16 * scale),
            ElevatedButton(
              key: const Key('admin_orders_retry_button'),
              onPressed: () => _controller.load(status: state.filterStatus),
              style: ElevatedButton.styleFrom(
                backgroundColor: SojuColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(double scale) {
    return Center(
      key: const Key('admin_orders_empty'),
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.receipt_long_outlined,
              size: 56 * scale,
              color: SojuColors.inkMuted,
            ),
            SizedBox(height: 12 * scale),
            Text(
              'Belum ada pesanan',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: SojuColors.ink,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              'Belum ada pesanan dari pelanggan untuk kategori ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 13 * scale,
                color: SojuColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(AdminOrdersState state, double scale) {
    return ListView.separated(
      key: const Key('admin_orders_list'),
      padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 96 * scale),
      itemCount: state.orders.length,
      separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
      itemBuilder: (BuildContext context, int index) {
        final CustomerOrder order = state.orders[index];
        return _AdminOrderCard(
          scale: scale,
          order: order,
          isUpdating: state.isUpdating(order.id),
          onStatusChange: (CustomerOrderStatus newStatus) async {
            final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
            final bool ok = await _controller.updateStatus(
              orderId: order.id,
              newStatus: newStatus,
            );
            if (ok && mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Status pesanan #${order.code} diubah menjadi ${newStatus.label}',
                  ),
                  backgroundColor: SojuColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({
    required this.scale,
    required this.order,
    required this.isUpdating,
    required this.onStatusChange,
  });

  final double scale;
  final CustomerOrder order;
  final bool isUpdating;
  final ValueChanged<CustomerOrderStatus> onStatusChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('admin_order_card_${order.id}'),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: SojuColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '#${order.code}',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: SojuColors.primary,
                      ),
                    ),
                    Text(
                      '${formatDayMonth(order.createdAt)} • ${formatClock(order.createdAt)}',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 11 * scale,
                        color: SojuColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          SizedBox(height: 6 * scale),
          Align(
            alignment: Alignment.centerLeft,
            child: _AdminPaymentPill(order: order, scale: scale),
          ),
          Divider(height: 18 * scale, color: SojuColors.border),
          Text(
            'Pemesan: ${order.recipientName} (${order.recipientPhone})',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
              color: SojuColors.ink,
            ),
          ),
          if (order.recipientAddress.isNotEmpty) ...<Widget>[
            SizedBox(height: 2 * scale),
            Text(
              'Alamat: ${order.recipientAddress}',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12 * scale,
                color: SojuColors.inkMuted,
              ),
            ),
          ],
          SizedBox(height: 10 * scale),
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: SojuColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final CustomerOrderItem item in order.items)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.productName}${item.hasVariant ? ' (${item.variant})' : ''}',
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 12.5 * scale,
                              color: SojuColors.ink,
                            ),
                          ),
                        ),
                        Text(
                          formatRupiah(item.subtotal),
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 12.5 * scale,
                            fontWeight: FontWeight.w600,
                            color: SojuColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w500,
                  color: SojuColors.inkMuted,
                ),
              ),
              Text(
                formatRupiah(order.total),
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w800,
                  color: SojuColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          if (!isUpdating &&
              (order.status == CustomerOrderStatus.menungguKonfirmasi ||
                  order.status == CustomerOrderStatus.diproses)) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    key: Key('admin_order_quick_action_${order.id}'),
                    onPressed: () => onStatusChange(
                      order.status == CustomerOrderStatus.menungguKonfirmasi
                          ? CustomerOrderStatus.diproses
                          : CustomerOrderStatus.selesai,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          order.status == CustomerOrderStatus.menungguKonfirmasi
                              ? SojuColors.brandNavy
                              : SojuColors.brandEmerald,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                    ),
                    icon: Icon(
                      order.status == CustomerOrderStatus.menungguKonfirmasi
                          ? Icons.local_fire_department_rounded
                          : Icons.check_circle_rounded,
                      size: 16 * scale,
                    ),
                    label: Text(
                      order.status == CustomerOrderStatus.menungguKonfirmasi
                          ? 'Proses Pesanan'
                          : 'Tandai Selesai',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12.5 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (order.recipientPhone.trim().isNotEmpty) ...<Widget>[
                  SizedBox(width: 8 * scale),
                  FilledButton.icon(
                    onPressed: () {
                      final String digits = order.recipientPhone
                          .replaceAll(RegExp(r'[^0-9]'), '');
                      final String normalized = digits.startsWith('0')
                          ? '62${digits.substring(1)}'
                          : digits;
                      if (normalized.isNotEmpty) {
                        launchWhatsAppOrderConfirmation(
                          context,
                          order,
                          adminPhone: normalized,
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: SojuColors.whatsappSoft,
                      foregroundColor: SojuColors.whatsappGreen,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale,
                        vertical: 10 * scale,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                    ),
                    icon: Icon(Icons.chat_rounded, size: 15 * scale),
                    label: Text(
                      'WA',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 8 * scale),
          ],
          Row(
            children: <Widget>[
              Text(
                'Ubah Status:',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12.5 * scale,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.ink,
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: isUpdating
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                        decoration: BoxDecoration(
                          color: SojuColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8 * scale),
                          border: Border.all(color: SojuColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CustomerOrderStatus>(
                            key: Key('order_status_dropdown_${order.id}'),
                            value: order.status,
                            isDense: true,
                            isExpanded: true,
                            items: CustomerOrderStatus.values.map((CustomerOrderStatus s) {
                              return DropdownMenuItem<CustomerOrderStatus>(
                                value: s,
                                child: Text(
                                  s.label,
                                  style: TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 12 * scale,
                                    color: SojuColors.ink,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (CustomerOrderStatus? next) {
                              if (next != null && next != order.status) {
                                onStatusChange(next);
                              }
                            },
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminPaymentPill extends StatelessWidget {
  const _AdminPaymentPill({required this.order, required this.scale});

  final CustomerOrder order;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final bool isPaid = order.isPaid;
    final bool isFailed = order.paymentStatus == CustomerPaymentStatus.expired ||
        order.paymentStatus == CustomerPaymentStatus.failed;
    final Color bg = isPaid
        ? SojuColors.incomeSoft
        : isFailed
            ? SojuColors.expenseSoft
            : SojuColors.amberSoft;
    final Color fg = isPaid
        ? SojuColors.brandEmerald
        : isFailed
            ? SojuColors.brandDanger
            : SojuColors.amberInk;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isPaid
                ? Icons.verified_rounded
                : isFailed
                    ? Icons.cancel_rounded
                    : Icons.schedule_rounded,
            size: 12 * scale,
            color: fg,
          ),
          SizedBox(width: 4 * scale),
          Flexible(
            child: Text(
              'Midtrans: ${order.paymentStatus.label}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 10.5 * scale,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminOrdersTopBar extends StatelessWidget {
  const _AdminOrdersTopBar({
    required this.scale,
    required this.topInset,
    this.onBack,
    this.onMenuTap,
    this.onNotificationTap,
  });

  final double scale;
  final double topInset;
  final VoidCallback? onBack;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30 * scale),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 1),
            blurRadius: 14,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        math.max(0, 24 * scale - topInset),
        16 * scale,
        18 * scale,
      ),
      child: Row(
        children: <Widget>[
          if (onBack != null) ...<Widget>[
            GestureDetector(
              key: const Key('admin_orders_back'),
              onTap: onBack,
              child: Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: const BoxDecoration(
                  color: SojuColors.field,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 19 * scale,
                  color: SojuColors.ink,
                ),
              ),
            ),
            SizedBox(width: 12 * scale),
          ] else if (onMenuTap != null) ...<Widget>[
            GestureDetector(
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
            SizedBox(width: 12 * scale),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Pesanan Pelanggan',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                Text(
                  'Kelola antrean dan perbarui status pesanan',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11.5 * scale,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          if (onNotificationTap != null)
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
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
