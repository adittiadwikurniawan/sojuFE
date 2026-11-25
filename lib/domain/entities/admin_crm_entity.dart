// lib/domain/entities/admin_crm_entity.dart
//
// Entity domain Pelanggan & Kampanye CRM (`SUPER_ADMIN`).

import 'package:flutter/foundation.dart';

/// Ringkasan statistik pelanggan (`/api/v1/customers/summary`).
@immutable
class AdminCustomerSummary {
  const AdminCustomerSummary({
    this.total = 0,
    this.active = 0,
    this.inactive = 0,
    this.promoOptIn = 0,
  });

  final int total;
  final int active;
  final int inactive;
  final int promoOptIn;
}

/// Data satu akun pelanggan pada panel Super Admin (`/api/v1/customers`).
@immutable
class AdminCustomerItem {
  const AdminCustomerItem({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isActive = true,
    this.promoOptIn = false,
    this.orderCount = 0,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;
  final bool promoOptIn;
  final int orderCount;
}

/// Segmen target kampanye CRM sesuai enum Prisma `SegmenKampanyePelanggan`.
enum CrmCampaignSegment {
  semuaBerizin(
    apiValue: 'SEMUA_BERIZIN',
    label: 'Semua Pelanggan Berizin Promo',
  ),
  belumPernahMemesan(
    apiValue: 'BELUM_PERNAH_MEMESAN',
    label: 'Belum Pernah Memesan',
  ),
  tidakMemesanLagi(
    apiValue: 'TIDAK_MEMESAN_LAGI',
    label: 'Lama Tidak Memesan',
  );

  const CrmCampaignSegment({
    required this.apiValue,
    required this.label,
  });

  final String apiValue;
  final String label;

  static CrmCampaignSegment fromApi(Object? raw) {
    return switch (raw?.toString()) {
      'BELUM_PERNAH_MEMESAN' => CrmCampaignSegment.belumPernahMemesan,
      'TIDAK_MEMESAN_LAGI' => CrmCampaignSegment.tidakMemesanLagi,
      _ => CrmCampaignSegment.semuaBerizin,
    };
  }
}

/// Satu draf kampanye CRM (`/api/v1/customer-campaigns`).
@immutable
class CrmCampaignItem {
  const CrmCampaignItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.body,
    required this.segment,
    this.inactiveDays,
    this.authorName,
  });

  final int id;
  final String title;
  final String subject;
  final String body;
  final CrmCampaignSegment segment;
  final int? inactiveDays;
  final String? authorName;
}

/// Payload simpan draf kampanye CRM.
@immutable
class CrmCampaignDraft {
  const CrmCampaignDraft({
    required this.title,
    required this.subject,
    required this.body,
    required this.segment,
    this.inactiveDays,
  });

  final String title;
  final String subject;
  final String body;
  final CrmCampaignSegment segment;
  final int? inactiveDays;
}
