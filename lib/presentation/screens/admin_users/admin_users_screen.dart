// lib/presentation/screens/admin_users/admin_users_screen.dart
//
// Layar Manajemen Multi-User Admin khusus `SUPER_ADMIN` (`TASK-027`, `AD-08`, `AD-11`).
// Mendukung pencarian, filter peran & status, tambah akun, ubah nama/peran,
// nonaktifkan/aktifkan dengan dialog konfirmasi, pemicu reset password,
// serta proteksi diri (self-disable & self-role-change dinonaktifkan di UI).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/admin_user_entity.dart';
import '../../../domain/entities/auth_session_entity.dart';
import '../../providers/admin_users/admin_users_controller.dart';
import '../../utils/format.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({
    super.key,
    required this.controllerFactory,
    this.currentUser,
    this.onBack,
  });

  final AdminUsersController Function() controllerFactory;
  final AuthUser? currentUser;
  final VoidCallback? onBack;

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late final AdminUsersController _controller;
  late final TextEditingController _searchController;

  bool get _isAuthorized =>
      widget.currentUser == null || widget.currentUser!.role.isSuperAdmin;

  int? get _currentUserId => widget.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
    _searchController = TextEditingController();
    if (_isAuthorized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.load();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showFeedback(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: AppTypography.family),
          ),
          backgroundColor: isError ? SojuColors.expense : SojuColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _openCreateUserDialog() async {
    final AdminUsersMutationResult? result =
        await showDialog<AdminUsersMutationResult>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _CreateUserDialog(
          onSubmit: ({
            required String name,
            required String email,
            String? password,
            required AdminUserRole role,
            required bool sendInvite,
          }) {
            return _controller.createUser(
              name: name,
              email: email,
              password: password,
              role: role,
              sendInvite: sendInvite,
            );
          },
        );
      },
    );

    if (result != null) {
      _showFeedback(result.message, isError: !result.ok);
    }
  }

  Future<void> _openEditUserDialog(AdminUser user) async {
    final bool isSelf = _currentUserId != null && user.id == _currentUserId;
    final AdminUsersMutationResult? result =
        await showDialog<AdminUsersMutationResult>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _EditUserDialog(
          user: user,
          isSelf: isSelf,
          onSubmit: ({
            required String name,
            required String email,
            AdminUserRole? role,
          }) {
            return _controller.updateUser(
              userId: user.id,
              name: name,
              email: email,
              role: role,
            );
          },
        );
      },
    );

    if (result != null) {
      _showFeedback(result.message, isError: !result.ok);
    }
  }

  Future<void> _confirmToggleStatus(AdminUser user) async {
    final bool isDisabling = user.isActive;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          key: const Key('admin_user_status_confirm_dialog'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            isDisabling ? 'Nonaktifkan Akun Admin?' : 'Aktifkan Akun Admin?',
            style: const TextStyle(
              fontFamily: AppTypography.family,
              fontWeight: FontWeight.w700,
              color: SojuColors.ink,
            ),
          ),
          content: Text(
            isDisabling
                ? 'Akun ${user.name} (${user.email}) akan dinonaktifkan dan '
                    'tidak dapat masuk ke sistem sampai diaktifkan kembali.'
                : 'Akun ${user.name} (${user.email}) akan diaktifkan kembali '
                    'dan dapat masuk ke sistem.',
            style: const TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13.5,
              color: SojuColors.inkMuted,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              key: const Key('confirm_toggle_user_status'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDisabling ? SojuColors.expense : SojuColors.positive,
                foregroundColor: Colors.white,
              ),
              child: Text(isDisabling ? 'Nonaktifkan' : 'Aktifkan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    final AdminUsersMutationResult result =
        await _controller.toggleUserStatus(user: user);
    _showFeedback(result.message, isError: !result.ok);
  }

  Future<void> _confirmResetPassword(AdminUser user) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          key: const Key('admin_user_reset_confirm_dialog'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Kirim Tautan Reset Password?',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontWeight: FontWeight.w700,
              color: SojuColors.ink,
            ),
          ),
          content: Text(
            'Tautan atur ulang password satu kali pakai akan dikirim ke '
            '${user.email}. Lanjutkan?',
            style: const TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13.5,
              color: SojuColors.inkMuted,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              key: const Key('confirm_reset_user_password'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: SojuColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kirim Tautan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    final AdminUsersMutationResult result =
        await _controller.triggerPasswordReset(userId: user.id);
    _showFeedback(result.message, isError: !result.ok);
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      key: const Key('admin_users_screen'),
      backgroundColor: SojuColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double contentWidth = math.min(constraints.maxWidth, 480);
            final double scale = contentWidth / 430;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _AdminUsersTopBar(
                      scale: scale,
                      topInset: topInset,
                      onBack: widget.onBack,
                      onAddTap: _isAuthorized ? _openCreateUserDialog : null,
                    ),
                    Expanded(
                      child: _isAuthorized
                          ? AnimatedBuilder(
                              animation: _controller,
                              builder: (BuildContext context, Widget? _) {
                                return _buildAuthorizedBody(
                                  _controller.state,
                                  scale,
                                );
                              },
                            )
                          : _buildAccessDenied(scale),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccessDenied(double scale) {
    return Center(
      key: const Key('admin_users_access_denied'),
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Container(
          padding: EdgeInsets.all(24 * scale),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(color: SojuColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 56 * scale,
                height: 56 * scale,
                decoration: BoxDecoration(
                  color: SojuColors.expenseSoft,
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 30 * scale,
                  color: SojuColors.expense,
                ),
              ),
              SizedBox(height: 14 * scale),
              Text(
                'Akses Ditolak',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Halaman Kelola Pengguna hanya dapat diakses oleh akun '
                'Super Admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13.5 * scale,
                  color: SojuColors.inkMuted,
                ),
              ),
              if (widget.onBack != null) ...<Widget>[
                SizedBox(height: 18 * scale),
                ElevatedButton(
                  onPressed: widget.onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SojuColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorizedBody(AdminUsersState state, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildSearchAndFilters(state, scale),
        Expanded(
          child: switch (state.status) {
            AdminUsersStatus.loading => _buildLoading(scale),
            AdminUsersStatus.error => _buildError(state, scale),
            AdminUsersStatus.empty => _buildEmpty(state, scale),
            AdminUsersStatus.data => _buildUserList(state, scale),
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(AdminUsersState state, double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 4 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            key: const Key('admin_users_search_field'),
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (String value) => _controller.setSearchQuery(value),
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13.5 * scale,
              color: SojuColors.ink,
            ),
            decoration: InputDecoration(
              hintText: 'Cari nama atau email pengelola...',
              hintStyle: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 13 * scale,
                color: SojuColors.inputHint,
              ),
              filled: true,
              fillColor: SojuColors.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14 * scale,
                vertical: 11 * scale,
              ),
              prefixIcon: IconButton(
                key: const Key('admin_users_search_submit'),
                icon: Icon(
                  Icons.search_rounded,
                  size: 20 * scale,
                  color: SojuColors.inkMuted,
                ),
                tooltip: 'Cari pengguna',
                onPressed: () =>
                    _controller.setSearchQuery(_searchController.text),
              ),
              suffixIcon: state.searchQuery.isNotEmpty ||
                      _searchController.text.isNotEmpty
                  ? IconButton(
                      key: const Key('admin_users_search_clear'),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18 * scale,
                        color: SojuColors.inkMuted,
                      ),
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        _searchController.clear();
                        _controller.setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * scale),
                borderSide: const BorderSide(color: SojuColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * scale),
                borderSide: const BorderSide(color: SojuColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * scale),
                borderSide: const BorderSide(color: SojuColors.primary),
              ),
            ),
          ),
          SizedBox(height: 8 * scale),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _FilterChip(
                  chipKey: const Key('users_filter_role_ALL'),
                  label: 'Semua Peran',
                  selected: state.roleFilter == null,
                  scale: scale,
                  onSelected: () => _controller.setRoleFilter(null),
                ),
                SizedBox(width: 6 * scale),
                _FilterChip(
                  chipKey: const Key('users_filter_role_SUPER_ADMIN'),
                  label: 'Super Admin',
                  selected: state.roleFilter == AdminUserRole.superAdmin,
                  scale: scale,
                  onSelected: () =>
                      _controller.setRoleFilter(AdminUserRole.superAdmin),
                ),
                SizedBox(width: 6 * scale),
                _FilterChip(
                  chipKey: const Key('users_filter_role_ADMIN'),
                  label: 'Admin',
                  selected: state.roleFilter == AdminUserRole.admin,
                  scale: scale,
                  onSelected: () =>
                      _controller.setRoleFilter(AdminUserRole.admin),
                ),
                SizedBox(width: 10 * scale),
                Container(
                  width: 1,
                  height: 22 * scale,
                  color: SojuColors.border,
                ),
                SizedBox(width: 10 * scale),
                _FilterChip(
                  chipKey: const Key('users_filter_status_ALL'),
                  label: 'Semua Status',
                  selected: state.activeFilter == null,
                  scale: scale,
                  onSelected: () => _controller.setActiveFilter(null),
                ),
                SizedBox(width: 6 * scale),
                _FilterChip(
                  chipKey: const Key('users_filter_status_ACTIVE'),
                  label: 'Aktif',
                  selected: state.activeFilter == true,
                  scale: scale,
                  onSelected: () => _controller.setActiveFilter(true),
                ),
                SizedBox(width: 6 * scale),
                _FilterChip(
                  chipKey: const Key('users_filter_status_INACTIVE'),
                  label: 'Nonaktif',
                  selected: state.activeFilter == false,
                  scale: scale,
                  onSelected: () => _controller.setActiveFilter(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(double scale) {
    return Center(
      key: const Key('admin_users_loading'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(color: SojuColors.primary),
          SizedBox(height: 12 * scale),
          Text(
            'Memuat daftar pengguna...',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 13.5 * scale,
              color: SojuColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AdminUsersState state, double scale) {
    return Center(
      key: const Key('admin_users_error'),
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 48 * scale,
              color: SojuColors.expense,
            ),
            SizedBox(height: 12 * scale),
            Text(
              state.errorMessage ?? 'Gagal memuat daftar pengguna.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: SojuColors.ink,
              ),
            ),
            SizedBox(height: 16 * scale),
            ElevatedButton(
              key: const Key('admin_users_retry_button'),
              onPressed: _controller.load,
              style: ElevatedButton.styleFrom(
                backgroundColor: SojuColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AdminUsersState state, double scale) {
    return Center(
      key: const Key('admin_users_empty'),
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.manage_accounts_outlined,
              size: 54 * scale,
              color: SojuColors.inkMuted,
            ),
            SizedBox(height: 12 * scale),
            Text(
              'Tidak ada pengguna ditemukan',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: SojuColors.ink,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              state.hasActiveFilters
                  ? 'Ubah kata kunci pencarian atau reset filter untuk melihat '
                      'semua akun.'
                  : 'Belum ada akun pengelola terdaftar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 13 * scale,
                color: SojuColors.inkMuted,
              ),
            ),
            if (state.hasActiveFilters) ...<Widget>[
              SizedBox(height: 14 * scale),
              OutlinedButton(
                key: const Key('admin_users_clear_filters'),
                onPressed: () {
                  _searchController.clear();
                  _controller.clearFilters();
                },
                child: const Text('Reset Filter'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(AdminUsersState state, double scale) {
    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.separated(
        key: const Key('admin_users_list'),
        padding: EdgeInsets.fromLTRB(
          16 * scale,
          8 * scale,
          16 * scale,
          32 * scale,
        ),
        itemCount: state.users.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _SummaryStrip(
              scale: scale,
              total: state.totalCount,
              active: state.activeCount,
              superAdminActive: state.activeSuperAdminCount,
            );
          }

          final AdminUser user = state.users[index - 1];
          final bool isSelf =
              _currentUserId != null && user.id == _currentUserId;

          return _AdminUserCard(
            scale: scale,
            user: user,
            isSelf: isSelf,
            isBusy: state.isBusy(user.id),
            onEdit: () => _openEditUserDialog(user),
            onResetPassword: () => _confirmResetPassword(user),
            onToggleStatus: () => _confirmToggleStatus(user),
          );
        },
      ),
    );
  }
}

class _AdminUsersTopBar extends StatelessWidget {
  const _AdminUsersTopBar({
    required this.scale,
    required this.topInset,
    this.onBack,
    this.onAddTap,
  });

  final double scale;
  final double topInset;
  final VoidCallback? onBack;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28 * scale),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 1),
            blurRadius: 12,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        math.max(10 * scale, 22 * scale - topInset),
        16 * scale,
        16 * scale,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            key: const Key('super_admin_module_back'),
            onPressed: onBack,
            tooltip: 'Kembali',
            style: IconButton.styleFrom(
              backgroundColor: SojuColors.field,
              foregroundColor: SojuColors.ink,
            ),
            icon: Icon(Icons.arrow_back_rounded, size: 20 * scale),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Kelola Pengguna',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 19 * scale,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                Text(
                  'Manajemen akun Admin & Super Admin',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11.5 * scale,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          if (onAddTap != null)
            ElevatedButton.icon(
              key: const Key('admin_users_add_button'),
              onPressed: onAddTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: SojuColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 9 * scale,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
              ),
              icon: Icon(Icons.person_add_alt_1_rounded, size: 17 * scale),
              label: Text(
                'Tambah',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12.5 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.scale,
    required this.total,
    required this.active,
    required this.superAdminActive,
  });

  final double scale;
  final int total;
  final int active;
  final int superAdminActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _SummaryMetric(
            scale: scale,
            label: 'Total Akun',
            value: '$total',
            color: SojuColors.ink,
          ),
        ),
        SizedBox(width: 8 * scale),
        Expanded(
          child: _SummaryMetric(
            scale: scale,
            label: 'Aktif',
            value: '$active',
            color: SojuColors.positive,
          ),
        ),
        SizedBox(width: 8 * scale),
        Expanded(
          child: _SummaryMetric(
            scale: scale,
            label: 'Super Admin',
            value: '$superAdminActive',
            color: SojuColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.scale,
    required this.label,
    required this.value,
    required this.color,
  });

  final double scale;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: SojuColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 11 * scale,
              color: SojuColors.inkMuted,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 17 * scale,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.scale,
    required this.onSelected,
  });

  final Key chipKey;
  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      key: chipKey,
      label: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 12 * scale,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Colors.white : SojuColors.ink,
        ),
      ),
      selected: selected,
      selectedColor: SojuColors.primary,
      backgroundColor: SojuColors.surface,
      side: BorderSide(
        color: selected ? SojuColors.primary : SojuColors.border,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

class _AdminUserCard extends StatelessWidget {
  const _AdminUserCard({
    required this.scale,
    required this.user,
    required this.isSelf,
    required this.isBusy,
    required this.onEdit,
    required this.onResetPassword,
    required this.onToggleStatus,
  });

  final double scale;
  final AdminUser user;
  final bool isSelf;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onResetPassword;
  final VoidCallback onToggleStatus;

  String _initials(String raw) {
    final List<String> parts = raw
        .trim()
        .split(RegExp(r'\s+'))
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'AD';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool disableToggle = isBusy || (isSelf && user.isActive);
    final bool disableReset = isBusy || !user.isActive;

    return Container(
      key: Key('admin_user_card_${user.id}'),
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: isSelf ? SojuColors.primary.withValues(alpha: 0.45) : SojuColors.border,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 20 * scale,
                backgroundColor: user.isSuperAdmin
                    ? SojuColors.infoSoft
                    : SojuColors.surfaceMuted,
                child: Text(
                  _initials(user.name),
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w700,
                    color:
                        user.isSuperAdmin ? SojuColors.primary : SojuColors.ink,
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 6 * scale,
                      runSpacing: 4 * scale,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          user.name,
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 14.5 * scale,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.ink,
                          ),
                        ),
                        if (isSelf)
                          Container(
                            key: Key('admin_user_self_badge_${user.id}'),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8 * scale,
                              vertical: 2 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: SojuColors.infoSoft,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              'Akun Anda',
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 10.5 * scale,
                                fontWeight: FontWeight.w700,
                                color: SojuColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12.5 * scale,
                        color: SojuColors.inkMuted,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Wrap(
                      spacing: 6 * scale,
                      runSpacing: 6 * scale,
                      children: <Widget>[
                        _StatusPill(
                          scale: scale,
                          label: user.role.label,
                          bg: user.isSuperAdmin
                              ? SojuColors.infoSoft
                              : SojuColors.surfaceMuted,
                          fg: user.isSuperAdmin
                              ? SojuColors.primaryDeep
                              : SojuColors.ink,
                        ),
                        _StatusPill(
                          scale: scale,
                          label: user.isActive ? 'Aktif' : 'Nonaktif',
                          bg: user.isActive
                              ? SojuColors.incomeSoft
                              : SojuColors.expenseSoft,
                          fg: user.isActive
                              ? SojuColors.positive
                              : SojuColors.expense,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          Text(
            user.lastLoginAt == null
                ? 'Terakhir masuk: Belum pernah masuk'
                : 'Terakhir masuk: ${formatDayMonth(user.lastLoginAt!)} • ${formatClock(user.lastLoginAt!)}',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 11.5 * scale,
              color: SojuColors.inkMuted,
            ),
          ),
          if (isSelf) ...<Widget>[
            SizedBox(height: 8 * scale),
            Container(
              key: Key('admin_user_self_protection_note_${user.id}'),
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 6 * scale,
              ),
              decoration: BoxDecoration(
                color: SojuColors.demoSoft,
                borderRadius: BorderRadius.circular(10 * scale),
                border: Border.all(color: SojuColors.demoBorder),
              ),
              child: Text(
                'Proteksi akun sendiri: peran tidak dapat diubah dan akun '
                'tidak dapat dinonaktifkan sendiri.',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 11 * scale,
                  color: SojuColors.demoInk,
                ),
              ),
            ),
          ],
          Divider(height: 20 * scale, color: SojuColors.hairline),
          if (isBusy)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8 * scale,
              runSpacing: 8 * scale,
              children: <Widget>[
                OutlinedButton.icon(
                  key: Key('admin_user_edit_${user.id}'),
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SojuColors.ink,
                    side: const BorderSide(color: SojuColors.border),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale,
                      vertical: 8 * scale,
                    ),
                  ),
                  icon: Icon(Icons.edit_outlined, size: 16 * scale),
                  label: Text(
                    'Ubah',
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12 * scale,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  key: Key('admin_user_reset_${user.id}'),
                  onPressed: disableReset ? null : onResetPassword,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SojuColors.primary,
                    side: const BorderSide(color: SojuColors.border),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale,
                      vertical: 8 * scale,
                    ),
                  ),
                  icon: Icon(Icons.lock_reset_rounded, size: 16 * scale),
                  label: Text(
                    'Reset Password',
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12 * scale,
                    ),
                  ),
                ),
                Tooltip(
                  message: isSelf && user.isActive
                      ? 'Tidak dapat menonaktifkan akun sendiri'
                      : (user.isActive
                          ? 'Nonaktifkan akun admin'
                          : 'Aktifkan akun admin'),
                  child: OutlinedButton.icon(
                    key: Key('admin_user_toggle_${user.id}'),
                    onPressed: disableToggle ? null : onToggleStatus,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: user.isActive
                          ? SojuColors.expense
                          : SojuColors.positive,
                      side: BorderSide(
                        color: disableToggle
                            ? SojuColors.border
                            : (user.isActive
                                ? SojuColors.expense.withValues(alpha: 0.4)
                                : SojuColors.positive.withValues(alpha: 0.4)),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 8 * scale,
                      ),
                    ),
                    icon: Icon(
                      user.isActive
                          ? Icons.person_off_outlined
                          : Icons.check_circle_outline_rounded,
                      size: 16 * scale,
                    ),
                    label: Text(
                      user.isActive ? 'Nonaktifkan' : 'Aktifkan',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.scale,
    required this.label,
    required this.bg,
    required this.fg,
  });

  final double scale;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9 * scale,
        vertical: 3 * scale,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 11 * scale,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog({required this.onSubmit});

  final Future<AdminUsersMutationResult> Function({
    required String name,
    required String email,
    String? password,
    required AdminUserRole role,
    required bool sendInvite,
  }) onSubmit;

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AdminUserRole _selectedRole = AdminUserRole.admin;
  bool _sendInvite = false;
  bool _submitting = false;
  String? _errorText;

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final String rawPassword = _passwordController.text;
    final AdminUsersMutationResult result = await widget.onSubmit(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: rawPassword.isEmpty ? null : rawPassword,
      role: _selectedRole,
      sendInvite: _sendInvite,
    );

    if (!mounted) return;
    if (result.ok) {
      Navigator.of(context).pop(result);
    } else {
      setState(() {
        _submitting = false;
        _errorText = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('admin_user_create_dialog'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Tambah Pengguna Admin',
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontWeight: FontWeight.w700,
          color: SojuColors.ink,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_errorText != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SojuColors.expenseSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12,
                      color: SojuColors.expense,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                key: const Key('create_user_name_field'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Contoh: Rina Operasional',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lengkap wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('create_user_email_field'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'nama@sojucorp.com',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  final String trimmed = (value ?? '').trim();
                  if (trimmed.isEmpty || !_emailRegex.hasMatch(trimmed)) {
                    return 'Masukkan alamat email yang valid.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AdminUserRole>(
                key: const Key('create_user_role_dropdown'),
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Peran',
                  border: OutlineInputBorder(),
                ),
                items: AdminUserRole.values
                    .map(
                      (AdminUserRole r) => DropdownMenuItem<AdminUserRole>(
                        value: r,
                        child: Text(r.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _submitting
                    ? null
                    : (AdminUserRole? next) {
                        if (next != null) {
                          setState(() => _selectedRole = next);
                        }
                      },
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                key: const Key('create_user_invite_switch'),
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Kirim email undangan',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Kirim tautan aktivasi ke email pengguna baru.',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11.5,
                    color: SojuColors.inkMuted,
                  ),
                ),
                value: _sendInvite,
                onChanged: _submitting
                    ? null
                    : (bool value) => setState(() => _sendInvite = value),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('create_user_password_field'),
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _sendInvite
                      ? 'Password Awal (Opsional)'
                      : 'Password Awal',
                  hintText: 'Minimal 8 karakter',
                  border: const OutlineInputBorder(),
                ),
                validator: (String? value) {
                  final String raw = value ?? '';
                  if (!_sendInvite && raw.length < 8) {
                    return 'Password awal minimal 8 karakter wajib diisi.';
                  }
                  if (_sendInvite && raw.isNotEmpty && raw.length < 8) {
                    return 'Password awal minimal 8 karakter.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          key: const Key('create_user_submit_button'),
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: SojuColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}

class _EditUserDialog extends StatefulWidget {
  const _EditUserDialog({
    required this.user,
    required this.isSelf,
    required this.onSubmit,
  });

  final AdminUser user;
  final bool isSelf;
  final Future<AdminUsersMutationResult> Function({
    required String name,
    required String email,
    AdminUserRole? role,
  }) onSubmit;

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late AdminUserRole _selectedRole;
  bool _submitting = false;
  String? _errorText;

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final AdminUsersMutationResult result = await widget.onSubmit(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: widget.isSelf ? null : _selectedRole,
    );

    if (!mounted) return;
    if (result.ok) {
      Navigator.of(context).pop(result);
    } else {
      setState(() {
        _submitting = false;
        _errorText = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('admin_user_edit_dialog'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Ubah Data Pengguna',
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontWeight: FontWeight.w700,
          color: SojuColors.ink,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_errorText != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SojuColors.expenseSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12,
                      color: SojuColors.expense,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                key: const Key('edit_user_name_field'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lengkap wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('edit_user_email_field'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  final String trimmed = (value ?? '').trim();
                  if (trimmed.isEmpty || !_emailRegex.hasMatch(trimmed)) {
                    return 'Masukkan alamat email yang valid.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AdminUserRole>(
                key: const Key('edit_user_role_dropdown'),
                initialValue: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Peran',
                  border: const OutlineInputBorder(),
                  filled: widget.isSelf,
                  fillColor: widget.isSelf ? SojuColors.surfaceMuted : null,
                ),
                items: AdminUserRole.values
                    .map(
                      (AdminUserRole r) => DropdownMenuItem<AdminUserRole>(
                        value: r,
                        child: Text(r.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (_submitting || widget.isSelf)
                    ? null
                    : (AdminUserRole? next) {
                        if (next != null) {
                          setState(() => _selectedRole = next);
                        }
                      },
              ),
              if (widget.isSelf) ...<Widget>[
                const SizedBox(height: 8),
                const Text(
                  'Peran akun sendiri tidak dapat diubah.',
                  key: Key('edit_user_self_role_note'),
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11.5,
                    color: SojuColors.demoInk,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          key: const Key('edit_user_submit_button'),
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: SojuColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan Perubahan'),
        ),
      ],
    );
  }
}
