// lib/presentation/widgets/admin_drawer.dart
//
// Drawer navigasi samping untuk Shell Admin & Super Admin (AD-08, AD-11):
// - Audit: tersedia untuk `ADMIN` dan `SUPER_ADMIN`.
// - Users, CMS, CRM: dikunci ketat khusus `SUPER_ADMIN`.

import 'package:flutter/material.dart';

import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';
import '../../domain/entities/auth_session_entity.dart';

/// Item menu pada [AdminDrawer] beserta aturan pembatasan peran (`AD-08`).
enum AdminDrawerItem {
  orders(
    label: 'Pesanan Pelanggan',
    subtitle: 'Kelola antrean pesanan masuk',
    icon: Icons.receipt_long_outlined,
    superAdminOnly: false,
  ),
  audit(
    label: 'Log Audit',
    subtitle: 'Riwayat aktivitas operasional',
    icon: Icons.fact_check_outlined,
    superAdminOnly: false,
  ),
  profile(
    label: 'Akun & Pengaturan',
    subtitle: 'Profil pengelola, password & bantuan',
    icon: Icons.person_outline_rounded,
    superAdminOnly: false,
  ),
  users(
    label: 'Kelola Pengguna',
    subtitle: 'Manajemen akun Admin & Super Admin',
    icon: Icons.manage_accounts_outlined,
    superAdminOnly: true,
  ),
  cms(
    label: 'Konten CMS & Produk',
    subtitle: 'Konten publik & katalog menu SOJU',
    icon: Icons.web_outlined,
    superAdminOnly: true,
  ),
  crm(
    label: 'Pelanggan & CRM',
    subtitle: 'Ringkasan pelanggan & kampanye promosi',
    icon: Icons.groups_outlined,
    superAdminOnly: true,
  );

  const AdminDrawerItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.superAdminOnly,
  });

  /// Label menu dalam Bahasa Indonesia.
  final String label;

  /// Deskripsi singkat fungsi menu dalam Bahasa Indonesia.
  final String subtitle;

  /// Ikon menu.
  final IconData icon;

  /// Apakah menu ini eksklusif untuk `SUPER_ADMIN`.
  final bool superAdminOnly;

  /// Daftar item yang diizinkan tampil untuk [role].
  static List<AdminDrawerItem> visibleFor(UserRole role) {
    if (!role.isAdminPortal) {
      return const <AdminDrawerItem>[];
    }
    return AdminDrawerItem.values
        .where(
          (AdminDrawerItem item) => !item.superAdminOnly || role.isSuperAdmin,
        )
        .toList(growable: false);
  }
}

/// Drawer navigasi pengelola internal (`ADMIN` & `SUPER_ADMIN`).
class AdminDrawer extends StatelessWidget {
  const AdminDrawer({
    super.key,
    required this.role,
    required this.onSelectItem,
    this.userName = 'Pengelola SOJU',
    this.userEmail = 'admin@sojucorp.com',
    this.selectedItem,
    this.onLogout,
  });

  final UserRole role;
  final String userName;
  final String userEmail;
  final AdminDrawerItem? selectedItem;
  final ValueChanged<AdminDrawerItem> onSelectItem;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final List<AdminDrawerItem> operationalItems =
        AdminDrawerItem.visibleFor(role)
            .where((AdminDrawerItem item) => !item.superAdminOnly)
            .toList(growable: false);
    final List<AdminDrawerItem> superAdminItems =
        AdminDrawerItem.visibleFor(role)
            .where((AdminDrawerItem item) => item.superAdminOnly)
            .toList(growable: false);

    return Drawer(
      key: const Key('admin_drawer'),
      backgroundColor: SojuColors.surface,
      surfaceTintColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _DrawerHeader(
            userName: userName,
            userEmail: userEmail,
            role: role,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              children: <Widget>[
                const _SectionHeading(title: 'MENU OPERASIONAL'),
                const SizedBox(height: 6),
                for (final AdminDrawerItem item in operationalItems)
                  _DrawerTile(
                    key: Key('admin_drawer_${item.name}'),
                    item: item,
                    selected: item == selectedItem,
                    onTap: () => onSelectItem(item),
                  ),
                if (superAdminItems.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: SojuColors.hairline),
                  const SizedBox(height: 10),
                  const _SectionHeading(title: 'KHUSUS SUPER ADMIN'),
                  const SizedBox(height: 6),
                  for (final AdminDrawerItem item in superAdminItems)
                    _DrawerTile(
                      key: Key('admin_drawer_${item.name}'),
                      item: item,
                      selected: item == selectedItem,
                      onTap: () => onSelectItem(item),
                    ),
                ],
              ],
            ),
          ),
          if (onLogout != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                child: OutlinedButton.icon(
                  key: const Key('admin_drawer_logout'),
                  onPressed: onLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SojuColors.expense,
                    side: const BorderSide(color: SojuColors.profileCardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 19),
                  label: const Text(
                    'Keluar Akun',
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.userName,
    required this.userEmail,
    required this.role,
  });

  final String userName;
  final String userEmail;
  final UserRole role;

  String _initials(String raw) {
    final List<String> parts = raw
        .trim()
        .split(RegExp(r'\s+'))
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'SJ';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topInset + 22, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[SojuColors.primaryDeep, SojuColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 24,
                backgroundColor: SojuColors.surface.withOpacity(0.18),
                child: Text(
                  _initials(userName),
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.surface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SojuColors.surface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12.5,
                        color: SojuColors.surface.withOpacity(0.84),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            key: const Key('admin_drawer_role_badge'),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: SojuColors.surface.withOpacity(0.18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              role.label,
              style: const TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: SojuColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: SojuColors.inkMuted,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AdminDrawerItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? SojuColors.primary : SojuColors.ink;
    final Color bg = selected ? SojuColors.infoSoft : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? SojuColors.primary.withOpacity(0.14)
                        : SojuColors.homeBackground,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(item.icon, size: 20, color: fg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 11.5,
                          color: SojuColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: selected ? SojuColors.primary : SojuColors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
