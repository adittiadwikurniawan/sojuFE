// lib/domain/entities/admin_cms_entity.dart
//
// Entity domain pengelolaan Konten CMS Publik & Katalog Produk (`SUPER_ADMIN`).

import 'package:flutter/foundation.dart';

/// Satu item konten CMS publik (`/api/v1/cms/content`).
@immutable
class CmsContentItem {
  const CmsContentItem({
    required this.id,
    required this.key,
    required this.title,
    this.subtitle,
    this.content,
    this.isActive = true,
  });

  final int id;
  final String key;
  final String title;
  final String? subtitle;
  final String? content;
  final bool isActive;
}

/// Draf pembuatan / pembaruan konten CMS.
@immutable
class CmsContentDraft {
  const CmsContentDraft({
    required this.key,
    required this.title,
    this.subtitle,
    this.content,
    this.isActive = true,
  });

  final String key;
  final String title;
  final String? subtitle;
  final String? content;
  final bool isActive;
}

/// Satu item produk operasional & katalog publik (`/api/v1/products`).
@immutable
class AdminProductItem {
  const AdminProductItem({
    required this.id,
    required this.code,
    required this.name,
    required this.unit,
    required this.price,
    this.variant,
    this.description,
    this.imageUrl,
    this.isActive = true,
  });

  final int id;
  final String code;
  final String name;
  final String? variant;
  final String unit;
  final int price;
  final String? description;
  final String? imageUrl;
  final bool isActive;
}

/// Draf pembuatan / pembaruan produk.
@immutable
class AdminProductDraft {
  const AdminProductDraft({
    required this.code,
    required this.name,
    required this.unit,
    required this.price,
    this.variant,
    this.description,
    this.imageUrl,
    this.isActive = true,
  });

  final String code;
  final String name;
  final String? variant;
  final String unit;
  final int price;
  final String? description;
  final String? imageUrl;
  final bool isActive;
}
