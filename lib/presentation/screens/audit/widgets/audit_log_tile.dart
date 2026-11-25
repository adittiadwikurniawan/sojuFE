// lib/presentation/screens/audit/widgets/audit_log_tile.dart
//
// Satu baris log audit pada layar Audit & Stok.
//
// Menampilkan waktu, aksi, nama record, detail, dan pengguna (bila ada).
// Tidak ada aksi sentuh mutasi — baris tidak dapat diubah maupun dihapus.

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../models/audit_view_data.dart';

/// Kartu satu log audit.
class AuditLogTile extends StatelessWidget {
  const AuditLogTile({super.key, required this.scale, required this.log});

  final double scale;
  final AuditLogViewData log;

  @override
  Widget build(BuildContext context) {
    final AuditActionStyle style = AuditActionStyle.of(log.kind);

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44 * scale,
            height: 44 * scale,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Icon(style.icon, size: 22 * scale, color: style.accent),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  log.recordNama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                SizedBox(height: 3 * scale),
                Row(
                  children: <Widget>[
                    _ActionBadge(
                      scale: scale,
                      label: log.aksiLabel,
                      style: style,
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      '${log.jamText} WIB',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 11.5 * scale,
                        fontWeight: FontWeight.w500,
                        color: SojuColors.analyticsMuted,
                      ),
                    ),
                  ],
                ),
                if (_hasDetail) ...<Widget>[
                  SizedBox(height: 6 * scale),
                  Text(
                    log.detail!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: SojuColors.analyticsLabel,
                    ),
                  ),
                ],
                if (_hasPengguna)
                  Padding(
                    padding: EdgeInsets.only(top: 6 * scale),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 16 * scale,
                          height: 16 * scale,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: SojuColors.surfaceMuted,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            log.pengguna!.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 9 * scale,
                              fontWeight: FontWeight.w800,
                              color: SojuColors.analyticsLabel,
                            ),
                          ),
                        ),
                        SizedBox(width: 5 * scale),
                        Flexible(
                          child: Text(
                            log.pengguna!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 11.5 * scale,
                              fontWeight: FontWeight.w600,
                              color: SojuColors.analyticsMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasDetail => log.detail != null && log.detail!.isNotEmpty;

  bool get _hasPengguna => log.pengguna != null && log.pengguna!.isNotEmpty;
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({
    required this.scale,
    required this.label,
    required this.style,
  });

  final double scale;
  final String label;
  final AuditActionStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 10.5 * scale,
          fontWeight: FontWeight.w700,
          color: style.accent,
        ),
      ),
    );
  }
}
