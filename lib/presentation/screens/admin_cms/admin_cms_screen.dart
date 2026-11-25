// lib/presentation/screens/admin_cms/admin_cms_screen.dart
//
// Layar Super Admin: Konten CMS Publik & Katalog Produk (`/admin/cms`).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/admin_cms_entity.dart';
import '../../providers/admin_cms/admin_cms_controller.dart';
import '../../utils/format.dart';
import 'admin_product_editor_screen.dart';

class AdminCmsScreen extends StatefulWidget {
  const AdminCmsScreen({
    super.key = const Key('admin_cms_screen'),
    required this.controllerFactory,
    this.onBack,
  });

  final AdminCmsController Function() controllerFactory;
  final VoidCallback? onBack;

  @override
  State<AdminCmsScreen> createState() => _AdminCmsScreenState();
}

class _AdminCmsScreenState extends State<AdminCmsScreen> {
  late final AdminCmsController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.loadAll();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openContentSheet({CmsContentItem? existing}) async {
    final bool isCreate = existing == null;
    final TextEditingController keyCtrl =
        TextEditingController(text: existing?.key ?? '');
    final TextEditingController titleCtrl =
        TextEditingController(text: existing?.title ?? '');
    final TextEditingController subtitleCtrl =
        TextEditingController(text: existing?.subtitle ?? '');
    final TextEditingController contentCtrl =
        TextEditingController(text: existing?.content ?? '');
    bool active = existing?.isActive ?? true;

    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SojuColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetCtx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setSheetState) {
            final double bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      isCreate ? 'Tambah Konten CMS' : 'Ubah Konten CMS',
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: SojuColors.ink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: keyCtrl,
                      enabled: isCreate,
                      decoration: _inputDecoration(
                        'Key Konten (contoh: headline_beranda)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: _inputDecoration('Judul Konten'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subtitleCtrl,
                      decoration: _inputDecoration('Subjudul (Opsional)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentCtrl,
                      maxLines: 4,
                      decoration: _inputDecoration('Isi Konten Publik'),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: SojuColors.primary,
                      title: const Text('Tampilkan di Halaman Publik'),
                      value: active,
                      onChanged: (bool val) =>
                          setSheetState(() => active = val),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: SojuColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final String k = keyCtrl.text.trim();
                        final String t = titleCtrl.text.trim();
                        if (k.isEmpty || t.isEmpty) return;
                        final bool ok = await _controller.saveContent(
                          draft: CmsContentDraft(
                            key: k,
                            title: t,
                            subtitle: subtitleCtrl.text.trim().isEmpty
                                ? null
                                : subtitleCtrl.text.trim(),
                            content: contentCtrl.text.trim().isEmpty
                                ? null
                                : contentCtrl.text.trim(),
                            isActive: active,
                          ),
                          isCreate: isCreate,
                        );
                        if (ok && sheetCtx.mounted) {
                          Navigator.of(sheetCtx).pop(true);
                        }
                      },
                      child: const Text('Simpan Konten'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konten CMS berhasil disimpan.'),
          backgroundColor: SojuColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openProductSheet({AdminProductItem? existing}) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext ctx) => AdminProductEditorScreen(
          existing: existing,
          onSave: (AdminProductDraft draft) => _controller.saveProduct(
            existingId: existing?.id,
            draft: draft,
          ),
          onDelete: existing == null
              ? null
              : () => _controller.deactivateProduct(existing.id),
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data produk berhasil disimpan.'),
          backgroundColor: SojuColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: SojuColors.homeBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SojuColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SojuColors.hairline),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: SojuColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = math.min(constraints.maxWidth, 480);
            final double scale = width / 430;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? _) {
                    final AdminCmsState state = _controller.state;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildTopBar(scale, topInset, state),
                        _buildTabSwitcher(scale, state),
                        if (state.errorMessage != null)
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              16 * scale,
                              8 * scale,
                              16 * scale,
                              0,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(12 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12 * scale),
                                border: Border.all(
                                  color: SojuColors.expense.withOpacity(0.35),
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: SojuColors.expense,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.errorMessage!,
                                      style: TextStyle(
                                        fontFamily: AppTypography.family,
                                        fontSize: 12.5 * scale,
                                        color: SojuColors.expense,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: _controller.clearError,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Expanded(
                          child: state.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: SojuColors.primary,
                                  ),
                                )
                              : state.activeTab == AdminCmsTab.content
                                  ? _buildContentTab(scale, state)
                                  : _buildProductsTab(scale, state),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(double scale, double topInset, AdminCmsState state) {
    return Container(
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28 * scale),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x18000000),
            offset: Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        math.max(12 * scale, 22 * scale - topInset),
        16 * scale,
        16 * scale,
      ),
      child: Row(
        children: <Widget>[
          if (widget.onBack != null) ...<Widget>[
            GestureDetector(
              key: const Key('super_admin_module_back'),
              onTap: widget.onBack,
              child: Container(
                width: 42 * scale,
                height: 42 * scale,
                decoration: const BoxDecoration(
                  color: SojuColors.field,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18 * scale,
                  color: SojuColors.ink,
                ),
              ),
            ),
            SizedBox(width: 12 * scale),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Konten CMS & Produk',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 19 * scale,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                Text(
                  'Kelola teks halaman publik & katalog menu SOJU',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12 * scale,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            key: const Key('admin_cms_add_button'),
            onPressed: () {
              if (state.activeTab == AdminCmsTab.content) {
                _openContentSheet();
              } else {
                _openProductSheet();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: SojuColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 10 * scale,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14 * scale),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              state.activeTab == AdminCmsTab.content ? 'Konten' : 'Produk',
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

  Widget _buildTabSwitcher(double scale, AdminCmsState state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 4 * scale),
      child: Container(
        padding: EdgeInsets.all(4 * scale),
        decoration: BoxDecoration(
          color: SojuColors.surface,
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(color: SojuColors.hairline),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _SegmentButton(
                label: 'Konten Publik (${state.contents.length})',
                selected: state.activeTab == AdminCmsTab.content,
                onTap: () => _controller.selectTab(AdminCmsTab.content),
              ),
            ),
            Expanded(
              child: _SegmentButton(
                label: 'Katalog Produk (${state.products.length})',
                selected: state.activeTab == AdminCmsTab.products,
                onTap: () => _controller.selectTab(AdminCmsTab.products),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTab(double scale, AdminCmsState state) {
    if (state.contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.web_outlined, size: 48 * scale, color: SojuColors.inkMuted),
            const SizedBox(height: 10),
            const Text(
              'Belum ada konten CMS publik.',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontWeight: FontWeight.w600,
                color: SojuColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _openContentSheet(),
              child: const Text('Tambah Konten Pertama'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.loadAll(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16 * scale, 10 * scale, 16 * scale, 32 * scale),
        itemCount: state.contents.length,
        separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
        itemBuilder: (BuildContext context, int index) {
          final CmsContentItem item = state.contents[index];
          return Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: SojuColors.surface,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: SojuColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: SojuColors.infoSoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        item.key,
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: SojuColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: item.isActive
                            ? const Color(0xFFECFDF5)
                            : SojuColors.field,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        item.isActive ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: item.isActive
                              ? SojuColors.positive
                              : SojuColors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 15.5 * scale,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                if (item.subtitle != null) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                      color: SojuColors.primary,
                    ),
                  ),
                ],
                if (item.content != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    item.content!,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12.5 * scale,
                      height: 1.45,
                      color: SojuColors.inkMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: () => _openContentSheet(existing: item),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Ubah'),
                    ),
                    TextButton.icon(
                      onPressed: () => _controller.deleteContent(item.key),
                      style: TextButton.styleFrom(
                        foregroundColor: SojuColors.expense,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 17),
                      label: const Text('Hapus'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsTab(double scale, AdminCmsState state) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(16 * scale, 10 * scale, 16 * scale, 6 * scale),
          child: TextField(
            controller: _searchController,
            onSubmitted: (String q) => _controller.loadAll(productSearch: q),
            decoration: InputDecoration(
              hintText: 'Cari nama atau kode produk...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _controller.loadAll(productSearch: '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: SojuColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * scale),
                borderSide: const BorderSide(color: SojuColors.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14 * scale),
                borderSide: const BorderSide(color: SojuColors.hairline),
              ),
            ),
          ),
        ),
        Expanded(
          child: state.products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48 * scale,
                        color: SojuColors.inkMuted,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Belum ada produk terdaftar.',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.ink,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _controller.loadAll(),
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      16 * scale,
                      6 * scale,
                      16 * scale,
                      32 * scale,
                    ),
                    itemCount: state.products.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
                    itemBuilder: (BuildContext context, int index) {
                      final AdminProductItem p = state.products[index];
                      return Container(
                        padding: EdgeInsets.all(14 * scale),
                        decoration: BoxDecoration(
                          color: SojuColors.surface,
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(color: SojuColors.hairline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  p.code,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.family,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: SojuColors.primary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.isActive
                                        ? const Color(0xFFECFDF5)
                                        : SojuColors.field,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    p.isActive ? 'Aktif' : 'Nonaktif',
                                    style: TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: p.isActive
                                          ? SojuColors.positive
                                          : SojuColors.inkMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.variant != null
                                  ? '${p.name} — ${p.variant}'
                                  : p.name,
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.w700,
                                color: SojuColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${formatRupiah(p.price)} / ${p.unit}',
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 13.5 * scale,
                                fontWeight: FontWeight.w700,
                                color: SojuColors.primaryDeep,
                              ),
                            ),
                            if (p.description != null) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                p.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 12 * scale,
                                  color: SojuColors.inkMuted,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton.icon(
                                  onPressed: () =>
                                      _openProductSheet(existing: p),
                                  icon: const Icon(Icons.edit_outlined, size: 17),
                                  label: const Text('Ubah'),
                                ),
                                if (p.isActive)
                                  TextButton.icon(
                                    onPressed: () =>
                                        _controller.deactivateProduct(p.id),
                                    style: TextButton.styleFrom(
                                      foregroundColor: SojuColors.expense,
                                    ),
                                    icon: const Icon(
                                      Icons.visibility_off_outlined,
                                      size: 17,
                                    ),
                                    label: const Text('Nonaktifkan'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? SojuColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : SojuColors.inkMuted,
          ),
        ),
      ),
    );
  }
}
