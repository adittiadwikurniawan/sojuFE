import 'package:flutter/material.dart';

import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/soju_colors.dart';
import '../../../../../domain/entities/sales_chat_entity.dart';
import '../../../../utils/format.dart';

/// Kartu draft penjualan pada prototype chat.
///
/// Seluruh nominal berasal dari [SalesChatDraft]. Kartu ini tidak pernah
/// menampilkan status "tersimpan" — hanya draft atau hasil simulasi.
class SalesDraftCard extends StatelessWidget {
  const SalesDraftCard({
    super.key,
    required this.scale,
    required this.draft,
    this.onCorrect,
    this.onConfirm,
    this.isSimulationComplete = false,
    this.simulationMessage,
    this.errorMessage,
  });

  final double scale;
  final SalesChatDraft draft;
  final VoidCallback? onCorrect;
  final VoidCallback? onConfirm;
  final bool isSimulationComplete;
  final String? simulationMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final List<String> missing = draft.missingFields;
    final bool canConfirm = draft.canConfirm && !isSimulationComplete;

    return Container(
      key: const Key('sales_draft_card'),
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: SojuColors.hairline),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isSimulationComplete) ...<Widget>[
            _InfoBanner(
              scale: scale,
              icon: Icons.check_circle_outline,
              text: simulationMessage ??
                  'Simulasi selesai — tidak masuk ke pembukuan.',
              background: SojuColors.infoSoft,
              border: const Color(0xFFBFD5FF),
              foreground: SojuColors.badgeBlue,
            ),
            SizedBox(height: 10 * scale),
          ],
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8 * scale,
            runSpacing: 6 * scale,
            children: <Widget>[
              _Badge(
                scale: scale,
                label: 'Draft — belum disimpan',
                background: SojuColors.draftBadge,
                foreground: SojuColors.draftBadgeInk,
                icon: Icons.edit_note,
              ),
              Text(
                'Data contoh',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 9 * scale,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.analyticsMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          _MetaRow(scale: scale, draft: draft),
          SizedBox(height: 12 * scale),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: SojuColors.draftRow,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'TOTAL PEMASUKAN',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 9 * scale,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: SojuColors.analyticsMuted,
                        ),
                      ),
                      SizedBox(height: 3 * scale),
                      Text(
                        draft.declaredTotal == null
                            ? 'Belum diisi'
                            : formatRupiah(draft.declaredTotal!),
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.w800,
                          color: draft.declaredTotal == null
                              ? SojuColors.freeTableAmber
                              : SojuColors.badgeBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                _Badge(
                  scale: scale,
                  label: '${draft.items.length} produk',
                  background: SojuColors.surface,
                  foreground: SojuColors.analyticsLabel,
                  icon: Icons.restaurant_menu,
                ),
              ],
            ),
          ),
          SizedBox(height: 14 * scale),
          _SectionTitle(
            scale: scale,
            title: 'Rincian produk',
            trailing: draft.itemTotal == null
                ? 'Belum lengkap'
                : formatRupiah(draft.itemTotal!),
          ),
          SizedBox(height: 6 * scale),
          if (draft.items.isEmpty)
            _MissingBox(
              scale: scale,
              text: 'Belum ada produk pada draft.',
            )
          else
            for (int index = 0;
                index < draft.items.length;
                index++) ...<Widget>[
              if (index > 0)
                Divider(
                  height: 12 * scale,
                  thickness: 0.7,
                  color: SojuColors.hairline,
                ),
              _ItemRow(
                scale: scale,
                item: draft.items[index],
              ),
            ],
          SizedBox(height: 14 * scale),
          _SectionTitle(
            scale: scale,
            title: 'Rincian pembayaran',
            trailing: draft.paymentTotal == null
                ? 'Belum lengkap'
                : formatRupiah(draft.paymentTotal!),
          ),
          SizedBox(height: 6 * scale),
          if (draft.payments.isEmpty)
            _MissingBox(
              scale: scale,
              text: 'Metode pembayaran belum diisi. Lengkapi lewat Koreksi '
                  'sebelum konfirmasi simulasi.',
            )
          else
            for (final SalesPaymentEntry payment in draft.payments)
              Padding(
                padding: EdgeInsets.only(bottom: 6 * scale),
                child: _PaymentRow(scale: scale, payment: payment),
              ),
          if (missing.isNotEmpty) ...<Widget>[
            SizedBox(height: 10 * scale),
            _ValidationBox(
              scale: scale,
              title: 'Perlu dilengkapi',
              icon: Icons.error_outline,
              background: SojuColors.demoSoft,
              border: SojuColors.demoBorder,
              foreground: SojuColors.demoInk,
              children: <Widget>[
                Wrap(
                  spacing: 6 * scale,
                  runSpacing: 6 * scale,
                  children: <Widget>[
                    for (final String field in missing.take(8))
                      _FieldChip(scale: scale, label: field),
                    if (missing.length > 8)
                      _FieldChip(
                        scale: scale,
                        label: '+${missing.length - 8} lainnya',
                      ),
                  ],
                ),
                SizedBox(height: 7 * scale),
                Text(
                  'Konfirmasi simulasi aktif setelah field wajib terisi.',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 9.5 * scale,
                    height: 1.4,
                    color: SojuColors.demoInk,
                  ),
                ),
              ],
            ),
          ],
          if (draft.hasItemMismatch) ...<Widget>[
            SizedBox(height: 8 * scale),
            _ValidationBox(
              scale: scale,
              title: 'Total item tidak cocok',
              icon: Icons.warning_amber_rounded,
              background: SojuColors.expenseSoft,
              border: const Color(0xFFFECACA),
              foreground: SojuColors.expense,
              children: <Widget>[
                Text(
                  'Total pemasukan ${formatRupiah(draft.declaredTotal!)} '
                  'berbeda dengan jumlah subtotal item '
                  '${formatRupiah(draft.itemTotal!)}. Selisih '
                  '${formatRupiah(draft.itemDifference!.abs())}.',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 9.5 * scale,
                    height: 1.4,
                    color: SojuColors.expense,
                  ),
                ),
              ],
            ),
          ],
          if (draft.hasPaymentMismatch) ...<Widget>[
            SizedBox(height: 8 * scale),
            _ValidationBox(
              scale: scale,
              title: 'Pembayaran tidak cocok',
              icon: Icons.warning_amber_rounded,
              background: SojuColors.expenseSoft,
              border: const Color(0xFFFECACA),
              foreground: SojuColors.expense,
              children: <Widget>[
                Text(
                  'Total pemasukan ${formatRupiah(draft.declaredTotal!)} '
                  'berbeda dengan rincian pembayaran '
                  '${formatRupiah(draft.paymentTotal!)}. Selisih '
                  '${formatRupiah(draft.paymentDifference!.abs())}.',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 9.5 * scale,
                    height: 1.4,
                    color: SojuColors.expense,
                  ),
                ),
              ],
            ),
          ],
          if (draft.canConfirm && !isSimulationComplete) ...<Widget>[
            SizedBox(height: 8 * scale),
            _ValidationBox(
              scale: scale,
              title: 'Draft siap disimulasikan',
              icon: Icons.verified_outlined,
              background: SojuColors.incomeSoft,
              border: const Color(0xFFA7F3D0),
              foreground: SojuColors.positive,
              children: <Widget>[
                Text(
                  'Total item dan rincian pembayaran sudah cocok. '
                  'Konfirmasi hanya menjalankan simulasi.',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 9.5 * scale,
                    height: 1.4,
                    color: SojuColors.positive,
                  ),
                ),
              ],
            ),
          ],
          if (errorMessage != null) ...<Widget>[
            SizedBox(height: 8 * scale),
            Text(
              errorMessage!,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 9.5 * scale,
                height: 1.4,
                color: SojuColors.expense,
              ),
            ),
          ],
          SizedBox(height: 14 * scale),
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionButton(
                  key: const Key('sales_draft_confirm'),
                  scale: scale,
                  label: isSimulationComplete
                      ? 'Simulasi selesai'
                      : 'Konfirmasi simulasi',
                  icon: isSimulationComplete
                      ? Icons.check_circle_outline
                      : Icons.play_circle_outline,
                  filled: true,
                  enabled: canConfirm,
                  onTap: canConfirm ? onConfirm : null,
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _ActionButton(
                  key: const Key('sales_draft_correct'),
                  scale: scale,
                  label: 'Koreksi',
                  icon: Icons.edit_outlined,
                  filled: false,
                  enabled: onCorrect != null,
                  onTap: onCorrect,
                ),
              ),
            ],
          ),
          SizedBox(height: 9 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.lock_outline,
                size: 11 * scale,
                color: SojuColors.analyticsMuted,
              ),
              SizedBox(width: 4 * scale),
              Expanded(
                child: Text(
                  draft.note,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 9 * scale,
                    height: 1.35,
                    color: SojuColors.analyticsMuted,
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.scale, required this.draft});

  final double scale;
  final SalesChatDraft draft;

  @override
  Widget build(BuildContext context) {
    final String date =
        draft.date == null ? 'Belum diisi' : formatWeekdayDate(draft.date!);
    final String shift = draft.shift == null || draft.shift!.trim().isEmpty
        ? 'Belum diisi'
        : 'Shift ${draft.shift}';

    return Wrap(
      spacing: 8 * scale,
      runSpacing: 6 * scale,
      children: <Widget>[
        _MetaPill(
          scale: scale,
          icon: Icons.calendar_today_outlined,
          label: date,
          missing: draft.date == null,
        ),
        _MetaPill(
          scale: scale,
          icon: Icons.schedule,
          label: shift,
          missing: draft.shift == null || draft.shift!.trim().isEmpty,
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.scale,
    required this.icon,
    required this.label,
    required this.missing,
  });

  final double scale;
  final IconData icon;
  final String label;
  final bool missing;

  @override
  Widget build(BuildContext context) {
    final Color color =
        missing ? SojuColors.freeTableAmber : SojuColors.analyticsLabel;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * scale,
        vertical: 5 * scale,
      ),
      decoration: BoxDecoration(
        color: missing ? SojuColors.demoSoft : SojuColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(
          color: missing ? SojuColors.demoBorder : SojuColors.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 11 * scale, color: color),
          SizedBox(width: 4 * scale),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 9.5 * scale,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.scale, required this.item});

  final double scale;
  final SalesChatItem item;

  @override
  Widget build(BuildContext context) {
    final bool missingPrice = item.unitPrice == null;
    final bool missingQuantity = item.quantity == null;
    final String quantity = missingQuantity
        ? 'Jumlah belum diisi'
        : '${item.quantity} ${item.unit ?? 'satuan belum diisi'}';
    final String price = missingPrice
        ? 'Harga belum diisi'
        : '@${formatRupiah(item.unitPrice!)}';
    final String method = item.method?.label ?? 'Metode belum diisi';
    final Color methodColor = item.method == null
        ? SojuColors.freeTableAmber
        : SojuColors.analyticsMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 30 * scale,
          height: 30 * scale,
          decoration: const BoxDecoration(
            color: SojuColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.restaurant,
            size: 15 * scale,
            color: SojuColors.analyticsLabel,
          ),
        ),
        SizedBox(width: 9 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.name ?? 'Nama produk belum diisi',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w700,
                  color: item.name == null
                      ? SojuColors.freeTableAmber
                      : SojuColors.notificationTitle,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                '$quantity × $price',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 9.5 * scale,
                  color: SojuColors.analyticsMuted,
                ),
              ),
              SizedBox(height: 3 * scale),
              Text(
                method,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 9 * scale,
                  fontWeight: FontWeight.w600,
                  color: methodColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8 * scale),
        Text(
          item.subtotal == null ? '—' : formatRupiah(item.subtotal!),
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 11 * scale,
            fontWeight: FontWeight.w700,
            color: item.subtotal == null
                ? SojuColors.freeTableAmber
                : SojuColors.notificationTitle,
          ),
        ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.scale, required this.payment});

  final double scale;
  final SalesPaymentEntry payment;

  @override
  Widget build(BuildContext context) {
    final String method = payment.method?.label ?? 'Metode belum diisi';
    final Color color = payment.method == null
        ? SojuColors.freeTableAmber
        : SojuColors.analyticsLabel;
    return Row(
      children: <Widget>[
        Icon(
          _paymentIcon(payment.method),
          size: 13 * scale,
          color: color,
        ),
        SizedBox(width: 5 * scale),
        Expanded(
          child: Text(
            method,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        Text(
          payment.amount == null
              ? 'Belum diisi'
              : formatRupiah(payment.amount!),
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 10 * scale,
            fontWeight: FontWeight.w700,
            color: payment.amount == null
                ? SojuColors.freeTableAmber
                : SojuColors.notificationTitle,
          ),
        ),
      ],
    );
  }

  IconData _paymentIcon(SalesPaymentMethod? method) {
    switch (method) {
      case SalesPaymentMethod.qris:
        return Icons.qr_code_2;
      case SalesPaymentMethod.cash:
        return Icons.payments_outlined;
      case SalesPaymentMethod.transfer:
        return Icons.account_balance_outlined;
      case null:
        return Icons.help_outline;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.scale,
    required this.title,
    required this.trailing,
  });

  final double scale;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 10 * scale,
              fontWeight: FontWeight.w700,
              color: SojuColors.analyticsLabel,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        Text(
          trailing,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 9.5 * scale,
            fontWeight: FontWeight.w600,
            color: SojuColors.analyticsMuted,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.scale,
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final double scale;
  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 10 * scale, color: foreground),
          SizedBox(width: 3 * scale),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 8.5 * scale,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationBox extends StatelessWidget {
  const _ValidationBox({
    required this.scale,
    required this.title,
    required this.icon,
    required this.background,
    required this.border,
    required this.foreground,
    required this.children,
  });

  final double scale;
  final String title;
  final IconData icon;
  final Color background;
  final Color border;
  final Color foreground;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9 * scale),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 12 * scale, color: foreground),
              SizedBox(width: 4 * scale),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 9.5 * scale,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          ...children,
        ],
      ),
    );
  }
}

class _MissingBox extends StatelessWidget {
  const _MissingBox({required this.scale, required this.text});

  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9 * scale),
      decoration: BoxDecoration(
        color: SojuColors.demoSoft,
        borderRadius: BorderRadius.circular(9 * scale),
        border: Border.all(color: SojuColors.demoBorder),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 9.5 * scale,
          height: 1.4,
          color: SojuColors.demoInk,
        ),
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  const _FieldChip({required this.scale, required this.label});

  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
        vertical: 3 * scale,
      ),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: SojuColors.demoBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 8.5 * scale,
          fontWeight: FontWeight.w600,
          color: SojuColors.demoInk,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.scale,
    required this.icon,
    required this.text,
    required this.background,
    required this.border,
    required this.foreground,
  });

  final double scale;
  final IconData icon;
  final String text;
  final Color background;
  final Color border;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9 * scale),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9 * scale),
        border: Border.all(color: border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 14 * scale, color: foreground),
          SizedBox(width: 5 * scale),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontSize: 9.5 * scale,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.scale,
    required this.label,
    required this.icon,
    required this.filled,
    required this.enabled,
    this.onTap,
  });

  final double scale;
  final String label;
  final IconData icon;
  final bool filled;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground;
    final Color background;
    final Color border;
    if (!enabled) {
      foreground = SojuColors.analyticsMuted;
      background = filled ? SojuColors.surfaceMuted : SojuColors.surface;
      border = SojuColors.hairline;
    } else if (filled) {
      foreground = SojuColors.surface;
      background = SojuColors.primary;
      border = SojuColors.primary;
    } else {
      foreground = SojuColors.primary;
      background = SojuColors.surface;
      border = SojuColors.primary;
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10 * scale),
          child: Container(
            height: 38 * scale,
            padding: EdgeInsets.symmetric(horizontal: 6 * scale),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 14 * scale, color: foreground),
                SizedBox(width: 4 * scale),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
