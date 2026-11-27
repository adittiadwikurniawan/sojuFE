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
import '../../widgets/role_badge_pill.dart';
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
  /// Id notifikasi yang sudah ditandai dibaca lewat "Abaikan" atau "Tandai Semua Dibaca".
  final Set<String> _readIds = <String>{};
  int _selectedFilterTab = 0; // 0: Semua, 1: Belum Dibaca, 2: Sudah Dibaca

  bool _isUnread(AppNotificationData notification) =>
      notification.isUnread && !_readIds.contains(notification.id);

  int get _unreadCount => widget.data.notifications.where(_isUnread).length;

  List<AppNotificationData> get _filteredNotifications {
    switch (_selectedFilterTab) {
      case 1:
        return widget.data.notifications.where(_isUnread).toList();
      case 2:
        return widget.data.notifications
            .where((AppNotificationData n) => !_isUnread(n))
            .toList();
      default:
        return widget.data.notifications;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (final AppNotificationData n in widget.data.notifications) {
        _readIds.add(n.id);
      }
    });
    _showSnack('Semua notifikasi ditandai sudah dibaca.');
  }

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
                            SizedBox(height: 16 * scale),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * scale,
                              ),
                              child: SojuUnderlineTabBar(
                                tabs: const <String>[
                                  'Semua',
                                  'Belum Dibaca',
                                  'Sudah Dibaca',
                                ],
                                selectedIndex: _selectedFilterTab,
                                badges: <int?>[
                                  widget.data.notifications.length,
                                  _unreadCount,
                                  widget.data.notifications.length -
                                      _unreadCount,
                                ],
                                onSelected: (int index) =>
                                    setState(() => _selectedFilterTab = index),
                              ),
                            ),
                            SizedBox(height: 16 * scale),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * scale,
                              ),
                              child: _SectionHeader(
                                scale: scale,
                                label: widget.data.todayLabel,
                                unreadCount: _unreadCount,
                                onMarkAllRead:
                                    _unreadCount > 0 ? _markAllAsRead : null,
                              ),
                            ),
                            SizedBox(height: 14 * scale),
                            if (_filteredNotifications.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24 * scale,
                                  vertical: 32 * scale,
                                ),
                                child: const Column(
                                  children: <Widget>[
                                    Icon(
                                      Icons.notifications_none_rounded,
                                      size: 44,
                                      color: SojuColors.inkMuted,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Semua notifikasi sudah terbaca',
                                      style: TextStyle(
                                        fontFamily: AppTypography.family,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: SojuColors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              for (final AppNotificationData notification
                                  in _filteredNotifications)
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
                                    unread: _isUnread(notification),
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
    this.onMarkAllRead,
  });

  final double scale;
  final String label;
  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 14.5 * scale,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: SojuColors.notificationBody,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        if (onMarkAllRead != null) ...<Widget>[
          InkWell(
            onTap: onMarkAllRead,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                'Tandai Dibaca',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 11.5 * scale,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.brandNavy,
                ),
              ),
            ),
          ),
          SizedBox(width: 6 * scale),
        ],
        Text(
          '$unreadCount Belum Dibaca',
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 13 * scale,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: SojuColors.notificationBlue,
          ),
        ),
      ],
    );
  }
}
