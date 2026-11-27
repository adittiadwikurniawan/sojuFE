// lib/presentation/screens/customer/widgets/order_item_card.dart
//
// Kartu pesanan pelanggan dengan status pembayaran Midtrans, rincian item,
// Struk Digital, tombol Bayar Midtrans, dan Konfirmasi via WhatsApp (tanpa tracking timeline).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/customer_order_entity.dart';
import '../../../utils/external_launcher.dart';
import '../../../utils/format.dart';
import 'order_status_badge.dart';

class OrderItemCard extends StatelessWidget {
  const OrderItemCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final CustomerOrder order;
  final VoidCallback? onTap;

  String _formatDateTime(DateTime dt) {
    return '${formatDayMonth(dt)} ${dt.year}, ${formatClock(dt)} WIB';
  }

  void _openDigitalReceipt(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: SojuColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SojuColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Struk Digital SOJU',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: SojuColors.ink,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Text(
                  '${order.code} • ${_formatDateTime(order.createdAt)}',
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12,
                    color: SojuColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: <Widget>[
                    OrderStatusBadge(status: order.status),
                    _PaymentStatusPill(order: order),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: SojuColors.hairline),
                const SizedBox(height: 12),
                ...order.items.map((CustomerOrderItem item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${item.productName} × ${item.quantity}',
                                style: const TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: SojuColors.ink,
                                ),
                              ),
                              if (item.hasVariant)
                                Text(
                                  'Varian: ${item.variant}',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 11.5,
                                    color: SojuColors.brandNavy,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          formatRupiah(item.subtotal),
                          style: const TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.ink,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 1, color: SojuColors.hairline),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Total Dibayar',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: SojuColors.ink,
                      ),
                    ),
                    Text(
                      formatRupiah(order.total),
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: SojuColors.brandNavy,
                      ),
                    ),
                  ],
                ),
                if (order.midtransOrderId != null &&
                    order.midtransOrderId!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    'Ref Midtrans: ${order.midtransOrderId}',
                    style: const TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 11.5,
                      color: SojuColors.inkMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () =>
                      launchWhatsAppOrderConfirmation(context, order),
                  style: FilledButton.styleFrom(
                    backgroundColor: SojuColors.whatsappGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text(
                    'Konfirmasi via WhatsApp',
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canPayMidtrans = !order.isPaid &&
        order.hasSnapUrl &&
        order.status != CustomerOrderStatus.dibatalkan;

    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SojuColors.hairline),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => _openDigitalReceipt(context),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header: Kode Pesanan, Tanggal, dan Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            order.code,
                            style: const TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: SojuColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _formatDateTime(order.createdAt),
                            style: const TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 12,
                              color: SojuColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OrderStatusBadge(status: order.status),
                  ],
                ),

                const SizedBox(height: 8),
                _PaymentStatusPill(order: order),

                const SizedBox(height: 12),
                const Divider(height: 1, color: SojuColors.hairline),
                const SizedBox(height: 12),

                // Data Penerima & Alamat
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: SojuColors.field,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: SojuColors.inkMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${order.recipientName} • ${order.recipientPhone}\n${order.recipientAddress}',
                          style: const TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 11.5,
                            height: 1.35,
                            color: SojuColors.inkMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Rincian Item Breakdown
                Column(
                  children: order.items.map((CustomerOrderItem item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: SojuColors.ink,
                                  ),
                                ),
                                if (item.hasVariant) ...<Widget>[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Varian: ${item.variant}',
                                    style: const TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 11.5,
                                      color: SojuColors.primaryDeep,
                                    ),
                                  ),
                                ],
                                if (item.hasNote) ...<Widget>[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Catatan: "${item.note}"',
                                    style: const TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 11.5,
                                      fontStyle: FontStyle.italic,
                                      color: SojuColors.inkMuted,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 2),
                                Text(
                                  '${item.quantity} × ${formatRupiah(item.price)}',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.family,
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
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: SojuColors.ink,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const Divider(height: 1, color: SojuColors.hairline),
                const SizedBox(height: 10),

                // Footer: Total Item dan Total Pembayaran
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total (${order.totalItems} menu)',
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 13,
                        color: SojuColors.inkMuted,
                      ),
                    ),
                    Text(
                      formatRupiah(order.total),
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: SojuColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Baris Aksi User-Friendly: Bayar Midtrans (jika pending), Struk Digital, & Konfirmasi WA
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    if (canPayMidtrans)
                      FilledButton.icon(
                        key: Key('order_pay_midtrans_${order.id}'),
                        onPressed: () => launchMidtransSnapUrl(
                          context,
                          order.snapRedirectUrl,
                        ),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.payment_rounded, size: 15),
                        label: const Text(
                          'Bayar Midtrans',
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    OutlinedButton.icon(
                      key: Key('order_receipt_${order.id}'),
                      onPressed: () => _openDigitalReceipt(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SojuColors.ink,
                        side: const BorderSide(color: SojuColors.cardBorder),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long_rounded, size: 15),
                      label: const Text(
                        'Struk',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      key: Key('order_confirm_wa_${order.id}'),
                      onPressed: () =>
                          launchWhatsAppOrderConfirmation(context, order),
                      style: FilledButton.styleFrom(
                        backgroundColor: SojuColors.whatsappSoft,
                        foregroundColor: SojuColors.whatsappGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.chat_rounded, size: 15),
                      label: const Text(
                        'Konfirmasi WA',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentStatusPill extends StatelessWidget {
  const _PaymentStatusPill({required this.order});

  final CustomerOrder order;

  @override
  Widget build(BuildContext context) {
    final CustomerPaymentStatus ps = order.paymentStatus;
    final Color bg;
    final Color fg;
    final IconData icon;

    switch (ps) {
      case CustomerPaymentStatus.paid:
        bg = SojuColors.incomeSoft;
        fg = SojuColors.brandEmerald;
        icon = Icons.check_circle_rounded;
        break;
      case CustomerPaymentStatus.pending:
        bg = SojuColors.amberSoft;
        fg = SojuColors.amberInk;
        icon = Icons.schedule_rounded;
        break;
      case CustomerPaymentStatus.expired:
      case CustomerPaymentStatus.failed:
        bg = SojuColors.expenseSoft;
        fg = SojuColors.brandDanger;
        icon = Icons.cancel_rounded;
        break;
    }

    final String methodSuffix = order.paymentMethod != null &&
            order.paymentMethod!.trim().isNotEmpty
        ? ' • ${order.paymentMethod!.toUpperCase()}'
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              'Midtrans: ${ps.label}$methodSuffix',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 11,
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
