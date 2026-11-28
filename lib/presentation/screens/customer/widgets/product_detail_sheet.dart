// lib/presentation/screens/customer/widgets/product_detail_sheet.dart
//
// Bottom sheet detail produk: pilih varian, jumlah (1..99), dan catatan.

import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';
import '../../../../domain/entities/storefront_entity.dart';
import '../../../utils/format.dart';
import 'storefront_widgets.dart';

/// Pilihan pengguna dari [ProductDetailSheet].
class ProductSelection {
  const ProductSelection({
    required this.variant,
    required this.quantity,
    required this.note,
  });

  final String variant;
  final int quantity;
  final String note;
}

/// Menampilkan [ProductDetailSheet] sebagai modal bottom sheet.
Future<ProductSelection?> showProductDetailSheet(
  BuildContext context,
  CatalogProduct product,
) {
  return showModalBottomSheet<ProductSelection>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: SojuColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (BuildContext context) => ProductDetailSheet(product: product),
  );
}

/// Konten detail produk. Menutup sheet dengan [ProductSelection].
class ProductDetailSheet extends StatefulWidget {
  const ProductDetailSheet({super.key, required this.product});

  final CatalogProduct product;

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  final TextEditingController _noteController = TextEditingController();
  final Set<String> _selectedVariants = <String>{};
  int _quantity = 1;
  bool _showVariantError = false;

  @override
  void initState() {
    super.initState();
    final List<String> variants = widget.product.variants;
    if (variants.length == 1) {
      _selectedVariants.add(variants.first);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleVariant(String variant) {
    setState(() {
      if (_selectedVariants.contains(variant)) {
        _selectedVariants.remove(variant);
      } else {
        _selectedVariants.add(variant);
      }
      if (_selectedVariants.isNotEmpty) {
        _showVariantError = false;
      }
    });
  }

  void _submit() {
    final CatalogProduct product = widget.product;
    if (product.hasVariants && _selectedVariants.isEmpty) {
      setState(() => _showVariantError = true);
      return;
    }
    // Pertahankan urutan sesuai daftar varian produk agar rapi.
    final List<String> orderedSelected = product.variants
        .where(_selectedVariants.contains)
        .toList(growable: false);
    Navigator.of(context).pop(
      ProductSelection(
        variant: orderedSelected.join(', '),
        quantity: _quantity,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CatalogProduct product = widget.product;
    const TextStyle label = TextStyle(
      fontFamily: AppTypography.family,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: SojuColors.ink,
    );

    return Padding(
      key: const Key('product_detail_sheet'),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: SojuColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: SojuColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: SojuColors.ink,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Detail Menu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.ink,
                          ),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: SojuColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: SojuColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 156,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: SojuColors.infoSoft.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    alignment: Alignment.center,
                    child: StorefrontProductImage(
                      url: product.imageUrl,
                      size: 156,
                      radius: 20,
                      enableLightbox: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Menu / SOJU / ${product.unit.isEmpty ? 'Produk' : product.unit}',
                    style: const TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SojuColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        product.unit.isEmpty
                            ? formatRupiah(product.price)
                            : '${formatRupiah(product.price)} / ${product.unit}',
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: SojuColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.star_rounded,
                        size: 17,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '4.9',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.ink,
                        ),
                      ),
                      if (product.code.isNotEmpty) ...<Widget>[
                        const SizedBox(width: 8),
                        Text(
                          '•  ${product.code}',
                          style: const TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 12.5,
                            color: SojuColors.inkMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (product.description != null) ...<Widget>[
                    const SizedBox(height: 12),
                    const Text('Info Produk', style: label),
                    const SizedBox(height: 4),
                    Text(
                      product.description!,
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 13.5,
                        height: 1.45,
                        color: SojuColors.inkMuted,
                      ),
                    ),
                  ],
                  if (product.hasVariants) ...<Widget>[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Pilih Varian', style: label),
                        Text(
                          _selectedVariants.isEmpty
                              ? 'Bisa pilih lebih dari satu'
                              : '${_selectedVariants.length} dipilih',
                          style: const TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: SojuColors.brandNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final String v in product.variants)
                          FilterChip(
                            key: Key('product_variant_$v'),
                            label: Text(v),
                            selected: _selectedVariants.contains(v),
                            checkmarkColor: SojuColors.brandNavy,
                            selectedColor: SojuColors.infoSoft,
                            side: BorderSide(
                              color: _selectedVariants.contains(v)
                                  ? SojuColors.brandNavy
                                  : SojuColors.cardBorder,
                            ),
                            labelStyle: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 13,
                              fontWeight: _selectedVariants.contains(v)
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedVariants.contains(v)
                                  ? SojuColors.brandNavy
                                  : SojuColors.ink,
                            ),
                            onSelected: (_) => _toggleVariant(v),
                          ),
                      ],
                    ),
                    if (_showVariantError)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Pilih varian terlebih dahulu.',
                          key: Key('product_variant_error'),
                          style: TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 12.5,
                            color: SojuColors.expense,
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 14),
                  const Text('Catatan (opsional)', style: label),
                  const SizedBox(height: 6),
                  TextField(
                    key: const Key('product_note_field'),
                    controller: _noteController,
                    maxLength: kCartNoteMaxLength,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Contoh: kurangi gula, tanpa es',
                      filled: true,
                      fillColor: SojuColors.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            decoration: const BoxDecoration(
              color: SojuColors.surface,
              border: Border(top: BorderSide(color: SojuColors.hairline)),
            ),
            child: Row(
              children: <Widget>[
                QuantityStepper(
                  value: _quantity,
                  valueKey: const Key('product_quantity_value'),
                  decrementKey: const Key('product_quantity_decrement'),
                  incrementKey: const Key('product_quantity_increment'),
                  onDecrement: _quantity > kCartMinQuantity
                      ? () => setState(() => _quantity--)
                      : null,
                  onIncrement: _quantity < kCartMaxQuantity
                      ? () => setState(() => _quantity++)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('product_add_to_cart'),
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: SojuColors.primary,
                      foregroundColor: SojuColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Tambah ke Keranjang • ${formatRupiah(product.price * _quantity)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
