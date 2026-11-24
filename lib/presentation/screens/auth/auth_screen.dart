import 'package:flutter/material.dart';

import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/auth_session_entity.dart';
import 'login_screen.dart';
import 'models/login_form_data.dart';
import 'models/register_form_data.dart';
import 'register_screen.dart';
import 'widgets/auth_header.dart';

/// Alur auth dalam satu layar: tab "Masuk" (Admin / Pelanggan) dan "Daftar"
/// (khusus Pelanggan) digeser dalam satu halaman, baik lewat tab maupun
/// sapuan horizontal.
///
/// Isian tiap formulir dipertahankan saat bergeser karena kedua layar
/// memakai [AutomaticKeepAliveClientMixin].
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    this.initialTab = AuthTab.login,
    this.initialPortal = AuthPortal.admin,
    this.onLoginSubmit,
    this.onRegisterSubmit,
    this.onForgotPassword,
    this.onForgotPasswordWithPortal,
    this.onPortalChanged,
    this.onOpenTerms,
    this.onOpenPrivacy,
    this.onTabChanged,
    this.onFieldChanged,
    this.isLoginLoading = false,
    this.loginError,
    this.isRegisterLoading = false,
    this.registerError,
  });

  /// Tab yang tampil pertama.
  final AuthTab initialTab;

  /// Jalur akun awal pada tab Masuk (`Admin` atau `Pelanggan`).
  final AuthPortal initialPortal;

  final ValueChanged<LoginFormData>? onLoginSubmit;
  final ValueChanged<RegisterFormData>? onRegisterSubmit;
  final VoidCallback? onForgotPassword;
  final ValueChanged<AuthPortal>? onForgotPasswordWithPortal;
  final ValueChanged<AuthPortal>? onPortalChanged;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;

  /// Dipanggil saat tab aktif berubah, mis. untuk menghapus pesan galat
  /// milik tab sebelumnya.
  final VoidCallback? onTabChanged;

  /// Dipanggil saat isian form berubah, untuk menghapus galat lama.
  final VoidCallback? onFieldChanged;

  final bool isLoginLoading;
  final String? loginError;
  final bool isRegisterLoading;
  final String? registerError;

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
    widget.onTabChanged?.call();
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
        onPageChanged: (int index) {
          if (index != _index) {
            widget.onTabChanged?.call();
          }
          setState(() => _index = index);
        },
        children: <Widget>[
          LoginScreen(
            initialPortal: widget.initialPortal,
            onSubmit: widget.onLoginSubmit,
            onRegisterTap: () => _goTo(AuthTab.register),
            onForgotPassword: widget.onForgotPassword,
            onForgotPasswordWithPortal: widget.onForgotPasswordWithPortal,
            onPortalChanged: widget.onPortalChanged,
            isLoading: widget.isLoginLoading,
            errorMessage: widget.loginError,
            onFieldChanged: widget.onFieldChanged,
          ),
          RegisterScreen(
            onSubmit: widget.onRegisterSubmit,
            onLoginTap: () => _goTo(AuthTab.login),
            onOpenTerms: widget.onOpenTerms,
            onOpenPrivacy: widget.onOpenPrivacy,
            isLoading: widget.isRegisterLoading,
            errorMessage: widget.registerError,
            onFieldChanged: widget.onFieldChanged,
          ),
        ],
      ),
    );
  }
}
