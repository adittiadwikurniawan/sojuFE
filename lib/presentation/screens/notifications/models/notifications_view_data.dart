// lib/presentation/screens/notifications/models/notifications_view_data.dart
//
// Model tampilan halaman Notifikasi (frame Figma `546:1841`).
//
// Seluruh teks, ikon, dan warna kartu berasal dari node Figma. Halaman ini
// masih read-only dan memakai data contoh; pemetaan API nanti cukup
// menghasilkan [NotificationsViewData] tanpa mengubah widget.

import 'package:flutter/material.dart';

import '../../../../core/themes/soju_colors.dart';

/// Data satu halaman notifikasi.
@immutable
class NotificationsViewData {
  const NotificationsViewData({
    required this.urgent,
    required this.todayLabel,
    required this.notifications,
  });

  /// Banner tindakan mendesak di atas daftar.
  final UrgentNotificationData urgent;

  /// Label kelompok daftar, mis. `HARI INI`.
  final String todayLabel;

  /// Notifikasi yang ditampilkan pada kelompok hari ini.
  final List<AppNotificationData> notifications;

  /// Jumlah notifikasi yang masih belum dibaca pada data sumber.
  int get unreadCount => notifications
      .where((AppNotificationData notification) => notification.isUnread)
      .length;

  /// Data contoh hasil slicing Figma.
  static const NotificationsViewData sample = NotificationsViewData(
    urgent: UrgentNotificationData(
      title: '2 Tindakan Butuh Perhatian Segera',
      badge: 'KRITIS',
      message: 'Stok bahan baku freezer mendekati habis & selisih fisik '
          'kas kasir shift pagi belum diselesaikan.',
      actionLabel: 'Buka Rekonsiliasi Kas',
    ),
    todayLabel: 'HARI INI',
    notifications: <AppNotificationData>[
      AppNotificationData(
        id: 'stock-critical',
        title: 'Peringatan Stok Kritis: Daging Ayam Fillet',
        body: <NotificationBodyPart>[
          NotificationBodyPart('Sisa stok fisik di '),
          NotificationBodyPart(
            'Freezer Utama tersisa 1.8 kg',
            strong: true,
          ),
          NotificationBodyPart(
            ' (di bawah batas minimum 5.0 kg). Segera restock dari '
            'supplier CV Jaya Meat.',
          ),
        ],
        timeLabel: '10 menit lalu',
        categoryLabel: 'Stok & Inventaris',
        isUnread: true,
        visual: NotificationVisualData(
          icon: Icons.warning_amber_rounded,
          backgroundColor: SojuColors.notificationUrgentBg,
          iconColor: SojuColors.notificationUrgent,
        ),
        actions: <NotificationActionData>[
          NotificationActionData(
            label: 'Abaikan',
            kind: NotificationActionKind.dismiss,
          ),
          NotificationActionData(
            label: 'Pesan ke Supplier',
            kind: NotificationActionKind.supplier,
            icon: Icons.send_rounded,
          ),
        ],
      ),
      AppNotificationData(
        id: 'cash-difference',
        title: 'Selisih Kasir Shift Pagi Ditemukan',
        body: <NotificationBodyPart>[
          NotificationBodyPart(
            'Terdapat selisih fisik kas vs buku pembukuan sebesar ',
          ),
          NotificationBodyPart(
            '-Rp 15.000',
            strong: true,
            danger: true,
          ),
          NotificationBodyPart(
            ' pada penutupan kasir jam 14:00 WIB oleh Kasir Rina.',
          ),
        ],
        timeLabel: '1 jam lalu',
        categoryLabel: 'Audit Kas Opname',
        isUnread: true,
        visual: NotificationVisualData(
          icon: Icons.point_of_sale_rounded,
          backgroundColor: SojuColors.notificationUrgentBg,
          iconColor: SojuColors.notificationUrgent,
        ),
        actions: <NotificationActionData>[
          NotificationActionData(
            label: 'Periksa & Sesuaikan',
            kind: NotificationActionKind.reconcile,
          ),
        ],
      ),
      AppNotificationData(
        id: 'supplier-due',
        title: 'Jatuh Tempo Besok: Tagihan CV Subur Gas',
        body: <NotificationBodyPart>[
          NotificationBodyPart(
            'Hutang pembelian refill 5 tabung LPG 3kg sebesar Rp 110.000 '
            'jatuh tempo pada 15 Okt 2026.',
          ),
        ],
        timeLabel: '3 jam lalu',
        categoryLabel: 'Hutang & Supplier',
        isUnread: true,
        visual: NotificationVisualData(
          icon: Icons.local_gas_station_rounded,
          backgroundColor: SojuColors.notificationSupplierBg,
          iconColor: SojuColors.notificationSupplierInk,
        ),
        actions: <NotificationActionData>[
          NotificationActionData(
            label: 'Bayar & Catat Kas',
            kind: NotificationActionKind.payment,
          ),
        ],
      ),
    ],
  );
}

/// Isi banner peringatan mendesak.
@immutable
class UrgentNotificationData {
  const UrgentNotificationData({
    required this.title,
    required this.badge,
    required this.message,
    required this.actionLabel,
  });

  final String title;
  final String badge;
  final String message;
  final String actionLabel;
}

/// Satu kartu notifikasi.
@immutable
class AppNotificationData {
  const AppNotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.categoryLabel,
    required this.isUnread,
    required this.visual,
    required this.actions,
  });

  final String id;
  final String title;

  /// Potongan isi; [NotificationBodyPart.strong] ditebalkan seperti Figma.
  final List<NotificationBodyPart> body;

  final String timeLabel;
  final String categoryLabel;
  final bool isUnread;
  final NotificationVisualData visual;
  final List<NotificationActionData> actions;
}

/// Potongan teks isi notifikasi.
@immutable
class NotificationBodyPart {
  const NotificationBodyPart(
    this.text, {
    this.strong = false,
    this.danger = false,
  });

  final String text;
  final bool strong;
  final bool danger;
}

/// Ikon dan warna kartu notifikasi.
@immutable
class NotificationVisualData {
  const NotificationVisualData({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

/// Jenis aksi pada kartu notifikasi.
enum NotificationActionKind { dismiss, reconcile, supplier, payment }

/// Tombol aksi pada kartu notifikasi.
@immutable
class NotificationActionData {
  const NotificationActionData({
    required this.label,
    required this.kind,
    this.icon,
  });

  final String label;
  final NotificationActionKind kind;
  final IconData? icon;

  /// Aksi selain "Abaikan" memakai tombol primer biru.
  bool get isPrimary => kind != NotificationActionKind.dismiss;
}
