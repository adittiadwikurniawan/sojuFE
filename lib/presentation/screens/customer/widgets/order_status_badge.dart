// lib/presentation/screens/customer/widgets/order_status_badge.dart
//
// Badge status pesanan pelanggan dengan palet warna SOJU tokens (TASK-025).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/customer_order_entity.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final CustomerOrderStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (Color bgColor, Color textColor, Color borderColor) = switch (status) {
      CustomerOrderStatus.menungguKonfirmasi => (
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
          const Color(0xFFFDE68A),
        ),
      CustomerOrderStatus.diproses => (
          const Color(0xFFEFF6FF),
          SojuColors.primary,
          const Color(0xFFBFDBFE),
        ),
      CustomerOrderStatus.selesai => (
          const Color(0xFFECFDF5),
          const Color(0xFF059669),
          const Color(0xFFA7F3D0),
        ),
      CustomerOrderStatus.dibatalkan => (
          const Color(0xFFFEF2F2),
          const Color(0xFFDC2626),
          const Color(0xFFFECACA),
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
