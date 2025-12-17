import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor.dart';
import 'package:wcas_frontend/models/request/remarks/guarantor_financials/income_statement_analysis.dart';
import 'package:wcas_frontend/models/request/remarks/guarantor_financials/balance_sheet_analysis.dart';
import 'package:wcas_frontend/repositories/remarks_repository.dart';
import 'state.dart';

/// ViewModel for managing guarantor financial remarks, tables, and searches.
class GuarantorFinancialViewModel extends Cubit<GuarantorFinancialState> {
  /// Initializes the ViewModel in a loading state.
  GuarantorFinancialViewModel()
      : super(
          GuarantorFinancialState(
            loaderStatus: LoadingStatus.loaded,
            guarantors: [
              Guarantor(
                entityId: 0,
                name: '',
                analysisHtml: '',
                spreadsmartUrl: '',
                canDelete: false,
              ),
            ],
          ),
        );

  /// Repository for fetching and persisting financial analysis data.
  RemarksRepository? repository;

  /// HTML editor controller used in the formatted text area.
  final HtmlEditorController controller = HtmlEditorController();

  /// Primary form key for validating and saving the main add‐guarantor tables.
  final GlobalKey<FormState> primaryFormKey = GlobalKey<FormState>();

  /// Secondary form key for validating and saving the add‐guarantor section.
  final GlobalKey<FormState> secondaryFormKey = GlobalKey<FormState>();

  /// Currently selected customer from the dropdown.
  Customer? selectedCustomer = Globals.request!.customers!.first;

  /// List of all available customers from the global request.
  List<Customer> get customers => Globals.request?.customers ?? [];

  /// Guard against overlapping calls when changing the customer selection.
  bool isChangingCustomer = false;
  bool hasCreditLensData = false;

  /// Data rows for the Income Statement analysis table.
  final List<IncomeStatement> incomeStatementRows = [];

  /// Data rows for the Balance Sheet analysis table.
  final List<BalanceSheet> balanceSheetRows = [];

  /// True if any Income Statement row is newly added and should show actions.
  bool get hasIncomeNewRows => incomeStatementRows.any((r) => r.isNew);

  /// True if any Balance Sheet row is newly added and should show actions.
  bool get hasBalanceNewRows => balanceSheetRows.any((r) => r.isNew);

  /// Selected health indicators for the Balance Sheet table.
  String unavailableText =
      "remarks.financialRatiosAnalysis.dataNotAvailable".tr();

  /// Dropdown options for Balance Sheet health status.
  List<Reference> balanceSheetHealth = [
    Reference(name: "Deteriorating"),
    Reference(name: "Stable"),
    Reference(name: "Improving")
  ];

  Reference? selectedBalanceSheetHealth = Reference(name: 'Select');

  List<RemarksTabs> showAsteriskTabs = [];

  /// Called from the view's `initState()`. Fetches repository instance
  /// and pre‐loads both Income Statement and Balance Sheet defaults.
  void init(context) async {
    logger.i('initialising GuarantorFinancialViewModel');
    showAsteriskTabs = Utils.getMandatoryRemarksTabs(selectedCustomer!);
    repository = RemarksRepository.instance;
    incomeStatementAnalysisRows();
  }

  /// Clears and adds a fixed set of default Income Statement rows,
  /// then emits the loaded state.
  void incomeStatementAnalysisRows() {
    final random = Random();

    incomeStatementRows
      ..clear()
      ..addAll([
        IncomeStatement(
          id: '1',
          incomePositions: 'Revenue',
          audited1: '${random.nextInt(10000)}',
          audited2: unavailableText,
          audited3: '${random.nextInt(10000)}',
          inhouse: '${random.nextInt(10000)}',
          estimated: unavailableText,
        ),
        IncomeStatement(
          id: '2',
          incomePositions: 'EBITDA (recurring only)',
          audited1: unavailableText,
          audited2: '${random.nextInt(10000)}',
          audited3: '${random.nextInt(10000)}',
          inhouse: unavailableText,
          estimated: '${random.nextInt(10000)}',
        ),
        IncomeStatement(
          id: '3',
          incomePositions: 'Net Income',
          audited1: '${random.nextInt(10000)}',
          audited2: '${random.nextInt(10000)}',
          audited3: unavailableText,
          inhouse: '${random.nextInt(10000)}',
          estimated: '${random.nextInt(10000)}',
        ),
        IncomeStatement(
          id: '4',
          incomePositions: 'Total Assets',
          audited1: unavailableText,
          audited2: unavailableText,
          audited3: '${random.nextInt(10000)}',
          inhouse: '${random.nextInt(10000)}',
          estimated: unavailableText,
        ),
        IncomeStatement(
          id: '5',
          incomePositions: 'Tangible NetWorth',
          audited1: '${random.nextInt(10000)}',
          audited2: '${random.nextInt(10000)}',
          audited3: '${random.nextInt(10000)}',
          inhouse: unavailableText,
          estimated: '${random.nextInt(10000)}',
        ),
        IncomeStatement(
          id: '6',
          incomePositions: 'Cash / Bank Deposits',
          audited1: unavailableText,
          audited2: '${random.nextInt(10000)}',
          audited3: unavailableText,
          inhouse: '${random.nextInt(10000)}',
          estimated: '${random.nextInt(10000)}',
        ),
        IncomeStatement(
          id: '7',
          incomePositions: 'Total Debt',
          audited1: '${random.nextInt(10000)}',
          audited2: unavailableText,
          audited3: '${random.nextInt(10000)}',
          inhouse: unavailableText,
          estimated: unavailableText,
        ),
        IncomeStatement(
          id: '8',
          incomePositions: 'Net Debt / EBITDA',
          audited1: '${random.nextInt(10000)}',
          audited2: '${random.nextInt(10000)}',
          audited3: '${random.nextInt(10000)}',
          inhouse: '${random.nextInt(10000)}',
          estimated: '${random.nextInt(10000)}',
        ),
      ]);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Called when the user changes the selected customer.
  ///
  /// Emits a loading state, simulates a fetch, then emits loaded.
  /// Prevents duplicate rapid calls via [isChangingCustomer].
  ///select customet name from list
  Future<void> onChangeCustomer(Customer customer) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    selectedCustomer = customer;
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
    ));
  }

  /// Updates the current entity ID as the user types in the search field.
  void updateEntityId(String text) {
    final id = int.tryParse(text.trim()) ?? 0;
    emit(state.copyWith(currentEntityId: id));
  }

  /// Arms the Add‐Guarantor section, showing its search field and button.
  void onAddTap() {
    emit(state.copyWith(nextCanDelete: true));
  }

  /// Internal helper that builds and appends a dummy Guarantor entry,
  /// managing all flags in one unified flow.
  Future<void> _addDummyGuarantor({required bool extraSection}) async {
    final entityId = state.currentEntityId;
    if (entityId == null || entityId <= 0) {
      try {
        AlertManager()
            .showFailureToast('remarks.guarantorFinancials.enterEntityId'.tr());
      } catch (_) {}
      return;
    }
    emit(state.copyWith(searchButtonLoading: true));
    await Future.delayed(const Duration(milliseconds: 500));

    final newItem = Guarantor(
      entityId: entityId,
      name: '',
      analysisHtml: '''
        <h3>Financial Ratios for $entityId</h3>
        <ul>
          <li>Current Ratio: 1.5</li>
          <li>Debt/Equity: 0.8</li>
          <li>Return on Assets: 6%</li>
        </ul>
        <p><em>All metrics are within acceptable ranges.</em></p>
      ''',
      spreadsmartUrl: 'https://spreadsmart.example.com/entity/$entityId',
      canDelete: state.nextCanDelete,
    );

    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
      guarantors: [...state.guarantors, newItem],
      currentEntityId: 0,
      nextCanDelete: false,
      showExtraTab: extraSection,
      canDeleteSection: extraSection,
    ));
  }

  /// Validates the current entity ID and triggers search logic.
  ///
  /// Emits loading, shows warning if ID is empty, then re‐emits loaded.
  Future<void> searchEntity() async {
    repository ??= RemarksRepository.instance;
    final entityId = state.currentEntityId;
    if (entityId == null || entityId <= 0) {
      try {
        AlertManager()
            .showFailureToast('remarks.guarantorFinancials.enterEntityId'.tr());
      } catch (_) {}
      return;
    }
    emit(state.copyWith(buttonStatus: LoadingStatus.loading));
    try {
      hasCreditLensData = true;
      emit(state.copyWith(buttonStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.i(e.toString());
      AlertManager().showFailureToast(
          "remarks.financialRatiosAnalysis.dataNotAvailable".tr());
      hasCreditLensData = false;
      emit(state.copyWith(buttonStatus: LoadingStatus.error));
    }
  }

  /// Searches and adds a guarantor for the Add‐Guarantor section
  /// (`extraSection = true`).
  Future<void> searchOnAddGuarantor() => _addDummyGuarantor(extraSection: true);

  /// Removes the guarantor at [index] from the list and emits the new state.
  void removeGuarantor(int index) {
    if (state.guarantors.length <= 1) return; // prevent removing the last one
    final list = List<Guarantor>.from(state.guarantors)..removeAt(index);
    emit(state.copyWith(guarantors: list));
  }

  /// Launches the SpreadSmart URL externally in the default browser.
  Future<void> openSpreadsmart(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// Adds a new, editable row to the Income Statement table,
  /// marks it as new, and emits the updated state.
  void addIncomeRow() {
    if (incomeStatementRows.length >= 18) {
      AlertManager().showFailureToast(
          "remarks.financialRatiosAnalysis.addRowsError".tr());
      return;
    }
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    incomeStatementRows.add(
      IncomeStatement(id: newId, isNew: true),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes the Income Statement row matching [id] and re‐emits loaded.
  void deleteIncomeRow(String id) {
    incomeStatementRows.removeWhere((r) => r.id == id);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a new, editable row to the Balance Sheet table,
  /// marks it as new, and emits the updated state.
  void addBalanceRow() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    balanceSheetRows.add(BalanceSheet(id: newId, isNew: true));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes the Balance Sheet row matching [id] and re‐emits loaded.
  void deleteBalanceRow(String id) {
    balanceSheetRows.removeWhere((r) => r.id == id);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Validates & saves both forms (main and secondary), shows a toast,
  /// and emits loading/loaded around the save flow.
  Future<void> onSavePress(bool isContinue, BuildContext context) async {
    // if (!(primaryFormKey.currentState?.validate() ?? false)) return;
    primaryFormKey.currentState?.save();

    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      AlertManager().showSuccessToast(
        'remarks.guarantorFinancials.savedSuccessfully'.tr(),
      );
      if (isContinue) {
        navigate();
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      // handle `isContinue` if needed
    } catch (err) {
      logger.e('Error saving guarantors', error: err);
      AlertManager().showFailureToast(err.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  void collapseExtraBox() {
    emit(state.copyWith(
      showExtraTab: false,
      canDeleteSection: false,
    ));
  }

  void navigate() {
    bool isCurrentRouteFound = false;
    for (MapEntry<RemarksTabs, String> entry
        in TabConstants.remarksRoutes.entries) {
      if (isCurrentRouteFound) {
        // can move to next tab/route
        changeTab(entry.key);
        return;
      }
      if (entry.key == state.activeTab) {
        isCurrentRouteFound = true;
      }
    }
    LayoutViewModel().goToNextRoute();
  }

  void changeTab(RemarksTabs tab) async {
    router.go(TabConstants.remarksRoutes[tab]!, extra: tab);
  }
}
