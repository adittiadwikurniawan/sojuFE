// lib/presentation/screens/free_tables/free_table_category_screen.dart
//
// Modal sheet "Buat Kategori Baru" varian Tabel Bebas (`546:5163`) dan
// kategori pemasukan dari tombol `+` navbar (`546:5430`).
//
// Screen ini hanya mengorkestrasi state form dan widget reusable. Semua
// pengiriman data melewati [FreeTableCategoryController] → usecase →
// repository → datasource; widget tidak memanggil HTTP langsung.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/themes/soju_colors.dart';
import '../../providers/free_tables/free_table_category_controller.dart';
import 'widgets/cashflow_type_switcher.dart';
import 'widgets/category_name_field.dart';
import 'widgets/custom_fields_section.dart';
import 'widgets/free_table_notice_card.dart';
import 'widgets/free_table_sheet_footer.dart';
import 'widgets/free_table_sheet_header.dart';
import 'widgets/target_department_field.dart';

/// Lebar desain acuan frame `546:5163`.
const double _kFreeTableDesignWidth = 390;

/// Tinggi desain acuan modal.
const double _kFreeTableDesignHeight = 814;

/// Layar/modal form Buat Kategori Baru Tabel Bebas.
class FreeTableCategoryScreen extends StatefulWidget {
  const FreeTableCategoryScreen({
    super.key,
    required this.controllerFactory,
    this.onClose,
    this.onSaved,
    this.backgroundColor = const Color(0x990F172A),
    this.applyTopInset = true,
  });

  /// Factory controller agar screen dapat diuji dengan repository palsu.
  final FreeTableCategoryController Function() controllerFactory;

  /// Aksi tutup modal (drag handle / area scrim).
  final VoidCallback? onClose;

  /// Dipanggil setelah kategori berhasil disimpan. Popup memakainya untuk
  /// langsung menutup sheet tanpa menunggu aksi pengguna.
  final VoidCallback? onSaved;

  /// Warna scrim. Popup memakai transparan agar barrier modal yang mengatur
  /// dimming, sementara route penuh tetap memakai scrim gelap.
  final Color backgroundColor;

  /// Popup yang tidak menyentuh status bar tidak perlu inset atas tambahan.
  final bool applyTopInset;

  @override
  State<FreeTableCategoryScreen> createState() =>
      _FreeTableCategoryScreenState();
}

class _FreeTableCategoryScreenState extends State<FreeTableCategoryScreen> {
  late final FreeTableCategoryController _controller;
  late final TextEditingController _nameController;
  late final TextEditingController _departmentController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _customFieldsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
    _nameController = TextEditingController(text: _controller.state.name);
    _departmentController = TextEditingController(
      text: _controller.state.department,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _departmentController.dispose();
    _nameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await _controller.submit();
    if (!mounted) {
      return;
    }
    final FreeTableCategoryState state = _controller.state;
    if (state.isSuccess) {
      widget.onSaved?.call();
      return;
    }
    if (state.nameError != null && _scrollController.hasClients) {
      try {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      } on Object {
        // Sheet bisa ditutup saat animasi validasi masih berjalan.
      }
    } else if (state.fieldsError != null) {
      final BuildContext? fieldsContext = _customFieldsKey.currentContext;
      if (fieldsContext != null && fieldsContext.mounted) {
        try {
          await Scrollable.ensureVisible(
            fieldsContext,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: 0.05,
          );
        } on Object {
          // Sheet bisa ditutup saat animasi validasi masih berjalan.
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        top: widget.applyTopInset,
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = math.min(constraints.maxWidth, 480);
            final double scale = width / _kFreeTableDesignWidth;
            final double height = math.min(
              _kFreeTableDesignHeight * scale,
              constraints.maxHeight * 0.96,
            );

            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onClose,
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Material(
                      color: SojuColors.surface,
                      elevation: 24,
                      shadowColor: const Color(0x33000000),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32 * scale),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (BuildContext context, Widget? child) {
                          final FreeTableCategoryState state =
                              _controller.state;
                          final bool enabled = !state.isSaving;

                          return Column(
                            children: <Widget>[
                              FreeTableSheetHeader(
                                scale: scale,
                                cashflowType: state.cashflowType,
                                onClose: widget.onClose,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  padding: EdgeInsets.fromLTRB(
                                    24 * scale,
                                    8 * scale,
                                    24 * scale,
                                    24 * scale,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      CategoryNameField(
                                        scale: scale,
                                        cashflowType: state.cashflowType,
                                        controller: _nameController,
                                        enabled: enabled,
                                        errorText: state.nameError,
                                        onChanged: _controller.updateName,
                                      ),
                                      SizedBox(height: 20 * scale),
                                      CashflowTypeSwitcher(
                                        scale: scale,
                                        selected: state.cashflowType,
                                        enabled: enabled,
                                        onChanged:
                                            _controller.selectCashflowType,
                                      ),
                                      SizedBox(height: 20 * scale),
                                      TargetDepartmentField(
                                        scale: scale,
                                        cashflowType: state.cashflowType,
                                        controller: _departmentController,
                                        enabled: enabled,
                                        onChanged: _controller.updateDepartment,
                                      ),
                                      SizedBox(height: 20 * scale),
                                      CustomFieldsSection(
                                        key: _customFieldsKey,
                                        scale: scale,
                                        cashflowType: state.cashflowType,
                                        fields: state.fields,
                                        selectedFieldType:
                                            state.selectedFieldType,
                                        fieldsError: state.fieldsError,
                                        enabled: enabled,
                                        onAddField: _controller.addField,
                                        onRemoveField: _controller.removeField,
                                        onSelectFieldType:
                                            _controller.selectFieldType,
                                      ),
                                      SizedBox(height: 20 * scale),
                                      FreeTableNoticeCard(scale: scale),
                                    ],
                                  ),
                                ),
                              ),
                              FreeTableSheetFooter(
                                scale: scale,
                                cashflowType: state.cashflowType,
                                bottomInset: bottomInset,
                                status: state.status,
                                errorMessage: state.errorMessage,
                                onSave: _submit,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
