// lib/presentation/screens/notifications/widgets/notification_card.dart
//
// Kartu notifikasi halaman Notifikasi (node Figma `546:1867`, `546:1903`,
// `546:1936`).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../widgets/role_badge_pill.dart';
import '../models/notifications_view_data.dart';

/// Satu kartu notifikasi dengan ikon, isi, metadata, dan aksi.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.scale,
    required this.data,
    required this.unread,
    required this.onAction,
  });

  final double scale;
  final AppNotificationData data;

  /// Status belum dibaca setelah aksi lokal "Abaikan".
  final bool unread;

  final ValueChanged<NotificationActionData> onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.5 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(17.7 * scale),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: SojuColors.notificationCardShadow,
            offset: Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: data.visual.backgroundColor,
                  borderRadius: BorderRadius.circular(13.3 * scale),
                ),
                child: Icon(
                  data.visual.icon,
                  size: 20 * scale,
                  color: data.visual.iconColor,
                ),
              ),
              SizedBox(width: 8.85 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            data.title,
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 19.9 * scale,
                              fontWeight: FontWeight.w600,
                              height: 27.38 / 19.9,
                              color: SojuColors.notificationTitle,
                            ),
                          ),
                        ),
                        if (unread) ...<Widget>[
                          SizedBox(width: 8 * scale),
                          Container(
                            key: Key('notification_unread_${data.id}'),
                            width: 11 * scale,
                            height: 11 * scale,
                            margin: EdgeInsets.only(top: 4 * scale),
                            decoration: const BoxDecoration(
                              color: SojuColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.4 * scale),
                    _BodyText(scale: scale, parts: data.body),
                    SizedBox(height: 10 * scale),
                    _Metadata(scale: scale, data: data),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 4.4 * scale,
              runSpacing: 6 * scale,
              children: <Widget>[
                for (final NotificationActionData action in data.actions)
                  _ActionButton(
                    scale: scale,
                    action: action,
                    onTap: () => onAction(action),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText({required this.scale, required this.parts});

  final double scale;
  final List<NotificationBodyPart> parts;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 15.5 * scale,
          fontWeight: FontWeight.w400,
          height: 25.2 / 15.5,
          color: SojuColors.notificationBody,
        ),
        children: <InlineSpan>[
          for (final NotificationBodyPart part in parts)
            TextSpan(
              text: part.text,
              style: TextStyle(
                fontWeight: part.strong ? FontWeight.w600 : FontWeight.w400,
                color: part.danger
                    ? SojuColors.expense
                    : part.strong
                        ? SojuColors.notificationTitle
                        : SojuColors.notificationBody,
              ),
            ),
        ],
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.scale, required this.data});

  final double scale;
  final AppNotificationData data;

  String _senderRoleFor(String category) {
    final String lower = category.toLowerCase();
    if (lower.contains('kas') ||
        lower.contains('audit') ||
        lower.contains('sistem') ||
        lower.contains('super')) {
      return 'SUPER_ADMIN';
    }
    return 'ADMIN';
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6 * scale,
      runSpacing: 4 * scale,
      children: <Widget>[
        RoleBadgePill.fromCode(
          _senderRoleFor(data.categoryLabel),
          compact: true,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.schedule_rounded,
              size: 13 * scale,
              color: SojuColors.notificationBody,
            ),
            SizedBox(width: 4 * scale),
            Text(
              data.timeLabel,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 11.06 * scale,
                fontWeight: FontWeight.w600,
                height: 15.49 / 11.06,
                color: SojuColors.notificationBody,
              ),
            ),
          ],
        ),
        Text(
          '•',
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 15 * scale,
            fontWeight: FontWeight.w400,
            height: 1,
            color: SojuColors.notificationBullet,
          ),
        ),
        Text(
          data.categoryLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 11.06 * scale,
            fontWeight: FontWeight.w500,
            height: 15.49 / 11.06,
            color: SojuColors.notificationBlue,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.scale,
    required this.action,
    required this.onTap,
  });

  final double scale;
  final NotificationActionData action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool primary = action.isPrimary;
    final Color foreground =
        primary ? SojuColors.surface : SojuColors.notificationBody;

    return Semantics(
      button: true,
      label: action.label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 31 * scale,
          padding: EdgeInsets.symmetric(horizontal: 15.5 * scale),
          decoration: BoxDecoration(
            color: primary
                ? SojuColors.primary
                : SojuColors.notificationSecondaryBg,
            borderRadius: BorderRadius.circular(100 * scale),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (action.icon != null) ...<Widget>[
                Icon(action.icon, size: 14 * scale, color: foreground),
                SizedBox(width: 4.4 * scale),
              ],
              Text(
                action.label,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13.27 * scale,
                  fontWeight: FontWeight.w600,
                  height: 17.7 / 13.27,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
