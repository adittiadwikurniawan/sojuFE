// lib/presentation/screens/notifications/widgets/urgent_alert_banner.dart
//
// Banner "Urgent Attention Alert" pada halaman Notifikasi
// (node Figma `546:1847`).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/notifications_view_data.dart';

/// Banner merah muda dengan ringkasan tindakan yang butuh perhatian.
class UrgentAlertBanner extends StatelessWidget {
  const UrgentAlertBanner({
    super.key,
    required this.scale,
    required this.data,
    this.onTap,
  });

  final double scale;
  final UrgentNotificationData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.5 * scale),
      decoration: BoxDecoration(
        color: SojuColors.notificationUrgentBg,
        borderRadius: BorderRadius.circular(17.75 * scale),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44 * scale,
            height: 44 * scale,
            decoration: BoxDecoration(
              color: SojuColors.notificationUrgent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13.3 * scale),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 20 * scale,
              color: SojuColors.notificationUrgent,
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
                          fontSize: 15.53 * scale,
                          fontWeight: FontWeight.w600,
                          height: 19.97 / 15.53,
                          color: SojuColors.notificationUrgentInk,
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.85 * scale,
                        vertical: 2.2 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: SojuColors.notificationUrgent,
                        borderRadius: BorderRadius.circular(100 * scale),
                      ),
                      child: Text(
                        data.badge,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 11.09 * scale,
                          fontWeight: FontWeight.w600,
                          height: 15.53 / 11.09,
                          color: SojuColors.surface,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6 * scale),
                Text(
                  data.message,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 13.31 * scale,
                    fontWeight: FontWeight.w400,
                    height: 21.63 / 13.31,
                    color: SojuColors.notificationUrgentInk.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: 12 * scale),
                Semantics(
                  button: true,
                  label: data.actionLabel,
                  child: GestureDetector(
                    key: const Key('urgent_alert_action'),
                    onTap: onTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.5 * scale,
                        vertical: 8 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: SojuColors.notificationUrgent,
                        borderRadius: BorderRadius.circular(100 * scale),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              data.actionLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 13.31 * scale,
                                fontWeight: FontWeight.w600,
                                height: 17.75 / 13.31,
                                color: SojuColors.surface,
                              ),
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14 * scale,
                            color: SojuColors.surface,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
