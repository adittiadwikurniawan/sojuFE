// lib/presentation/screens/customer/widgets/order_item_card.dart
//
// Kartu pesanan pelanggan dengan rincian item breakdown dan badge status (TASK-025).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/customer_order_entity.dart';
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

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
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

                const SizedBox(height: 12),
                const Divider(height: 1, color: SojuColors.hairline),
                const SizedBox(height: 12),

                // Data Penerima & Alamat
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
