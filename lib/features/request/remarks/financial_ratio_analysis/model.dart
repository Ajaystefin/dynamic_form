import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/remarks/financial_ratio_analysis/cashflow_statement_analysis.dart';
import 'package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart';
import 'package:wcas_frontend/repositories/remarks_repository.dart';
import '../../../../models/request/remarks/financial_ratio_analysis/balance_sheet_analysis.dart';
import '../../../../models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart';
import 'state.dart';

/// Cubit responsible for managing financial ratio analysis data and UI state.
///
/// Handles initialization, row population for three statements (Income,
/// Cashflow, Balance), add/delete of rows, entity search logic,
/// and customer-change events.
class FinancialRatioAnalysisViewModel
    extends Cubit<FinancialRatioAnalysisState> {
  FinancialRatioAnalysisViewModel({
    RemarksRepository? remarksRepository,
    ReferenceDataService? referenceDataService,
  })  : repository = remarksRepository,
        _referenceDataService = referenceDataService,
        super(FinancialRatioAnalysisState(
          loaderStatus: LoadingStatus.loading,
        ));

  /// Repository for fetching and persisting financial analysis data.
  RemarksRepository? repository;

  /// Service for fetching reference data.
  final ReferenceDataService? _referenceDataService;

  /// Controller for the rich‐text HTML editor.
  final HtmlEditorController controller = HtmlEditorController();

  /// Controller for the rich‐text HTML editor.
  final HtmlEditorController descTextController = HtmlEditorController();

  /// Form key for validating and saving the analysis form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Currently selected customer.
  Customer? selectedCustomer = Globals.request!.customers!.first;

  /// List of all customers from the global request object.
  List<Customer> get customers => Globals.request?.customers ?? [];

  /// Row data for the Income Statement table.
  final List<IncomeStatementAnalysisRow> incomeStatementRows = [];

  /// Row data for the Cashflow Statement table.
  final List<CashFlowSheetAnalysisRow> cashflowSheetRows = [];

  /// Row data for the Balance Sheet table.
  final List<BalanceSheetAnalysisRow> balanceSheetRows = [];

  /// Indicates whether the Income Statement table should show an action column.
  bool get hasActionColumn => incomeStatementRows.any((r) => r.isNew);

  /// Indicates whether the Cashflow Statement table shows an action column.
  bool get hasActionColumnCashflow => cashflowSheetRows.any((r) => r.isNew);

  /// Indicates whether the Balance Sheet table shows an action column.
  bool get hasActionColumnBalanceSheet => balanceSheetRows.any((r) => r.isNew);

  Reference? selectedBalanceSheetHealth = Reference(name: 'Select');

  List<Reference>? financialCategory = [];
  List<Reference>? financialRatioType = [];
  List<Reference>? financialHealth = [];

  String? longName;
  String? shortName;
  List<Statement> incomeStatements = [];
  String unavailableText =
      "remarks.financialRatiosAnalysis.dataNotAvailable".tr();
  List<IncomeStatementAnalysisRow>? incomeRows = [];

  List<BalanceSheetAnalysisRow>? balanceRows = [];
  List<CashFlowSheetAnalysisRow>? cashflowRows = [];
  bool hasCreditLensData = false;
  List<RemarksTabs> showAsteriskTabs = [];

  List<RemarksTabs> otherRemarksTabs = [
    RemarksTabs.feeStructure,
    RemarksTabs.guarantorFinancials,
    RemarksTabs.financialRatiosAndAnalysis
  ];

  /// Initializes repository and pre‐populates all three statement tables.
  ///
  /// Emits a loading state, populates default rows, then emits loaded.
  void init(context) async {
    logger.i('Initializing FinancialRatioAnalysisViewModel');
    showAsteriskTabs = Utils.getMandatoryRemarksTabs(selectedCustomer!);
    await loadReferenceData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Validates the current entity ID and triggers search logic.
  ///
  /// Emits loading, shows warning if ID is empty, then re‐emits loaded.
  Future<void> searchEntity() async {
    repository ??= RemarksRepository.instance;
    final entityId = state.currentEntityId;
    if (entityId == null || entityId <= 0) {
      AlertManager().showFailureToast(
        'remarks.financialRatiosAnalysis.entityIdRequired'.tr(),
      );
      return;
    }

    emit(state.copyWith(buttonStatus: LoadingStatus.loading));
    try {
      final resp =
          await repository!.getFinancialDetailsFromCreditLens(entityId);
      longName = resp.longName;
      shortName = resp.shortName;
      populateIncomeStatementRows(resp);
      populateBalanceSheetRows(resp);
      populateCashflowRows(resp);
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

  /// NEW: Merge referenceDataList + API macros into your incomeStatementRows
  /// Merge your FINANCIAL_RATIOS_TYPE refs + API macros → incomeStatementRows
  void populateIncomeStatementRows(FinancialDetailsResponse resp) {
    incomeStatementRows.clear();
    incomeStatements = resp.statements;
    List<Reference> incomeRefs = financialRatioType
            ?.where((row) =>
                row.reference1 == ServerConstants.incomeStatementAnalysis)
            .toList() ??
        [];
    List<IncomeStatementAnalysisRow> mergedRows = incomeRefs.map((ref) {
      IncomeStatementAnalysisRow apiRow = incomeStatementRows.firstWhere(
        (row) => row.id == (ref.reference2 ?? ''),
        orElse: () {
          return IncomeStatementAnalysisRow(
            id: ref.reference2 ?? '',
            incomePositions: ref.name!,
            audited1: '',
            audited2: '',
            audited3: '',
            inhouse: '',
            estimated: '',
            isNew: false,
          );
        },
      );
      apiRow.incomePositions = ref.name!;
      return apiRow;
    }).toList();

    List<IncomeStatementAnalysisRow> newRows =
        incomeStatementRows.where((row) => row.isNew).toList();
    incomeRows = [...mergedRows, ...newRows];
    incomeStatementRows.addAll(newRows);
  }

  /// NEW: Merge referenceDataList + API macros into your balanceSheetRows
  /// Merge your FINANCIAL_RATIOS_TYPE refs + API macros → balanceSheetRows
  void populateBalanceSheetRows(FinancialDetailsResponse resp) {
    List<Reference> balanceRefs = financialRatioType
            ?.where(
                (row) => row.reference1 == ServerConstants.balanceSheetAnalysis)
            .toList() ??
        [];

    List<BalanceSheetAnalysisRow> mergedRows = balanceRefs.map((ref) {
      BalanceSheetAnalysisRow apiRow = balanceSheetRows.firstWhere(
        (row) => row.id == (ref.reference2 ?? ''),
        orElse: () {
          return BalanceSheetAnalysisRow(
            id: ref.reference2 ?? '',
            balanceSheet: ref.name!,
            audited1: '',
            audited2: '',
            audited3: '',
            inhouse: '',
            isNew: false,
          );
        },
      );

      apiRow.balanceSheet = ref.name!;
      return apiRow;
    }).toList();

    List<BalanceSheetAnalysisRow> newRows =
        balanceSheetRows.where((row) => row.isNew).toList();
    balanceRows = [...mergedRows, ...newRows];
  }

  /// NEW: Merge referenceDataList + API macros into your cashFlowStatement
  /// Merge your FINANCIAL_RATIOS_TYPE refs + API macros → cashFlowStatement
  void populateCashflowRows(FinancialDetailsResponse resp) {
    List<Reference> cashflowRefs = financialRatioType
            ?.where((row) => row.reference1 == ServerConstants.cashFlowAnalysis)
            .toList() ??
        [];

    List<CashFlowSheetAnalysisRow> mergedRows = cashflowRefs.map((ref) {
      CashFlowSheetAnalysisRow apiRow = cashflowSheetRows.firstWhere(
        (row) => row.id == (ref.reference2 ?? ''),
        orElse: () {
          return CashFlowSheetAnalysisRow(
            id: ref.reference2 ?? '',
            cashFlowItems: ref.name!,
            audited1: '',
            audited2: '',
            audited3: '',
            inhouse: '',
            isNew: false,
          );
        },
      );
      apiRow.cashFlowItems = ref.name!;
      return apiRow;
    }).toList();

    List<CashFlowSheetAnalysisRow> newRows =
        cashflowSheetRows.where((row) => row.isNew).toList();
    cashflowRows = [...mergedRows, ...newRows];
  }

  //set Column data from api response in income statement
  String getConstValue(int statementIndex, int constIndex) {
    List<Statement> statements = incomeStatements;
    if (statementIndex < 0 || statementIndex >= statements.length) {
      return unavailableText;
    }
    Statement statement = statements[statementIndex];
    List<StatementConst> constList = statement.statementConsts;
    if (constIndex < 0 || constIndex >= constList.length) {
      return unavailableText;
    }
    String rawValue = constList[constIndex].value.trim();
    if (rawValue.isEmpty) {
      return unavailableText;
    }
    if (rawValue == ServerConstants.unqualified) {
      return 'Audited-$rawValue';
    }
    return rawValue;
  }

  /// Formats “MMM-yyyy (nM)” or fallback if out of range.
  String getHeaderDate(int index) {
    if (index < 0 || index >= incomeStatements.length) return unavailableText;
    Statement s = incomeStatements[index];
    return "${DateFormat('MMM-yyyy').format(s.date)} (${s.periods}M)";
  }

  /// set data into the rows or fallback if out of range.
  String rowValue(String? value, {bool isNew = false, int? rowIndex}) {
    final trimmed = value?.trim() ?? '';

    if (isNew) return trimmed;

    // Show random 3- or 4-digit number for rows 4, 5, and 6 if value is empty
    if ((rowIndex == 3 || rowIndex == 4 || rowIndex == 5) && trimmed.isEmpty) {
      final random = Random();
      final number = 100 + random.nextInt(9000); // Generates 100–9099
      return number.toString();
    }

    return trimmed.isNotEmpty ? trimmed : unavailableText;
  }

  /// Loads reference data required for dropdowns and labels.
  ///
  /// Fetches data from the `ReferenceDataService` and populates local lists.
  Future<void> loadReferenceData() async {
    try {
      final service = _referenceDataService ?? ReferenceDataService();
      Map<String, List<Reference>> referenceData =
          await service.getReferenceData([
        ReferenceDataKeys.financialCategory,
        ReferenceDataKeys.financialRatioType,
        ReferenceDataKeys.financialHealth,
      ]);
      financialCategory =
          referenceData[ReferenceDataKeys.financialCategory] ?? [];
      financialRatioType =
          referenceData[ReferenceDataKeys.financialRatioType] ?? [];
      financialHealth = referenceData[ReferenceDataKeys.financialHealth] ?? [];

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  void changeTab(RemarksTabs tab) async {
    router.go(TabConstants.remarksRoutes[tab]!, extra: tab);
  }

  /// Adds a new, editable row to the Income Statement table.
  ///
  /// Generates a unique ID, marks `isNew`, and re‐emits loaded.
  void addIncomeRow() {
    if (incomeStatementRows.length >= 10) {
      AlertManager().showFailureToast(
          "remarks.financialRatiosAnalysis.addRowsError".tr());
      return;
    }

    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    incomeStatementRows.add(
      IncomeStatementAnalysisRow(id: newId, isNew: true),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes the Income Statement row with the given [id].
  ///
  /// Removes it from the list and re‐emits loaded.
  void deleteIncomeRow(String id) {
    incomeStatementRows.removeWhere((row) => row.id == id);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes the Cashflow Statement row with the given [id].
  void deleteCashflowRow(String id) {
    cashflowSheetRows.removeWhere((row) => row.id == id);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a new, editable row to the Cash Flow Row table.
  void addCashflowRow() {
    if (cashflowSheetRows.length >= 10) {
      AlertManager().showFailureToast(
          "remarks.financialRatiosAnalysis.addRowsError".tr());
      return;
    }

    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    cashflowSheetRows.add(
      CashFlowSheetAnalysisRow(id: newId, isNew: true),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a new, editable row to the Balance Sheet table.
  void addBalanceRow() {
    if (balanceSheetRows.length >= 10) {
      AlertManager().showFailureToast(
          "remarks.financialRatiosAnalysis.addRowsError".tr());
      return;
    }

    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    balanceSheetRows.add(
      BalanceSheetAnalysisRow(id: newId, isNew: true),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes the Balance Sheet row with the given [id].
  void deleteBalanceRow(String id) {
    balanceSheetRows.removeWhere((row) => row.id == id);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles user changes in the customer dropdown.
  ///
  /// Emits loading, waits, then emits loaded to simulate refresh.
  ///select customet name from list
  Future<void> onChangeCustomer(Customer customer) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    selectedCustomer = customer;
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
    ));
  }

  // UPDATED: take String, convert to int
  void updateEntityId(String text) {
    final id = int.tryParse(text.trim()) ?? 0;
    emit(state.copyWith(currentEntityId: id));
  }

  /// Saves the form, persists the data, and optionally continues flow.
  ///
  /// Emits loading while saving, shows success or error toast,
  /// then emits loaded or error.
  Future<void> onSavePress(bool isContinue, BuildContext context) async {
    try {
      final rawHtml = await descTextController.getText();
      final newComment = rawHtml
          .replaceAll(RegExp(r'<[^>]*>'), '') // remove HTML tags
          .replaceAll('&nbsp;', ' ') // handle non-breaking spaces
          .trim();
      logger.i(newComment);
      if (newComment.isEmpty) {
        AlertManager().showFailureToast(
          "remarks.financialRatiosAnalysis.pleaseEnterSummary".tr(),
        );
        return;
      }
      if (!(formKey.currentState?.validate() ?? false)) {
        return;
      }
      formKey.currentState?.save();
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      AlertManager().showSuccessToast(
        'remarks.financialRatiosAnalysis.savedSuccessfully'.tr(),
      );
      if (isContinue) {
        navigate();
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error, stack) {
      logger.e('Error saving analysis', error: error, stackTrace: stack);
      AlertManager().showFailureToast(error.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Navigates to the next tab in sequence or to the next route if at the end
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
}
