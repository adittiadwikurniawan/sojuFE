// lib/presentation/widgets/quick_manual_entry_sheet.dart
//
// Bottom sheet pencatatan buku kas mandiri dari tombol (+) tengah navbar:
// 1. Pemasukan (Uang Masuk) dengan kategori starter + bebas tambah kategori sendiri
// 2. Pengeluaran (Uang Keluar) dengan kategori starter + bebas tambah kategori sendiri
// 3. Pendataan Bebas (pindah ke Tab Pendataan Operasional)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/app_routes.dart';
import '../../core/themes/app_typography.dart';
import '../../core/themes/soju_colors.dart';

enum ManualEntryType {
  pemasukan(
    label: 'Pemasukan',
    subtitle: 'Uang masuk / hasil jualan',
    color: SojuColors.brandEmerald,
    bgSoft: Color(0xFFECFDF5),
    icon: Icons.arrow_downward_rounded,
  ),
  pengeluaran(
    label: 'Pengeluaran',
    subtitle: 'Belanja bahan / biaya usaha',
    color: Color(0xFFEF4444),
    bgSoft: Color(0xFFFEF2F2),
    icon: Icons.arrow_upward_rounded,
  ),
  pendataan(
    label: 'Pendataan',
    subtitle: 'Tabel catatan bebas',
    color: SojuColors.brandNavy,
    bgSoft: SojuColors.blueSoft,
    icon: Icons.table_chart_rounded,
  );

  const ManualEntryType({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgSoft,
    required this.icon,
  });

  final String label;
  final String subtitle;
  final Color color;
  final Color bgSoft;
  final IconData icon;
}

/// Menampilkan sheet Quick Manual Entry dari tombol (+) navbar tengah.
Future<void> showQuickManualEntrySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x660F172A),
    builder: (BuildContext ctx) => const QuickManualEntrySheet(),
  );
}

class QuickManualEntrySheet extends StatefulWidget {
  const QuickManualEntrySheet({super.key});

  @override
  State<QuickManualEntrySheet> createState() => _QuickManualEntrySheetState();
}

class _QuickManualEntrySheetState extends State<QuickManualEntrySheet> {
  ManualEntryType _selectedType = ManualEntryType.pemasukan;
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _customCategoryCtrl = TextEditingController();

  bool _isAddingCategory = false;
  String _selectedCategory = 'Penjualan';
  String _selectedPaymentMethod = 'Tunai (Cash)';
  String? _amountError;

  final List<String> _pemasukanCategories = <String>[
    'Penjualan',
    'Modal',
    'Lainnya',
  ];

  final List<String> _pengeluaranCategories = <String>[
    'Bahan Baku',
    'Kemasan',
    'Operasional',
    'Lainnya',
  ];

  final List<String> _paymentMethods = <String>[
    'Tunai (Cash)',
    'QRIS Midtrans',
    'Transfer Bank',
  ];

  List<String> get _activeCategories =>
      _selectedType == ManualEntryType.pemasukan
          ? _pemasukanCategories
          : _pengeluaranCategories;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _customCategoryCtrl.dispose();
    super.dispose();
  }

  void _onTypeChanged(ManualEntryType type) {
    setState(() {
      _selectedType = type;
      _amountError = null;
      _isAddingCategory = false;
      _customCategoryCtrl.clear();
      if (type == ManualEntryType.pemasukan) {
        _selectedCategory = _pemasukanCategories.first;
      } else if (type == ManualEntryType.pengeluaran) {
        _selectedCategory = _pengeluaranCategories.first;
      }
    });
  }

  void _addCustomCategory() {
    final String name = _customCategoryCtrl.text.trim();
    if (name.isEmpty) {
      return;
    }
    setState(() {
      if (!_activeCategories.contains(name)) {
        _activeCategories.insert(0, name);
      }
      _selectedCategory = name;
      _customCategoryCtrl.clear();
      _isAddingCategory = false;
    });
  }

  void _submitTransaction() {
    final String cleanAmount =
        _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final int amount = int.tryParse(cleanAmount) ?? 0;

    if (amount <= 0) {
      setState(() {
        _amountError = 'Nominal harus lebih besar dari Rp 0';
      });
      return;
    }

    final String typeLabel = _selectedType.label;
    final String category = _selectedCategory;
    final String note = _noteCtrl.text.trim();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: SojuColors.brandNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _selectedType.color,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Berhasil Catat $typeLabel',
                    style: const TextStyle(
                      fontFamily: AppTypography.family,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Rp ${_formatNumber(amount)} • $category${note.isNotEmpty ? ' ($note)' : ''}',
                    style: const TextStyle(
                      fontFamily: AppTypography.family,
                      color: Color(0xFFCBD5E1),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: SojuColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: SojuColors.cardBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Title
            Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        SojuColors.brandNavy,
                        SojuColors.brandEmerald,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Catat Data Manual',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: SojuColors.ink,
                        ),
                      ),
                      Text(
                        'Catat uang masuk, uang keluar, atau pendataan bebas',
                        style: TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 12,
                          color: SojuColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: SojuColors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Segmented 3 Pilihan: Pemasukan | Pengeluaran | Pendataan
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: SojuColors.homeBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SojuColors.cardBorder),
              ),
              child: Row(
                children: ManualEntryType.values.map((ManualEntryType type) {
                  final bool isSelected = _selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onTypeChanged(type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? type.color : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: type.color.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                type.icon,
                                size: 15,
                                color: isSelected
                                    ? Colors.white
                                    : SojuColors.inkMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                type.label,
                                style: TextStyle(
                                  fontFamily: AppTypography.family,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : SojuColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // KONTEN SESUAI TYPE
            if (_selectedType == ManualEntryType.pendataan) ...<Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: SojuColors.blueSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: SojuColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Row(
                      children: <Widget>[
                        Icon(
                          Icons.table_chart_rounded,
                          color: SojuColors.brandNavy,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tabel Bebas & Pendataan',
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: SojuColors.brandNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Buat catatan tabel bebas sesuai kebutuhan usahamu (stok bahan, daftar belanja, catatan harian) langsung di tab Pendataan.',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12.5,
                        height: 1.4,
                        color: SojuColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go(AppRoutes.analytics);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: SojuColors.brandNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Buka Layar Pendataan'),
                    ),
                  ],
                ),
              ),
            ] else ...<Widget>[
              // Form Input Nominal
              const Text(
                'Nominal (Rp)',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                key: const Key('manual_entry_amount_field'),
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SojuColors.ink,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp  ',
                  prefixStyle: TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _selectedType.color,
                  ),
                  hintText: '0',
                  hintStyle: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 22,
                    color: SojuColors.hint,
                  ),
                  filled: true,
                  fillColor: SojuColors.homeBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: SojuColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: SojuColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _selectedType.color, width: 2),
                  ),
                  errorText: _amountError,
                ),
                onChanged: (_) {
                  if (_amountError != null) {
                    setState(() => _amountError = null);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Kategori Transaksi (Starter + Bebas Tambah Sendiri)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Kategori ${_selectedType.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: SojuColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    key: const Key('manual_entry_add_category_toggle'),
                    onTap: () {
                      setState(() => _isAddingCategory = !_isAddingCategory);
                    },
                    child: Text(
                      _isAddingCategory ? 'Batal' : '+ Kategori',
                      style: TextStyle(
                        fontFamily: AppTypography.family,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _selectedType.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Input Inline Tambah Kategori Bebas
              if (_isAddingCategory) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        key: const Key('manual_entry_custom_category_field'),
                        controller: _customCategoryCtrl,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addCustomCategory(),
                        style: const TextStyle(
                          fontFamily: AppTypography.family,
                          fontSize: 13,
                          color: SojuColors.ink,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tulis kategori baru (mis. Beli Saus)...',
                          hintStyle: const TextStyle(
                            fontFamily: AppTypography.family,
                            fontSize: 12,
                            color: SojuColors.hint,
                          ),
                          filled: true,
                          fillColor: SojuColors.homeBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: SojuColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: SojuColors.cardBorder),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      key: const Key('manual_entry_save_category_button'),
                      onPressed: _addCustomCategory,
                      style: FilledButton.styleFrom(
                        backgroundColor: _selectedType.color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(52, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Pakai'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _activeCategories.map((String cat) {
                  final bool isCatSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isCatSelected,
                    selectedColor: _selectedType.bgSoft,
                    backgroundColor: SojuColors.homeBackground,
                    labelStyle: TextStyle(
                      fontFamily: AppTypography.family,
                      fontSize: 12,
                      fontWeight:
                          isCatSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isCatSelected
                          ? _selectedType.color
                          : SojuColors.inkMuted,
                    ),
                    side: BorderSide(
                      color: isCatSelected
                          ? _selectedType.color
                          : SojuColors.cardBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Pilihan Metode Pembayaran
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _paymentMethods.map((String method) {
                  final bool isMethodSelected = _selectedPaymentMethod == method;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _selectedPaymentMethod = method);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          backgroundColor: isMethodSelected
                              ? SojuColors.blueSoft
                              : SojuColors.homeBackground,
                          side: BorderSide(
                            color: isMethodSelected
                                ? SojuColors.brandNavy
                                : SojuColors.cardBorder,
                            width: isMethodSelected ? 1.5 : 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            method,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.family,
                              fontSize: 11,
                              fontWeight: isMethodSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isMethodSelected
                                  ? SojuColors.brandNavy
                                  : SojuColors.inkMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Keterangan / Catatan Opsional
              const Text(
                'Catatan / Keterangan (Opsional)',
                style: TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: SojuColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _noteCtrl,
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                  fontFamily: AppTypography.family,
                  fontSize: 13,
                  color: SojuColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Contoh: Beli es batu 1 bal atau jual 5 porsi',
                  hintStyle: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 12.5,
                    color: SojuColors.hint,
                  ),
                  filled: true,
                  fillColor: SojuColors.homeBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SojuColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SojuColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: SojuColors.brandNavy,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Tombol Submit Simpan Transaksi
              FilledButton(
                key: const Key('manual_entry_submit_button'),
                onPressed: _submitTransaction,
                style: FilledButton.styleFrom(
                  backgroundColor: _selectedType.color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Simpan ${_selectedType.label}',
                  style: const TextStyle(
                    fontFamily: AppTypography.family,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
