import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/soju_colors.dart';
import '../../../../../domain/entities/sales_chat_entity.dart';

/// Sheet koreksi draft penjualan.
///
/// Semua perubahan hanya mengubah state lokal prototype. Tidak ada request
/// jaringan dan tidak ada penulisan transaksi.
class SalesDraftEditorSheet extends StatefulWidget {
  const SalesDraftEditorSheet({
    super.key,
    required this.draft,
  });

  final SalesChatDraft draft;

  @override
  State<SalesDraftEditorSheet> createState() => _SalesDraftEditorSheetState();
}

class _SalesDraftEditorSheetState extends State<SalesDraftEditorSheet> {
  late final TextEditingController _date;
  late final TextEditingController _shift;
  late final TextEditingController _total;
  late final List<_ItemFields> _items;
  late final List<_PaymentFields> _payments;

  String? _error;

  @override
  void initState() {
    super.initState();
    _date = TextEditingController(text: _formatDateInput(widget.draft.date));
    _shift = TextEditingController(text: widget.draft.shift ?? '');
    _total = TextEditingController(
      text: widget.draft.declaredTotal?.toString() ?? '',
    );
    _items = <_ItemFields>[
      for (final SalesChatItem item in widget.draft.items) _ItemFields(item),
    ];
    if (_items.isEmpty) {
      _items.add(_ItemFields(const SalesChatItem()));
    }
    _payments = <_PaymentFields>[
      for (final SalesPaymentEntry payment in widget.draft.payments)
        _PaymentFields(payment),
    ];
    if (_payments.isEmpty) {
      _payments.add(_PaymentFields(const SalesPaymentEntry()));
    }
  }

  @override
  void dispose() {
    _date.dispose();
    _shift.dispose();
    _total.dispose();
    for (final _ItemFields item in _items) {
      item.dispose();
    }
    for (final _PaymentFields payment in _payments) {
      payment.dispose();
    }
    super.dispose();
  }

  void _save() {
    String? error;
    bool invalid = false;

    int? parseAmount(String text, String label) {
      if (text.trim().isEmpty) {
        return null;
      }
      final String cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
      final int? value = int.tryParse(cleaned);
      if (value == null) {
        invalid = true;
        error = '$label harus berupa angka.';
      }
      return value;
    }

    DateTime? date;
    final String dateText = _date.text.trim();
    if (dateText.isNotEmpty) {
      date = DateTime.tryParse(dateText);
      if (date == null) {
        invalid = true;
        error = 'Format tanggal harus YYYY-MM-DD.';
      }
    }

    final int? total = parseAmount(_total.text, 'Total pemasukan');
    final List<SalesChatItem> items = <SalesChatItem>[
      for (final _ItemFields fields in _items)
        SalesChatItem(
          name: _emptyToNull(fields.name.text),
          quantity: parseAmount(fields.quantity.text, 'Jumlah produk'),
          unit: _emptyToNull(fields.unit.text),
          unitPrice: parseAmount(fields.price.text, 'Harga satuan'),
          method: fields.method,
        ),
    ];
    final List<SalesPaymentEntry> payments = <SalesPaymentEntry>[
      for (final _PaymentFields fields in _payments)
        SalesPaymentEntry(
          method: fields.method,
          amount: parseAmount(fields.amount.text, 'Nominal pembayaran'),
        ),
    ];

    if (invalid) {
      setState(() => _error = error);
      return;
    }

    final SalesChatDraft updated = SalesChatDraft(
      id: widget.draft.id,
      date: date,
      shift: _emptyToNull(_shift.text),
      declaredTotal: total,
      items: items,
      payments: payments,
      note: 'Draft contoh — perubahan hanya di sesi prototype, belum disimpan.',
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double scale = math.min(width, 480) / 430;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final double maxHeight = math.max(
      320,
      MediaQuery.sizeOf(context).height * 0.92 - bottomInset,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: SojuColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22 * scale),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _SheetHeader(scale: scale),
            const Divider(height: 1, color: SojuColors.hairline),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  14 * scale,
                  16 * scale,
                  18 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _HintBanner(scale: scale),
                    SizedBox(height: 14 * scale),
                    _FieldLabel(scale: scale, text: 'Tanggal'),
                    _TextField(
                      key: const Key('draft_editor_date'),
                      controller: _date,
                      hint: 'YYYY-MM-DD',
                      keyboardType: TextInputType.datetime,
                    ),
                    SizedBox(height: 10 * scale),
                    _FieldLabel(scale: scale, text: 'Shift'),
                    _TextField(
                      key: const Key('draft_editor_shift'),
                      controller: _shift,
                      hint: 'Contoh: Siang',
                    ),
                    SizedBox(height: 10 * scale),
                    _FieldLabel(scale: scale, text: 'Total pemasukan'),
                    _TextField(
                      key: const Key('draft_editor_total'),
                      controller: _total,
                      hint: 'Contoh: 1375000',
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    SizedBox(height: 16 * scale),
                    _SectionHeading(
                      scale: scale,
                      title: 'Produk',
                      actionLabel: 'Tambah produk',
                      actionKey: const Key('draft_editor_add_item'),
                      onAction: () {
                        setState(() {
                          _items.add(_ItemFields(const SalesChatItem()));
                        });
                      },
                    ),
                    SizedBox(height: 8 * scale),
                    for (int index = 0; index < _items.length; index++) ...[
                      _ItemEditor(
                        scale: scale,
                        index: index,
                        fields: _items[index],
                        canRemove: _items.length > 1,
                        onRemove: () {
                          setState(() {
                            final _ItemFields removed = _items.removeAt(index);
                            removed.dispose();
                          });
                        },
                        onChanged: () => setState(() {}),
                      ),
                      SizedBox(height: 9 * scale),
                    ],
                    SizedBox(height: 6 * scale),
                    _SectionHeading(
                      scale: scale,
                      title: 'Pembayaran',
                      actionLabel: 'Tambah pembayaran',
                      actionKey: const Key('draft_editor_add_payment'),
                      onAction: () {
                        setState(() {
                          _payments.add(
                            _PaymentFields(const SalesPaymentEntry()),
                          );
                        });
                      },
                    ),
                    SizedBox(height: 8 * scale),
                    for (int index = 0; index < _payments.length; index++) ...[
                      _PaymentEditor(
                        scale: scale,
                        index: index,
                        fields: _payments[index],
                        canRemove: _payments.length > 1,
                        onRemove: () {
                          setState(() {
                            final _PaymentFields removed =
                                _payments.removeAt(index);
                            removed.dispose();
                          });
                        },
                        onChanged: () => setState(() {}),
                      ),
                      SizedBox(height: 9 * scale),
                    ],
                    if (_error != null) ...<Widget>[
                      SizedBox(height: 4 * scale),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 10 * scale,
                          height: 1.4,
                          color: SojuColors.expense,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _SheetFooter(
              scale: scale,
              onCancel: () => Navigator.of(context).pop(),
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }

  String? _emptyToNull(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatDateInput(DateTime? date) {
    if (date == null) {
      return '';
    }
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _ItemFields {
  _ItemFields(SalesChatItem item)
      : name = TextEditingController(text: item.name ?? ''),
        quantity = TextEditingController(text: item.quantity?.toString() ?? ''),
        unit = TextEditingController(text: item.unit ?? ''),
        price = TextEditingController(text: item.unitPrice?.toString() ?? ''),
        method = item.method;

  final TextEditingController name;
  final TextEditingController quantity;
  final TextEditingController unit;
  final TextEditingController price;
  SalesPaymentMethod? method;

  void dispose() {
    name.dispose();
    quantity.dispose();
    unit.dispose();
    price.dispose();
  }
}

class _PaymentFields {
  _PaymentFields(SalesPaymentEntry payment)
      : amount = TextEditingController(text: payment.amount?.toString() ?? ''),
        method = payment.method;

  final TextEditingController amount;
  SalesPaymentMethod? method;

  void dispose() {
    amount.dispose();
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        12 * scale,
        10 * scale,
        10 * scale,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34 * scale,
            height: 34 * scale,
            decoration: const BoxDecoration(
              color: SojuColors.infoSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_note,
              size: 19 * scale,
              color: SojuColors.primary,
            ),
          ),
          SizedBox(width: 9 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Koreksi draft',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w800,
                    color: SojuColors.notificationTitle,
                  ),
                ),
                Text(
                  'Perubahan hanya di sesi prototype',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 9.5 * scale,
                    color: SojuColors.analyticsMuted,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Tutup koreksi',
            child: IconButton(
              key: const Key('draft_editor_close'),
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close,
                size: 20 * scale,
                color: SojuColors.analyticsLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  const _HintBanner({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9 * scale),
      decoration: BoxDecoration(
        color: SojuColors.demoSoft,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: SojuColors.demoBorder),
      ),
      child: Text(
        'Lengkapi field yang belum diisi. Total item dan rincian pembayaran '
        'harus sama dengan total pemasukan.',
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.scale, required this.text});

  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * scale),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 10 * scale,
          fontWeight: FontWeight.w700,
          color: SojuColors.analyticsLabel,
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.sizeOf(context).width / 430;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontFamily: AppTypography.family,
        fontSize: 12 * scale,
        color: SojuColors.notificationTitle,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: SojuColors.surfaceMuted,
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 11 * scale,
          color: SojuColors.analyticsMuted,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 11 * scale,
          vertical: 11 * scale,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10 * scale),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.scale,
    required this.title,
    required this.actionLabel,
    required this.actionKey,
    required this.onAction,
  });

  final double scale;
  final String title;
  final String actionLabel;
  final Key actionKey;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8 * scale,
      runSpacing: 4 * scale,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTypography.family,
            fontSize: 11 * scale,
            fontWeight: FontWeight.w800,
            color: SojuColors.notificationTitle,
          ),
        ),
        TextButton.icon(
          key: actionKey,
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: SojuColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: 6 * scale,
              vertical: 4 * scale,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(Icons.add, size: 14 * scale),
          label: Text(
            actionLabel,
            style: TextStyle(
              fontFamily: AppTypography.family,
              fontSize: 9.5 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemEditor extends StatelessWidget {
  const _ItemEditor({
    required this.scale,
    required this.index,
    required this.fields,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  final double scale;
  final int index;
  final _ItemFields fields;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: SojuColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Produk ${index + 1}',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.analyticsLabel,
                ),
              ),
              const Spacer(),
              if (canRemove)
                Semantics(
                  button: true,
                  label: 'Hapus produk ${index + 1}',
                  child: IconButton(
                    key: Key('draft_editor_item_${index}_remove'),
                    onPressed: onRemove,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 28 * scale,
                      minHeight: 28 * scale,
                    ),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16 * scale,
                      color: SojuColors.expense,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 5 * scale),
          _LabeledField(
            scale: scale,
            label: 'Nama produk',
            child: _TextField(
              key: Key('draft_editor_item_${index}_name'),
              controller: fields.name,
              hint: 'Nama produk',
            ),
          ),
          SizedBox(height: 7 * scale),
          Row(
            children: <Widget>[
              Expanded(
                child: _LabeledField(
                  scale: scale,
                  label: 'Jumlah',
                  child: _TextField(
                    key: Key('draft_editor_item_${index}_quantity'),
                    controller: fields.quantity,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ),
              SizedBox(width: 7 * scale),
              Expanded(
                child: _LabeledField(
                  scale: scale,
                  label: 'Satuan',
                  child: _TextField(
                    key: Key('draft_editor_item_${index}_unit'),
                    controller: fields.unit,
                    hint: 'porsi',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 7 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: _LabeledField(
                  scale: scale,
                  label: 'Harga satuan',
                  child: _TextField(
                    key: Key('draft_editor_item_${index}_price'),
                    controller: fields.price,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ),
              SizedBox(width: 7 * scale),
              Expanded(
                child: _LabeledField(
                  scale: scale,
                  label: 'Metode',
                  child: _PaymentDropdown(
                    key: Key('draft_editor_item_${index}_method'),
                    scale: scale,
                    value: fields.method,
                    onChanged: (SalesPaymentMethod? method) {
                      fields.method = method;
                      onChanged();
                    },
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

class _PaymentEditor extends StatelessWidget {
  const _PaymentEditor({
    required this.scale,
    required this.index,
    required this.fields,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  final double scale;
  final int index;
  final _PaymentFields fields;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: SojuColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _LabeledField(
              scale: scale,
              label: 'Metode',
              child: _PaymentDropdown(
                key: Key('draft_editor_payment_${index}_method'),
                scale: scale,
                value: fields.method,
                onChanged: (SalesPaymentMethod? method) {
                  fields.method = method;
                  onChanged();
                },
              ),
            ),
          ),
          SizedBox(width: 7 * scale),
          Expanded(
            flex: 4,
            child: _LabeledField(
              scale: scale,
              label: 'Nominal',
              child: _TextField(
                key: Key('draft_editor_payment_${index}_amount'),
                controller: fields.amount,
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
          if (canRemove)
            Padding(
              padding: EdgeInsets.only(left: 4 * scale),
              child: IconButton(
                key: Key('draft_editor_payment_${index}_remove'),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 28 * scale,
                  minHeight: 28 * scale,
                ),
                icon: Icon(
                  Icons.delete_outline,
                  size: 16 * scale,
                  color: SojuColors.expense,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.scale,
    required this.label,
    required this.child,
  });

  final double scale;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FieldLabel(scale: scale, text: label),
        child,
      ],
    );
  }
}

class _PaymentDropdown extends StatelessWidget {
  const _PaymentDropdown({
    super.key,
    required this.scale,
    required this.value,
    required this.onChanged,
  });

  final double scale;
  final SalesPaymentMethod? value;
  final ValueChanged<SalesPaymentMethod?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SalesPaymentMethod>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: SojuColors.surfaceMuted,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 9 * scale,
          vertical: 9 * scale,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10 * scale),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text(
        'Pilih',
        style: TextStyle(
          fontFamily: AppTypography.family,
          fontSize: 11 * scale,
          color: SojuColors.analyticsMuted,
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        size: 17 * scale,
        color: SojuColors.analyticsLabel,
      ),
      style: TextStyle(
        fontFamily: AppTypography.family,
        fontSize: 11 * scale,
        color: SojuColors.notificationTitle,
      ),
      items: <DropdownMenuItem<SalesPaymentMethod>>[
        for (final SalesPaymentMethod method in SalesPaymentMethod.values)
          DropdownMenuItem<SalesPaymentMethod>(
            value: method,
            child: Text(method.label),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _SheetFooter extends StatelessWidget {
  const _SheetFooter({
    required this.scale,
    required this.onCancel,
    required this.onSave,
  });

  final double scale;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16 * scale,
          10 * scale,
          16 * scale,
          10 * scale,
        ),
        decoration: const BoxDecoration(
          color: SojuColors.surface,
          border: Border(
            top: BorderSide(color: SojuColors.hairline, width: 0.8),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                key: const Key('draft_editor_cancel'),
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SojuColors.analyticsLabel,
                  side: const BorderSide(color: SojuColors.hairline),
                  minimumSize: Size(0, 40 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                ),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              flex: 2,
              child: FilledButton(
                key: const Key('draft_editor_save'),
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: SojuColors.primary,
                  foregroundColor: SojuColors.surface,
                  minimumSize: Size(0, 40 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                ),
                child: Text(
                  'Simpan koreksi',
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
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
