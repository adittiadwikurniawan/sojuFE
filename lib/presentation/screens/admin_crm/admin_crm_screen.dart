// lib/presentation/screens/admin_crm/admin_crm_screen.dart
//
// Layar Super Admin: Pelanggan & Kampanye CRM (`/admin/crm`).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/app_typography.dart';
import '../../../core/themes/soju_colors.dart';
import '../../../domain/entities/admin_crm_entity.dart';
import '../../providers/admin_crm/admin_crm_controller.dart';

class AdminCrmScreen extends StatefulWidget {
  const AdminCrmScreen({
    super.key = const Key('admin_crm_screen'),
    required this.controllerFactory,
    this.onBack,
  });

  final AdminCrmController Function() controllerFactory;
  final VoidCallback? onBack;

  @override
  State<AdminCrmScreen> createState() => _AdminCrmScreenState();
}

class _AdminCrmScreenState extends State<AdminCrmScreen> {
  late final AdminCrmController _controller;
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

  Future<void> _openCampaignSheet({CrmCampaignItem? existing}) async {
    final TextEditingController titleCtrl =
        TextEditingController(text: existing?.title ?? '');
    final TextEditingController subjectCtrl =
        TextEditingController(text: existing?.subject ?? '');
    final TextEditingController bodyCtrl =
        TextEditingController(text: existing?.body ?? '');
    final TextEditingController daysCtrl = TextEditingController(
      text: existing?.inactiveDays?.toString() ?? '30',
    );
    CrmCampaignSegment segment =
        existing?.segment ?? CrmCampaignSegment.semuaBerizin;
    int? previewCount;

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
                      existing == null
                          ? 'Buat Draf Kampanye Email (SMTP)'
                          : 'Ubah Draf Kampanye Email (SMTP)',
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: SojuColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: SojuColors.blueSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: SojuColors.freeTableBlueBorder60,
                        ),
                      ),
                      child: const Row(
                        children: <Widget>[
                          Icon(
                            Icons.mark_email_read_outlined,
                            size: 16,
                            color: SojuColors.brandNavy,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Email dikirim via SMTP hanya ke pelanggan yang mengaktifkan opt-in promosi.',
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 11.5,
                                color: SojuColors.brandNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtrl,
                      decoration: _inputDecoration('Judul Kampanye Internal'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectCtrl,
                      decoration: _inputDecoration('Subjek Pesan / Email'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CrmCampaignSegment>(
                      value: segment,
                      decoration: _inputDecoration('Segmen Pelanggan'),
                      items: CrmCampaignSegment.values
                          .map(
                            (CrmCampaignSegment s) =>
                                DropdownMenuItem<CrmCampaignSegment>(
                              value: s,
                              child: Text(s.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (CrmCampaignSegment? val) {
                        if (val != null) {
                          setSheetState(() {
                            segment = val;
                            previewCount = null;
                          });
                        }
                      },
                    ),
                    if (segment == CrmCampaignSegment.tidakMemesanLagi) ...<Widget>[
                      const SizedBox(height: 12),
                      TextField(
                        controller: daysCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Jumlah Hari Tidak Memesan',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyCtrl,
                      maxLines: 4,
                      decoration: _inputDecoration('Isi Pesan Promosi'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: () async {
                            final int? days = int.tryParse(daysCtrl.text.trim());
                            final int? count = await _controller.previewTarget(
                              segment: segment,
                              inactiveDays: days,
                            );
                            if (ctx.mounted && count != null) {
                              setSheetState(() => previewCount = count);
                            }
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 17),
                          label: const Text('Cek Estimasi Target'),
                        ),
                        if (previewCount != null) ...<Widget>[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$previewCount pelanggan memenuhi kriteria',
                              style: const TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: SojuColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: SojuColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final String title = titleCtrl.text.trim();
                        final String subject = subjectCtrl.text.trim();
                        final String body = bodyCtrl.text.trim();
                        if (title.isEmpty || subject.isEmpty || body.isEmpty) {
                          return;
                        }
                        final int? days =
                            segment == CrmCampaignSegment.tidakMemesanLagi
                                ? (int.tryParse(daysCtrl.text.trim()) ?? 30)
                                : null;
                        final bool ok = await _controller.saveCampaign(
                          existingId: existing?.id,
                          draft: CrmCampaignDraft(
                            title: title,
                            subject: subject,
                            body: body,
                            segment: segment,
                            inactiveDays: days,
                          ),
                        );
                        if (ok && sheetCtx.mounted) {
                          Navigator.of(sheetCtx).pop(true);
                        }
                      },
                      child: const Text('Simpan Draf Kampanye'),
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
          content: Text('Draf kampanye CRM berhasil disimpan.'),
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
                    final AdminCrmState state = _controller.state;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildTopBar(scale, topInset, state),
                        _buildSummaryRow(scale, state.summary),
                        _buildTabSwitcher(scale, state),
                        if (state.errorMessage != null)
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              16 * scale,
                              6 * scale,
                              16 * scale,
                              0,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(10 * scale),
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
                                        fontSize: 12 * scale,
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
                              : state.activeTab == AdminCrmTab.customers
                                  ? _buildCustomersTab(scale, state)
                                  : _buildCampaignsTab(scale, state),
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

  Widget _buildTopBar(double scale, double topInset, AdminCrmState state) {
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
                  'Pelanggan & CRM',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 19 * scale,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                Text(
                  'Kelola akun pelanggan & draf kampanye promosi',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12 * scale,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          if (state.activeTab == AdminCrmTab.campaigns)
            FilledButton.icon(
              key: const Key('admin_crm_add_campaign'),
              onPressed: () => _openCampaignSheet(),
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
              label: const Text('Kampanye'),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(double scale, AdminCustomerSummary s) {
    final List<({String label, String val})> items = <({
      String label,
      String val,
    })>[
      (label: 'Total', val: '${s.total}'),
      (label: 'Aktif', val: '${s.active}'),
      (label: 'Nonaktif', val: '${s.inactive}'),
      (label: 'Izin Promo', val: '${s.promoOptIn}'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 4 * scale),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: 8 * scale),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10 * scale,
                  horizontal: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: SojuColors.surface,
                  borderRadius: BorderRadius.circular(14 * scale),
                  border: Border.all(color: SojuColors.hairline),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      items[i].val,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w800,
                        color: SojuColors.primaryDeep,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 10.5 * scale,
                        color: SojuColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabSwitcher(double scale, AdminCrmState state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 4 * scale),
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
              child: _CrmTabButton(
                label: 'Pelanggan (${state.customers.length})',
                selected: state.activeTab == AdminCrmTab.customers,
                onTap: () => _controller.selectTab(AdminCrmTab.customers),
              ),
            ),
            Expanded(
              child: _CrmTabButton(
                label: 'Kampanye CRM (${state.campaigns.length})',
                selected: state.activeTab == AdminCrmTab.campaigns,
                onTap: () => _controller.selectTab(AdminCrmTab.campaigns),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomersTab(double scale, AdminCrmState state) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 6 * scale),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (String q) => _controller.loadAll(query: q),
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau email pelanggan...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: SojuColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
              SizedBox(width: 8 * scale),
              PopupMenuButton<String>(
                initialValue: state.statusFilter,
                onSelected: (String s) => _controller.loadAll(status: s),
                itemBuilder: (_) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'semua', child: Text('Semua')),
                  PopupMenuItem<String>(value: 'aktif', child: Text('Aktif')),
                  PopupMenuItem<String>(
                    value: 'nonaktif',
                    child: Text('Nonaktif'),
                  ),
                ],
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 11 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: SojuColors.surface,
                    borderRadius: BorderRadius.circular(14 * scale),
                    border: Border.all(color: SojuColors.hairline),
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    color: SojuColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.customers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.groups_outlined,
                        size: 48 * scale,
                        color: SojuColors.inkMuted,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Belum ada akun pelanggan.',
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
                    itemCount: state.customers.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
                    itemBuilder: (BuildContext context, int index) {
                      final AdminCustomerItem c = state.customers[index];
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
                                Expanded(
                                  child: Text(
                                    c.name,
                                    style: TextStyle(
                                      fontFamily: AppTypography.family,
                                      fontSize: 15 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: SojuColors.ink,
                                    ),
                                  ),
                                ),
                                Switch(
                                  activeColor: SojuColors.primary,
                                  value: c.isActive,
                                  onChanged: (bool val) =>
                                      _controller.toggleCustomerStatus(
                                    customer: c,
                                    isActive: val,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              c.email,
                              style: TextStyle(
                                fontFamily: AppTypography.family,
                                fontSize: 12.5 * scale,
                                color: SojuColors.inkMuted,
                              ),
                            ),
                            if (c.phone != null) ...<Widget>[
                              const SizedBox(height: 2),
                              Text(
                                c.phone!,
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 12 * scale,
                                  color: SojuColors.inkMuted,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children: <Widget>[
                                _BadgeChip(
                                  label: '${c.orderCount} Pesanan',
                                  bg: SojuColors.infoSoft,
                                  fg: SojuColors.primary,
                                ),
                                _BadgeChip(
                                  label: c.promoOptIn
                                      ? 'Izin Promo'
                                      : 'Tanpa Promo',
                                  bg: c.promoOptIn
                                      ? const Color(0xFFECFDF5)
                                      : SojuColors.field,
                                  fg: c.promoOptIn
                                      ? SojuColors.positive
                                      : SojuColors.inkMuted,
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

  Widget _buildCampaignsTab(double scale, AdminCrmState state) {
    if (state.campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.campaign_outlined,
              size: 48 * scale,
              color: SojuColors.inkMuted,
            ),
            const SizedBox(height: 10),
            const Text(
              'Belum ada draf kampanye promosi.',
              style: TextStyle(
                fontFamily: AppTypography.family,
                fontWeight: FontWeight.w600,
                color: SojuColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _openCampaignSheet(),
              child: const Text('Buat Kampanye Baru'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.loadAll(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 32 * scale),
        itemCount: state.campaigns.length,
        separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
        itemBuilder: (BuildContext context, int index) {
          final CrmCampaignItem item = state.campaigns[index];
          return Container(
            padding: EdgeInsets.all(15 * scale),
            decoration: BoxDecoration(
              color: SojuColors.surface,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: SojuColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _BadgeChip(
                  label: item.segment.label,
                  bg: SojuColors.infoSoft,
                  fg: SojuColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w700,
                    color: SojuColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Subjek: ${item.subject}',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12.5 * scale,
                    fontWeight: FontWeight.w600,
                    color: SojuColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12.5 * scale,
                    height: 1.4,
                    color: SojuColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: () => _openCampaignSheet(existing: item),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Ubah'),
                    ),
                    TextButton.icon(
                      onPressed: () => _controller.deleteCampaign(item.id),
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
}

class _CrmTabButton extends StatelessWidget {
  const _CrmTabButton({
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

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
