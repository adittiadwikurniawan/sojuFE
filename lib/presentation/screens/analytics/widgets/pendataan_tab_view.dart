import 'package:flutter/material.dart';

import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/soju_colors.dart';

enum PendataanColumnType {
  teks('TEKS', 'Teks'),
  angka('ANGKA', 'Angka'),
  tanggal('TANGGAL', 'Tanggal'),
  dropdown('DROPDOWN', 'Dropdown');

  const PendataanColumnType(this.code, this.label);
  final String code;
  final String label;
}

class PendataanColumnDef {
  const PendataanColumnDef({
    required this.name,
    required this.type,
    this.options = const <String>[],
  });

  final String name;
  final PendataanColumnType type;
  final List<String> options;
}

class PendataanTableDef {
  PendataanTableDef({
    required this.id,
    required this.name,
    required this.description,
    required this.columns,
    List<Map<String, String>>? rows,
  }) : rows = rows ?? <Map<String, String>>[];

  final String id;
  final String name;
  final String description;
  final List<PendataanColumnDef> columns;
  final List<Map<String, String>> rows;
}

/// Tab **Pendataan** — seluruh form (Buat Tabel & Tambah/Edit Baris) tampil
/// langsung sebagai **Card inline di tengah halaman** (tanpa popup/bottom sheet).
class PendataanTabView extends StatefulWidget {
  const PendataanTabView({
    super.key,
    required this.scale,
  });

  final double scale;

  @override
  State<PendataanTabView> createState() => _PendataanTabViewState();
}

class _PendataanTabViewState extends State<PendataanTabView> {
  final List<PendataanTableDef> _tables = <PendataanTableDef>[];
  String? _activeTableId;

  // State form inline: Buat Tabel Baru
  bool _isCreatingTable = false;
  final TextEditingController _tableNameCtrl = TextEditingController();
  final TextEditingController _tableDescCtrl = TextEditingController();
  final TextEditingController _colNameCtrl = TextEditingController();
  final TextEditingController _dropdownOptsCtrl = TextEditingController();
  PendataanColumnType _selectedColType = PendataanColumnType.teks;
  List<PendataanColumnDef> _draftColumns = <PendataanColumnDef>[
    const PendataanColumnDef(name: 'Nama Item', type: PendataanColumnType.teks),
    const PendataanColumnDef(name: 'Jumlah', type: PendataanColumnType.angka),
  ];
  String? _tableFormError;
  String? _tableNameError;
  String? _colNameError;
  String? _dropdownOptsError;

  // State form inline: Tambah / Edit Baris
  bool _isEditingRow = false;
  int? _editingRowIndex;
  String? _rowFormError;
  final Map<String, String> _rowFieldErrors = <String, String>{};
  final Map<String, TextEditingController> _rowCtrls =
      <String, TextEditingController>{};

  PendataanTableDef? get _activeTable {
    if (_tables.isEmpty) return null;
    return _tables.firstWhere(
      (PendataanTableDef t) => t.id == _activeTableId,
      orElse: () => _tables.first,
    );
  }

  @override
  void dispose() {
    _tableNameCtrl.dispose();
    _tableDescCtrl.dispose();
    _colNameCtrl.dispose();
    _dropdownOptsCtrl.dispose();
    _disposeRowControllers();
    super.dispose();
  }

  void _disposeRowControllers() {
    for (final TextEditingController c in _rowCtrls.values) {
      c.dispose();
    }
    _rowCtrls.clear();
  }

  void _startCreateTable() {
    setState(() {
      _isCreatingTable = true;
      _isEditingRow = false;
      _tableNameCtrl.clear();
      _tableDescCtrl.clear();
      _colNameCtrl.clear();
      _dropdownOptsCtrl.clear();
      _selectedColType = PendataanColumnType.teks;
      _draftColumns = <PendataanColumnDef>[
        const PendataanColumnDef(
          name: 'Nama Item',
          type: PendataanColumnType.teks,
        ),
        const PendataanColumnDef(
          name: 'Jumlah',
          type: PendataanColumnType.angka,
        ),
      ];
      _tableFormError = null;
      _tableNameError = null;
      _colNameError = null;
      _dropdownOptsError = null;
    });
  }

  void _addDraftColumn() {
    final String cName = _colNameCtrl.text.trim();
    if (cName.isEmpty) {
      setState(() {
        _colNameError = 'Nama kolom wajib diisi sebelum menambah kolom.';
        _tableFormError = 'Lengkapi nama kolom terlebih dahulu.';
      });
      return;
    }

    final bool isDuplicate = _draftColumns.any(
      (PendataanColumnDef c) => c.name.toLowerCase() == cName.toLowerCase(),
    );
    if (isDuplicate) {
      setState(() {
        _colNameError = 'Kolom "$cName" sudah ada di tabel ini.';
        _tableFormError = 'Nama kolom tidak boleh sama.';
      });
      return;
    }

    List<String> opts = const <String>[];
    if (_selectedColType == PendataanColumnType.dropdown) {
      opts = _dropdownOptsCtrl.text
          .split(',')
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .toSet()
          .toList();
      if (opts.length < 2) {
        setState(() {
          _colNameError = null;
          _dropdownOptsError =
              'Dropdown butuh minimal 2 opsi dipisah koma (contoh: Tersedia, Habis).';
          _tableFormError = 'Lengkapi opsi dropdown minimal 2 pilihan.';
        });
        return;
      }
    }

    setState(() {
      _draftColumns.add(
        PendataanColumnDef(
          name: cName,
          type: _selectedColType,
          options: opts,
        ),
      );
      _colNameCtrl.clear();
      _dropdownOptsCtrl.clear();
      _colNameError = null;
      _dropdownOptsError = null;
      _tableFormError = null;
    });
  }

  void _saveTable() {
    final String tName = _tableNameCtrl.text.trim();
    if (tName.isEmpty) {
      setState(() {
        _tableNameError = 'Nama tabel wajib diisi.';
        _tableFormError = 'Periksa kolom yang ditandai merah di bawah.';
      });
      return;
    }
    if (tName.length < 2) {
      setState(() {
        _tableNameError = 'Nama tabel minimal 2 karakter.';
        _tableFormError = 'Periksa kolom yang ditandai merah di bawah.';
      });
      return;
    }
    final bool duplicateTable = _tables.any(
      (PendataanTableDef t) => t.name.toLowerCase() == tName.toLowerCase(),
    );
    if (duplicateTable) {
      setState(() {
        _tableNameError = 'Tabel "$tName" sudah ada.';
        _tableFormError = 'Gunakan nama tabel yang berbeda.';
      });
      return;
    }
    if (_draftColumns.isEmpty) {
      setState(() {
        _colNameError = 'Tambahkan minimal 1 kolom terlebih dahulu.';
        _tableFormError = 'Tabel wajib memiliki minimal 1 kolom.';
      });
      return;
    }
    if (_colNameCtrl.text.trim().isNotEmpty) {
      setState(() {
        _colNameError =
            'Klik "+ Tambah Kolom" dulu untuk memasukkan "${_colNameCtrl.text.trim()}", atau kosongkan.';
        _tableFormError = 'Ada kolom baru yang belum ditambahkan.';
      });
      return;
    }

    final PendataanTableDef table = PendataanTableDef(
      id: 'tbl-${DateTime.now().millisecondsSinceEpoch}',
      name: tName,
      description: _tableDescCtrl.text.trim(),
      columns: List<PendataanColumnDef>.from(_draftColumns),
    );
    setState(() {
      _tables.add(table);
      _activeTableId = table.id;
      _isCreatingTable = false;
      _tableFormError = null;
      _tableNameError = null;
      _colNameError = null;
      _dropdownOptsError = null;
    });
  }

  void _startEditRow(PendataanTableDef table, {int? editIndex}) {
    _disposeRowControllers();
    final Map<String, String> existing = editIndex != null
        ? Map<String, String>.from(table.rows[editIndex])
        : <String, String>{};
    for (final PendataanColumnDef c in table.columns) {
      _rowCtrls[c.name] = TextEditingController(
        text: existing[c.name] ??
            (c.type == PendataanColumnType.dropdown && c.options.isNotEmpty
                ? c.options.first
                : ''),
      );
    }
    setState(() {
      _isCreatingTable = false;
      _isEditingRow = true;
      _editingRowIndex = editIndex;
      _rowFormError = null;
      _rowFieldErrors.clear();
    });
  }

  void _saveRow(PendataanTableDef table) {
    final Map<String, String> errors = <String, String>{};
    final Map<String, String> rowData = <String, String>{};
    bool hasAnyValue = false;

    for (final PendataanColumnDef c in table.columns) {
      final String val = _rowCtrls[c.name]?.text.trim() ?? '';
      rowData[c.name] = val;
      if (val.isNotEmpty) {
        hasAnyValue = true;
      }
      if (c.type == PendataanColumnType.angka && val.isNotEmpty) {
        final String clean = val.replaceAll('.', '').replaceAll(',', '');
        if (num.tryParse(clean) == null) {
          errors[c.name] = '${c.name} harus berupa angka yang valid.';
        }
      }
      if (c.type == PendataanColumnType.tanggal && val.isNotEmpty) {
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(val)) {
          errors[c.name] = 'Format tanggal harus YYYY-MM-DD (contoh: 2026-11-28).';
        }
      }
    }

    if (!hasAnyValue) {
      setState(() {
        _rowFieldErrors.clear();
        _rowFormError = 'Isi minimal satu kolom sebelum menyimpan baris.';
      });
      return;
    }

    if (errors.isNotEmpty) {
      setState(() {
        _rowFieldErrors
          ..clear()
          ..addAll(errors);
        _rowFormError = 'Periksa isian yang ditandai merah di bawah.';
      });
      return;
    }

    setState(() {
      if (_editingRowIndex == null) {
        table.rows.insert(0, rowData);
      } else {
        table.rows[_editingRowIndex!] = rowData;
      }
      _isEditingRow = false;
      _editingRowIndex = null;
      _rowFormError = null;
      _rowFieldErrors.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.scale;

    if (_isCreatingTable) {
      return _buildCreateTableCard(scale);
    }

    if (_tables.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24 * scale),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(color: SojuColors.cardBorder),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: SojuColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.table_chart_outlined,
                  color: SojuColors.brandNavy,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Belum Ada Tabel Pendataan',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Buat tabel operasional bebas (stok bahan, jadwal piket, suhu chiller) langsung di sini tanpa popup.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12.5,
                  height: 1.4,
                  color: SojuColors.inkMuted,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('pendataan_create_table_button'),
                onPressed: _startCreateTable,
                style: FilledButton.styleFrom(
                  backgroundColor: SojuColors.brandNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Buat Tabel Pendataan'),
              ),
            ],
          ),
        ),
      );
    }

    final PendataanTableDef active = _activeTable!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tables.map((PendataanTableDef t) {
                    final bool selected = t.id == active.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${t.name} (${t.rows.length})'),
                        selected: selected,
                        selectedColor: SojuColors.blueSoft,
                        onSelected: (_) => setState(() {
                          _activeTableId = t.id;
                          _isEditingRow = false;
                        }),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: _startCreateTable,
              tooltip: 'Buat tabel baru',
              icon: const Icon(Icons.add_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isEditingRow) ...<Widget>[
          _buildInlineRowCard(active, scale),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SojuColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SojuColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          active.name,
                          style: const TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: SojuColors.ink,
                          ),
                        ),
                        if (active.description.isNotEmpty)
                          Text(
                            active.description,
                            style: const TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 12,
                              color: SojuColors.inkMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _startEditRow(active),
                    style: FilledButton.styleFrom(
                      backgroundColor: SojuColors.brandEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text(
                      'Tambah Baris',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (active.rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Belum ada data di tabel ini. Ketuk "Tambah Baris" untuk mulai mencatat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12.5,
                      color: SojuColors.inkMuted,
                    ),
                  ),
                )
              else
                ...active.rows.asMap().entries.map((entry) {
                  final int idx = entry.key;
                  final Map<String, String> row = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SojuColors.canvas,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SojuColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: active.columns.map((c) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    c.name,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: SojuColors.inkMuted,
                                    ),
                                  ),
                                  Text(
                                    (row[c.name] ?? '').isEmpty
                                        ? '-'
                                        : row[c.name]!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: SojuColors.ink,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit baris',
                          visualDensity: VisualDensity.compact,
                          onPressed: () =>
                              _startEditRow(active, editIndex: idx),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: SojuColors.brandNavy,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Hapus baris',
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            setState(() => active.rows.removeAt(idx));
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: SojuColors.brandDanger,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  /// Card inline di tengah halaman untuk membuat Tabel Pendataan baru (tanpa popup).
  Widget _buildCreateTableCard(double scale) {
    return Center(
      child: Container(
        key: const Key('pendataan_inline_create_card'),
        width: double.infinity,
        padding: EdgeInsets.all(18 * scale),
        decoration: BoxDecoration(
          color: SojuColors.surface,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: SojuColors.freeTableBlueBorder60),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0D0F172A),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Buat Tabel Pendataan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: SojuColors.brandNavy,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Batal',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _isCreatingTable = false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            if (_tableFormError != null) ...<Widget>[
              const SizedBox(height: 8),
              Container(
                key: const Key('pendataan_table_error_banner'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: SojuColors.brandDanger.withOpacity(0.35),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: SojuColors.brandDanger,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _tableFormError!,
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: SojuColors.brandDanger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              key: const Key('pendataan_table_name_field'),
              controller: _tableNameCtrl,
              onChanged: (_) {
                if (_tableNameError != null || _tableFormError != null) {
                  setState(() {
                    _tableNameError = null;
                    _tableFormError = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Nama Tabel *',
                hintText: 'Contoh: Stok Sosis Frozen, Daftar Belanja',
                errorText: _tableNameError,
                filled: true,
                fillColor: SojuColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tableDescCtrl,
              decoration: InputDecoration(
                labelText: 'Deskripsi (opsional)',
                hintText: 'Kegunaan tabel pendataan ini...',
                filled: true,
                fillColor: SojuColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Kolom Tabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: SojuColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_draftColumns.length} kolom',
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 11,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _draftColumns.asMap().entries.map((entry) {
                final int idx = entry.key;
                final PendataanColumnDef col = entry.value;
                return Chip(
                  backgroundColor: SojuColors.blueSoft,
                  side: BorderSide(
                    color: SojuColors.brandNavy.withOpacity(0.2),
                  ),
                  label: Text(
                    '${col.name} (${col.type.label})',
                    style: const TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SojuColors.brandNavy,
                    ),
                  ),
                  deleteIcon: _draftColumns.length > 1
                      ? const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: SojuColors.brandNavy,
                        )
                      : null,
                  onDeleted: _draftColumns.length > 1
                      ? () => setState(() => _draftColumns.removeAt(idx))
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: TextField(
                    key: const Key('pendataan_col_name_field'),
                    controller: _colNameCtrl,
                    onChanged: (_) {
                      if (_colNameError != null || _tableFormError != null) {
                        setState(() {
                          _colNameError = null;
                          _tableFormError = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Nama kolom baru',
                      hintText: 'Contoh: Status Stok',
                      errorText: _colNameError,
                      errorMaxLines: 2,
                      isDense: true,
                      filled: true,
                      fillColor: SojuColors.canvas,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<PendataanColumnType>(
                    value: _selectedColType,
                    isDense: true,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Tipe',
                      filled: true,
                      fillColor: SojuColors.canvas,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 11,
                      ),
                    ),
                    items: PendataanColumnType.values
                        .map(
                          (PendataanColumnType t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t.label,
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (PendataanColumnType? val) {
                      if (val != null) {
                        setState(() {
                          _selectedColType = val;
                          _dropdownOptsError = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_selectedColType == PendataanColumnType.dropdown) ...<Widget>[
              const SizedBox(height: 8),
              TextField(
                key: const Key('pendataan_dropdown_opts_field'),
                controller: _dropdownOptsCtrl,
                onChanged: (_) {
                  if (_dropdownOptsError != null || _tableFormError != null) {
                    setState(() {
                      _dropdownOptsError = null;
                      _tableFormError = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Pilihan Dropdown (pisahkan koma)',
                  hintText: 'Contoh: Tersedia, Menipis, Habis',
                  helperText: 'Minimal 2 pilihan dipisahkan tanda koma (,)',
                  errorText: _dropdownOptsError,
                  errorMaxLines: 2,
                  isDense: true,
                  filled: true,
                  fillColor: SojuColors.canvas,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('pendataan_add_column_button'),
                onPressed: _addDraftColumn,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('Tambah Kolom'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isCreatingTable = false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _saveTable,
                    style: FilledButton.styleFrom(
                      backgroundColor: SojuColors.brandNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan Tabel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card inline di tengah halaman untuk Tambah / Edit Baris Data (tanpa popup).
  Widget _buildInlineRowCard(PendataanTableDef table, double scale) {
    return Container(
      key: const Key('pendataan_inline_row_card'),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: SojuColors.brandEmerald.withOpacity(0.45)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _editingRowIndex == null
                    ? 'Tambah Baris Data'
                    : 'Edit Baris Data',
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: SojuColors.brandNavy,
                ),
              ),
              IconButton(
                tooltip: 'Tutup form',
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() {
                  _isEditingRow = false;
                  _editingRowIndex = null;
                }),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          if (_rowFormError != null) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: SojuColors.brandDanger.withOpacity(0.35),
                ),
              ),
              child: Text(
                _rowFormError!,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.brandDanger,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          for (final PendataanColumnDef c in table.columns) ...<Widget>[
            if (c.type == PendataanColumnType.dropdown && c.options.isNotEmpty)
              DropdownButtonFormField<String>(
                value: c.options.contains(_rowCtrls[c.name]?.text)
                    ? _rowCtrls[c.name]!.text
                    : c.options.first,
                decoration: InputDecoration(
                  labelText: c.name,
                  filled: true,
                  fillColor: SojuColors.canvas,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: c.options
                    .map(
                      (String opt) => DropdownMenuItem<String>(
                        value: opt,
                        child: Text(opt),
                      ),
                    )
                    .toList(),
                onChanged: (String? v) {
                  if (v != null && _rowCtrls[c.name] != null) {
                    setState(() {
                      _rowCtrls[c.name]!.text = v;
                      _rowFormError = null;
                    });
                  }
                },
              )
            else
              TextField(
                controller: _rowCtrls[c.name],
                keyboardType: c.type == PendataanColumnType.angka
                    ? TextInputType.number
                    : TextInputType.text,
                onChanged: (_) {
                  if (_rowFieldErrors.containsKey(c.name) ||
                      _rowFormError != null) {
                    setState(() {
                      _rowFieldErrors.remove(c.name);
                      _rowFormError = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: c.name,
                  hintText: c.type == PendataanColumnType.tanggal
                      ? 'YYYY-MM-DD (contoh: 2026-11-28)'
                      : 'Isi ${c.name.toLowerCase()}...',
                  errorText: _rowFieldErrors[c.name],
                  filled: true,
                  fillColor: SojuColors.canvas,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            const SizedBox(height: 10),
          ],
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _isEditingRow = false;
                    _editingRowIndex = null;
                  }),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => _saveRow(table),
                  style: FilledButton.styleFrom(
                    backgroundColor: SojuColors.brandEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _editingRowIndex == null ? 'Simpan Baris' : 'Perbarui Baris',
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
