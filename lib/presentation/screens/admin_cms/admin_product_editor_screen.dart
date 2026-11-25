// lib/presentation/screens/admin_cms/admin_product_editor_screen.dart
//
// Editor produk responsif (Desktop 2-kolom & Mobile 1-kolom) bergaya Mockup 2
// untuk mengelola produk katalog & sinkronisasi visibilitas ke aplikasi Pelanggan.

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/admin_cms_entity.dart';
import '../../../domain/entities/storefront_entity.dart';
import '../customer/widgets/product_detail_sheet.dart';
import '../customer/widgets/storefront_widgets.dart';

enum _ProductDetailTab { general, advanced }

/// Layar tambah/ubah produk untuk Admin & Super Admin.
class AdminProductEditorScreen extends StatefulWidget {
  const AdminProductEditorScreen({
    super.key = const Key('admin_product_editor_screen'),
    this.existing,
    required this.onSave,
    this.onDelete,
  });

  final AdminProductItem? existing;
  final Future<bool> Function(AdminProductDraft draft) onSave;
  final Future<bool> Function()? onDelete;

  @override
  State<AdminProductEditorScreen> createState() =>
      _AdminProductEditorScreenState();
}

class _AdminProductEditorScreenState extends State<AdminProductEditorScreen> {
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _variantCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imgCtrl;

  late bool _isActive;
  _ProductDetailTab _tab = _ProductDetailTab.general;
  bool _isSaving = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final AdminProductItem? e = widget.existing;
    _codeCtrl = TextEditingController(
      text: e?.code ?? 'PRD-${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _variantCtrl = TextEditingController(text: e?.variant ?? '');
    _unitCtrl = TextEditingController(text: e?.unit ?? 'pcs');
    _priceCtrl = TextEditingController(
      text: e != null ? e.price.toString() : '',
    );
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _imgCtrl = TextEditingController(text: e?.imageUrl ?? '');
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _variantCtrl.dispose();
    _unitCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _imgCtrl.dispose();
    super.dispose();
  }

  AdminProductDraft _buildDraft({required bool active}) {
    final int price = int.tryParse(
          _priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    return AdminProductDraft(
      code: _codeCtrl.text.trim().isEmpty
          ? 'PRD-${DateTime.now().millisecondsSinceEpoch % 10000}'
          : _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      variant:
          _variantCtrl.text.trim().isEmpty ? null : _variantCtrl.text.trim(),
      unit: _unitCtrl.text.trim().isEmpty ? 'pcs' : _unitCtrl.text.trim(),
      price: price,
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      imageUrl: _imgCtrl.text.trim().isEmpty ? null : _imgCtrl.text.trim(),
      isActive: active,
    );
  }

  Future<void> _submit({required bool publish}) async {
    if (_isSaving) return;
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _validationError = 'Nama produk wajib diisi.');
      return;
    }
    setState(() {
      _validationError = null;
      _isActive = publish;
      _isSaving = true;
    });
    final bool ok = await widget.onSave(_buildDraft(active: publish));
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleDelete() async {
    final Future<bool> Function()? deleteFn = widget.onDelete;
    if (deleteFn == null || _isSaving) return;
    setState(() => _isSaving = true);
    final bool ok = await deleteFn();
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  void _openPreview() {
    final AdminProductDraft draft = _buildDraft(active: _isActive);
    final List<String> variants = (draft.variant ?? '')
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    final CatalogProduct previewProduct = CatalogProduct(
      id: widget.existing?.id ?? 0,
      code: draft.code,
      name: draft.name.isEmpty ? 'Pratinjau Produk SOJU' : draft.name,
      variants: variants,
      unit: draft.unit,
      price: draft.price,
      imageUrl: draft.imageUrl,
      description: draft.description ??
          'Pratinjau tampilan produk di aplikasi Pelanggan.',
    );
    showProductDetailSheet(context, previewProduct);
  }

  @override
  Widget build(BuildContext context) {
    final bool isCreate = widget.existing == null;
    return Scaffold(
      backgroundColor: SojuColors.homeBackground,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide = constraints.maxWidth >= 840;
          return Column(
            children: <Widget>[
              _buildTopBar(context, isCreate: isCreate, isWide: isWide),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 24 : 16,
                    16,
                    isWide ? 24 : 16,
                    isWide ? 28 : 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: isWide ? _buildWideBody() : _buildMobileBody(),
                    ),
                  ),
                ),
              ),
              if (!isWide) _buildMobileBottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context, {
    required bool isCreate,
    required bool isWide,
  }) {
    final double topInset = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 12),
      decoration: const BoxDecoration(
        color: SojuColors.surface,
        border: Border(bottom: BorderSide(color: SojuColors.hairline)),
      ),
      child: Row(
        children: <Widget>[
          InkWell(
            key: const Key('admin_product_back_button'),
            onTap: () => Navigator.of(context).pop(false),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SojuColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: SojuColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isCreate ? 'Tambah Produk Baru' : 'Edit Produk',
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                const Text(
                  'Kelola detail & tampilan produk di aplikasi pelanggan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onDelete != null) ...<Widget>[
            IconButton(
              key: const Key('admin_product_delete_button'),
              tooltip: 'Nonaktifkan Produk',
              onPressed: _isSaving ? null : _handleDelete,
              style: IconButton.styleFrom(
                backgroundColor: SojuColors.freeTableRequiredBg,
                foregroundColor: SojuColors.expense,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          if (isWide) ...<Widget>[
            OutlinedButton(
              key: const Key('admin_product_draft_button'),
              onPressed: _isSaving ? null : () => _submit(publish: false),
              style: OutlinedButton.styleFrom(
                foregroundColor: SojuColors.ink,
                side: const BorderSide(color: SojuColors.hairline),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Simpan Draft'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const Key('admin_product_publish_button'),
              onPressed: _isSaving ? null : () => _submit(publish: true),
              style: FilledButton.styleFrom(
                backgroundColor: SojuColors.primary,
                foregroundColor: SojuColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Publikasikan'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWideBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Column(
            children: <Widget>[
              _buildMediaCard(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: _buildVisibilityCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPreviewCard()),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 6,
          child: _buildDetailsCard(),
        ),
      ],
    );
  }

  Widget _buildMobileBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildMediaCard(),
        const SizedBox(height: 14),
        _buildDetailsCard(),
        const SizedBox(height: 14),
        _buildVisibilityCard(),
        const SizedBox(height: 14),
        _buildPreviewCard(),
      ],
    );
  }

  Widget _buildMediaCard() {
    final String imgUrl = _imgCtrl.text.trim();
    return _PanelCard(
      child: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  color: SojuColors.infoSoft.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SojuColors.hairline),
                ),
                alignment: Alignment.center,
                child: StorefrontProductImage(
                  url: imgUrl.isEmpty ? null : imgUrl,
                  size: 132,
                  radius: 14,
                ),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: SojuColors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SojuColors.hairline),
                  ),
                  child: const Text(
                    'Cover',
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: SojuColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _tab = _ProductDetailTab.advanced),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 144,
                decoration: BoxDecoration(
                  color: SojuColors.homeBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: SojuColors.primary.withValues(alpha: 0.4),
                    width: 1.4,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 28,
                      color: SojuColors.primary,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Atur URL Gambar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: SojuColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityCard() {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Visibilitas',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: SojuColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Atur tampilan produk ini untuk pelanggan di katalog',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12.5,
              color: SojuColors.inkMuted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Switch(
                key: const Key('admin_product_visibility_switch'),
                activeThumbColor: SojuColors.primary,
                value: _isActive,
                onChanged: (bool val) => setState(() => _isActive = val),
              ),
              const SizedBox(width: 6),
              Text(
                _isActive ? 'Tampil' : 'Tersembunyi',
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Pratinjau',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: SojuColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Lihat tampilan produk seperti yang dilihat pelanggan',
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 12.5,
              color: SojuColors.inkMuted,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              key: const Key('admin_product_preview_button'),
              onPressed: _openPreview,
              style: OutlinedButton.styleFrom(
                foregroundColor: SojuColors.ink,
                side: const BorderSide(color: SojuColors.hairline),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Pratinjau',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Detail Produk',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SojuColors.ink,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Informasi utama untuk menampilkan menu di etalase.',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12,
                        color: SojuColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _isActive
                      ? SojuColors.infoSoft
                      : SojuColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SojuColors.hairline),
                ),
                child: Text(
                  _isActive ? 'Status: Aktif' : 'Status: Draft',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _isActive ? SojuColors.primary : SojuColors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: SojuColors.homeBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _TabPill(
                    key: const Key('admin_product_tab_general'),
                    label: 'Umum',
                    selected: _tab == _ProductDetailTab.general,
                    onTap: () =>
                        setState(() => _tab = _ProductDetailTab.general),
                  ),
                ),
                Expanded(
                  child: _TabPill(
                    key: const Key('admin_product_tab_advanced'),
                    label: 'Lanjutan',
                    selected: _tab == _ProductDetailTab.advanced,
                    onTap: () =>
                        setState(() => _tab = _ProductDetailTab.advanced),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_validationError != null) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SojuColors.freeTableRequiredBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _validationError!,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12.5,
                  color: SojuColors.expense,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_tab == _ProductDetailTab.general) ...<Widget>[
            const _FieldLabel('Nama Produk *'),
            const SizedBox(height: 6),
            TextField(
              key: const Key('admin_product_name_field'),
              controller: _nameCtrl,
              decoration: _inputDecoration('Contoh: Soju Sparkling Peach'),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _FieldLabel('Kode Produk *'),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('admin_product_code_field'),
                        controller: _codeCtrl,
                        decoration: _inputDecoration('PRD-001'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _FieldLabel('Satuan *'),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('admin_product_unit_field'),
                        controller: _unitCtrl,
                        decoration: _inputDecoration('pcs / botol / porsi'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _FieldLabel('Varian (pisahkan koma)'),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('admin_product_variant_field'),
                        controller: _variantCtrl,
                        decoration: _inputDecoration('Dingin, Normal'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _FieldLabel('Harga (Rp) *'),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('admin_product_price_field'),
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('45000'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _FieldLabel('Deskripsi'),
            const SizedBox(height: 6),
            TextField(
              key: const Key('admin_product_desc_field'),
              controller: _descCtrl,
              maxLines: 4,
              decoration: _inputDecoration(
                'Tulis deskripsi singkat rasa, komposisi, atau keunggulan menu...',
              ),
            ),
          ] else ...<Widget>[
            const _FieldLabel('URL Gambar (S3 / HTTPS)'),
            const SizedBox(height: 6),
            TextField(
              key: const Key('admin_product_image_field'),
              controller: _imgCtrl,
              onChanged: (_) => setState(() {}),
              decoration: _inputDecoration('https://cdn.soju.id/menu.jpg'),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SojuColors.infoSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Jika URL gambar dikosongkan, etalase pelanggan otomatis menggunakan fallback gambar BLOB dari server (/api/public/products/:id/image).',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12.5,
                  height: 1.4,
                  color: SojuColors.primaryDeep,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: SojuColors.surface,
          border: Border(top: BorderSide(color: SojuColors.hairline)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                key: const Key('admin_product_draft_button'),
                onPressed: _isSaving ? null : () => _submit(publish: false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SojuColors.ink,
                  side: const BorderSide(color: SojuColors.hairline),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Draft'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                key: const Key('admin_product_publish_button'),
                onPressed: _isSaving ? null : () => _submit(publish: true),
                style: FilledButton.styleFrom(
                  backgroundColor: SojuColors.primary,
                  foregroundColor: SojuColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Publikasikan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: SojuColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SojuColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SojuColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SojuColors.primary, width: 1.4),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SojuColors.hairline),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppTypography.family,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: SojuColors.ink,
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? SojuColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? SojuColors.ink : SojuColors.inkMuted,
          ),
        ),
      ),
    );
  }
}
