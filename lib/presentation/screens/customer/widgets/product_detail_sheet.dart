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
  String? _variant;
  int _quantity = 1;
  bool _showVariantError = false;

  @override
  void initState() {
    super.initState();
    final List<String> variants = widget.product.variants;
    if (variants.length == 1) _variant = variants.first;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final CatalogProduct product = widget.product;
    if (product.hasVariants && _variant == null) {
      setState(() => _showVariantError = true);
      return;
    }
    Navigator.of(context).pop(
      ProductSelection(
        variant: _variant ?? '',
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StorefrontProductImage(url: product.imageUrl, size: 88),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: SojuColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.unit.isEmpty
                            ? formatRupiah(product.price)
                            : '${formatRupiah(product.price)} / ${product.unit}',
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (product.description != null) ...<Widget>[
              const SizedBox(height: 14),
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
              const SizedBox(height: 18),
              const Text('Pilih Varian', style: label),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final String v in product.variants)
                    ChoiceChip(
                      key: Key('product_variant_$v'),
                      label: Text(v),
                      selected: _variant == v,
                      selectedColor: SojuColors.infoSoft,
                      onSelected: (_) => setState(() {
                        _variant = v;
                        _showVariantError = false;
                      }),
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
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                const Expanded(child: Text('Jumlah', style: label)),
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
              ],
            ),
            const SizedBox(height: 18),
            const Text('Catatan (opsional)', style: label),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
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
    );
  }
}
