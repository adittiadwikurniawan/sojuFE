import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/auth_session_entity.dart';

/// Pemilih jalur akun (`Admin` atau `Pelanggan`) pada layar autentikasi.
class AuthPortalSelector extends StatelessWidget {
  const AuthPortalSelector({
    super.key,
    required this.scale,
    required this.selectedPortal,
    required this.onChanged,
    this.enabled = true,
  });

  final double scale;
  final AuthPortal selectedPortal;
  final ValueChanged<AuthPortal> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: SojuColors.border, width: 1 * scale),
      ),
      child: Row(
        children: <Widget>[
          for (final AuthPortal portal in AuthPortal.values)
            Expanded(
              child: _PortalOption(
                key: Key('auth_portal_${portal.name}'),
                scale: scale,
                portal: portal,
                selected: portal == selectedPortal,
                enabled: enabled,
                onTap: () {
                  if (enabled && portal != selectedPortal) {
                    onChanged(portal);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _PortalOption extends StatelessWidget {
  const _PortalOption({
    super.key,
    required this.scale,
    required this.portal,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final double scale;
  final AuthPortal portal;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IconData icon = portal == AuthPortal.admin
        ? Icons.admin_panel_settings_outlined
        : Icons.storefront_outlined;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? SojuColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10 * scale),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10 * scale),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10 * scale,
              horizontal: 8 * scale,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: 18 * scale,
                  color: selected ? SojuColors.surface : SojuColors.inkMuted,
                ),
                SizedBox(width: 6 * scale),
                Flexible(
                  child: Text(
                    portal.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: selected ? SojuColors.surface : SojuColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
