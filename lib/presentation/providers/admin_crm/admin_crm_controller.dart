// lib/presentation/providers/admin_crm/admin_crm_controller.dart
//
// Controller Pelanggan & Kampanye CRM (`SUPER_ADMIN`).

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/entities/admin_crm_entity.dart';
import '../../../domain/usecases/admin_crm_usecases.dart';

enum AdminCrmTab { customers, campaigns }

class AdminCrmState {
  const AdminCrmState({
    this.activeTab = AdminCrmTab.customers,
    this.isLoading = false,
    this.isSubmitting = false,
    this.summary = const AdminCustomerSummary(),
    this.customers = const <AdminCustomerItem>[],
    this.campaigns = const <CrmCampaignItem>[],
    this.searchQuery = '',
    this.statusFilter = 'semua',
    this.errorMessage,
  });

  final AdminCrmTab activeTab;
  final bool isLoading;
  final bool isSubmitting;
  final AdminCustomerSummary summary;
  final List<AdminCustomerItem> customers;
  final List<CrmCampaignItem> campaigns;
  final String searchQuery;
  final String statusFilter;
  final String? errorMessage;

  AdminCrmState copyWith({
    AdminCrmTab? activeTab,
    bool? isLoading,
    bool? isSubmitting,
    AdminCustomerSummary? summary,
    List<AdminCustomerItem>? customers,
    List<CrmCampaignItem>? campaigns,
    String? searchQuery,
    String? statusFilter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminCrmState(
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      summary: summary ?? this.summary,
      customers: customers ?? this.customers,
      campaigns: campaigns ?? this.campaigns,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AdminCrmController extends ChangeNotifier {
  AdminCrmController({
    required GetAdminCustomerSummary getCustomerSummary,
    required GetAdminCustomers getCustomers,
    required UpdateAdminCustomerStatus updateCustomerStatus,
    required GetCrmCampaigns getCampaigns,
    required PreviewCrmCampaignTarget previewCampaignTarget,
    required SaveCrmCampaign saveCampaign,
    required DeleteCrmCampaign deleteCampaign,
  })  : _getCustomerSummary = getCustomerSummary,
        _getCustomers = getCustomers,
        _updateCustomerStatus = updateCustomerStatus,
        _getCampaigns = getCampaigns,
        _previewCampaignTarget = previewCampaignTarget,
        _saveCampaign = saveCampaign,
        _deleteCampaign = deleteCampaign;

  final GetAdminCustomerSummary _getCustomerSummary;
  final GetAdminCustomers _getCustomers;
  final UpdateAdminCustomerStatus _updateCustomerStatus;
  final GetCrmCampaigns _getCampaigns;
  final PreviewCrmCampaignTarget _previewCampaignTarget;
  final SaveCrmCampaign _saveCampaign;
  final DeleteCrmCampaign _deleteCampaign;

  AdminCrmState _state = const AdminCrmState(isLoading: true);
  AdminCrmState get state => _state;

  void selectTab(AdminCrmTab tab) {
    if (_state.activeTab == tab) return;
    _state = _state.copyWith(activeTab: tab, clearError: true);
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  Future<void> loadAll({String? query, String? status}) async {
    final String q = query ?? _state.searchQuery;
    final String st = status ?? _state.statusFilter;
    _state = _state.copyWith(
      isLoading: true,
      searchQuery: q,
      statusFilter: st,
      clearError: true,
    );
    notifyListeners();

    final Future<Result<AdminCustomerSummary>> sumFuture =
        _getCustomerSummary();
    final Future<Result<List<AdminCustomerItem>>> custFuture = _getCustomers(
      query: q.isEmpty ? null : q,
      status: st,
    );
    final Future<Result<List<CrmCampaignItem>>> campFuture = _getCampaigns();

    final Result<AdminCustomerSummary> sumRes = await sumFuture;
    final Result<List<AdminCustomerItem>> custRes = await custFuture;
    final Result<List<CrmCampaignItem>> campRes = await campFuture;

    String? err;
    AdminCustomerSummary nextSummary = _state.summary;
    List<AdminCustomerItem> nextCustomers = _state.customers;
    List<CrmCampaignItem> nextCampaigns = _state.campaigns;

    sumRes.fold(
      onFailure: (AppFailure f) => err = f.message,
      onSuccess: (AdminCustomerSummary s) => nextSummary = s,
    );
    custRes.fold(
      onFailure: (AppFailure f) => err ??= f.message,
      onSuccess: (List<AdminCustomerItem> c) => nextCustomers = c,
    );
    campRes.fold(
      onFailure: (AppFailure f) => err ??= f.message,
      onSuccess: (List<CrmCampaignItem> c) => nextCampaigns = c,
    );

    _state = _state.copyWith(
      isLoading: false,
      summary: nextSummary,
      customers: nextCustomers,
      campaigns: nextCampaigns,
      errorMessage: err,
    );
    notifyListeners();
  }

  Future<bool> toggleCustomerStatus({
    required AdminCustomerItem customer,
    required bool isActive,
  }) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    final Result<AdminCustomerItem> res = await _updateCustomerStatus(
      id: customer.id,
      isActive: isActive,
    );
    bool ok = false;
    res.fold(
      onFailure: (AppFailure f) {
        _state = _state.copyWith(isSubmitting: false, errorMessage: f.message);
      },
      onSuccess: (AdminCustomerItem updated) {
        ok = true;
        final List<AdminCustomerItem> list = _state.customers
            .map(
              (AdminCustomerItem c) => c.id == customer.id
                  ? AdminCustomerItem(
                      id: c.id,
                      name: updated.name.isNotEmpty ? updated.name : c.name,
                      email: updated.email.isNotEmpty ? updated.email : c.email,
                      phone: c.phone,
                      isActive: updated.isActive,
                      promoOptIn: c.promoOptIn,
                      orderCount: c.orderCount,
                    )
                  : c,
            )
            .toList(growable: false);
        _state = _state.copyWith(isSubmitting: false, customers: list);
      },
    );
    notifyListeners();
    if (ok) {
      final Result<AdminCustomerSummary> sumRes = await _getCustomerSummary();
      sumRes.fold(
        onFailure: (_) {},
        onSuccess: (AdminCustomerSummary s) {
          _state = _state.copyWith(summary: s);
          notifyListeners();
        },
      );
    }
    return ok;
  }

  Future<int?> previewTarget({
    required CrmCampaignSegment segment,
    int? inactiveDays,
  }) async {
    final Result<int> res = await _previewCampaignTarget(
      segment: segment,
      inactiveDays: inactiveDays,
    );
    int? count;
    res.fold(
      onFailure: (AppFailure f) {
        _state = _state.copyWith(errorMessage: f.message);
        notifyListeners();
      },
      onSuccess: (int total) => count = total,
    );
    return count;
  }

  Future<bool> saveCampaign({
    required CrmCampaignDraft draft,
    int? existingId,
  }) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    final Result<CrmCampaignItem> res = await _saveCampaign(
      draft: draft,
      existingId: existingId,
    );
    bool ok = false;
    res.fold(
      onFailure: (AppFailure f) {
        _state = _state.copyWith(isSubmitting: false, errorMessage: f.message);
      },
      onSuccess: (CrmCampaignItem saved) {
        ok = true;
        final List<CrmCampaignItem> list = List<CrmCampaignItem>.of(
          _state.campaigns,
        );
        final int idx = list.indexWhere(
          (CrmCampaignItem c) => c.id == saved.id,
        );
        if (idx >= 0) {
          list[idx] = saved;
        } else {
          list.insert(0, saved);
        }
        _state = _state.copyWith(isSubmitting: false, campaigns: list);
      },
    );
    notifyListeners();
    return ok;
  }

  Future<bool> deleteCampaign(int id) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    final Result<void> res = await _deleteCampaign(id: id);
    bool ok = false;
    res.fold(
      onFailure: (AppFailure f) {
        _state = _state.copyWith(isSubmitting: false, errorMessage: f.message);
      },
      onSuccess: (_) {
        ok = true;
        _state = _state.copyWith(
          isSubmitting: false,
          campaigns: _state.campaigns
              .where((CrmCampaignItem c) => c.id != id)
              .toList(growable: false),
        );
      },
    );
    notifyListeners();
    return ok;
  }
}
