// lib/presentation/screens/customer/customer_profile_screen.dart
//
// Layar profil akun pelanggan & ganti kata sandi SOJU (TASK-025).

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/auth_session_entity.dart';
import '../../../../domain/entities/customer_profile_entity.dart';
import '../../providers/customer/customer_profile_controller.dart';
import '../../widgets/bottom_glass_overlay.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({
    super.key,
    this.controller,
    this.controllerFactory,
    this.user,
    this.onLogout,
  });

  final CustomerProfileController? controller;
  final CustomerProfileController Function()? controllerFactory;
  final AuthUser? user;
  final VoidCallback? onLogout;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  CustomerProfileController? _internalController;

  CustomerProfileController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = widget.controllerFactory?.call();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.profile == null && !_controller.isLoading) {
        _controller.loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  void _openEditProfileSheet(CustomerProfile profile) {
    final TextEditingController nameCtrl =
        TextEditingController(text: profile.name);
    final TextEditingController emailCtrl =
        TextEditingController(text: profile.email);
    final TextEditingController phoneCtrl =
        TextEditingController(text: profile.phone);
    final TextEditingController addressCtrl =
        TextEditingController(text: profile.address);
    bool promoAllowed = profile.promotionAllowed;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final double keyboard = MediaQuery.viewInsetsOf(context).bottom;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, keyboard + 24),
              decoration: const BoxDecoration(
                color: SojuColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Ubah Profil Akun',
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.ink,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      label: 'Nama Lengkap',
                      key: const Key('customer_profile_name_input'),
                      controller: nameCtrl,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      label: 'Email',
                      key: const Key('customer_profile_email_input'),
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      label: 'Nomor Telepon',
                      key: const Key('customer_profile_phone_input'),
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      label: 'Alamat Pengiriman',
                      key: const Key('customer_profile_address_input'),
                      controller: addressCtrl,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      key: const Key('customer_profile_promo_switch'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Izinkan Penawaran & Promosi',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.ink,
                        ),
                      ),
                      subtitle: const Text(
                        'Dapatkan info menu baru dan promo spesial SOJU.',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12,
                          color: SojuColors.inkMuted,
                        ),
                      ),
                      value: promoAllowed,
                      activeThumbColor: SojuColors.primary,
                      onChanged: (bool value) {
                        setModalState(() => promoAllowed = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const Key('customer_save_profile_button'),
                      onPressed: () async {
                        final bool ok = await _controller.saveProfile(
                          name: nameCtrl.text,
                          email: emailCtrl.text,
                          phone: phoneCtrl.text,
                          address: addressCtrl.text,
                          promotionAllowed: promoAllowed,
                        );
                        if (ok && sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profil berhasil diperbarui!'),
                                backgroundColor: SojuColors.success,
                              ),
                            );
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: SojuColors.primary,
                        foregroundColor: SojuColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openChangePasswordSheet() {
    final TextEditingController oldPassCtrl = TextEditingController();
    final TextEditingController newPassCtrl = TextEditingController();
    final TextEditingController confirmPassCtrl = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final double keyboard = MediaQuery.viewInsetsOf(context).bottom;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, keyboard + 24),
              decoration: const BoxDecoration(
                color: SojuColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Ubah Password Akun',
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.ink,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      label: 'Password Saat Ini',
                      key: const Key('customer_old_password_input'),
                      controller: oldPassCtrl,
                      obscureText: obscureOld,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureOld
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () =>
                            setModalState(() => obscureOld = !obscureOld),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      label: 'Password Baru (min. 8 karakter)',
                      key: const Key('customer_new_password_input'),
                      controller: newPassCtrl,
                      obscureText: obscureNew,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () =>
                            setModalState(() => obscureNew = !obscureNew),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      label: 'Konfirmasi Password Baru',
                      key: const Key('customer_confirm_password_input'),
                      controller: confirmPassCtrl,
                      obscureText: obscureNew,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const Key('customer_submit_password_button'),
                      onPressed: () async {
                        final bool ok = await _controller.updatePassword(
                          currentPassword: oldPassCtrl.text,
                          newPassword: newPassCtrl.text,
                          confirmPassword: confirmPassCtrl.text,
                        );
                        if (ok && sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password berhasil diperbarui!'),
                                backgroundColor: SojuColors.success,
                              ),
                            );
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: SojuColors.primary,
                        foregroundColor: SojuColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Simpan Password Baru'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, _) {
        final CustomerProfileController controller = _controller;
        final CustomerProfile profile = controller.profile ??
            CustomerProfile(
              id: widget.user?.id ?? 1,
              name: widget.user?.name ?? 'Pelanggan SOJU',
              email: widget.user?.email ?? 'pelanggan@sojucorp.com',
              phone: widget.user?.phone ?? '-',
              address: widget.user?.address ?? '-',
              promotionAllowed: widget.user?.promotionAllowed ?? false,
            );

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final double scale = (width > 480 ? 480 : width) / 430;

            return Scaffold(
              key: const Key('customer_account_screen'),
              backgroundColor: SojuColors.homeBackground,
              body: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    20 * scale,
                    20 * scale,
                    kBottomContentInset * scale + 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Akun Pelanggan',
                                  style: TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: SojuColors.ink,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Kelola profil pengiriman dan keamanan akun Anda.',
                                  style: TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 13,
                                    color: SojuColors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: SojuColors.infoSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Pelanggan',
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: SojuColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Pesan Galat / Sukses bila ada
                      if (controller.errorMessage != null) ...<Widget>[
                        _buildMessageBanner(
                          message: controller.errorMessage!,
                          isError: true,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (controller.passwordError != null) ...<Widget>[
                        _buildMessageBanner(
                          message: controller.passwordError!,
                          isError: true,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Profil Card Hero
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: SojuColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: SojuColors.hairline),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        SojuColors.primary,
                                        SojuColors.primaryDeep,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    profile.initials,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: SojuColors.surface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        profile.name,
                                        style: const TextStyle(
                                          fontFamily: AppTypography.family,
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                          color: SojuColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              profile.email,
                                              style: const TextStyle(
                                                fontFamily:
                                                    AppTypography.family,
                                                fontSize: 13,
                                                color: SojuColors.inkMuted,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: profile.isEmailVerified
                                                  ? const Color(0xFFECFDF5)
                                                  : const Color(0xFFFEF3C7),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              profile.isEmailVerified
                                                  ? 'Terverifikasi'
                                                  : 'Belum Terverifikasi',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTypography.family,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: profile.isEmailVerified
                                                  ? const Color(0xFF059669)
                                                  : const Color(0xFFD97706),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(
                              height: 1,
                              color: SojuColors.hairline,
                            ),
                            const SizedBox(height: 14),

                            _buildInfoRow(
                              Icons.phone_outlined,
                              'Nomor Telepon',
                              profile.phone,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              'Alamat Pengiriman',
                              profile.address,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              Icons.campaign_outlined,
                              'Promosi & Penawaran',
                              profile.promotionAllowed
                                  ? 'Diizinkan (Aktif)'
                                  : 'Nonaktif',
                            ),

                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                key: const Key('customer_edit_profile_button'),
                                onPressed: () =>
                                    _openEditProfileSheet(profile),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                ),
                                label: const Text('Ubah Profil'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: SojuColors.primaryDeep,
                                  side: const BorderSide(
                                    color: SojuColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Keamanan & Ubah Password Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: SojuColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: SojuColors.hairline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Row(
                              children: <Widget>[
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 20,
                                  color: SojuColors.primary,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Keamanan & Sandi',
                                  style: TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: SojuColors.ink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Perbarui kata sandi akun pelanggan secara berkala untuk menjaga keamanan pesanan.',
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 13,
                                color: SojuColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                key: const Key(
                                  'customer_change_password_button',
                                ),
                                onPressed: _openChangePasswordSheet,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: SojuColors.ink,
                                  side: const BorderSide(
                                    color: SojuColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Ganti Password'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tombol Keluar / Logout
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          key: const Key('customer_logout_button'),
                          onPressed: widget.onLogout,
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: SojuColors.expense,
                          ),
                          label: const Text(
                            'Keluar dari Akun',
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: SojuColors.expense,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFFECACA),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormField({
    required String label,
    required Key key,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: SojuColors.inkMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: key,
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: SojuColors.field,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 16, color: SojuColors.inkMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 11.5,
                  color: SojuColors.inkMuted,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: SojuColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBanner({
    required String message,
    required bool isError,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
            color: isError ? SojuColors.expense : SojuColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 12.5,
                color: isError ? SojuColors.expense : SojuColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
