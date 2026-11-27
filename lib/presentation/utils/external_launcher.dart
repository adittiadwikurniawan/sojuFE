import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/themes/soju_colors.dart';
import '../../domain/entities/customer_order_entity.dart';
import 'format.dart';

/// Nomor WhatsApp resmi admin SOJU (format internasional tanpa `+`).
const String kSojuAdminWhatsappNumber = '6281234567890';

/// Membuka halaman pembayaran **Midtrans Snap** di browser eksternal secara aman.
Future<bool> launchMidtransSnapUrl(
  BuildContext context,
  String? redirectUrl,
) async {
  final String trimmed = redirectUrl?.trim() ?? '';
  if (trimmed.isEmpty) {
    _showFeedback(
      context,
      'Link pembayaran Midtrans belum tersedia untuk pesanan ini.',
      isError: true,
    );
    return false;
  }

  final Uri? uri = Uri.tryParse(trimmed);
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    _showFeedback(
      context,
      'Format link pembayaran Midtrans tidak valid.',
      isError: true,
    );
    return false;
  }

  try {
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showFeedback(
        context,
        'Tidak dapat membuka halaman Midtrans. Coba salin link atau buka browser.',
        isError: true,
      );
    }
    return launched;
  } catch (_) {
    if (context.mounted) {
      _showFeedback(
        context,
        'Gagal membuka browser untuk Midtrans Snap.',
        isError: true,
      );
    }
    return false;
  }
}

/// Membuka WhatsApp (`wa.me`) dengan pesan konfirmasi pesanan yang sudah terisi otomatis.
Future<bool> launchWhatsAppOrderConfirmation(
  BuildContext context,
  CustomerOrder order, {
  String adminPhone = kSojuAdminWhatsappNumber,
}) async {
  final String itemsSummary = order.items
      .map((CustomerOrderItem item) {
        final String variantPart =
            item.hasVariant ? ' (${item.variant})' : '';
        return '- ${item.productName}$variantPart × ${item.quantity}';
      })
      .join('\n');

  final String paymentInfo = order.isPaid
      ? 'Lunas (${order.paymentMethod?.toUpperCase() ?? 'Midtrans'})'
      : 'Menunggu Pembayaran Midtrans';

  final String message = [
    'Halo Admin SOJU! Saya ingin konfirmasi pesanan:',
    'Kode Pesanan: *${order.code}*',
    'Nama: ${order.recipientName}',
    'Total: *${formatRupiah(order.total)}*',
    'Status Pembayaran: *$paymentInfo*',
    if (order.midtransOrderId != null && order.midtransOrderId!.isNotEmpty)
      'Ref Midtrans: ${order.midtransOrderId}',
    if (itemsSummary.isNotEmpty) 'Rincian:\n$itemsSummary',
    'Alamat: ${order.recipientAddress}',
  ].join('\n');

  final Uri waUri = Uri.https(
    'wa.me',
    '/$adminPhone',
    <String, String>{'text': message},
  );

  try {
    final bool launched = await launchUrl(
      waUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showFeedback(
        context,
        'WhatsApp tidak ditemukan di perangkat ini.',
        isError: true,
      );
    }
    return launched;
  } catch (_) {
    if (context.mounted) {
      _showFeedback(
        context,
        'Gagal membuka WhatsApp untuk konfirmasi pesanan.',
        isError: true,
      );
    }
    return false;
  }
}

void _showFeedback(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? SojuColors.expense : SojuColors.brandEmerald,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
