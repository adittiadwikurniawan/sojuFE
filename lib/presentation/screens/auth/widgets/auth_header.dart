import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../widgets/role_badge_pill.dart';

/// Tab pada header layar auth.
enum AuthTab {
  /// Masuk ke akun yang sudah ada.
  login('Masuk'),

  /// Membuat akun baru.
  register('Daftar');

  const AuthTab(this.label);

  /// Label tab.
  final String label;
}

/// Header layar auth 1:1 mengikuti `renderAuthFullPage()` pada HTML prototype:
/// - Latar gradien halus `brandNavy/5 -> surface`
/// - Emblem bulat SOJU di tengah + judul `Buku Dapur SOJU`
/// - Segmented pill switcher (`Masuk` | `Daftar`) dengan pil aktif `brandNavy`
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.activeTab,
    this.onTabSelected,
  });

  final double scale;
  final String title;
  final String subtitle;
  final AuthTab activeTab;
  final ValueChanged<AuthTab>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            SojuColors.brandNavy.withOpacity(0.08),
            SojuColors.canvas,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        topInset + 20 * scale,
        20 * scale,
        8 * scale,
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 72 * scale,
            height: 72 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SojuColors.surface,
              border: Border.all(
                color: SojuColors.brandNavy.withOpacity(0.14),
                width: 2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: SojuColors.brandNavy.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: SojuLogoEmblem(size: 52 * scale),
          ),
          SizedBox(height: 12 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 21 * scale,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: SojuColors.brandNavy,
            ),
          ),
          SizedBox(height: 4 * scale),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 320 * scale),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: SojuColors.inkMuted,
              ),
            ),
          ),
          SizedBox(height: 18 * scale),
          // Segmented Pill Switcher 1:1 HTML
          Container(
            padding: EdgeInsets.all(4 * scale),
            decoration: BoxDecoration(
              color: SojuColors.surface,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: SojuColors.cardBorder),
            ),
            child: Row(
              children: <Widget>[
                for (final AuthTab tab in AuthTab.values)
                  Expanded(
                    child: _AuthTabButton(
                      scale: scale,
                      tab: tab,
                      active: tab == activeTab,
                      onTap: onTabSelected,
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

class _AuthTabButton extends StatelessWidget {
  const _AuthTabButton({
    required this.scale,
    required this.tab,
    required this.active,
    this.onTap,
  });

  final double scale;
  final AuthTab tab;
  final bool active;
  final ValueChanged<AuthTab>? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: active,
      button: true,
      child: Material(
        color: active ? SojuColors.brandNavy : Colors.transparent,
        borderRadius: BorderRadius.circular(12 * scale),
        child: InkWell(
          onTap: onTap == null ? null : () => onTap!(tab),
          borderRadius: BorderRadius.circular(12 * scale),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10 * scale),
            alignment: Alignment.center,
            child: Text(
              tab.label,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : SojuColors.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
