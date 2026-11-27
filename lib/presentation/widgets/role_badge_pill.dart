import 'package:flutter/material.dart';

import '../../core/themes/soju_colors.dart';

/// Badge peran yang konsisten di header & kartu notifikasi:
/// `SUPER ADMIN`, `ADMIN`, atau `PELANGGAN`.
class RoleBadgePill extends StatelessWidget {
  const RoleBadgePill({
    super.key,
    required this.roleLabel,
    this.compact = false,
  });

  factory RoleBadgePill.fromCode(String roleCode, {bool compact = false}) {
    final normalized = roleCode.trim().toUpperCase();
    if (normalized.contains('SUPER') || normalized.contains('UTAMA')) {
      return RoleBadgePill(roleLabel: 'SUPER ADMIN', compact: compact);
    }
    if (normalized.contains('ADMIN') || normalized.contains('CO_OPERATOR')) {
      return RoleBadgePill(roleLabel: 'ADMIN', compact: compact);
    }
    return RoleBadgePill(roleLabel: 'PELANGGAN', compact: compact);
  }

  final String roleLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final String upper = roleLabel.trim().toUpperCase();
    final bool isSuperAdmin = upper.contains('SUPER');
    final bool isAdmin = !isSuperAdmin && upper.contains('ADMIN');

    final Color bgColor = isSuperAdmin
        ? SojuColors.brandNavy
        : isAdmin
            ? const Color(0xFFDBEAFE)
            : SojuColors.incomeSoft;
    final Color fgColor = isSuperAdmin
        ? Colors.white
        : isAdmin
            ? SojuColors.brandNavy
            : SojuColors.brandEmerald;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 2.5 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isSuperAdmin
                ? Icons.verified_user_rounded
                : isAdmin
                    ? Icons.admin_panel_settings_rounded
                    : Icons.person_rounded,
            size: compact ? 11 : 13,
            color: fgColor,
          ),
          const SizedBox(width: 4),
          Text(
            upper,
            style: TextStyle(
              color: fgColor,
              fontSize: compact ? 9.5 : 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Emblem logo SOJU / Buku Dapur yang ringkas untuk app bar.
class SojuLogoEmblem extends StatelessWidget {
  const SojuLogoEmblem({
    super.key,
    this.size = 34,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[SojuColors.brandNavy, SojuColors.brandBlue],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: SojuColors.brandNavy.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        color: Colors.white,
        size: size * 0.54,
      ),
    );
  }
}

/// Tab bar bergaya underline bersih (user-friendly & mudah dibaca) untuk
/// halaman Pesanan Customer, Data/Analytics, dan Notifikasi.
class SojuUnderlineTabBar extends StatelessWidget {
  const SojuUnderlineTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    this.badges,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<int?>? badges;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: SojuColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        children: List<Widget>.generate(tabs.length, (int index) {
          final bool active = index == selectedIndex;
          final int? badgeCount =
              badges != null && index < badges!.length ? badges![index] : null;
          return Expanded(
            child: InkWell(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? SojuColors.brandNavy : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        tabs[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? SojuColors.brandNavy
                              : SojuColors.inkMuted,
                        ),
                      ),
                    ),
                    if (badgeCount != null && badgeCount > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? SojuColors.brandNavy
                              : SojuColors.cardBorder,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : SojuColors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
