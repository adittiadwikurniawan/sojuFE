// lib/domain/entities/storefront_entity.dart
//
// Entity etalase Pelanggan (TASK-024): produk katalog publik dan item
// keranjang yang disinkronkan ke `/api/customer/keranjang`.

/// Batas jumlah per item sesuai validasi backend (1..99).
const int kCartMinQuantity = 1;
const int kCartMaxQuantity = 99;

/// Batas panjang catatan per item sesuai backend.
const int kCartNoteMaxLength = 255;

/// Produk aktif pada katalog publik.
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.code,
    required this.name,
    required this.variants,
    required this.unit,
    required this.price,
    this.imageUrl,
    this.description,
  });

  final int id;
  final String code;
  final String name;

  /// Daftar varian (hasil pemisahan koma); kosong bila tanpa varian.
  final List<String> variants;
  final String unit;

  /// Harga default dalam rupiah penuh.
  final int price;

  /// URL gambar terselesaikan (S3 `gambarUrl` atau fallback BLOB).
  final String? imageUrl;
  final String? description;

  bool get hasVariants => variants.isNotEmpty;
}

/// Satu baris item keranjang.
class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    this.variant = '',
    this.note = '',
    this.price = 0,
    this.unit = '',
    this.imageUrl,
  });

  final int productId;
  final String name;
  final String variant;
  final int quantity;
  final String note;
  final int price;
  final String unit;
  final String? imageUrl;

  int get subtotal => price * quantity;

  /// Item dianggap sama bila produk dan varian sama (case-insensitive).
  bool sameLine(int otherProductId, String otherVariant) =>
      productId == otherProductId &&
      variant.trim().toLowerCase() == otherVariant.trim().toLowerCase();

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      productId: productId,
      name: name,
      variant: variant,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      price: price,
      unit: unit,
      imageUrl: imageUrl,
    );
  }
}

/// Ringkasan total keranjang.
extension CartTotals on List<CartItem> {
  int get totalQuantity => fold(0, (int sum, CartItem i) => sum + i.quantity);

  int get totalPrice => fold(0, (int sum, CartItem i) => sum + i.subtotal);
}
