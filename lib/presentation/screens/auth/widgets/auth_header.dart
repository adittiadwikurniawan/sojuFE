import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

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

/// Header layar auth (frame `546:1547`, node `546:1603`): logo, judul,
/// subjudul, dan tab "Masuk"/"Daftar".
///
/// Dipakai bersama oleh layar masuk dan daftar; layar cukup menentukan
/// [activeTab] dan [onTabSelected].
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

  static const String _logoAsset = 'assets/images/logo_bukukita.png';

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: const BoxDecoration(
        color: SojuColors.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 1),
            blurRadius: 14,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: topInset + 8 * scale,
        bottom: 12 * scale,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 56 * scale,
            child: Image.asset(_logoAsset, fit: BoxFit.contain),
          ),
          SizedBox(height: 8 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 28 * scale,
              fontWeight: FontWeight.w700,
              height: 34 / 28,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4 * scale),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300 * scale),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                height: 22.75 / 12,
                color: SojuColors.inkMuted,
              ),
            ),
          ),
          SizedBox(height: 20 * scale),
          Row(
            children: <Widget>[
              for (final AuthTab tab in AuthTab.values)
                Expanded(
                    child: _AuthTabButton(
                  scale: scale,
                  tab: tab,
                  active: tab == activeTab,
                  onTap: onTabSelected,
                )),
            ],
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
    final Color color = active ? SojuColors.tabActive : Colors.black;

    return Semantics(
      selected: active,
      button: true,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(tab),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6 * scale),
          child: Column(
            children: <Widget>[
              Text(
                tab.label,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w600,
                  height: 22.75 / 18,
                  color: color,
                ),
              ),
              SizedBox(height: 6 * scale),
              Container(
                height: 2 * scale,
                width: 44 * scale,
                color: active ? SojuColors.tabActive : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
