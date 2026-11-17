import 'package:flutter/material.dart';

import '../../../core/themes/soju_colors.dart';
import 'login_screen.dart';
import 'models/login_form_data.dart';
import 'models/register_form_data.dart';
import 'register_screen.dart';
import 'widgets/auth_header.dart';

/// Alur auth dalam satu layar: tab "Masuk" dan "Daftar" digeser
/// (bukan berpindah halaman), baik lewat tab maupun sapuan horizontal.
///
/// Isian tiap formulir dipertahankan saat bergeser karena kedua layar
/// memakai [AutomaticKeepAliveClientMixin].
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    this.initialTab = AuthTab.login,
    this.onLoginSubmit,
    this.onRegisterSubmit,
    this.onForgotPassword,
    this.onGoogleLogin,
    this.onOpenTerms,
    this.onOpenPrivacy,
  });

  /// Tab yang tampil pertama.
  final AuthTab initialTab;

  final ValueChanged<LoginFormData>? onLoginSubmit;
  final ValueChanged<RegisterFormData>? onRegisterSubmit;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onGoogleLogin;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const Duration _transition = Duration(milliseconds: 280);

  late final PageController _controller = PageController(
    initialPage: widget.initialTab.index,
  );
  late int _index = widget.initialTab.index;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(AuthTab tab) {
    if (tab.index == _index) {
      return;
    }
    FocusScope.of(context).unfocus();
    _controller.animateToPage(
      tab.index,
      duration: _transition,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SojuColors.surface,
      body: PageView(
        controller: _controller,
        onPageChanged: (int index) => setState(() => _index = index),
        children: <Widget>[
          LoginScreen(
            onSubmit: widget.onLoginSubmit,
            onRegisterTap: () => _goTo(AuthTab.register),
            onForgotPassword: widget.onForgotPassword,
            onGoogleLogin: widget.onGoogleLogin,
          ),
          RegisterScreen(
            onSubmit: widget.onRegisterSubmit,
            onLoginTap: () => _goTo(AuthTab.login),
            onOpenTerms: widget.onOpenTerms,
            onOpenPrivacy: widget.onOpenPrivacy,
          ),
        ],
      ),
    );
  }
}
