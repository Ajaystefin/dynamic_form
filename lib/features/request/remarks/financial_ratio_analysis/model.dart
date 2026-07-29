import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/balance_sheet_analysis.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/cashflow_statement_analysis.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_ratio_response.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/remarks_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel (Cubit) for **Remarks → Financial Ratios & Analysis**.
///
/// What this ViewModel controls:
/// 1) Loads reference dropdowns (ratio types + health options)
/// 2) Fetches saved Financial Ratio Analysis data for the selected customer (RIM)
/// 3) Builds the table headers (up to 5 periods) and populates 3 tables:
///    - Income Statement Analysis
///    - Cashflow Statement Analysis
///    - Balance Sheet Analysis
/// 4) Manages rich-text remarks editors:
///    - Description of Accounts (top editor)
///    - Income remarks editor
///    - Cashflow remarks editor
///    - Balance remarks editor
/// 5) FI fallback: when saved ratio API does not provide `descOfAccounts`,
///    the ViewModel loads retained remark strategy comment via `getRemarks()`.
/// 6) Draft support: auto-save / restore drafts in edit mode.
///
/// Why resetting fields matters:
/// - Rich text editors use persistent controllers. If you switch customer and do not
///   clear/reset controllers and selected dropdown values, the UI may show previous
///   customer’s data even though tables refresh correctly.
class FinancialRatioAnalysisViewModel
    extends SafeCubit<FinancialRatioAnalysisState>
    with DraftMixin<FinancialRatioAnalysisViewModel> {
  /// Creates a view model for managing Financial Ratio Analysis data
  /// and dependencies.
  FinancialRatioAnalysisViewModel({
    RemarksRepository? remarksRepository,
    ReferenceDataService? referenceDataService,
  })  : repository = remarksRepository,
        _referenceDataService = referenceDataService,
        super(
          FinancialRatioAnalysisState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used to fetch/save Financial Ratio Analysis data.
  /// If not supplied, it defaults to [RemarksRepository.instance] in runtime methods.
  RemarksRepository? repository;

  /// Reference data service used to load dropdown options.
  final ReferenceDataService? _referenceDataService;

  // ---------------------------------------------------------------------------
  // Draft identity (DraftMixin)
  // --------------------------------------------------------------------------
  @override
  String get draftModuleKey => DraftModuleKeys.remarks;

  @override
  String get draftFormKey =>
      "${Routes.financialRatiosAnalysis}_${selectedCustomer?.customerRimNo}";

  @override
  DraftHandler<FinancialRatioAnalysisViewModel> get draftHandler =>
      FinancialRatioAnalysisDraftHandler();

  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------

  /// Rich text editor controller: Balance Sheet “RM Remarks” section.
  final UnifiedEditorController balanceSheetcontroller =
      UnifiedEditorController();

  /// Rich text editor controller: Cashflow “RM Remarks” section.
  final UnifiedEditorController cashflowController = UnifiedEditorController();

  /// Rich text editor controller: Income Statement “RM Remarks” section.
  final UnifiedEditorController incomeStatementController =
      UnifiedEditorController();

  /// Rich text editor controller: “Description of Accounts” section.
  final UnifiedEditorController descTextController = UnifiedEditorController();

  /// Scroll controller for the page.
  final ScrollController scrollController = ScrollController();

  /// Form key for validation on save.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Used to store the strategy remark response (FI fallback).
  Comment? commentData = Comment();

  // ---------------------------------------------------------------------------
  // Customer selection
  // ---------------------------------------------------------------------------

  /// Current selected customer (RIM context for all API calls).
  Customer? selectedCustomer =
      Globals.selectedCustomer ?? Globals.request?.customers?.first;

  /// All customers from the current application request.
  List<Customer> get customers => Globals.request?.customers ?? [];

  /// Customer list used in dropdown (group apps may load child rims).
  List<Customer>? customerList = [];

  // ---------------------------------------------------------------------------
  // Tables
  // ---------------------------------------------------------------------------

  /// Income statement table rows displayed in UI.
  final List<IncomeStatementAnalysisRow> incomeStatementRows = [];

  /// Cashflow table rows displayed in UI.
  final List<CashFlowSheetAnalysisRow> cashflowSheetRows = [];

  /// Balance sheet table rows displayed in UI.
  final List<BalanceSheetAnalysisRow> balanceSheetRows = [];

  /// Backend category identifier for Income Statement Analysis.
  static const int categoryIncome = 234;

  /// Backend category identifier for Cash Flow Statement Analysis.
  static const int categoryCashflow = 236;

  /// Backend category identifier for Balance Sheet Analysis.
  static const int categoryBalance = 237;

  /// UI flag: show delete/action column when any row is user-added in Income.
  bool get hasActionColumn =>
      incomeStatementRows.any((IncomeStatementAnalysisRow row) => row.isNew);

  /// UI flag: show delete/action column when any row is user-added in Cashflow.
  bool get hasActionColumnCashflow =>
      cashflowSheetRows.any((CashFlowSheetAnalysisRow row) => row.isNew);

  /// UI flag: show delete/action column when any row is user-added in Balance.
  bool get hasActionColumnBalanceSheet =>
      balanceSheetRows.any((BalanceSheetAnalysisRow row) => row.isNew);

  // ---------------------------------------------------------------------------
  // Reference data (dropdowns)
  // ---------------------------------------------------------------------------

  /// Selected health indicator for the Balance Sheet Analysis section.
  Reference? selectedBalanceSheetHealth = Reference(name: "Select");

  /// Selected health indicator for the Income Statement Analysis section.
  Reference? selectedIncomeHealth = Reference(name: "Select");

  /// Selected health indicator for the Cash Flow Statement Analysis section.
  Reference? selectedCashFlowHealth = Reference(name: "Select");

  /// Financial category reference data.
  List<Reference>? financialCategory = [];

  /// Financial ratio type reference data.
  List<Reference>? financialRatioType = [];

  /// Cash Flow Statement Analysis health options.
  List<Reference>? cashflowHealth = [];

  /// Income Statement Analysis health options.
  List<Reference>? incomeHealth = [];

  /// Balance Sheet Analysis health options.
  List<Reference>? balanceHealth = [];

  // ---------------------------------------------------------------------------
  // Header + remarks state
  // --------------------------------------------------------------------------

  /// Long name of the selected entity.
  String? longName;

  /// Short name of the selected entity.
  String? shortName;

  /// Column headers (up to 5 periods) built from saved or credit lens data.
  List<Statement> incomeStatements = [];

  /// Localized placeholder text for missing values.
  String unavailableText =
      "remarks.financialRatiosAnalysis.dataNotAvailable".tr();

  /// Cached income statement rows used for rendering.
  List<IncomeStatementAnalysisRow>? incomeRows = [];

  /// Cached balance sheet rows used for rendering.
  List<BalanceSheetAnalysisRow>? balanceRows = [];

  /// Cached cash flow statement rows used for rendering.
  List<CashFlowSheetAnalysisRow>? cashflowRows = [];

  /// Indicates whether Credit Lens data has been loaded.
  bool hasCreditLensData = false;

  /// Indicates whether saved financial analysis data is available.
  bool hasSavedAnalysisData = false;

  /// True if backend already has financial details (determines which save API to use).
  bool hasExistingFinancialDetails = false;

  /// Indicates whether the current flow is for Financial Institutions.
  bool isFI = false;

  /// Indicates whether the current application belongs to the Corporate segment.
  bool get isCorporateApp =>
      Utils.checkBusinessSegment(BusinessSegment.corporate);

  /// Tab list used for asterisk display.
  List<RemarksTabs> showAsteriskTabs = [];

  /// Tabs that route outside this screen (not part of Common Tabs view).
  List<RemarksTabs> otherRemarksTabs = [
    RemarksTabs.feeStructure,
    RemarksTabs.guarantorFinancials,
    RemarksTabs.financialRatiosAndAnalysis,
  ];

  /// Selected entity identifier.
  int? entityId;

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Indicates whether the page is in read-only mode.
  bool get isReadOnlyMode => pageMode == PageMode.view;

  /// Description of accounts entered in the main editor.
  String? description;

  /// Remarks for Income Statement Analysis.
  String? incomeDescription;

  /// Remarks for Cash Flow Statement Analysis.
  String? cashflowDescription;

  /// Remarks for Balance Sheet Analysis.
  String? balanceSheetdescription;

  /// Entity ID input field controller.
  TextEditingController entityController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initializes screen state:
  /// - page mode (edit/view)
  /// - customer list (borrower/child rim)
  /// - mandatory asterisk tabs
  /// - reference data
  /// - saved analysis for selected customer
  /// - drafts (edit mode only)
  Future<void> init(BuildContext context) async {
    logger.i("Initializing FinancialRatioAnalysisViewModel");
    pageMode = AuthRepository.getPageMode(RightConstants.remarksCommentary);
    isFI = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    defaultSelectedCustomer();
    await getChildRimsForGroup();
    await setAsterisks();
    await loadReferenceData();
    await fetchSavedFinancialAnalysis();

    if (!isReadOnlyMode) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  // ---------------------------------------------------------------------------
  // Customer helpers
  // ---------------------------------------------------------------------------

  /// Loads child rims for group applications and sets [selectedCustomer].
  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupApplication()) {
        customerList =
            await CustomerRepository.instance.getChildRimsForGroup() ?? [];
        if ((customerList ?? []).isNotEmpty) {
          selectedCustomer = customerList?.first;
        } else {
          defaultSelectedCustomer();
        }
      } else {
        defaultSelectedCustomer();
      }
    } on Object catch (e) {
      logger.i("Error fetching getChildRimsForGroup : $e");
      defaultSelectedCustomer();
      rethrow;
    }
  }

  /// Selects a default customer from borrowers (preferred) else customers list.
  void defaultSelectedCustomer() {
    final List<Customer> borrowers = Globals.request?.borrowers ?? [];
    final List<Customer> customers = Globals.request?.customers ?? [];

    if (borrowers.isNotEmpty) {
      selectedCustomer = borrowers.first;
    } else if (customers.isNotEmpty) {
      selectedCustomer = customers.first;
    } else if (Globals.request?.customerRimNo != null) {
      selectedCustomer = Customer(
        customerRimNo: Globals.request?.customerRimNo,
        customerName: Globals.request?.customerName,
      );
    } else {
      selectedCustomer = null;
    }

    if (selectedCustomer != null) {
      customerList = [selectedCustomer!];
    }

    Globals.selectedCustomer = selectedCustomer;
  }

  /// Called by dropdown: updates selected customer and reloads all saved data.
  ///
  /// IMPORTANT:
  /// We reset customer-dependent UI state first, otherwise editors/dropdowns
  /// will keep the previous customer's values.
  Future<void> onChangeCustomer(Customer customer) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    // save previous customer's unsaved work before switching
    unawaited(Globals.onAutoSave?.call());

    selectedCustomer = customer;
    Globals.selectedCustomer = customer;

    // clear previous customer's selections + remarks to avoid stale UI
    _resetCustomerDependentFields();

    entityController.text = "";
    await setAsterisks();
    await fetchSavedFinancialAnalysis();

    // load incoming customer's draft (overrides live data with any draft)
    if (!isReadOnlyMode) {
      await loadDraftIfAvailable();
    }

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Fetch saved analysis
  // ---------------------------------------------------------------------------

  /// Fetches saved Financial Ratio Analysis for the selected customer.
  ///
  /// Behavior:
  /// - Clears all customer-dependent UI fields before loading new data
  /// - Uses Financial Ratio API description if present
  /// - If FI and description is empty, falls back to retained strategy comment
  /// - Populates:
  ///   - statement remarks editors
  ///   - health selections
  ///   - tables (income/cashflow/balance)
  Future<void> fetchSavedFinancialAnalysis() async {
    try {
      repository ??= RemarksRepository.instance;
      final int rimNo = selectedCustomer?.customerRimNo ??
          selectedCustomer?.customerRimNo ??
          0;
      if (rimNo <= 0) {
        hasSavedAnalysisData = false;
        // clear UI when no valid rim
        _resetCustomerDependentFields();
        return;
      }

      // clear previous values before applying new response
      _resetCustomerDependentFields();

      final FinancialRatioAnalysisResponse resp =
          await repository!.getFinancialRatioAnalysisDetails(rimNo: rimNo);

      final String descFromRatioApi = (resp.descOfAccounts ?? "").trim();
      hasExistingFinancialDetails = true;

      if (descFromRatioApi.isNotEmpty) {
        description = descFromRatioApi;
        descTextController.setText(descFromRatioApi);
      } else {
        if (isFI) {
          await getRemarks();
        } else {
          description = "";
          descTextController.setText("");
        }
      }

      if (resp.entityDetails.isNotEmpty) {
        final EntityDetail firstEntityDetail = resp.entityDetails.first;
        entityController.text = firstEntityDetail.entityId.toString();

        final List<FinancialCategoryDetail> categoryDetails =
            firstEntityDetail.financialsCategory;

        for (final categoryItem in categoryDetails) {
          final String text = (categoryItem.remarks ?? "").trim();
          switch (categoryItem.financialsCategory) {
            case categoryIncome: // 234 → Income Statement
              if (text.isNotEmpty) {
                incomeDescription = text;
                incomeStatementController.setText(text);
              }
              selectedIncomeHealth =
                  healthRefById(categoryItem.financialHealth, incomeHealth);

            case categoryCashflow: // 236 → Cash Flow
              if (text.isNotEmpty) {
                cashflowDescription = text;
                cashflowController.setText(text);
              }
              selectedCashFlowHealth =
                  healthRefById(categoryItem.financialHealth, cashflowHealth);

            case categoryBalance: // 237 → Balance Sheet
              if (text.isNotEmpty) {
                balanceSheetdescription = text;
                balanceSheetcontroller.setText(text);
              }
              selectedBalanceSheetHealth =
                  healthRefById(categoryItem.financialHealth, balanceHealth);

            default:
              break;
          }
        }

        longName = firstEntityDetail.entityLongName;
        entityId = firstEntityDetail.entityId;

        final FinancialCategoryDetail incomeCategory =
            categoryDetails.firstWhere(
          (FinancialCategoryDetail detail) =>
              detail.financialsCategory == categoryIncome,
          orElse: () => FinancialCategoryDetail(
            financialsCategory: categoryIncome,
            financialsValues: const [],
            financialHealth: null,
            remarks: null,
          ),
        );
        final FinancialCategoryDetail cashflowCategory =
            categoryDetails.firstWhere(
          (FinancialCategoryDetail detail) =>
              detail.financialsCategory == categoryCashflow,
          orElse: () => FinancialCategoryDetail(
            financialsCategory: categoryCashflow,
            financialsValues: const [],
            financialHealth: null,
            remarks: null,
          ),
        );
        final FinancialCategoryDetail balanceCategory =
            categoryDetails.firstWhere(
          (FinancialCategoryDetail detail) =>
              detail.financialsCategory == categoryBalance,
          orElse: () => FinancialCategoryDetail(
            financialsCategory: categoryBalance,
            financialsValues: const [],
            financialHealth: null,
            remarks: null,
          ),
        );

        final List<FinancialValue> headerSourceValues =
            incomeCategory.financialsValues.isNotEmpty
                ? incomeCategory.financialsValues
                : (cashflowCategory.financialsValues.isNotEmpty
                    ? cashflowCategory.financialsValues
                    : balanceCategory.financialsValues);

        incomeStatements = buildStatementsFromSavedValues(
          headerSourceValues,
        );

        // ===== Populate Income table from saved =====
        incomeStatementRows.clear();
        if (incomeCategory.financialsValues.isNotEmpty) {
          final Map<String, List<FinancialValue>> valuesGroupedByKey = {};
          for (final FinancialValue savedValue
              in incomeCategory.financialsValues) {
            final String rawCode =
                savedValue.financialRatioType.trim(); // "101", "74", "", "null"
            final String rawUserLabel = (savedValue.userAddedRatioType ?? "")
                .trim(); // e.g., "incomesuser"
            final bool isUserAddedRow =
                rawCode.isEmpty || rawCode.toLowerCase() == "null"; // NEW
            final String groupingKey = isUserAddedRow ? rawUserLabel : rawCode;
            if (groupingKey.isEmpty) {
              continue;
            }
            (valuesGroupedByKey[groupingKey] ??= <FinancialValue>[])
                .add(savedValue);
          }

          for (final MapEntry<String, List<FinancialValue>> groupedEntry
              in valuesGroupedByKey.entries) {
            incomeStatementRows.add(
              mkIncomeRowFromSaved(
                groupedEntry.key,
                groupedEntry.value,
                unavailableText,
              ),
            );
          }
          final List<IncomeStatementAnalysisRow> userAddedRows =
              incomeStatementRows
                  .where((IncomeStatementAnalysisRow row) => row.isNew)
                  .toList();
          incomeRows = [...incomeStatementRows, ...userAddedRows];
        }

        // ===== Populate cashflow table from saved =====
        cashflowSheetRows.clear();
        if (cashflowCategory.financialsValues.isNotEmpty) {
          final Map<String, List<FinancialValue>> valuesGroupedByKey = {};
          for (final FinancialValue savedValue
              in cashflowCategory.financialsValues) {
            final String rawCode = savedValue.financialRatioType.trim();
            final String rawUserLabel =
                (savedValue.userAddedRatioType ?? "").trim();
            final bool isUserAddedRow =
                rawCode.isEmpty || rawCode.toLowerCase() == "null";
            final String groupingKey = isUserAddedRow ? rawUserLabel : rawCode;
            if (groupingKey.isEmpty) {
              continue;
            }
            (valuesGroupedByKey[groupingKey] ??= <FinancialValue>[])
                .add(savedValue);
          }

          final List<CashFlowSheetAnalysisRow> mergedRows =
              <CashFlowSheetAnalysisRow>[];
          for (final MapEntry<String, List<FinancialValue>> groupedEntry
              in valuesGroupedByKey.entries) {
            mergedRows.add(
              mkCashflowRowFromSaved(
                groupedEntry.key,
                groupedEntry.value,
                unavailableText,
              ),
            );
          }
          cashflowSheetRows.addAll(mergedRows);
          final List<CashFlowSheetAnalysisRow> userAddedRows = cashflowSheetRows
              .where((CashFlowSheetAnalysisRow row) => row.isNew)
              .toList();
          cashflowRows = [...mergedRows, ...userAddedRows];
        }

        // ===== Populate Balance table from saved =====
        balanceSheetRows.clear();
        if (balanceCategory.financialsValues.isNotEmpty) {
          final Map<String, List<FinancialValue>> valuesGroupedByKey = {};
          for (final FinancialValue savedValue
              in balanceCategory.financialsValues) {
            final String rawCode = savedValue.financialRatioType.trim();
            final String rawUserLabel =
                (savedValue.userAddedRatioType ?? "").trim();
            final bool isUserAddedRow =
                rawCode.isEmpty || rawCode.toLowerCase() == "null";
            final String groupingKey = isUserAddedRow ? rawUserLabel : rawCode;
            if (groupingKey.isEmpty) {
              continue;
            }
            (valuesGroupedByKey[groupingKey] ??= <FinancialValue>[])
                .add(savedValue);
          }

          final List<BalanceSheetAnalysisRow> mergedRows =
              <BalanceSheetAnalysisRow>[];
          for (final MapEntry<String, List<FinancialValue>> groupedEntry
              in valuesGroupedByKey.entries) {
            mergedRows.add(
              mkBalanceRowFromSaved(
                groupedEntry.key,
                groupedEntry.value,
                unavailableText,
              ),
            );
          }
          balanceSheetRows.addAll(mergedRows);
          final List<BalanceSheetAnalysisRow> userAddedRows = balanceSheetRows
              .where((BalanceSheetAnalysisRow row) => row.isNew)
              .toList();
          balanceRows = [...mergedRows, ...userAddedRows];
        }

        emit(state.copyWith(currentEntityId: firstEntityDetail.entityId));
        hasSavedAnalysisData = true;
      } else {
        hasSavedAnalysisData = false;
      }
    } on Object {
      hasSavedAnalysisData = false;
      hasExistingFinancialDetails = false;
      await getRemarks();
    }
  }

  /// Decodes a small subset of HTML entities commonly returned by backend.
  ///
  /// Recommended version:
  /// If backend returns escaped HTML like `&lt;p&gt;Hello&lt;/p&gt;`,
  /// this converts it to `<p>Hello</p>` so rich text editor can render it
  String _decodeHtmlEntities(String value) {
    return value
        .replaceAll("&lt;", "<")
        .replaceAll("&gt;", ">")
        .replaceAll("&amp;", "&");
  }

  /// Clears UI fields that are customer-specific (dropdown selections + remarks editors).
  /// Call this before loading a different customer to avoid showing previous customer's values.
  void _resetCustomerDependentFields() {
    // Clear description of accounts + editor
    description = "";
    descTextController.setText("");

    // Clear entity metadata
    entityId = null;
    longName = null;
    shortName = null;
    entityController.text = "";

    // Clear statement remarks + editors
    incomeDescription = "";
    cashflowDescription = "";
    balanceSheetdescription = "";
    incomeStatementController.setText("");
    cashflowController.setText("");
    balanceSheetcontroller.setText("");

    // Reset health dropdown selections (so UI shows "Select")
    selectedIncomeHealth = null;
    selectedCashFlowHealth = null;
    selectedBalanceSheetHealth = null;

    // Clear table rows so previous customer's data is not shown when the new
    // customer has no saved financial details (empty API response)
    incomeStatements = [];
    incomeStatementRows.clear();
    cashflowSheetRows.clear();
    balanceSheetRows.clear();
    incomeRows = [];
    cashflowRows = [];
    balanceRows = [];

    // Reset visibility flags so the table widgets are hidden until the new
    // customer's data is loaded. hasCreditLensData in particular never resets
    // on its own, so without this it leaks from the previous customer's entity
    // search and causes empty tables to render for the new customer.
    hasCreditLensData = false;
    hasSavedAnalysisData = false;
  }

  /// Loads reference data required for dropdowns and labels.
  ///
  /// Fetches data from the `ReferenceDataService` and populates local lists.
  Future<void> loadReferenceData() async {
    try {
      final ReferenceDataService service =
          _referenceDataService ?? ReferenceDataService();
      final Map<String, List<Reference>> referenceData =
          await service.getReferenceData([
        ReferenceDataKeys.financialCategory,
        ReferenceDataKeys.financialRatioType,
        ReferenceDataKeys.cashflowStatementHealth,
        ReferenceDataKeys.incomeStatementHealth,
        ReferenceDataKeys.balanceSheetHealth,
      ]);
      financialCategory =
          referenceData[ReferenceDataKeys.financialCategory] ?? [];
      financialRatioType =
          referenceData[ReferenceDataKeys.financialRatioType] ?? [];
      cashflowHealth =
          referenceData[ReferenceDataKeys.cashflowStatementHealth] ?? [];
      incomeHealth =
          referenceData[ReferenceDataKeys.incomeStatementHealth] ?? [];
      balanceHealth = referenceData[ReferenceDataKeys.balanceSheetHealth] ?? [];
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Maps a saved “health id” to the actual [Reference] item in a reference list.
  Reference? healthRefById(int? healthId, List<Reference>? list) {
    if (healthId == null) {
      return null;
    }
    final List<Reference> healthList = list ?? const <Reference>[];
    final int matchedIndex = healthList
        .indexWhere((Reference referenceItem) => referenceItem.id == healthId);
    return (matchedIndex >= 0) ? healthList[matchedIndex] : null;
  }

  /// Fetches FI retained strategy comment for “Description of Accounts”.
  ///
  /// Used when the Financial Ratio API does not provide descOfAccounts.
  Future<void> getRemarks() async {
    try {
      commentData = await RequestRepository.instance.getRemarkStrategyData(
            selectedCustomer,
            ServerConstants.commentTypeId[CommentsType.remarks],
            ServerConstants.remarksTabId[state.activeTab],
          ) ??
          Comment();

      final String rawStrategyComment =
          (commentData?.strategyComment ?? "").trim();

      final String sanitizedComment = (rawStrategyComment.isEmpty ||
              rawStrategyComment.toLowerCase() == "null")
          ? ""
          : rawStrategyComment;

      // Decode escaped HTML (FI responses may be encoded)
      final String decodedHtml = _decodeHtmlEntities(sanitizedComment);

      // update BOTH description + controller (view uses initialText)
      description = decodedHtml;
      descTextController.setText(decodedHtml);
    } on Object catch (e) {
      commentData = Comment();
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Validates the current entity ID and triggers search logic.
  ///
  /// Emits loading, shows warning if ID is empty, then re‐emits loaded.
  Future<void> searchEntity() async {
    repository ??= RemarksRepository.instance;
    final int? searchedEntityId = state.currentEntityId;
    if (searchedEntityId == null || searchedEntityId <= 0) {
      AlertManager().showFailureToast(
        "remarks.financialRatiosAnalysis.entityIdRequired".tr(),
      );
      return;
    }

    emit(state.copyWith(buttonStatus: LoadingStatus.loading));
    try {
      final FinancialDetailsResponse resp =
          await repository!.getFinancialDetailsFromCreditLens(searchedEntityId);
      longName = resp.longName;
      shortName = resp.shortName;
      populateIncomeStatementRows(resp);
      populateBalanceSheetRows(resp);
      populateCashflowRows(resp);
      hasCreditLensData = true;
      hasExistingFinancialDetails = true;
      emit(state.copyWith(buttonStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      logger.i(e.toString());
      AlertManager().showFailureToast(e.toString());
      hasCreditLensData = false;
      emit(state.copyWith(buttonStatus: LoadingStatus.loaded));
    }
  }

  /// Build canonical headers from CreditLens statements:
  /// - group by year
  /// - pick the latest month in that year
  /// - take the latest 5 years
  /// - order ascending (oldest → newest) for column display
  List<Statement> _canonicalHeaders(List<Statement> input) {
    if (input.isEmpty) {
      return const <Statement>[];
    }

    // group by year, keep latest-by-date in each year
    final Map<int, Statement> latestPerYear = {};
    for (final s in input) {
      final int y = s.date.year;
      final Statement? existing = latestPerYear[y];
      if (existing == null || s.date.isAfter(existing.date)) {
        latestPerYear[y] = s;
      }
    }

    // pick latest 5 years overall
    final List<Statement> perYear = latestPerYear.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // oldest → newest

    final int n = perYear.length;
    final List<Statement> lastFive =
        (n <= 5) ? perYear : perYear.sublist(n - 5, n);

    // ensure deterministic id/order for rendering; keep original id/consts
    return lastFive;
  }

  /// Strict value lookup: prefer exact header date match; if no exact match,
  /// fall back to the latest macro item in the same year. Return
  /// `unavailableText` for
  /// "", null, "NaN", or no match.
  String _valForByDate(
    List<MacroItem> items,
    Statement header,
    String unavailableText,
  ) {
    if (items.isEmpty) {
      return unavailableText;
    }

    // 1) Exact match by date
    final MacroItem exact = items.firstWhere(
      (it) => it.stmtDate.isAtSameMomentAs(header.date),
      orElse: () => MacroItem(stmtID: -1, stmtDate: DateTime(1970), value: ""),
    );
    if (exact.stmtID != -1) {
      final String raw = exact.value.trim();
      if (raw.isEmpty || raw.toLowerCase() == "nan") {
        return unavailableText;
      }
      final double? roundedStr = double.tryParse(raw);
      if (roundedStr == null) {
        return unavailableText;
      }
      return roundedStr.toStringAsFixed(2);
    }

    // 2) Fallback: latest month in the same year (handles duplicate-year
    // macros)
    final int year = header.date.year;
    final List<MacroItem> sameYear = items
        .where((it) => it.stmtDate.year == year)
        .toList()
      ..sort((a, b) => a.stmtDate.compareTo(b.stmtDate)); // oldest → newest

    if (sameYear.isNotEmpty) {
      final MacroItem latest = sameYear.last;
      final String raw = latest.value.trim();
      if (raw.isEmpty || raw.toLowerCase() == "nan") {
        return unavailableText;
      }
      final double? roundedStr = double.tryParse(raw);
      if (roundedStr == null) {
        return unavailableText;
      }
      return roundedStr.toStringAsFixed(2);
    }

    return unavailableText;
  }

  // ---------------------------------------------------------------------------
  // Populate tables from CreditLens response
  // ---------------------------------------------------------------------------

  /// Populates Income Statement table from CreditLens response.
  void populateIncomeStatementRows(FinancialDetailsResponse resp) {
    incomeStatementRows.clear();
    incomeStatements = _canonicalHeaders(resp.statements);

    final List<Reference> incomeRowReferences = financialRatioType
            ?.where(
              (Reference referenceItem) =>
                  referenceItem.reference1 ==
                  ServerConstants.incomeStatementAnalysis,
            )
            .toList() ??
        [];

    final List<IncomeStatementAnalysisRow> mergedRows =
        incomeRowReferences.map((Reference referenceItem) {
      final String macroKey = referenceItem.reference2 ?? "";
      final List<MacroItem> macroItems = (macroKey.isNotEmpty)
          ? (resp.macros[macroKey] ?? const [])
          : const [];

      final IncomeStatementAnalysisRow row = IncomeStatementAnalysisRow(
        id: macroKey.isNotEmpty
            ? macroKey
            : DateTime.now().millisecondsSinceEpoch.toString(),
        incomePositions: referenceItem.name ?? "",
        audited1: unavailableText,
        audited2: unavailableText,
        audited3: unavailableText,
        inhouse: unavailableText,
        estimated: unavailableText, // 5th column slot
      );

      for (int columnIndex = 0;
          columnIndex < incomeStatements.length && columnIndex < 5;
          columnIndex++) {
        final Statement headerStatement = incomeStatements[columnIndex];
        final String computedValue =
            _valForByDate(macroItems, headerStatement, unavailableText);
        if (columnIndex == 0) {
          row.audited1 = computedValue;
        } else if (columnIndex == 1) {
          row.audited2 = computedValue;
        } else if (columnIndex == 2) {
          row.audited3 = computedValue;
        } else if (columnIndex == 3) {
          row.inhouse = computedValue;
        } else if (columnIndex == 4) {
          row.estimated = computedValue;
        }
      }
      return row;
    }).toList();

    incomeStatementRows.addAll(mergedRows);
    final List<IncomeStatementAnalysisRow> newRows =
        incomeStatementRows.where((row) => row.isNew).toList();
    incomeRows = [...mergedRows, ...newRows];
  }

  /// Populates Balance Sheet table from CreditLens response.
  void populateBalanceSheetRows(FinancialDetailsResponse resp) {
    if (incomeStatements.isEmpty) {
      incomeStatements = _canonicalHeaders(resp.statements);
    }
    final List<Statement> headers = incomeStatements;

    final List<Reference> balanceRowReferences = financialRatioType
            ?.where(
              (Reference referenceItem) =>
                  referenceItem.reference1 ==
                  ServerConstants.balanceSheetAnalysis,
            )
            .toList() ??
        [];

    final List<BalanceSheetAnalysisRow> mergedRows =
        balanceRowReferences.map((Reference referenceItem) {
      final String macroKey = referenceItem.reference2 ?? "";
      final List<MacroItem> macroItems = (macroKey.isNotEmpty)
          ? (resp.macros[macroKey] ?? const [])
          : const [];

      final BalanceSheetAnalysisRow apiRow = balanceSheetRows.firstWhere(
        (BalanceSheetAnalysisRow row) => row.id == macroKey,
        orElse: () => BalanceSheetAnalysisRow(
          id: macroKey,
          balanceSheet: referenceItem.name ?? "",
        ),
      )..balanceSheet = referenceItem.name ?? "";

      if (headers.isNotEmpty && macroItems.isNotEmpty) {
        for (int columnIndex = 0;
            columnIndex < headers.length && columnIndex < 5;
            columnIndex++) {
          final Statement headerStatement = headers[columnIndex];
          final String computedValue =
              _valForByDate(macroItems, headerStatement, unavailableText);
          if (columnIndex == 0) {
            apiRow.audited1 = computedValue;
          } else if (columnIndex == 1) {
            apiRow.audited2 = computedValue;
          } else if (columnIndex == 2) {
            apiRow.audited3 = computedValue;
          } else if (columnIndex == 3) {
            apiRow.inhouse = computedValue;
          } else if (columnIndex == 4) {
            apiRow.estimated = computedValue;
          } // 5th column
        }
      } else {
        apiRow
          ..audited1 = unavailableText
          ..audited2 = unavailableText
          ..audited3 = unavailableText
          ..inhouse = unavailableText
          ..estimated = unavailableText;
      }
      return apiRow;
    }).toList();

    balanceSheetRows
      ..clear()
      ..addAll(mergedRows);
    final List<BalanceSheetAnalysisRow> newRows =
        balanceSheetRows.where((row) => row.isNew).toList();
    balanceRows = [...mergedRows, ...newRows];
  }

  /// Populates Cashflow table from CreditLens response.
  void populateCashflowRows(FinancialDetailsResponse resp) {
    if (incomeStatements.isEmpty) {
      incomeStatements = _canonicalHeaders(resp.statements);
    }
    final List<Statement> headers = incomeStatements;

    final List<Reference> cashflowRefs = financialRatioType
            ?.where(
              (Reference referenceItem) =>
                  referenceItem.reference1 == ServerConstants.cashFlowAnalysis,
            )
            .toList() ??
        [];

    final List<CashFlowSheetAnalysisRow> mergedRows =
        cashflowRefs.map((Reference referenceItem) {
      final String macroKey = referenceItem.reference2 ?? "";
      final List<MacroItem> macroItems = (macroKey.isNotEmpty)
          ? (resp.macros[macroKey] ?? const [])
          : const [];

      final CashFlowSheetAnalysisRow apiRow = cashflowSheetRows.firstWhere(
        (CashFlowSheetAnalysisRow row) => row.id == macroKey,
        orElse: () => CashFlowSheetAnalysisRow(
          id: macroKey,
          cashFlowItems: referenceItem.name ?? "",
        ),
      )..cashFlowItems = referenceItem.name ?? "";

      if (headers.isNotEmpty && macroItems.isNotEmpty) {
        for (int columnIndex = 0;
            columnIndex < headers.length && columnIndex < 5;
            columnIndex++) {
          final Statement headerStatement = headers[columnIndex];
          final String computedValue =
              _valForByDate(macroItems, headerStatement, unavailableText);
          if (columnIndex == 0) {
            apiRow.audited1 = computedValue;
          } else if (columnIndex == 1) {
            apiRow.audited2 = computedValue;
          } else if (columnIndex == 2) {
            apiRow.audited3 = computedValue;
          } else if (columnIndex == 3) {
            apiRow.inhouse = computedValue;
          } else if (columnIndex == 4) {
            apiRow.estimated = computedValue;
          }
        }
      } else {
        apiRow
          ..audited1 = unavailableText
          ..audited2 = unavailableText
          ..audited3 = unavailableText
          ..inhouse = unavailableText
          ..estimated = unavailableText;
      }
      return apiRow;
    }).toList();

    cashflowSheetRows
      ..clear()
      ..addAll(mergedRows);

    final List<CashFlowSheetAnalysisRow> userAddedRows =
        cashflowSheetRows.where((row) => row.isNew).toList();
    cashflowRows = [...mergedRows, ...userAddedRows];
  }

  // ---------------------------------------------------------------------------
  // Saved header helpers (from saved FinancialValue list)
  // ---------------------------------------------------------------------------

  /// Parses "6M", "12M" etc. into integer months.
  int parseSavedMonths(String period) {
    final RegExpMatch? match = RegExp(r"(\d+)").firstMatch(period);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  /// Converts saved value to a DateTime:
  /// - Prefer `statementDate` if present and parseable
  /// - Otherwise derive month from `period` and year from `financialYear`
  DateTime dateFromSaved(FinancialValue value) {
    final String? statementDateString = value.statementDate;
    if (statementDateString != null && statementDateString.trim().isNotEmpty) {
      try {
        return DateTime.parse(
          statementDateString.trim(),
        ); // full fidelity: uses the real month/day
      } on Object catch (_) {
        // fall through to the period-based fallback
      }
    }
    final int monthsFromPeriod = parseSavedMonths(value.period);
    final int derivedMonth =
        (monthsFromPeriod == 12) ? 12 : monthsFromPeriod.clamp(1, 12);
    return DateTime(value.financialYear, derivedMonth);
  }

  /// Build canonical headers from saved FinancialValue entries:
  /// - group by year
  /// - Keep the entry with the latest month in that year
  /// - Keep last 5 years (oldest → newest)
  List<Statement> buildStatementsFromSavedValues(List<FinancialValue> values) {
    if (values.isEmpty) {
      return const <Statement>[];
    }

    int monthsFromPeriod(String period) {
      final RegExpMatch? match = RegExp(r"(\d+)").firstMatch(period);
      return (match != null) ? int.tryParse(match.group(1)!) ?? 0 : 0;
    }

    // Latest value (by months) per financial year
    final Map<int, FinancialValue> latestPerYear = {};
    for (final value in values) {
      final int year = value.financialYear;
      final int months = monthsFromPeriod(value.period);
      final FinancialValue? existing = latestPerYear[year];
      final bool isNewer =
          (existing == null) || (months > monthsFromPeriod(existing.period));
      if (isNewer) {
        latestPerYear[year] = value;
      }
    }

    // Sort oldest → newest by (year, months)
    final List<FinancialValue> perYear = latestPerYear.values.toList()
      ..sort((a, b) {
        final int am = monthsFromPeriod(a.period);
        final int bm = monthsFromPeriod(b.period);
        if (a.financialYear != b.financialYear) {
          return a.financialYear.compareTo(b.financialYear);
        }
        return am.compareTo(bm);
      }); // oldest → newest

    // Keep at most the last five years
    final int totalYears = perYear.length;
    final List<FinancialValue> lastFive = (totalYears <= 5)
        ? perYear
        : perYear.sublist(totalYears - 5, totalYears);

    // Build headers using saved values (date from statementDate via
    // dateFromSaved)
    return List<Statement>.generate(lastFive.length, (i) {
      final FinancialValue fv = lastFive[i];
      final int months = monthsFromPeriod(fv.period);
      final DateTime headerDate = dateFromSaved(fv); //  use statementDate
      return Statement(
        id: i + 1, // 1..5
        date: headerDate, // real month from API
        periods: months,
        statementConsts: [
          StatementConst(id: 0, value: fv.auditMethod), // audit method
          StatementConst(id: 1, value: fv.auditor ?? ""), // auditor (may be "")
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Display name lookup + row builders for saved tables
  // ---------------------------------------------------------------------------

  /// Returns display name for a ratio code from reference list.
  /// If not found, returns the code itself.
  String displayNameForCode(String code) {
    final Reference ref = (financialRatioType ?? []).firstWhere(
      (r) => (r.reference2 ?? "") == code,
      orElse: () => Reference(name: ""),
    );
    return (ref.name?.isNotEmpty ?? false) ? ref.name! : code;
  }

  /// Builds an Income row object from saved values for a single ratio.
  IncomeStatementAnalysisRow mkIncomeRowFromSaved(
    String ratioKey,
    List<FinancialValue> savedItems,
    String unavailableText,
  ) {
    final String firstRatioCode = savedItems.first.financialRatioType.trim();
    final bool isCodeBased =
        firstRatioCode.isNotEmpty && firstRatioCode.toLowerCase() != "null";

    final IncomeStatementAnalysisRow row = IncomeStatementAnalysisRow(
      id: ratioKey,
      incomePositions: displayNameForCode(ratioKey),
      audited1: unavailableText,
      audited2: unavailableText,
      audited3: unavailableText,
      inhouse: unavailableText,
      estimated: unavailableText,
      isNew: !isCodeBased,
    );

    final int maxVisibleColumns = incomeStatements.length.clamp(0, 5);
    for (int columnIndex = 0; columnIndex < maxVisibleColumns; columnIndex++) {
      final Statement headerStatement = incomeStatements[columnIndex];
      String fmtStmtDate(DateTime dateTimeValue) =>
          DateFormat("yyyy-MM-dd").format(dateTimeValue);
      final FinancialValue matchingValue = savedItems.firstWhere(
        (FinancialValue candidate) =>
            candidate.financialYear == headerStatement.date.year &&
            parseSavedMonths(candidate.period) == headerStatement.periods,
        orElse: () => FinancialValue(
          financialsCategory: categoryIncome,
          financialRatioType: ratioKey,
          userAddedRatioType: null,
          financialYear: headerStatement.date.year,
          statementDate: fmtStmtDate(headerStatement.date),
          period: "${headerStatement.periods}M",
          auditMethod: "",
          auditor: "",
          value: null,
        ),
      );
      final double? numericValue = matchingValue.value;
      final String cellText = (numericValue == null)
          ? unavailableText
          : numericValue.toStringAsFixed(2);
      if (columnIndex == 0) {
        row.audited1 = cellText;
      } else if (columnIndex == 1) {
        row.audited2 = cellText;
      } else if (columnIndex == 2) {
        row.audited3 = cellText;
      } else if (columnIndex == 3) {
        row.inhouse = cellText;
      } else if (columnIndex == 4) {
        row.estimated = cellText;
      }
    }
    return row;
  }

  /// Builds a Cashflow row object from saved values for a single ratio.
  CashFlowSheetAnalysisRow mkCashflowRowFromSaved(
    String key,
    List<FinancialValue> savedItems,
    String unavailableText,
  ) {
    final String firstRatioCode = savedItems.first.financialRatioType.trim();
    final bool isCodeBased =
        firstRatioCode.isNotEmpty && firstRatioCode.toLowerCase() != "null";

    final CashFlowSheetAnalysisRow row = CashFlowSheetAnalysisRow(
      id: key,
      cashFlowItems: displayNameForCode(key),
      audited1: unavailableText,
      audited2: unavailableText,
      audited3: unavailableText,
      inhouse: unavailableText,
      estimated: unavailableText,
      isNew: !isCodeBased,
    );

    final int maxVisibleColumns = incomeStatements.length.clamp(0, 5);
    for (int columnIndex = 0; columnIndex < maxVisibleColumns; columnIndex++) {
      final Statement headerStatement = incomeStatements[columnIndex];
      String fmtStmtDate(DateTime dateTimeValue) =>
          DateFormat("yyyy-MM-dd").format(dateTimeValue);
      final FinancialValue matchedValue = savedItems.firstWhere(
        (x) =>
            x.financialYear == headerStatement.date.year &&
            parseSavedMonths(x.period) == headerStatement.periods,
        orElse: () => FinancialValue(
          financialsCategory: categoryCashflow,
          financialRatioType: key,
          userAddedRatioType: null,
          financialYear: headerStatement.date.year,
          statementDate: fmtStmtDate(headerStatement.date),
          period: "${headerStatement.periods}M",
          auditMethod: "",
          auditor: "",
          value: null,
        ),
      );
      final double? numericValue = matchedValue.value;
      final String cellText = (numericValue == null)
          ? unavailableText
          : numericValue.toStringAsFixed(2);
      if (columnIndex == 0) {
        row.audited1 = cellText;
      } else if (columnIndex == 1) {
        row.audited2 = cellText;
      } else if (columnIndex == 2) {
        row.audited3 = cellText;
      } else if (columnIndex == 3) {
        row.inhouse = cellText;
      } else if (columnIndex == 4) {
        row.estimated = cellText;
      }
    }
    return row;
  }

  /// Builds a Balance row object from saved values for a single ratio.
  BalanceSheetAnalysisRow mkBalanceRowFromSaved(
    String ratioKey,
    List<FinancialValue> savedItems,
    String unavailableText,
  ) {
    final String firstRatioCode = savedItems.first.financialRatioType.trim();
    final bool isCodeBased =
        firstRatioCode.isNotEmpty && firstRatioCode.toLowerCase() != "null";

    final BalanceSheetAnalysisRow row = BalanceSheetAnalysisRow(
      id: ratioKey,
      balanceSheet: displayNameForCode(ratioKey),
      audited1: unavailableText,
      audited2: unavailableText,
      audited3: unavailableText,
      inhouse: unavailableText,
      estimated: unavailableText,
      isNew: !isCodeBased,
    );

    final int maxVisibleColumns = incomeStatements.length.clamp(0, 5);
    for (int columnIndex = 0; columnIndex < maxVisibleColumns; columnIndex++) {
      final Statement headerStatement = incomeStatements[columnIndex];
      String fmtStmtDate(DateTime dateTimeValue) =>
          DateFormat("yyyy-MM-dd").format(dateTimeValue);
      final FinancialValue matchingValue = savedItems.firstWhere(
        (FinancialValue candidate) =>
            candidate.financialYear == headerStatement.date.year &&
            parseSavedMonths(candidate.period) == headerStatement.periods,
        orElse: () => FinancialValue(
          financialsCategory: 237,
          financialRatioType: ratioKey,
          userAddedRatioType: null,
          financialYear: headerStatement.date.year,
          statementDate: fmtStmtDate(headerStatement.date),
          period: "${headerStatement.periods}M",
          auditMethod: "",
          auditor: "",
          value: null,
        ),
      );
      final double? numericValue = matchingValue.value;
      final String cellText = (numericValue == null)
          ? unavailableText
          : numericValue.toStringAsFixed(2);
      if (columnIndex == 0) {
        row.audited1 = cellText;
      } else if (columnIndex == 1) {
        row.audited2 = cellText;
      } else if (columnIndex == 2) {
        row.audited3 = cellText;
      } else if (columnIndex == 3) {
        row.inhouse = cellText;
      } else if (columnIndex == 4) {
        row.estimated = cellText;
      }
    }
    return row;
  }

  /// Returns a header “constant” value for the given statement column.
  ///
  /// In this screen, each header column can include extra metadata (stored as
  /// [StatementConst] inside [Statement.statementConsts]) such as:
  /// - audit method (constIndex = 0)
  /// - auditor name (constIndex = 1)
  ///
  /// If the requested indices are out of range, or the value is blank, this
  /// returns [unavailableText].
  ///
  /// Special case:
  /// - If the audit method is `"Unqualif'd"` (ServerConstants.unqualified),
  ///   UI requires prefix `"Audited-"`, so we return `"Audited-Unqualif'd".
  String getConstValue(int statementIndex, int constIndex) {
    final List<Statement> headerStatements = incomeStatements;
    if (statementIndex < 0 || statementIndex >= headerStatements.length) {
      return unavailableText;
    }

    final Statement headerStatement = headerStatements[statementIndex];
    final List<StatementConst> constList = headerStatement.statementConsts;
    if (constIndex < 0 || constIndex >= constList.length) {
      return unavailableText;
    }

    final String rawConstValue = constList[constIndex].value.trim();
    if (rawConstValue.isEmpty) {
      return unavailableText;
    }

    if (rawConstValue == ServerConstants.unqualified) {
      return "Audited-$rawConstValue ";
    }
    return rawConstValue;
  }

  /// Formats the table header label for a given column index.
  ///
  /// Output format:
  /// `MMM-yyyy (nM)`
  /// Example: `Dec-2024 (12M)`
  ///
  /// If [index] is invalid (out of range), returns [unavailableText].
  String getHeaderDate(int index) {
    if (index < 0 || index >= incomeStatements.length) {
      return unavailableText;
    }
    final Statement headerStatement = incomeStatements[index];
    return "${DateFormat('MMM-yyyy').format(headerStatement.date)} (${headerStatement.periods}M)";
  }

  /// Normalizes cell values before displaying them in the table.
  ///
  /// - If the row is user-added ([isNew] == true), return the raw trimmed input
  ///   (so the user sees exactly what they typed).
  /// - Otherwise, show [unavailableText] when the value is empty.
  /// - [rowIndex] is currently not used but retained for API compatibility.
  String rowValue(String? value, {bool isNew = false, int? rowIndex}) {
    final String trimmedValue = value?.trim() ?? "";
    if (isNew) {
      return trimmedValue;
    }

    return formatNumberForDisplay(trimmedValue);
  }

  /// Adds a new **user-added** row to the Income Statement table.
  ///
  /// Business rules:
  /// - Maximum 10 user-added rows are allowed.
  /// - Row id uses a unique `"u-<microseconds>"` prefix to distinguish new rows.
  /// - Emits loaded state to refresh UI.
  void addIncomeRow() {
    final int userAddedRowCount = incomeStatementRows
        .where((IncomeStatementAnalysisRow row) => row.isNew)
        .length;
    if (userAddedRowCount >= 10) {
      AlertManager().showFailureToast(
        "remarks.financialRatiosAnalysis.addRowsError".tr(),
      );
      return;
    }

    final String newId = "u-${DateTime.now().microsecondsSinceEpoch}";

    incomeStatementRows.add(
      IncomeStatementAnalysisRow(id: newId, isNew: true),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a new **user-added** row to the Cahflow Statement table.
  ///
  /// Business rules:
  /// - Maximum 10 user-added rows are allowed.
  /// - Row id uses a unique `"u-<microseconds>"` prefix to distinguish new rows.
  /// - Emits loaded state to refresh UI.
  void addCashflowRow() {
    final int userAddedRowCount = cashflowSheetRows
        .where((CashFlowSheetAnalysisRow row) => row.isNew)
        .length;
    if (userAddedRowCount >= 10) {
      AlertManager().showFailureToast(
        "remarks.financialRatiosAnalysis.addRowsError".tr(),
      );
      return;
    }
    final String newId = "u-${DateTime.now().microsecondsSinceEpoch}";

    // final String newId = DateTime.now().millisecondsSinceEpoch.toString();
    cashflowSheetRows.add(
      CashFlowSheetAnalysisRow(id: newId, isNew: true),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a new **user-added** row to the Balance Sheet table.
  ///
  /// Business rules:
  /// - Maximum 10 user-added rows are allowed.
  /// - Row id uses a unique `"u-<microseconds>"` prefix to distinguish new rows.
  /// - Emits loaded state to refresh UI.
  void addBalanceRow() {
    final int userAddedRowCount = balanceSheetRows
        .where((BalanceSheetAnalysisRow row) => row.isNew)
        .length;
    if (userAddedRowCount >= 10) {
      AlertManager().showFailureToast(
        "remarks.financialRatiosAnalysis.addRowsError".tr(),
      );
      return;
    }
    final String newId = "u-${DateTime.now().microsecondsSinceEpoch}";

    // final String newId = DateTime.now().millisecondsSinceEpoch.toString();
    balanceSheetRows.add(
      BalanceSheetAnalysisRow(id: newId, isNew: true),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes the Income Statement row with the given [id].
  ///
  /// Removes it from the list and re‐emits loaded.
  void deleteIncomeRow(String id) {
    incomeStatementRows
        .removeWhere((IncomeStatementAnalysisRow row) => row.id == id);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes the Cashflow Statement row with the given [id].
  void deleteCashflowRow(String id) {
    cashflowSheetRows
        .removeWhere((CashFlowSheetAnalysisRow row) => row.id == id);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes the Balance Sheet row with the given [id].
  void deleteBalanceRow(String id) {
    balanceSheetRows.removeWhere((BalanceSheetAnalysisRow row) => row.id == id);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the cubit state with the current entity id typed in the UI.
  ///
  /// This ensures the search section and save payload have a numeric entity id.
  /// If parsing fails, entity id becomes 0.
  void updateEntityId(String text) {
    final int parsedEntityId = int.tryParse(text.trim()) ?? 0;
    emit(state.copyWith(currentEntityId: parsedEntityId));
  }

  /// Converts UI audit method value into backend-safe audit method.
  ///
  /// UI sometimes prepends `"Audited-"` (for display), but backend expects the raw value.
  /// This method strips that prefix if presen
  String auditMethodForSave(String method) {
    final String trimmedMethod = method.trim();
    return trimmedMethod.startsWith("Audited-")
        ? trimmedMethod.replaceFirst("Audited-", "")
        : trimmedMethod;
  }

  /// Map placeholders to empty string instead of null, so fetch → show symmetry
  /// holds.
  String auditorForSave(String auditorRaw) {
    final String raw = auditorRaw.trim();
    if (raw.isEmpty ||
        raw.toLowerCase() == unavailableText.toLowerCase() ||
        raw.toLowerCase() == ServerConstants.dataNotAvailable) {
      return ""; // return empty string, not null
    }
    return raw;
  }

  /// Build one FinancialValue per visible column for a row:
  /// - 5 columns: audited1, audited2, audited3, inhouse, estimated
  /// - Do NOT skip NA/empty/NaN cells; we still emit a FinancialValue with value=null.
  /// - Periods and year are taken from the shared headers (incomeStatements).
  List<FinancialValue> valuesFromRow({
    required String? ratioCode,
    required String? userAddedType,
    required List<String> cols,
    required int categoryId, // 234 / 236 / 237
  }) {
    final List<FinancialValue> out = <FinancialValue>[];

    for (int columnIndex = 0;
        columnIndex < cols.length &&
            columnIndex < incomeStatements.length &&
            columnIndex < 5;
        columnIndex++) {
      final Statement s = incomeStatements[columnIndex];
      final String raw = cols[columnIndex].trim();
      final double? valueDouble = double.tryParse(raw);
      final String auditMethod =
          auditMethodForSave(getConstValue(columnIndex, 0));
      final String auditor = auditorForSave(getConstValue(columnIndex, 1));
      final String stmtDate = DateFormat("yyyy-MM-dd").format(s.date);

      out.add(
        FinancialValue(
          financialsCategory: categoryId,
          financialRatioType: ratioCode ?? "",
          userAddedRatioType: userAddedType,
          financialYear: s.date.year,
          period: "${s.periods}M",
          auditMethod: auditMethod,
          statementDate: stmtDate,
          auditor: auditor,
          value: valueDouble,
        ),
      );
    }

    return out;
  }

  /// Saves Financial Ratio Analysis.
  ///
  /// Save logic has two paths:
  /// 1) If backend does NOT yet have financial details:
  ///    - Save the "Description of Accounts" via remarks strategy comment API.
  /// 2) If backend HAS financial details:
  ///    - Build the Financial Ratio Analysis payload and save via remarks API.
  ///
  /// After success:
  /// - delete draft (fire-and-forget)
  /// - show toast
  /// - if [isContinue] is true, navigate to next tab/rout
  Future<void> onSavePress(
    BuildContext context, {
    required bool isContinue,
  }) async {
    try {
      repository ??= RemarksRepository.instance;
      final String descComment = await descTextController.getText();
      if (!isCorporateApp && descComment.isEmpty) {
        AlertManager().showFailureToast(
          "remarks.financialRatiosAnalysis.descriptionAccountsRequired".tr(),
        );
        return;
      }
      if (!hasExistingFinancialDetails) {
        final Comment comment = Comment.fromInputData(
          strategyComment: descComment,
          categoryType: state.activeTab.name,
          type: CommentsType.remarks,
          entityType: EntityIdentifier.remarks,
          categoryId: ServerConstants.remarksTabId[state.activeTab],
          rimNo: selectedCustomer?.customerRimNo,
        );
        await RequestRepository.instance
            .saveRemarkStrategyData(selectedCustomer, comment);

        description = descComment;
        descTextController.setText(descComment);

        unawaited(deleteDraft()); // Fire-and-forget
        if (descComment.isNotEmpty) {
          AlertManager().showSuccessToast(
            "remarks.financialRatiosAnalysis.savedSuccessfully".tr(),
          );
        }
        if (isContinue) {
          navigate();
        }
        return;
      } else {
        final List<FinancialRatioAnalysisResponse> items =
            await buildSaveItems(descComment);

        final List<FinancialRatioAnalysisResponse> saved =
            await repository!.saveFinancialRatioAnalysisDetails(items: items);

        //  keep UI in sync after save (use server response if present)
        final String savedDesc = saved.isNotEmpty
            ? (saved.first.descOfAccounts ?? descComment)
            : descComment;

        description = savedDesc;
        descTextController.setText(savedDesc);

        unawaited(deleteDraft()); // Fire-and-forget

        AlertManager().showSuccessToast(
          "remarks.financialRatiosAnalysis.savedSuccessfully".tr(),
        );
        if (isContinue) {
          navigate();
        }
      }
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// This method composes a single [FinancialRatioAnalysisResponse] containing:
  /// - Description of Accounts (required)
  /// - Entity block (entity id + long name)
  /// - Category blocks (Income/Cashflow/Balance) if there are rows to save
  /// - Remarks for each category (from rich-text editors)
  /// - Financial health selections for each category (from dropdowns)
  ///
  /// Notes for new developers:
  /// - We only include table remarks if tables are visible (CreditLens data OR saved analysis exists),
  ///   otherwise we send empty remarks.
  /// - `rows` are copied into snapshots before building payload so that mid-render UI changes do not
  ///   mutate the list while we are building the save object.
  Future<List<FinancialRatioAnalysisResponse>> buildSaveItems(
    String descComment,
  ) async {
    final bool shouldIncludeTableRemarks =
        hasCreditLensData || hasSavedAnalysisData;

    final String incomeStatementRemarks = shouldIncludeTableRemarks
        ? await incomeStatementController.getText()
        : "";
    final String cashflowStatementRemarks =
        shouldIncludeTableRemarks ? await cashflowController.getText() : "";
    final String balanceSheetRemarks =
        shouldIncludeTableRemarks ? await balanceSheetcontroller.getText() : "";

    // Snapshot the row lists (prevents accidental mutation while building payload).
    final List<IncomeStatementAnalysisRow> incomeRowsSnapshot =
        List<IncomeStatementAnalysisRow>.from(incomeStatementRows);
    final List<CashFlowSheetAnalysisRow> cashflowRowsSnapshot =
        List<CashFlowSheetAnalysisRow>.from(cashflowSheetRows);
    final List<BalanceSheetAnalysisRow> balanceRowsSnapshot =
        List<BalanceSheetAnalysisRow>.from(balanceSheetRows);

    final List<FinancialCategoryDetail> categories = [];

    if (incomeRowsSnapshot.isNotEmpty) {
      categories.add(
        categoryBlock(
          categoryId: categoryIncome,
          remarksText: incomeStatementRemarks,
          healthId: selectedIncomeHealth?.id, // if you have per-category health
          rows: incomeRowsSnapshot, // ← live list
        ),
      );
    }

    if (cashflowRowsSnapshot.isNotEmpty) {
      categories.add(
        categoryBlock(
          categoryId: categoryCashflow,
          remarksText: cashflowStatementRemarks,
          healthId: selectedCashFlowHealth?.id,
          rows: cashflowRowsSnapshot, // ← live list
        ),
      );
    }

    if (balanceRowsSnapshot.isNotEmpty) {
      categories.add(
        categoryBlock(
          categoryId: categoryBalance,
          remarksText: balanceSheetRemarks,
          healthId: selectedBalanceSheetHealth?.id,
          rows: balanceRowsSnapshot, // ← live list
        ),
      );
    }

    // Entity id is stored in cubit state because it is updated through UI search field.
    final int entityIdToSave = state.currentEntityId ?? 0;

    final EntityDetail entityBlock = EntityDetail(
      customerFinancialsId: null,
      entityId: entityIdToSave,
      entityLongName: longName ?? "",
      financialsCategory: categories,
    );

    final DateTime nowUtc = DateTime.now().toUtc();
    final FinancialRatioAnalysisResponse payloadItem =
        FinancialRatioAnalysisResponse(
      customerFinancialsId: null,
      appRefNo: Globals.request?.applicationRefNo ?? "",
      rimNo: selectedCustomer?.customerRimNo ?? 0,
      customerName: (selectedCustomer?.customerName?.trim().isNotEmpty ?? false)
          ? selectedCustomer!.customerName!.trim()
          : "",
      descOfAccounts: descComment,
      entityDetails: [entityBlock],
      createdBy: Globals.user?.name,
      createdDate: nowUtc,
      updatedBy: Globals.user?.name,
      updatedDate: nowUtc,
    );

    return [payloadItem];
  }

  /// Updates the entity long name displayed in the UI header.
  ///
  /// This is typically edited in the UI and used in the save payload.
  /// No state emit is required because the UI generally reads this directly.
  void updateLongName(String text) {
    longName = text.trim(); // keep it clean; no state emit needed
  }

  /// Builds a `FinancialCategoryDetail` block for a specific category:
  /// - Income (234)
  /// - Cashflow (236)
  /// - Balance (237)
  ///
  /// Each row is expanded into multiple [FinancialValue] entries (one per visible column).
  ///
  /// Key rules:
  /// - User-added rows are forced to use financialRatioType = "0".
  /// - Completely empty user-added rows (no label + all cells empty) are skipped.
  /// - We still include values with `value = null` for empty cells to preserve column structure.
  FinancialCategoryDetail categoryBlock({
    required int categoryId, // 234 / 236 / 237
    required String remarksText,
    required int? healthId,
    required List<dynamic> rows, // income / cashflow / balance rows
  }) {
    final List<FinancialValue> allCategoryValues = <FinancialValue>[];

    for (final dynamic rowItem in rows) {
      final String resolvedRatioCode =
          (!rowItem.isNew && (rowItem.id?.isNotEmpty ?? false))
              ? rowItem.id!
              : "0";

      final String labelFromRowType = labelForRow(rowItem);

      final String resolvedLabel = labelFromRowType.isNotEmpty
          ? labelFromRowType
          : (rowItem is CashFlowSheetAnalysisRow
              ? rowItem.cashFlowItems
              : rowItem is IncomeStatementAnalysisRow
                  ? rowItem.incomePositions
                  : rowItem is BalanceSheetAnalysisRow
                      ? rowItem.balanceSheet
                      : "");

      final List<String> columnValues = <String>[
        rowItem.audited1 ?? "",
        rowItem.audited2 ?? "",
        rowItem.audited3 ?? "",
        rowItem.inhouse ?? "",
        rowItem.estimated ?? "",
      ];

      //Skip untouched user‑added rows (no label AND all cells empty)
      final bool isEmptyUserAddedRow = (rowItem.isNew ?? false) &&
          resolvedRatioCode == "0" &&
          resolvedLabel.isEmpty &&
          columnValues.every((String cell) => cell.trim().isEmpty);

      if (isEmptyUserAddedRow) {
        continue; // ← do not emit values for this row; keeps payload clean
      }

      // Convert row into FinancialValue list.
      final List<FinancialValue> mappedValues = valuesFromRow(
        ratioCode: resolvedRatioCode == "0"
            ? null
            : resolvedRatioCode, // user-added → null (we stamp "0" below)
        userAddedType:
            (rowItem.isNew && resolvedRatioCode == "0") ? resolvedLabel : null,
        cols: columnValues,
        categoryId: categoryId,
      )
          .map(
            (FinancialValue valueItem) => FinancialValue(
              financialsCategory: categoryId,
              financialRatioType: (resolvedRatioCode == "0")
                  ? "0"
                  : valueItem
                      .financialRatioType, // force "0" for user-added rows
              userAddedRatioType: valueItem.userAddedRatioType,
              financialYear: valueItem.financialYear,
              statementDate: valueItem.statementDate,
              period: valueItem.period,
              auditMethod: valueItem.auditMethod,
              auditor: valueItem.auditor,
              value: valueItem.value, // null allowed
            ),
          )
          .toList();

      allCategoryValues.addAll(mappedValues);
    }

    return FinancialCategoryDetail(
      financialsCategory: categoryId,
      financialsValues: allCategoryValues, // includes NA/null entries
      financialHealth: healthId,
      remarks: remarksText.isNotEmpty ? remarksText : null,
    );
  }

  /// Extracts the label field from a row object based on its runtime type.
  ///
  /// This is used when building save payloads to determine the label/value typed by user.
  /// - Income row label => `incomePositions`
  /// - Cashflow row label => `cashFlowItems`
  /// - Balance row label => `balanceSheet`
  String labelForRow(Object? row) {
    if (row is IncomeStatementAnalysisRow) {
      return row.incomePositions;
    }
    if (row is CashFlowSheetAnalysisRow) {
      return row.cashFlowItems;
    }
    if (row is BalanceSheetAnalysisRow) {
      return row.balanceSheet;
    }
    return "";
  }

  /// Deletes a user-added Income Statement row.
  ///
  /// Behavior:
  /// - If row id starts with `"u-"`, it is unsaved (UI-only) => remove locally.
  /// - Otherwise, it exists in backend => delete via API first, then remove locally.
  Future<void> deleteUserAddedIncomeRow(IncomeStatementAnalysisRow row) async {
    try {
      final bool isUnsavedRow = row.id.startsWith("u-");

      if (!isUnsavedRow) {
        repository ??= RemarksRepository.instance;
        final int rimNo = selectedCustomer?.customerRimNo ?? 0;
        final int currentEntityId = state.currentEntityId ?? 0;
        await repository!.deleteFinancialRatioAnalysisDetails(
          rimNo: rimNo,
          entityId: currentEntityId,
          financialsCategory: categoryIncome, // 234
          userAddedRatioType: row.incomePositions, // label user typed
        );
      }
      incomeStatementRows.removeWhere(
        (IncomeStatementAnalysisRow existingRow) => existingRow.id == row.id,
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showSuccessToast("Deleted successfully");
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Deletes a user-added Cashflow Statement row.
  ///
  /// Behavior:
  /// - If row id starts with `"u-"`, it is unsaved (UI-only) => remove locally.
  /// - Otherwise, it exists in backend => delete via API first, then remove locally
  Future<void> deleteUserAddedCashflowRow(CashFlowSheetAnalysisRow row) async {
    try {
      final bool isUnsavedRow = row.id.startsWith("u-");
      if (!isUnsavedRow) {
        repository ??= RemarksRepository.instance;
        final int rimNo = selectedCustomer?.customerRimNo ?? 0;
        final int currentEntityId = state.currentEntityId ?? 0;
        await repository!.deleteFinancialRatioAnalysisDetails(
          rimNo: rimNo,
          entityId: currentEntityId,
          financialsCategory: categoryCashflow, // 236
          userAddedRatioType: row.cashFlowItems, // label user typed
        );
      }
      cashflowSheetRows.removeWhere(
        (CashFlowSheetAnalysisRow existingRow) => existingRow.id == row.id,
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showSuccessToast("Deleted successfully");
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Deletes a user-added Balance Sheet row.
  ///
  /// Behavior:
  /// - If row id starts with `"u-"`, it is unsaved (UI-only) => remove locally.
  /// - Otherwise, it exists in backend => delete via API first then remove locally.
  Future<void> deleteUserAddedBalanceRow(BalanceSheetAnalysisRow row) async {
    try {
      final bool isUnsavedRow = row.id.startsWith("u-");
      if (!isUnsavedRow) {
        repository ??= RemarksRepository.instance;
        final int rimNo = selectedCustomer?.customerRimNo ?? 0;
        final int currentEntityId = state.currentEntityId ?? 0;
        await repository!.deleteFinancialRatioAnalysisDetails(
          rimNo: rimNo,
          entityId: currentEntityId,
          financialsCategory: categoryBalance, // 237
          userAddedRatioType: row.balanceSheet, // label user typed
        );
      }
      balanceSheetRows.removeWhere(
        (BalanceSheetAnalysisRow existingRow) => existingRow.id == row.id,
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showSuccessToast("Deleted successfully");
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Navigates to the next *visible* tab (filtered by customer/FI rules)
  /// in sequence, or to the next route if at the end
  void navigate() {
    // Filtering requires a customer; if none, just fall through to the next route.
    final Customer? currentCustomer = selectedCustomer;
    if (currentCustomer == null) {
      LayoutViewModel().goToNextRoute();
      return;
    }

    // Visibility rules (e.g. isFI) that hide certain tabs for non-FI customers.
    final Map<RemarksTabs, bool Function()> tabVisibilityRules =
        TabConstants.getRemarksRoutes(currentCustomer);

    // Keep remarksRoutes' original order, but drop tabs hidden for this customer.
    final List<RemarksTabs> orderedVisibleTabs =
        TabConstants.remarksRoutes.entries
            .where((entry) {
              // No rule => always visible; otherwise defer to the rule.
              final bool Function()? isVisible = tabVisibilityRules[entry.key];
              return isVisible == null || isVisible();
            })
            .map((entry) => entry.key)
            .toList();

    // Locate the current tab within the filtered/visible list.
    final int currentIndex = orderedVisibleTabs.indexOf(state.activeTab);
    if (currentIndex != -1 && currentIndex < orderedVisibleTabs.length - 1) {
      // Advance to the next visible tab.
      changeTab(orderedVisibleTabs[currentIndex + 1]);
      return;
    }
    // No next visible tab => hand off to the layout's next route.
    LayoutViewModel().goToNextRoute();
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers (kept)
  // ---------------------------------------------------------------------------

  /// Navigates to a specific Remarks tab.
  ///
  /// Why we pass `extra: tab`:
  /// - Some routes (like `Routes.remarksCommonTabs`) reuse a single screen
  ///   for multiple tabs, and the tab is chosen based on router `extra`.
  Future<void> changeTab(RemarksTabs tab) async {
    router.go(TabConstants.remarksRoutes[tab]!, extra: tab);
  }

  /// Updates which tabs show mandatory asterisks based on selected customer.
  Future<void> setAsterisks() async {
    showAsteriskTabs = Utils.getMandatoryRemarksTabs(selectedCustomer);

    emit(state.copyWith(loaderStatus: state.loaderStatus));
  }

  /// Only FI types should show the "View more / View less" affordance.
  /// Country (and other non-FI) show all chips without the toggle.
  bool get showViewMore =>
      selectedCustomer?.type == CustomerType.belowInvestmentGradeBanks ||
      selectedCustomer?.type == CustomerType.investmentGradeBanks;

  /// Updates the current entity id from outside this ViewModel.
  ///
  /// Useful when another widget wants to drive the entity search section.
  /// This only updates the Cubit state; it does not automatically fetch CreditLens.
  void changeEntityIdExternally(int entityId) {
    emit(state.copyWith(currentEntityId: entityId));
  }

  /// Formats numeric table cell values for display with thousand separators
  /// and two decimal places.
  ///
  /// This method is intended only for UI display. It does not mutate the actual
  /// row values used for save payloads, so backend saving still receives clean
  /// numeric strings without commas.
  ///
  /// Examples:
  /// - `1234.5` becomes `1,234.50`
  /// - `1000000` becomes `1,000,000.00`
  /// - `-2500.75` becomes `-2,500.75`
  ///
  /// Non-numeric values such as unavailable text, empty values, or labels are
  /// returned safely without formatting.
  String formatNumberForDisplay(String value) {
    final String trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return unavailableText;
    }

    if (trimmedValue.toLowerCase() == unavailableText.toLowerCase() ||
        trimmedValue.toLowerCase() == ServerConstants.dataNotAvailable ||
        trimmedValue.toLowerCase() == "nan") {
      return unavailableText;
    }

    final String normalizedValue = trimmedValue.replaceAll(",", "");
    final double? number = double.tryParse(normalizedValue);

    if (number == null) {
      return trimmedValue;
    }

    return NumberFormat("#,##0.00").format(number);
  }
}
