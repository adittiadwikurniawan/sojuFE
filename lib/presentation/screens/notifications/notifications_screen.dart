// lib/presentation/screens/notifications/notifications_screen.dart
//
// Layar Notifikasi (frame Figma `546:1841`).
//
// Halaman read-only dengan data contoh. "Abaikan" hanya mengubah status baca
// di layar ini; aksi lain diteruskan lewat callback atau menampilkan pesan
// bahwa integrasi API belum tersedia. Tidak ada request HTTP dari widget.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import 'models/notifications_view_data.dart';
import 'widgets/notification_card.dart';
import 'widgets/notifications_top_bar.dart';
import 'widgets/urgent_alert_banner.dart';

/// Layar daftar notifikasi.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.data = NotificationsViewData.sample,
    this.onBack,
    this.onReconcile,
    this.onAction,
  });

  /// Data tampilan; bawaannya [NotificationsViewData.sample].
  final NotificationsViewData data;

  /// Aksi tombol kembali.
  final VoidCallback? onBack;

  /// Membuka halaman rekonsiliasi kas (Analytics) dari banner atau kartu
  /// selisih kas.
  final VoidCallback? onReconcile;

  /// Callback aksi lain, mis. untuk integrasi API di Phase B.
  final void Function(
    AppNotificationData notification,
    NotificationActionData action,
  )? onAction;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// Id notifikasi yang sudah ditandai dibaca lewat "Abaikan".
  final Set<String> _readIds = <String>{};

  int get _unreadCount => widget.data.notifications
      .where(
        (AppNotificationData notification) =>
            notification.isUnread && !_readIds.contains(notification.id),
      )
      .length;

  void _handleUrgentTap() {
    final VoidCallback? reconcile = widget.onReconcile;
    if (reconcile != null) {
      reconcile();
      return;
    }
    _showSnack('Rekonsiliasi kas belum tersambung ke API.');
  }

  void _handleAction(
    AppNotificationData notification,
    NotificationActionData action,
  ) {
    if (action.kind == NotificationActionKind.dismiss) {
      setState(() => _readIds.add(notification.id));
      widget.onAction?.call(notification, action);
      return;
    }

    if (action.kind == NotificationActionKind.reconcile) {
      final VoidCallback? reconcile = widget.onReconcile;
      if (reconcile != null) {
        widget.onAction?.call(notification, action);
        reconcile();
        return;
      }
    }

    final void Function(
      AppNotificationData notification,
      NotificationActionData action,
    )? handler = widget.onAction;
    if (handler != null) {
      handler(notification, action);
      return;
    }
    _showSnack('Aksi "${action.label}" belum tersambung ke API.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SojuColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = math.min(constraints.maxWidth, 480);
            final double scale = width / 430;
            final double topInset = MediaQuery.paddingOf(context).top;
            final double bottomInset = MediaQuery.paddingOf(context).bottom;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: Column(
                  children: <Widget>[
                    NotificationsTopBar(
                      scale: scale,
                      topInset: topInset,
                      onBack: widget.onBack,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: 24 * scale + bottomInset,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(height: 9 * scale),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * scale,
                              ),
                              child: UrgentAlertBanner(
                                scale: scale,
                                data: widget.data.urgent,
                                onTap: _handleUrgentTap,
                              ),
                            ),
                            SizedBox(height: 24 * scale),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * scale,
                              ),
                              child: _SectionHeader(
                                scale: scale,
                                label: widget.data.todayLabel,
                                unreadCount: _unreadCount,
                              ),
                            ),
                            SizedBox(height: 18 * scale),
                            for (final AppNotificationData notification
                                in widget.data.notifications)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 16 * scale,
                                  right: 16 * scale,
                                  bottom: 11 * scale,
                                ),
                                child: NotificationCard(
                                  key: Key(
                                    'notification_card_${notification.id}',
                                  ),
                                  scale: scale,
                                  data: notification,
                                  unread: notification.isUnread &&
                                      !_readIds.contains(notification.id),
                                  onAction: (NotificationActionData action) =>
                                      _handleAction(notification, action),
                                ),
                              ),
                          ],
                        ),
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
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.scale,
    required this.label,
    required this.unreadCount,
  });

  final double scale;
  final String label;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: SojuColors.notificationBody,
          ),
        ),
        const Spacer(),
        Text(
          '$unreadCount Belum Dibaca',
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: SojuColors.notificationBlue,
          ),
        ),
      ],
    );
  }
}
