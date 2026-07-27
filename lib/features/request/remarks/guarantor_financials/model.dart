import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
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
import "package:wcas_frontend/features/request/remarks/guarantor_financials/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/balance_sheet_analysis.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor_financial_response.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/remarks_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for the Guarantor Financial remarks tab.
///
/// Responsibilities:
/// - Fetch guarantor financial ratios from Credit Lens using Entity ID.
/// - Maintain one financial table per guarantor entity.
/// - Maintain one remarks editor per guarantor entity.
/// - Allow user-added financial rows.
/// - Build the save payload expected by backend.
/// - Support draft/autosave behavior.
///
/// FSD alignment:
/// - Guarantor Financials allows Entity ID search and Credit Lens ratio fetch.
/// - Users can add up to 10 manual financial rows.
/// - Values are editable and rounded/formatted to two decimals.
/// - SpreadSmart link is available through SSO.
/// - Remarks/autosave behavior must prevent user-entered data loss.
class GuarantorFinancialViewModel extends SafeCubit<GuarantorFinancialState>
    with DraftMixin<GuarantorFinancialViewModel> {
  GuarantorFinancialViewModel()
      : super(
          GuarantorFinancialState(
            guarantors: [
              Guarantor(
                entityId: 0,
                name: "",
                analysisHtml: "",
                spreadsmartUrl: EnvConfig.spreadSmartUrl,
              ),
            ],
          ),
        );

  /// Repository for fetching and persisting financial analysis data.
  RemarksRepository? repository;

  /// Service for fetching reference data.
  ReferenceDataService? _referenceDataService;

  /// Income statement rows grouped by guarantor entity ID.
  ///
  /// Each guarantor has its own financial table, so rows must not be stored
  /// in one shared list.
  final Map<int, List<IncomeStatementAnalysisRow>>
      _incomeStatementRowsByEntityId = {};

  /// Statement headers grouped by guarantor entity ID.
  ///
  /// These headers contain statement date, period, audit method, and auditor
  final Map<int, List<Statement>> _statementHeadersByEntityId = {};

  /// Guarantor/company long name grouped by entity ID.
  final Map<int, String> _entityLongNameByEntityId = {};

  /// Selected guarantor health value grouped by entity ID.
  final Map<int, Reference?> _selectedHealthByEntityId = {};

  /// Rich text editor controller grouped by entity ID.
  ///
  /// Each guarantor section has a separate remarks editor
  final Map<int, UnifiedEditorController> _remarksEditorByEntityId = {};

  /// Cached remarks text grouped by entity ID.
  ///
  /// This prevents remarks from being lost when the screen rebuilds.
  final Map<int, String> _remarksTextByEntityId = {};

  /// Returns the remarks editor for a guarantor entity.
  ///
  /// A separate editor is maintained for each guarantor because the page can
  /// display multiple guarantor sections at the same time
  UnifiedEditorController remarksEditorForEntity(int entityId) {
    return _remarksEditorByEntityId.putIfAbsent(
      entityId,
      UnifiedEditorController.new,
    );
  }

  /// Entity IDs already saved in backend.
  ///
  /// Used to decide whether delete should call backend API or only remove
  /// unsaved UI data.
  final Set<int> _savedEntityIds = <int>{};

  /// helper to read a cached remark for an entity (used as initial text)
  String remarksForEntity(int entityId) =>
      _remarksTextByEntityId[entityId] ?? "";

  /// comment: small helper getters (kept very lightweight)
  List<IncomeStatementAnalysisRow> incomeRowsFor(int entityId) =>
      _incomeStatementRowsByEntityId[entityId] ?? const [];

  /// Returns statement headers for the specified entity.
  List<Statement> statementsFor(int entityId) =>
      _statementHeadersByEntityId[entityId] ?? const [];

  /// Returns the long name for the specified entity.
  String? longNameFor(int entityId) => _entityLongNameByEntityId[entityId];

  /// Returns the selected health indicator for the specified entity.
  Reference? selectedHealthFor(int entityId) =>
      _selectedHealthByEntityId[entityId];

  /// Editor used when no guarantor financial tables(entity id data) are loaded yet.
  ///
  /// This stores the generic remarks strategy comment
  final UnifiedEditorController controller = UnifiedEditorController();

  /// Entity ID input controller for the first guarantor section.
  TextEditingController entityController = TextEditingController();

  /// Entity ID input controller for the first guarantor section.
  final ScrollController scrollController = ScrollController();

  /// Primary form key for validating and saving the main add‐guarantor tables.
  final GlobalKey<FormState> primaryFormKey = GlobalKey<FormState>();

  /// Secondary form key for validating and saving the add‐guarantor section.
  final GlobalKey<FormState> secondaryFormKey = GlobalKey<FormState>();

  /// Income Statement Analysis category identifier.
  static const int categoryIncome = ServerConstants.incomeFinancialCategory;

  /// Currently selected customer.
  Customer? selectedCustomer =
      Globals.selectedCustomer ?? Globals.request?.customers?.first;

  /// Available customers for selection.
  List<Customer>? customerList = [];

  /// List of all available customers from the global request.
  List<Customer> get customers => Globals.request?.customers ?? [];

  /// Indicates whether a customer change operation is in progress.
  bool isChangingCustomer = false;

  /// Indicates whether Credit Lens data is available.
  bool hasCreditLensData = false;

  /// Long name of the currently selected entity.
  String? longName;

  /// Short name of the currently selected entity.
  String? shortName;

  int? _draftEntityId;

  bool _isSaving = false;

  /// Indicates whether the Income Statement table should show an action column.
  bool get hasActionColumn => incomeStatementRows.any((r) => r.isNew);

  /// Income statement analysis rows.
  final List<IncomeStatementAnalysisRow> incomeStatementRows = [];

  /// Income statement column headers.
  List<Statement> incomeStatements = [];

  /// Financial category reference data.
  List<Reference>? financialCategory = [];

  /// Financial ratio type reference data.
  List<Reference>? financialRatioType = [];

  /// Financial health reference data.
  List<Reference>? financialHealth = [];

  /// Guarantor health reference data.
  List<Reference>? guarantorsHealth = [];

  /// Cached income statement rows.
  List<IncomeStatementAnalysisRow>? incomeRows = [];

  /// Balance sheet analysis rows.
  final List<BalanceSheet> balanceSheetRows = [];

  // Add a controller per _tabView section (non-first sections)
  final Map<int, TextEditingController> _entityInputControllersBySection =
      <int, TextEditingController>{};

  /// True if any Income Statement row is newly added and should show actions.
  bool get hasIncomeNewRows => incomeStatementRows.any((r) => r.isNew);

  /// True if any Balance Sheet row is newly added and should show actions.
  bool get hasBalanceNewRows => balanceSheetRows.any((r) => r.isNew);

  /// Selected health indicators for the Balance Sheet table.
  String unavailableText =
      "remarks.financialRatiosAnalysis.dataNotAvailable".tr();

  /// Selected balance sheet health indicator.
  Reference? selectedBalanceSheetHealth = Reference(name: "Select");

  /// Available balance sheet health options.
  List<Reference> balanceSheetHealth = [];

  /// Tabs marked as mandatory.
  List<RemarksTabs> showAsteriskTabs = [];

  /// Loaded remark data.
  Comment? commentData = Comment();

  /// Indicates whether saved analysis data is available.
  bool hasSavedAnalysisData = false;

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Indicates whether the page is in read-only mode.
  bool get isReadOnlyMode => pageMode == PageMode.view;

  /// Guarantor financial details identifier.
  int? guarantorFinancialsId;

  /// Guarantor remarks.
  String? guarantorRemarks;

  /// Indicates whether guarantor financial details already exist.
  bool hasExistingGuarantorDetails = false;

  /// Indicates whether the current section is the first section.
  final bool isFirstSection = false;

  // Holds the user-typed entity ID per section.
  final Map<int, int> _draftEntityIdBySection = <int, int>{};

  /// Indicates whether the current flow is for Financial Institutions.
  bool isFI = false;

  /// Returns a stable text controller for the specified section.
  TextEditingController textControllerForSection(int sectionEntityId) {
    return _entityInputControllersBySection.putIfAbsent(
      sectionEntityId,
      () {
        final TextEditingController textController = TextEditingController();
        if (sectionEntityId > 0) {
          textController.text = sectionEntityId.toString(); // first render seed
        }
        return textController;
      },
    );
  }

  /// Saved guarantor financial details.
  late GuarantorFinancialDetailsResponse guarantorFinancialDetails;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.remarks;

  @override
  String get draftFormKey => "${Routes.guarantorFinancials}_"
      "${selectedCustomer?.customerRimNo}_${state.activeTab.name}";

  @override
  DraftHandler<GuarantorFinancialViewModel> get draftHandler =>
      GuarantorFinancialDraftHandler();

  // ---------------------------------------------------------------------------

  /// Called from the view's `initState()`. Fetches repository instance
  /// and pre‐loads both Income Statement and Balance Sheet defaults.
  Future<void> init(BuildContext context) async {
    logger.i("initialising GuarantorFinancialViewModel");
    repository = RemarksRepository.instance;
    pageMode = AuthRepository.getPageMode(RightConstants.remarksCommentary);
    // for checkup with request type creditRisk
    isFI = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    defaultSelectedCustomer();
    await getChildRimsForGroup();
    await setAsterisks();
    await loadReferenceData();
    await fetchSavedGuarantorFinancialDetails();

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

  /// Loads reference data required for guarantor financial analysis.
  Future<void> loadReferenceData() async {
    try {
      final ReferenceDataService referenceDataService =
          _referenceDataService ?? ReferenceDataService();
      final Map<String, List<Reference>> referenceData =
          await referenceDataService.getReferenceData([
        ReferenceDataKeys.financialCategory,
        ReferenceDataKeys.financialRatioType,
        ReferenceDataKeys.cashflowStatementHealth,
        ReferenceDataKeys.guarantorsHealth,
      ]);
      financialCategory =
          referenceData[ReferenceDataKeys.financialCategory] ?? [];
      financialRatioType =
          referenceData[ReferenceDataKeys.financialRatioType] ?? [];
      financialHealth =
          referenceData[ReferenceDataKeys.cashflowStatementHealth] ?? [];
      guarantorsHealth =
          referenceData[ReferenceDataKeys.guarantorsHealth] ?? [];

      balanceSheetHealth = financialHealth ?? [];
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Loads child RIMs for group applications and updates
  /// the selected customer.
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

  /// Sets the default selected customer.
  void defaultSelectedCustomer() {
    selectedCustomer = ((Globals.request?.borrowers ?? []).isNotEmpty)
        ? Globals.request?.borrowers?.first
        : Globals.request?.customers?.first;
  }

  /// Loads remarks for the selected customer and active tab.
  Future<void> getRemarks() async {
    try {
      commentData = await RequestRepository.instance.getRemarkStrategyData(
            selectedCustomer,
            ServerConstants.commentTypeId[CommentsType.remarks],
            ServerConstants.remarksTabId[state.activeTab],
          ) ??
          Comment();

      final String? savedStrategyCommentText = commentData?.strategyComment;
      final String trimmedSavedStrategyComment =
          (savedStrategyCommentText == null)
              ? ""
              : savedStrategyCommentText.trim();
      final String displayStrategyComment =
          (trimmedSavedStrategyComment.isEmpty ||
                  trimmedSavedStrategyComment.toLowerCase() == "null")
              ? ""
              : trimmedSavedStrategyComment;

      controller.setText(displayStrategyComment);
    } on Object catch (e) {
      commentData = Comment();
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Populates income statement rows from Credit Lens financial data.
  void populateIncomeStatementRows(
    FinancialDetailsResponse financialDetailsResponse,
  ) {
    incomeStatementRows.clear();

    final List<Statement> headers =
        _canonicalHeaders(financialDetailsResponse.statements);
    incomeStatements = headers;

    const List<String> desiredNames = ServerConstants.desiredNames;
    String norm(String? referenceName) =>
        (referenceName ?? "").replaceAll(RegExp(r"[\s/_-]+"), "").toLowerCase();
    final Map<String, int> rowNameOrder = {
      for (int index = 0; index < desiredNames.length; index++)
        norm(desiredNames[index]): index,
    };
    final List<Reference> allFinancialRatioReferences =
        financialRatioType ?? [];
    final List<Reference> candidates = allFinancialRatioReferences
        .where((row) => rowNameOrder.containsKey(norm(row.name)))
        .toList()
      ..sort(
        (a, b) => (rowNameOrder[norm(a.name)] ?? 999)
            .compareTo(rowNameOrder[norm(b.name)] ?? 999),
      );
    final Map<String, Reference> uniqueByName = {};
    for (final Reference value in candidates) {
      final String key = norm(value.name);
      uniqueByName[key] = uniqueByName[key] ?? value;
    }
    final List<Reference> incomeRefs = desiredNames
        .map((label) => uniqueByName[norm(label)])
        .where((reference) => reference != null)
        .cast<Reference>()
        .toList();

    final List<IncomeStatementAnalysisRow> mergedRows = incomeRefs.map((ref) {
      final String ratioCode = ref.reference2 ?? "";
      final List<MacroItem> items = (ratioCode.isNotEmpty)
          ? (financialDetailsResponse.macros[ratioCode] ?? const [])
          : const [];

      final IncomeStatementAnalysisRow row = IncomeStatementAnalysisRow(
        id: ratioCode.isNotEmpty
            ? ratioCode
            : DateTime.now().millisecondsSinceEpoch.toString(),
        incomePositions: ref.name ?? "",
        audited1: unavailableText,
        audited2: unavailableText,
        audited3: unavailableText,
        inhouse: unavailableText,
        estimated: unavailableText, // 5th column
      );

      for (int statementColumnIndex = 0;
          statementColumnIndex < headers.length && statementColumnIndex < 5;
          statementColumnIndex++) {
        final Statement headerStatement = headers[statementColumnIndex];
        final String resolvedCellValue =
            _valForByDate(items, headerStatement, unavailableText);
        if (statementColumnIndex == 0) {
          row.audited1 = resolvedCellValue;
        } else if (statementColumnIndex == 1) {
          row.audited2 = resolvedCellValue;
        } else if (statementColumnIndex == 2) {
          row.audited3 = resolvedCellValue;
        } else if (statementColumnIndex == 3) {
          row.inhouse = resolvedCellValue;
        } else if (statementColumnIndex == 4) {
          row.estimated = resolvedCellValue;
        }
      }

      return row;
    }).toList();

    // Persist for the active entity (single-table path)
    final int entity = financialDetailsResponse.entityId;
    _incomeStatementRowsByEntityId[entity] = mergedRows;
    _statementHeadersByEntityId[entity] = headers;
    _entityLongNameByEntityId[entity] = financialDetailsResponse.longName;

    if (state.currentEntityId != null && state.currentEntityId == entity) {
      incomeStatementRows
        ..clear()
        ..addAll(mergedRows);
      incomeStatements = headers;
    }

    final List<IncomeStatementAnalysisRow> newRows =
        incomeStatementRows.where((row) => row.isNew).toList();
    incomeRows = [...mergedRows, ...newRows];
  }

  ///search and fetch credit lens data and populate into the
  ///table rows and columns as per section
  Future<void> searchEntityForSection(
    int sectionEntityId, {
    bool isFirstSection = false,
  }) async {
    repository ??= RemarksRepository.instance;
    final int typedId =
        _draftEntityIdBySection[sectionEntityId] ?? sectionEntityId;
    if (typedId <= 0) {
      AlertManager().showFailureToast(
        "remarks.financialRatiosAnalysis.entityIdRequired".tr(),
      );
      return;
    }
    try {
      //send only one entity id at a time if user search again with
      // new entity id without deletion not all id should add in save payload
      int? prevId;
      if (isFirstSection) {
        prevId = state.currentEntityId;
      } else {
        final int idx = state.guarantors.indexWhere(
          (guarantor) => (guarantor.entityId ?? 0) == sectionEntityId,
        );
        if (idx >= 0) {
          prevId = state.guarantors[idx].entityId;
        }
      }

      if (prevId != null && prevId > 0 && prevId != typedId) {
        _incomeStatementRowsByEntityId.remove(prevId);
        _statementHeadersByEntityId.remove(prevId);
        _entityLongNameByEntityId.remove(prevId);
        _selectedHealthByEntityId.remove(prevId);
        _remarksTextByEntityId.remove(prevId);
        _remarksEditorByEntityId.remove(prevId);
      }

      final UnifiedEditorController sourceCtrl =
          (hasCreditLensData || hasSavedAnalysisData)
              ? remarksEditorForEntity(
                  sectionEntityId,
                ) // already per-entity on this section
              : controller; // global editor before first search
      try {
        final String raw = await sourceCtrl
            .getText()
            .timeout(const Duration(milliseconds: 500));
        if (raw.isNotEmpty) {
          _remarksTextByEntityId[typedId] = raw;
          remarksEditorForEntity(typedId).setText(raw);
        }
      } on Object catch (_) {}

      final FinancialDetailsResponse resp =
          await repository!.getFinancialDetailsFromCreditLens(typedId);
      longName = resp.longName;
      shortName = resp.shortName;
      _populateCreditLensForSection(
        typedId,
        resp,
      ); // fills rows/headers for THIS section
      hasCreditLensData = true;
      hasExistingGuarantorDetails = true;
      if (isFirstSection) {
        entityController.text =
            typedId.toString(); // first section keeps controller
        emit(
          state.copyWith(
            firstSectionTablesVisible: true,
            currentEntityId: typedId, //  stamp current section id
          ),
        );
      } else {
        textControllerForSection(sectionEntityId).text = typedId.toString();
        final List<Guarantor> list = List<Guarantor>.from(state.guarantors);
        final int sectionIndex = list.indexWhere(
          (guarantor) => (guarantor.entityId ?? 0) == sectionEntityId,
        );
        if (sectionIndex >= 0) {
          final Guarantor guarantorSection = list[sectionIndex];
          list[sectionIndex] = Guarantor(
            entityId: typedId,
            name: guarantorSection.name,
            analysisHtml: guarantorSection.analysisHtml,
            spreadsmartUrl: guarantorSection.spreadsmartUrl,
            canDelete: guarantorSection.canDelete,
          );
          emit(state.copyWith(guarantors: list));
        }
      }

      emit(state.copyWith(buttonStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      incomeStatementRows.clear();
      incomeStatements.clear();
      incomeRows = [];
      longName = null;
      shortName = null;
      hasCreditLensData = false;

      emit(
        state.copyWith(
          firstSectionTablesVisible: false,
          buttonStatus: LoadingStatus.loaded,
        ),
      );

      AlertManager().showFailureToast(e.toString());
    }
  }

  //populate credit lens data into the table
  void _populateCreditLensForSection(
    int sectionEntityId,
    FinancialDetailsResponse financialDetailsResponse,
  ) {
    final List<Statement> headers =
        _canonicalHeaders(financialDetailsResponse.statements);
    _statementHeadersByEntityId[sectionEntityId] = headers;
    _entityLongNameByEntityId[sectionEntityId] =
        financialDetailsResponse.longName;

    const List<String> desiredNames = ServerConstants.desiredNames;
    String norm(String? s) =>
        (s ?? "").replaceAll(RegExp(r"[\s/_-]+"), "").toLowerCase();
    final Map<String, int> rowNameOrder = {
      for (int i = 0; i < desiredNames.length; i++) norm(desiredNames[i]): i,
    };
    final List<Reference> allRefs = financialRatioType ?? [];
    final List<Reference> candidates =
        allRefs.where((r) => rowNameOrder.containsKey(norm(r.name))).toList()
          ..sort(
            (a, b) => (rowNameOrder[norm(a.name)] ?? 999)
                .compareTo(rowNameOrder[norm(b.name)] ?? 999),
          );
    final Map<String, Reference> uniqueByName = {};
    for (final value in candidates) {
      final String key = norm(value.name);
      uniqueByName[key] = uniqueByName[key] ?? value;
    }
    final List<Reference> incomeRefs = desiredNames
        .map((label) => uniqueByName[norm(label)])
        .where((r) => r != null)
        .cast<Reference>()
        .toList();

    final List<IncomeStatementAnalysisRow> mergedRows =
        incomeRefs.map((financialRatioReference) {
      final String key = financialRatioReference.reference2 ?? "";
      final List<MacroItem> items = (key.isNotEmpty)
          ? (financialDetailsResponse.macros[key] ?? const [])
          : const [];

      final IncomeStatementAnalysisRow row = IncomeStatementAnalysisRow(
        id: key,
        incomePositions: financialRatioReference.name ?? "",
        audited1: unavailableText,
        audited2: unavailableText,
        audited3: unavailableText,
        inhouse: unavailableText,
        estimated: unavailableText,
      );

      for (int i = 0; i < headers.length && i < 5; i++) {
        final Statement statementHeader = headers[i];
        final String cellValue =
            _valForByDate(items, statementHeader, unavailableText);
        if (i == 0) {
          row.audited1 = cellValue;
        } else if (i == 1) {
          row.audited2 = cellValue;
        } else if (i == 2) {
          row.audited3 = cellValue;
        } else if (i == 3) {
          row.inhouse = cellValue;
        } else if (i == 4) {
          row.estimated = cellValue;
        }
      }

      return row;
    }).toList();

    _incomeStatementRowsByEntityId[sectionEntityId] = mergedRows;

    if (state.currentEntityId == sectionEntityId) {
      incomeStatementRows
        ..clear()
        ..addAll(mergedRows);
      incomeStatements = headers;
    }
  }

  /// Returns the display value for a guarantor financial table cell.
  ///
  /// Existing API/saved rows are formatted using number formatting, for example:
  /// `1234567.89` becomes `1,234,567.89`.
  ///
  /// Newly added editable rows are returned as raw values to avoid conflicts with
  /// input formatters while the user is typing.
  ///
  /// Empty, `NaN`, or unavailable values are displayed as [unavailableText].
  String rowValue(String? value, {bool isNew = false}) {
    final String trimmedValue = value?.trim() ?? "";

    if (isNew) {
      return trimmedValue;
    }

    return formatNumberForDisplay(trimmedValue);
  }

  /// Formats numeric table cell values for display with thousand separators
  /// and two decimal places.
  ///
  /// This method is intended only for UI display. It does not mutate the actual
  /// row values used for save payloads, so backend saving still receives clean
  /// numeric strings.
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

  /// Build canonical headers from CreditLens statements:
  /// - group by year
  /// - pick the latest month within the year
  /// - take the latest 5 years
  /// - order ascending (oldest → newest)
  List<Statement> _canonicalHeaders(List<Statement> input) {
    if (input.isEmpty) {
      return const <Statement>[];
    }
    final Map<int, Statement> latestFinancialValueByYear = {};
    for (final statement in input) {
      final int statementYear = statement.date.year;
      final Statement? currentLatestStatement =
          latestFinancialValueByYear[statementYear];
      if (currentLatestStatement == null ||
          statement.date.isAfter(currentLatestStatement.date)) {
        latestFinancialValueByYear[statementYear] = statement;
      }
    }
    final List<Statement> financialValuesSortedByYear =
        latestFinancialValueByYear.values.toList()
          ..sort((a, b) => a.date.compareTo(b.date)); // oldest → newest

    final int financialYearCount = financialValuesSortedByYear.length;
    return (financialYearCount <= 5)
        ? financialValuesSortedByYear
        : financialValuesSortedByYear.sublist(
            financialYearCount - 5,
            financialYearCount,
          );
  }

  /// Strict value lookup for a given header:
  /// - try exact stmtDate match
  /// - else use latest macro item in the same year
  /// Return `unavailableText` on "", NaN, or no match.
  String _valForByDate(
    List<MacroItem> items,
    Statement header,
    String unavailableText,
  ) {
    if (items.isEmpty) {
      return unavailableText;
    }

    // Exact date match
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

    // Latest month in same year
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

  /// Fetch and render retained guarantor details.
  /// - If responseData is empty → fetch only strategy comment (no tables).
  /// - If responseData has multiple entityDetails → render one _tabView per
  /// entity.
  Future<void> fetchSavedGuarantorFinancialDetails() async {
    try {
      repository ??= RemarksRepository.instance;
      final int rimNo = selectedCustomer?.customerRimNo ?? 0;
      if (rimNo <= 0) {
        return;
      }

      try {
        guarantorFinancialDetails =
            await repository!.getGuarantorFinancialDetails(rimNo: rimNo);
      } on Object catch (e, st) {
        logger.w(
          "Parsed empty saved details (responseData: [])."
          " Falling back to getRemarks().",
          error: e,
          stackTrace: st,
        );

        hasSavedAnalysisData = false;
        hasCreditLensData = false;
        hasExistingGuarantorDetails = false;

        await getRemarks();

        emit(
          state.copyWith(
            guarantors: [
              Guarantor(
                entityId: 0,
                name: "",
                analysisHtml: "",
                spreadsmartUrl: EnvConfig.spreadSmartUrl,
              ),
            ],
            clearCurrentEntityId: true,
            firstSectionTablesVisible: false,
            nextCanDelete: false,
            showExtraTab: false,
            canDeleteSection: false,
            loaderStatus: LoadingStatus.loaded,
          ),
        );

        return;
      }

      if (guarantorFinancialDetails.entityDetails.isEmpty) {
        hasSavedAnalysisData = false;
        hasCreditLensData = false;
        hasExistingGuarantorDetails = false;
        _savedEntityIds.clear();
        await getRemarks();

        emit(
          state.copyWith(
            guarantors: [
              Guarantor(
                entityId: 0,
                name: "",
                analysisHtml: "",
                spreadsmartUrl: EnvConfig.spreadSmartUrl,
              ),
            ],
            clearCurrentEntityId: true,
            firstSectionTablesVisible: false,
            nextCanDelete: false,
            showExtraTab: false,
            canDeleteSection: false,
            loaderStatus: LoadingStatus.loaded,
          ),
        );

        return;
      }

      _savedEntityIds
        ..clear()
        ..addAll(
          guarantorFinancialDetails.entityDetails
              .map((entityId) => entityId.entityId),
        );

      guarantorFinancialsId = guarantorFinancialDetails.guarantorFinancialsId ??
          guarantorFinancialsId;

      final List<Guarantor> sections = <Guarantor>[];
      for (int i = 0; i < guarantorFinancialDetails.entityDetails.length; i++) {
        final GuarantorEntityDetail entityDetail =
            guarantorFinancialDetails.entityDetails[i];
        final int incomeCategoryIndex = entityDetail.financialsCategory
            .indexWhere((c) => c.financialsCategory == categoryIncome);
        if (incomeCategoryIndex != -1) {
          final GuarantorCategoryDetail incomeCategory =
              entityDetail.financialsCategory[incomeCategoryIndex];

          final String remark = (incomeCategory.remarks ?? "").trim();
          if (remark.isNotEmpty) {
            _remarksTextByEntityId[entityDetail.entityId] = remark;
            remarksEditorForEntity(entityDetail.entityId).setText(remark);
          }

          final int? healthId = incomeCategory.guarantorHealth;
          final List<Reference> healthOptions = guarantorsHealth ?? [];
          if (healthId != null && healthOptions.isNotEmpty) {
            final int healthIndex =
                healthOptions.indexWhere((r) => r.id == healthId);
            _selectedHealthByEntityId[entityDetail.entityId] =
                (healthIndex >= 0) ? healthOptions[healthIndex] : null;
          } else {
            _selectedHealthByEntityId[entityDetail.entityId] = null;
          }
        }

        sections.add(
          Guarantor(
            entityId: entityDetail.entityId,
            name: "",
            analysisHtml: "",
            spreadsmartUrl: EnvConfig.spreadSmartUrl,
            canDelete: i > 0,
          ),
        );
      }

      final int firstEntityId =
          guarantorFinancialDetails.entityDetails.first.entityId;

      entityController.text = firstEntityId.toString();

      emit(
        state.copyWith(
          guarantors: sections,
          currentEntityId: firstEntityId,
          canDeleteSection: true,
        ),
      );

      populateIncomeStatementRowsFromSavedMulti(guarantorFinancialDetails);

      hasSavedAnalysisData = true;
      emit(
        state.copyWith(
          firstSectionTablesVisible: true,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
    } on Object catch (e, st) {
      logger.e(
        "Error fetching guarantor financial details",
        error: e,
        stackTrace: st,
      );
      hasSavedAnalysisData = false;
      _savedEntityIds.clear();
      await getRemarks();
    }
  }

  /// Populates income statement data for all entities from saved
  /// guarantor financial details.
  void populateIncomeStatementRowsFromSavedMulti(
    GuarantorFinancialDetailsResponse gResp,
  ) {
    for (final GuarantorEntityDetail ed in gResp.entityDetails) {
      _populateSavedForEntity(ed); // per-entity fill (below)
    }
  }

  /// Adds a new user-defined income statement row for the specified entity.
  void addIncomeRowForEntity(int entityId) {
    final List<IncomeStatementAnalysisRow> list =
        List<IncomeStatementAnalysisRow>.from(
      _incomeStatementRowsByEntityId[entityId] ?? const [],
    );
    final int userAddedCount = list.where((r) => r.isNew).length;
    if (userAddedCount >= 10) {
      AlertManager().showFailureToast(
        "remarks.financialRatiosAnalysis.addRowsError".tr(),
      );
      return;
    }
    final String newId = "u-$entityId-${DateTime.now().microsecondsSinceEpoch}";
    list.add(IncomeStatementAnalysisRow(id: newId, isNew: true));
    _incomeStatementRowsByEntityId[entityId] = list;
    if (state.currentEntityId == entityId) {
      incomeStatementRows
        ..clear()
        ..addAll(list);
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes a user-added income statement row for the specified entity.
  Future<void> deleteUserAddedIncomeRowForEntity(
    int entityId,
    IncomeStatementAnalysisRow row,
  ) async {
    try {
      final bool isUnsaved = row.id.startsWith("u-");

      if (!isUnsaved) {
        repository ??= RemarksRepository.instance;
        final int rimNo = selectedCustomer?.customerRimNo ?? 0;
        await repository!.deleteGuarantorDetails(
          rimNo: rimNo,
          entityId: entityId,
          financialsCategory: categoryIncome,
          userAddedRatioType: row.incomePositions, // the label user typed
        );
      }
      final List<IncomeStatementAnalysisRow> list =
          List<IncomeStatementAnalysisRow>.from(
        _incomeStatementRowsByEntityId[entityId] ?? const [],
      );
      _incomeStatementRowsByEntityId[entityId] = list
        ..removeWhere((incomeRow) => incomeRow.id == row.id);

      if (state.currentEntityId == entityId) {
        incomeStatementRows
          ..clear()
          ..addAll(list);
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showSuccessToast("Deleted successfully");
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  // per-entity fill used by the multi-entity helper
  void _populateSavedForEntity(GuarantorEntityDetail entityDetail) {
    final int entityId = entityDetail.entityId;
    final int incomeCategoryIndex = entityDetail.financialsCategory.indexWhere(
      (category) => category.financialsCategory == categoryIncome,
    );
    if (incomeCategoryIndex == -1) {
      return;
    }

    final GuarantorCategoryDetail incomeCategory =
        entityDetail.financialsCategory[incomeCategoryIndex];
    final List<GuarantorFinancialValue> savedFinancialValues =
        incomeCategory.financialsValues;

    final Map<String, GuarantorFinancialValue> uniqueFinancialValuesByKey = {};
    for (final GuarantorFinancialValue financialValue in savedFinancialValues) {
      final String ratioOrUserAddedKey =
          (financialValue.financialRatioType?.trim().isNotEmpty ?? false)
              ? financialValue.financialRatioType!.trim()
              : (financialValue.userAddedRatioType ?? "").trim();
      if (ratioOrUserAddedKey.isEmpty) {
        continue;
      }
      final int months = _parsePeriodMonths(financialValue.period);
      final String uniqueValueKey =
          "$ratioOrUserAddedKey|${financialValue.financialYear}|$months";
      uniqueFinancialValuesByKey[uniqueValueKey] = financialValue; // last wins
    }
    final List<GuarantorFinancialValue> deduplicatedFinancialValues =
        uniqueFinancialValuesByKey.values.toList();
    final List<Statement> headers =
        _buildStatementsFromSaved(deduplicatedFinancialValues);
    _statementHeadersByEntityId[entityId] = headers;
    _entityLongNameByEntityId[entityId] = entityDetail.entityLongName;

    final int? healthId = incomeCategory.guarantorHealth;
    final List<Reference> healthOptions = guarantorsHealth ?? [];
    if (healthId != null && healthOptions.isNotEmpty) {
      final int healthIndex = healthOptions.indexWhere((r) => r.id == healthId);
      _selectedHealthByEntityId[entityId] =
          (healthIndex >= 0) ? healthOptions[healthIndex] : null;
    } else {
      _selectedHealthByEntityId[entityId] = null;
    }

    final String remark = (incomeCategory.remarks ?? "").trim();
    _remarksTextByEntityId[entityId] = remark;
    remarksEditorForEntity(entityId).setText(remark);

    // Build per-entity rows
    String displayNameFor(String key) {
      final Reference ref = (financialRatioType ?? []).firstWhere(
        (r) => (r.reference2 ?? "") == key,
        orElse: () => Reference(name: ""),
      );
      return (ref.name?.isNotEmpty ?? false) ? ref.name! : key;
    }

    final Map<String, List<GuarantorFinancialValue>> financialValuesByRatioKey =
        {};
    for (final GuarantorFinancialValue financialValue
        in deduplicatedFinancialValues) {
      final String ratioOrUserAddedKey =
          (financialValue.financialRatioType?.trim().isNotEmpty ?? false)
              ? financialValue.financialRatioType!.trim()
              : (financialValue.userAddedRatioType ?? "").trim();
      if (ratioOrUserAddedKey.isEmpty) {
        continue;
      }
      financialValuesByRatioKey
          .putIfAbsent(ratioOrUserAddedKey, () => [])
          .add(financialValue);
    }

    final List<IncomeStatementAnalysisRow> rowsForEntity = [];
    final int maxStatementColumns = headers.length.clamp(0, 5);
    for (final MapEntry<String, List<GuarantorFinancialValue>> ratioGroupEntry
        in financialValuesByRatioKey.entries) {
      final String ratioCode = ratioGroupEntry.key;
      final List<GuarantorFinancialValue> items = ratioGroupEntry.value;
      final String firstFinancialRatioCode =
          (items.first.financialRatioType ?? "").trim();
      final bool isSystemDefinedRatioRow = firstFinancialRatioCode.isNotEmpty &&
          firstFinancialRatioCode.toLowerCase() != "null";
      final IncomeStatementAnalysisRow row = IncomeStatementAnalysisRow(
        id: ratioCode,
        incomePositions: displayNameFor(ratioCode),
        audited1: unavailableText,
        audited2: unavailableText,
        audited3: unavailableText,
        inhouse: unavailableText,
        estimated: unavailableText,
        isNew: !isSystemDefinedRatioRow,
      );

      for (int columnIndex = 0;
          columnIndex < maxStatementColumns;
          columnIndex++) {
        final Statement statementHeader = headers[columnIndex];
        final int months = statementHeader.periods;
        final int year = statementHeader.date.year;
        String formatStatementDate(DateTime d) =>
            DateFormat("yyyy-MM-dd").format(d);

        final GuarantorFinancialValue financialValue = items.firstWhere(
          (savedFinancialValue) =>
              savedFinancialValue.financialYear == year &&
              _parsePeriodMonths(savedFinancialValue.period) == months,
          orElse: () => GuarantorFinancialValue(
            financialsCategory: categoryIncome,
            financialRatioType: items.first.financialRatioType,
            userAddedRatioType: items.first.userAddedRatioType,
            statementDate: formatStatementDate(statementHeader.date),
            financialYear: year,
            period: "${months}M",
            auditMethod: "",
            auditor: "",
            value: null,
          ),
        );
        final String formattedSavedValue =
            _formatSavedValue(financialValue.value);
        if (columnIndex == 0) {
          row.audited1 = formattedSavedValue;
        } else if (columnIndex == 1) {
          row.audited2 = formattedSavedValue;
        } else if (columnIndex == 2) {
          row.audited3 = formattedSavedValue;
        } else if (columnIndex == 3) {
          row.inhouse = formattedSavedValue;
        } else if (columnIndex == 4) {
          row.estimated = formattedSavedValue;
        }
      }
      rowsForEntity.add(row);
    }

    _incomeStatementRowsByEntityId[entityId] = rowsForEntity;

    if (state.currentEntityId == entityId) {
      incomeStatements = headers;
      incomeStatementRows
        ..clear()
        ..addAll(rowsForEntity);
    }
  }

  int _parsePeriodMonths(String period) {
    final RegExpMatch? regexMatch = RegExp(r"(\d+)").firstMatch(period);
    if (regexMatch != null) {
      return int.tryParse(regexMatch.group(1)!) ?? 0;
    }
    return 0;
  }

  DateTime _dateFromSaved(GuarantorFinancialValue fv) {
    final String? sd = fv.statementDate;
    if (sd != null && sd.trim().isNotEmpty) {
      try {
        return DateTime.parse(
          sd.trim(),
        ); // full fidelity: uses the real month/day
      } on Object catch (_) {
        // fall through to the period-based fallback
      }
    }
    int months(String period) {
      final m = RegExp(r"(\d+)").firstMatch(period);
      return (m != null) ? int.tryParse(m.group(1)!) ?? 0 : 0;
    }

    final int mths = months(fv.period);
    final int month = (mths == 12) ? 12 : mths.clamp(1, 12);
    return DateTime(fv.financialYear, month);
  }

  /// Build canonical headers from saved values:
  /// - group by year
  /// - pick the latest month within the year
  /// - take the latest 5 years
  /// - order oldest → newest (for column display)
  List<Statement> _buildStatementsFromSaved(
    List<GuarantorFinancialValue> values,
  ) {
    if (values.isEmpty) {
      return const <Statement>[];
    }

    int parsePeriodMonthsOrZero(String period) {
      final RegExpMatch? regexMatch = RegExp(r"(\d+)").firstMatch(period);
      return (regexMatch != null) ? int.tryParse(regexMatch.group(1)!) ?? 0 : 0;
    }

    // latest value per year (by month)
    final Map<int, GuarantorFinancialValue> latestFinancialValueByYear = {};
    for (final GuarantorFinancialValue financialValue in values) {
      final int financialYear = financialValue.financialYear;
      final GuarantorFinancialValue? existing =
          latestFinancialValueByYear[financialYear];
      final bool isNewerPeriodValue = (existing == null) ||
          (parsePeriodMonthsOrZero(financialValue.period) >
              parsePeriodMonthsOrZero(existing.period));
      if (isNewerPeriodValue) {
        latestFinancialValueByYear[financialYear] = financialValue;
      }
    }

    // sort oldest → newest and keep last 5
    final List<GuarantorFinancialValue> financialValuesSortedByYear =
        latestFinancialValueByYear.values.toList()
          ..sort((firstFinancialValue, secondFinancialValue) {
            if (firstFinancialValue.financialYear !=
                secondFinancialValue.financialYear) {
              return firstFinancialValue.financialYear
                  .compareTo(secondFinancialValue.financialYear);
            }
            return parsePeriodMonthsOrZero(firstFinancialValue.period)
                .compareTo(
              parsePeriodMonthsOrZero(secondFinancialValue.period),
            );
          });

    final int financialYearCount = financialValuesSortedByYear.length;
    final List<GuarantorFinancialValue> latestFiveFinancialValues =
        (financialYearCount <= 5)
            ? financialValuesSortedByYear
            : financialValuesSortedByYear.sublist(
                financialYearCount - 5,
                financialYearCount,
              );

    return List<Statement>.generate(latestFiveFinancialValues.length, (index) {
      final GuarantorFinancialValue financialValue =
          latestFiveFinancialValues[index];
      final int periodMonths = parsePeriodMonthsOrZero(financialValue.period);
      final DateTime statementHeaderDate =
          _dateFromSaved(financialValue); //  use statementDate
      return Statement(
        id: index + 1,
        date: statementHeaderDate, // real month from API
        periods: periodMonths,
        statementConsts: [
          StatementConst(
            id: 0,
            value: financialValue.auditMethod,
          ), // audit method
          StatementConst(
            id: 1,
            value: financialValue.auditor ?? "",
          ), // auditor can be ""
        ],
      );
    });
  }

  String _formatSavedValue(double? savedValue) {
    if (savedValue == null) {
      return unavailableText;
    }
    final double truncated = (savedValue * 100).truncate() / 100.0;
    return truncated.toStringAsFixed(2);
  }

  /// Updates the selected health indicator for the specified entity.
  void setSelectedHealthFor(int entityId, Reference? reference) {
    _selectedHealthByEntityId[entityId] = reference;

    // Keep old active-entity variable in sync.
    // This prevents first section/draft/save flow from losing selected value.
    if (state.currentEntityId == entityId) {
      selectedBalanceSheetHealth = reference;
    }
  }

  /// Populate IncomeStatement rows from saved guarantor response (robust/deduped)
  void populateIncomeStatementRowsFromSaved(
    GuarantorFinancialDetailsResponse guarantorFinancialResponse,
  ) {
    incomeStatementRows.clear();

    final List<GuarantorCategoryDetail> allFinancialCategories =
        guarantorFinancialResponse.entityDetails
            .expand((entityId) => entityId.financialsCategory)
            .toList();
    final int incomeCategoryIndex = allFinancialCategories
        .indexWhere((c) => c.financialsCategory == categoryIncome);
    final GuarantorCategoryDetail? incomeCategory = (incomeCategoryIndex == -1)
        ? null
        : allFinancialCategories[incomeCategoryIndex];

    if (incomeCategory == null || incomeCategory.financialsValues.isEmpty) {
      return; // nothing to populate
    }

    final int entityId =
        guarantorFinancialResponse.entityDetails.first.entityId;

    final List<GuarantorFinancialValue> savedFinancialValues =
        incomeCategory.financialsValues;

    final Map<String, GuarantorFinancialValue> uniqueFinancialValuesByKey = {};
    for (final GuarantorFinancialValue value in savedFinancialValues) {
      final String ratioOrUserAddedKey =
          (value.financialRatioType?.trim().isNotEmpty ?? false)
              ? value.financialRatioType!.trim()
              : (value.userAddedRatioType ?? "").trim();
      if (ratioOrUserAddedKey.isEmpty) {
        continue;
      }

      final int months = _parsePeriodMonths(value.period);
      final String uniqueValueKey =
          "$ratioOrUserAddedKey|${value.financialYear}|$months";
      uniqueFinancialValuesByKey[uniqueValueKey] = value; // last wins
    }
    final List<GuarantorFinancialValue> deduplicatedFinancialValues =
        uniqueFinancialValuesByKey.values.toList();

    incomeStatements = _buildStatementsFromSaved(deduplicatedFinancialValues);
    final List<Statement> headers =
        _buildStatementsFromSaved(deduplicatedFinancialValues);
    final List<IncomeStatementAnalysisRow> rowsForEntity = [];

    _incomeStatementRowsByEntityId[entityId] = rowsForEntity;
    _statementHeadersByEntityId[entityId] = headers;
    _entityLongNameByEntityId[entityId] =
        guarantorFinancialResponse.entityDetails.first.entityLongName;

    _incomeStatementRowsByEntityId[entityId] = rowsForEntity;
    _statementHeadersByEntityId[entityId] = headers;
    _entityLongNameByEntityId[entityId] =
        guarantorFinancialResponse.entityDetails.first.entityLongName;

    final int? healthId = incomeCategory.guarantorHealth;
    final List<Reference> healthOptions = guarantorsHealth ?? [];

    if (healthId != null && healthOptions.isNotEmpty) {
      final int healthIndex = healthOptions.indexWhere((r) => r.id == healthId);
      _selectedHealthByEntityId[entityId] =
          (healthIndex >= 0) ? healthOptions[healthIndex] : null;
    } else {
      _selectedHealthByEntityId[entityId] = null;
    }

    if (state.currentEntityId == entityId) {
      selectedBalanceSheetHealth = _selectedHealthByEntityId[entityId];
    }

    String displayNameFor(String key) {
      final Reference matchedRatioReference =
          (financialRatioType ?? []).firstWhere(
        (ratioReference) => (ratioReference.reference2 ?? "") == key,
        orElse: () => Reference(name: ""),
      );
      return (matchedRatioReference.name?.isNotEmpty ?? false)
          ? matchedRatioReference.name!
          : key;
    }

    final Map<String, List<GuarantorFinancialValue>> financialValuesByRatioKey =
        {};
    for (final GuarantorFinancialValue value in deduplicatedFinancialValues) {
      final String ratioType =
          (value.financialRatioType?.trim().isNotEmpty ?? false)
              ? value.financialRatioType!.trim()
              : (value.userAddedRatioType ?? "").trim();
      if (ratioType.isEmpty) {
        continue;
      }
      financialValuesByRatioKey.putIfAbsent(ratioType, () => []).add(value);
    }
    for (final MapEntry<String, List<GuarantorFinancialValue>> ratioGroupEntry
        in financialValuesByRatioKey.entries) {
      final String ratioCode = ratioGroupEntry.key;
      final List<GuarantorFinancialValue> items = ratioGroupEntry.value;

      final bool isSystemDefinedRatioRow =
          items.first.financialRatioType?.trim().isNotEmpty ?? false;

      final IncomeStatementAnalysisRow row = IncomeStatementAnalysisRow(
        id: isSystemDefinedRatioRow
            ? ratioCode
            : DateTime.now().millisecondsSinceEpoch.toString(),
        incomePositions: displayNameFor(ratioCode),
        audited1: unavailableText,
        audited2: unavailableText,
        audited3: unavailableText,
        inhouse: unavailableText,
        estimated: unavailableText, // API doesn't carry a 5th period
        isNew: !isSystemDefinedRatioRow, // user-added rows remain editable
      );

      final int maxCols = incomeStatements.length.clamp(0, 5);
      for (int colIndex = 0; colIndex < maxCols; colIndex++) {
        final Statement statementHeader = incomeStatements[colIndex];
        final int months = statementHeader.periods;
        final int year = statementHeader.date.year;
        String fmtStmtDate(DateTime d) => DateFormat("yyyy-MM-dd").format(d);

        final GuarantorFinancialValue matchingFinancialValue = items.firstWhere(
          (savedFinancialValue) =>
              savedFinancialValue.financialYear == year &&
              _parsePeriodMonths(savedFinancialValue.period) == months,
          orElse: () => GuarantorFinancialValue(
            financialsCategory: categoryIncome,
            financialRatioType: items.first.financialRatioType,
            userAddedRatioType: items.first.userAddedRatioType,
            financialYear: year,
            statementDate: fmtStmtDate(statementHeader.date),
            period: "${months}M",
            auditMethod: "",
            auditor: "",
            value: null,
          ),
        );

        final String formattedSavedValue =
            _formatSavedValue(matchingFinancialValue.value);

        if (colIndex == 0) {
          row.audited1 = formattedSavedValue;
        } else if (colIndex == 1) {
          row.audited2 = formattedSavedValue;
        } else if (colIndex == 2) {
          row.audited3 = formattedSavedValue;
        } else if (colIndex == 3) {
          row.inhouse = formattedSavedValue;
        } else if (colIndex == 4) {
          row.estimated = formattedSavedValue;
        }
      }

      incomeStatementRows.add(row);
    }

    final List<IncomeStatementAnalysisRow> userAddedRows =
        incomeStatementRows.where((incomeRow) => incomeRow.isNew).toList();
    incomeRows = [...incomeStatementRows, ...userAddedRows];
    hasSavedAnalysisData = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns a statement constant value for the specified
  /// statement and constant indexes.
  String getConstValue(int statementIndex, int constIndex) {
    final List<Statement> statements = incomeStatements;
    if (statementIndex < 0 || statementIndex >= statements.length) {
      return unavailableText;
    }
    final Statement statement = statements[statementIndex];
    final List<StatementConst> statementConstants = statement.statementConsts;
    if (constIndex < 0 || constIndex >= statementConstants.length) {
      return unavailableText;
    }
    final String statementConstantValue =
        statementConstants[constIndex].value.trim();
    if (statementConstantValue.isEmpty) {
      return unavailableText;
    }
    if (statementConstantValue == ServerConstants.unqualified) {
      return "Audited-$statementConstantValue";
    }
    return statementConstantValue;
  }

  /// Formats “MMM-yyyy (nM)” or fallback if out of range.
  String getHeaderDate(int index) {
    if (index < 0 || index >= incomeStatements.length) {
      return unavailableText;
    }
    final Statement statementHeader = incomeStatements[index];
    return "${DateFormat('MMM-yyyy').format(statementHeader.date)} (${statementHeader.periods}M)";
  }

  /// Deletes the specified guarantor section and its associated data.
  Future<void> deleteGuarantorSection(int entityId) async {
    try {
      repository ??= RemarksRepository.instance;
      final int rimNo = selectedCustomer?.customerRimNo ?? 0;
      final int sectionIndex = state.guarantors.indexWhere(
        (guarantorSection) => (guarantorSection.entityId ?? 0) == entityId,
      );

      final bool isFirstSection =
          (sectionIndex == 0) || (entityId == (state.currentEntityId ?? -1));

      final bool isPersisted = _savedEntityIds.contains(entityId);

      if (!isPersisted) {
        // ---------- UNSAVED SECTION ----------
        if (isFirstSection) {
          _incomeStatementRowsByEntityId.remove(entityId);
          _selectedHealthByEntityId.remove(entityId);
          _remarksTextByEntityId.remove(entityId);
          _remarksTextByEntityId[entityId] = "";

          if (state.currentEntityId == entityId) {
            incomeStatementRows.clear();
          }
          hasCreditLensData = false;
          hasSavedAnalysisData = false;
          entityController.text = "";
          remarksEditorForEntity(entityId).setText("");
          entityController.clear();

          emit(
            state.copyWith(
              loaderStatus: LoadingStatus.loading, // pulse
              buttonStatus: LoadingStatus.loading,
              nextCanDelete: false,
              firstSectionTablesVisible: false, // hide tables
            ),
          );
          emit(
            state.copyWith(
              loaderStatus: LoadingStatus.loaded, // settle
              buttonStatus: LoadingStatus.loaded,
            ),
          );
        } else {
          final List<Guarantor> updatedGuarantors =
              List<Guarantor>.from(state.guarantors)
                ..removeWhere(
                  (guarantorSection) =>
                      (guarantorSection.entityId ?? 0) == entityId,
                );

          _incomeStatementRowsByEntityId.remove(entityId);
          _statementHeadersByEntityId.remove(entityId);
          _entityLongNameByEntityId.remove(entityId);
          _selectedHealthByEntityId.remove(entityId);
          _remarksTextByEntityId.remove(entityId);
          _remarksEditorByEntityId.remove(entityId);

          final int? nextCurrentEntityId = (state.currentEntityId == entityId)
              ? (updatedGuarantors.isNotEmpty
                  ? (updatedGuarantors.first.entityId ?? 0)
                  : null)
              : state.currentEntityId;

          emit(
            state.copyWith(
              guarantors: updatedGuarantors,
              currentEntityId:
                  (nextCurrentEntityId == 0 ? null : nextCurrentEntityId),
              loaderStatus: LoadingStatus.loaded,
            ),
          );
        }

        AlertManager().showSuccessToast("Deleted Successfully");
        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loaded,
          ),
        );
        return;
      }

      // ---------- SAVED SECTION ----------
      await repository!.deleteGuarantorDetailsByEntityId(
        entityId: entityId,
        rimNo: rimNo,
      );
      _savedEntityIds.remove(entityId);

      if (isFirstSection) {
        _incomeStatementRowsByEntityId.remove(entityId);
        _statementHeadersByEntityId.remove(entityId);
        _entityLongNameByEntityId.remove(entityId);
        _selectedHealthByEntityId.remove(entityId);
        _remarksTextByEntityId.remove(entityId);
        _remarksTextByEntityId[entityId] = "";

        if (state.currentEntityId == entityId) {
          incomeStatementRows.clear();
          incomeStatements.clear();
        }

        remarksEditorForEntity(entityId).setText("");
        entityController.clear();
        final bool hasAnyData = _incomeStatementRowsByEntityId.isNotEmpty ||
            _statementHeadersByEntityId.isNotEmpty;
        hasCreditLensData = hasAnyData;
        hasSavedAnalysisData = hasAnyData;
        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loading, // pulse
            buttonStatus: LoadingStatus.loading,
            firstSectionTablesVisible: false, // hide tables
          ),
        );
        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loaded, // settle
            buttonStatus: LoadingStatus.loaded,
          ),
        );
      } else {
        // Remove only THIS saved section and its caches
        final List<Guarantor> list = List<Guarantor>.from(state.guarantors)
          ..removeWhere((g) => (g.entityId ?? 0) == entityId);

        _incomeStatementRowsByEntityId.remove(entityId);
        _statementHeadersByEntityId.remove(entityId);
        _entityLongNameByEntityId.remove(entityId);
        _selectedHealthByEntityId.remove(entityId);
        _remarksTextByEntityId.remove(entityId);
        _remarksEditorByEntityId.remove(entityId);

        final int? nextId = (state.currentEntityId == entityId)
            ? (list.isNotEmpty ? (list.first.entityId ?? 0) : null)
            : state.currentEntityId;

        emit(
          state.copyWith(
            guarantors: list,
            currentEntityId: (nextId == 0 ? null : nextId),
            loaderStatus: LoadingStatus.loaded,
          ),
        );
      }

      AlertManager().showSuccessToast("Deleted successfully");
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Called when the user changes the selected customer.
  /// Emits a loading state, simulates a fetch, then emits loaded.
  /// Prevents duplicate rapid calls via [isChangingCustomer].
  ///select customet name from list
  Future<void> onChangeCustomer(Customer customer) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    selectedCustomer = customer;
    Globals.selectedCustomer = customer;

    _resetGuarantorFinancialDataForRimChange();

    await fetchSavedGuarantorFinancialDetails();
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Updates the pending entity ID for the specified guarantor section.
  void updatePendingEntityId(int sectionEntityId, String text) {
    _draftEntityIdBySection[sectionEntityId] = int.tryParse(text.trim()) ?? 0;
  }

  /// Updates the entity ID for the current section or the specified section.
  void updateEntityId(String text, {int? sectionEntityId}) {
    final int id = int.tryParse(text.trim()) ?? 0;
    if (sectionEntityId != null) {
      _draftEntityIdBySection[sectionEntityId] = id;
    } else {
      _draftEntityId = id;
    }
  }

  /// Updates the draft entity ID used in the Add Guarantor section.
  void updateEntityIdDraft(String text) {
    _draftEntityId = int.tryParse(text.trim());
  }

  /// Arms the Add‐Guarantor section, showing its search field and button.
  void onAddTap() {
    _cacheMountedGuarantorRemarks();
    emit(
      state.copyWith(
        nextCanDelete: true,
      ),
    );
  }

  /// Collapse the Add‑Guarantor UI and refresh with a loader pulse
  void cancelAddGuarantor() {
    _cacheMountedGuarantorRemarks();
    _draftEntityId = null;
    emit(
      state.copyWith(
        buttonStatus: LoadingStatus.loading,
        nextCanDelete: false, // Hide the Add‑Guarantor panel
      ),
    );
    emit(
      state.copyWith(
        buttonStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Internal helper that builds and appends a dummy Guarantor entry,
  /// managing all flags in one unified flow.
  Future<void> _addGuarantor({required bool extraSection}) async {
    final int? entityId = _draftEntityId ??
        state.currentEntityId ??
        int.tryParse(entityController.text);
    if (entityId == null || entityId <= 0) {
      try {
        AlertManager()
            .showFailureToast("remarks.guarantorFinancials.enterEntityId".tr());
      } on Object catch (_) {}
      return;
    }

    //block duplicates across all sections (ignore placeholder 0)
    final Set<int> existingEntityIds = {
      if (state.currentEntityId != null) state.currentEntityId!,
      ...state.guarantors
          .map((guarantorSection) => guarantorSection.entityId ?? 0),
    }..removeWhere((entityId) => entityId <= 0);

    if (existingEntityIds.contains(entityId)) {
      AlertManager()
          .showFailureToast("remarks.guarantorFinancials.repeartedSearch".tr());
      return; // ← do not fetch OR add
    }

    emit(state.copyWith(buttonStatus: LoadingStatus.loading));
    try {
      final FinancialDetailsResponse resp =
          await repository!.getFinancialDetailsFromCreditLens(entityId);
      longName = resp.longName;
      shortName = resp.shortName;
      populateIncomeStatementRows(resp);
      hasCreditLensData = true;

      if (!extraSection) {
        entityController.text = entityId.toString();
      }

      final Guarantor newGuarantorSection = Guarantor(
        entityId: entityId,
        name: "",
        analysisHtml: """ """,
        spreadsmartUrl: EnvConfig.spreadSmartUrl,
        canDelete: state.nextCanDelete,
      );
      emit(
        state.copyWith(
          guarantors: [...state.guarantors, newGuarantorSection],
          currentEntityId: extraSection ? state.currentEntityId : entityId,
          nextCanDelete: false,
          showExtraTab: extraSection,
          canDeleteSection: extraSection,
        ),
      );
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(buttonStatus: LoadingStatus.loaded));
    }
  }

  /// Searches and adds a guarantor for the Add‐Guarantor section
  /// (`extraSection = true`).
  Future<void> searchOnAddGuarantor() => _addGuarantor(extraSection: true);

  /// Launches the SpreadSmart URL externally in the default browser.
  Future<void> openSpreadsmart(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// Adds a new user-defined income statement row.
  void addIncomeRow() {
    final int userAddedCount = incomeStatementRows.where((r) => r.isNew).length;
    if (userAddedCount >= 10) {
      AlertManager().showFailureToast(
        "remarks.financialRatiosAnalysis.addRowsError".tr(),
      );
      return;
    }

    final String newId = DateTime.now().millisecondsSinceEpoch.toString();
    incomeStatementRows.add(
      IncomeStatementAnalysisRow(id: newId, isNew: true),
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

  /// Saves guarantor financial details and optionally navigates
  /// to the next section on successful save.
  Future<void> onSavePress(
    BuildContext context, {
    required bool isContinue,
  }) async {
    if (_isSaving) {
      return;
    }

    _isSaving = true;

    try {
      final Set<int> entityIds = {
        if (state.currentEntityId != null) state.currentEntityId!,
        ..._statementHeadersByEntityId.keys,
        ..._incomeStatementRowsByEntityId.keys,
      }..removeWhere((entityId) => entityId <= 0);

      final bool hasAnyEntity = entityIds.isNotEmpty;

      if (!hasExistingGuarantorDetails && !hasAnyEntity) {
        final String generalRemarksText = await controller.getText();
        final Comment comment = Comment.fromInputData(
          strategyComment: generalRemarksText,
          categoryType: state.activeTab.name,
          type: CommentsType.remarks,
          entityType: EntityIdentifier.remarks,
          categoryId: ServerConstants.remarksTabId[state.activeTab],
          rimNo: selectedCustomer?.customerRimNo,
        );
        await RequestRepository.instance
            .saveRemarkStrategyData(selectedCustomer, comment);
        AlertManager().showSuccessToast(
          "remarks.guarantorFinancials.savedSuccessfully".tr(),
        );
        if (isContinue) {
          await Future.microtask(() {
            if (!isClosed) {
              navigate();
            }
          });
        }
        return;
      } else {
        final List<GuarantorFinancialDetailsResponse> items =
            await buildSaveItems();
        final bool hasNoEntityData =
            items.isEmpty || items.first.entityDetails.isEmpty;
        if (hasNoEntityData) {
          navigate();
          return;
        }
        await repository!.saveGuarantorFinancialDetails(items: items);

        await deleteDraft();

        AlertManager().showSuccessToast(
          "remarks.guarantorFinancials.savedSuccessfully".tr(),
        );

        if (isContinue) {
          await Future.microtask(() {
            if (!isClosed) {
              navigate();
            }
          });
        }
      }
    } on Object catch (error, stack) {
      logger.e(
        "Error saving guarantor financial details",
        error: error,
        stackTrace: stack,
      );
      AlertManager().showFailureToast(error.toString());
    } finally {
      _isSaving = false;
    }
  }

  /// Returns plain text by removing HTML tags and formatting
  /// characters from the editor content.
  ///
  /// Intended for testing and validation purposes, but no use now.
  Future<String> getCleanText(UnifiedEditorController controller) async {
    final rawHtml = await controller.getText();
    return rawHtml
        .replaceAll(RegExp("<[^>]*>"), "") // Remove HTML tags
        .replaceAll("&nbsp;", " ") // Handle non-breaking spaces
        .replaceAll("\u00A0", " ") // Replace non-breaking spaces
        .trim();
  }

  String _auditMethodForSave(String method) {
    final String audited = method.trim();
    return audited.startsWith("Audited-")
        ? audited.replaceFirst("Audited-", "")
        : audited;
  }

  String? _auditorForSave(String auditorRaw) {
    final String auditorName = auditorRaw.trim();
    if (auditorName.isEmpty ||
        auditorName.toLowerCase() == unavailableText.toLowerCase() ||
        auditorName.toLowerCase() == "data not available") {
      return ""; // optional: make it empty string instead of null
    }
    return auditorName;
  }

  /// Converts one income statement row into backend financial values.
  ///
  /// One row can generate up to five values because the table displays up to
  /// five statement columns.
  List<GuarantorFinancialValue> _financialValuesFromIncomeRow({
    required int entityId,
    required String?
        financialRatioCode, // "101" for API rows; "0" for user-added
    required String? userAddedRatioName, // label for user-added rows
    required List<String>
        columnValues, // [audited1, audited2, audited3, inhouse, estimated]
  }) {
    final List<GuarantorFinancialValue> financialValues =
        <GuarantorFinancialValue>[];
    final List<Statement> statementHeaders = statementsFor(entityId);

    for (int colIndex = 0;
        colIndex < columnValues.length &&
            colIndex < statementHeaders.length &&
            colIndex < 5;
        colIndex++) {
      final Statement statementHeader = statementHeaders[colIndex];
      final String rawCellValue = columnValues[colIndex].trim();
      final String normalizedCellValue = rawCellValue.replaceAll(",", "");
      final bool isUnavailableValue = normalizedCellValue.isEmpty ||
          normalizedCellValue.toLowerCase() == "nan";
      final double? numericValue =
          isUnavailableValue ? null : double.tryParse(normalizedCellValue);

      final String auditMethod =
          _auditMethodForSave(_getConstValueForEntity(entityId, colIndex, 0));
      final String? auditor =
          _auditorForSave(_getConstValueForEntity(entityId, colIndex, 1));
      final String stmtDate =
          DateFormat("yyyy-MM-dd").format(statementHeader.date);

      financialValues.add(
        GuarantorFinancialValue(
          financialsCategory: 0, // stamped later in _categoryBlock
          financialRatioType:
              financialRatioCode, // "101" (API) or "0" (user-added)
          userAddedRatioType: userAddedRatioName, // label for user-added rows
          financialYear: statementHeader.date.year,
          period: "${statementHeader.periods}M", // e.g., "12M", "6M", "9M"
          auditMethod: auditMethod,
          statementDate: stmtDate,
          auditor: auditor, // may be null/empty
          value: numericValue, // null allowed
        ),
      );
    }

    return financialValues;
  }

  /// Removes the guarantor section at the specified index and
  /// clears its associated cached data.
  void removeGuarantor(int index) {
    if (state.guarantors.length <= 1) {
      return;
    }

    final removedEntityId = state.guarantors[index].entityId ?? 0;

    final list = List<Guarantor>.from(state.guarantors)..removeAt(index);
    emit(state.copyWith(guarantors: list));
    _incomeStatementRowsByEntityId.remove(removedEntityId);
    _statementHeadersByEntityId.remove(removedEntityId);
    _entityLongNameByEntityId.remove(removedEntityId);
    _selectedHealthByEntityId.remove(removedEntityId);
  }

  /// Deletes a user-added income statement row from the backend
  /// and removes it from the current entity's analysis data.
  Future<void> deleteUserAddedIncomeRow(
    IncomeStatementAnalysisRow row,
  ) async {
    try {
      repository ??= RemarksRepository.instance;
      final int rimNo = selectedCustomer?.customerRimNo ?? 0;
      final int entityId = state.currentEntityId ?? 0;
      await repository!.deleteGuarantorDetails(
        rimNo: rimNo,
        entityId: entityId,
        financialsCategory: categoryIncome,
        userAddedRatioType: row.incomePositions,
      );
      deleteIncomeRow(row.id);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Builds the backend category payload for one guarantor income statement table.
  ///
  /// The Guarantor Financial page currently saves the Income Statement Analysis
  /// category. User-added rows are sent with financialRatioType = "0" and
  /// userAddedRatioType populated with the user-entered row name.
  GuarantorCategoryDetail _categoryBlock({
    required int entityId,
    required int categoryId,
    required String remarksText,
    required int? healthId,
    required List<dynamic> rows,
  }) {
    final List<GuarantorFinancialValue> financialValuesForCategory =
        <GuarantorFinancialValue>[];

    for (final incomeStatementRow in rows) {
      final String label = (incomeStatementRow.incomePositions ??
              incomeStatementRow.balanceSheet ??
              incomeStatementRow.cashFlowItems ??
              "")
          .trim();
      final String financialRatioCode = (!incomeStatementRow.isNew &&
              (incomeStatementRow.id?.isNotEmpty ?? false))
          ? incomeStatementRow.id!
          : "0";

      final String? userAddedRatioName =
          (incomeStatementRow.isNew && financialRatioCode == "0")
              ? (label.isNotEmpty ? label : null)
              : null;

      final List<String> columnValues = <String>[
        incomeStatementRow.audited1 ?? "",
        incomeStatementRow.audited2 ?? "",
        incomeStatementRow.audited3 ?? "",
        incomeStatementRow.inhouse ?? "",
        incomeStatementRow.estimated ?? "", // send the 5th column too
      ];

      //Skip untouched user‑added rows (no label AND all cells empty)
      final bool isEmptyUserAddedRow = (incomeStatementRow.isNew ?? false) &&
          financialRatioCode == "0" &&
          label.isEmpty &&
          columnValues.every((category) => category.trim().isEmpty);

      if (isEmptyUserAddedRow) {
        continue; // ← do not emit values for this row; keeps payload clean
      }

      final List<GuarantorFinancialValue> mappedFinancialValues =
          _financialValuesFromIncomeRow(
        entityId: entityId,
        financialRatioCode:
            financialRatioCode, // "101" for API rows; "0" for user-added rows
        userAddedRatioName: userAddedRatioName, // label when user-added
        columnValues: columnValues,
      )
              .map(
                (financialValue) => GuarantorFinancialValue(
                  financialsCategory:
                      categoryId, // stamp category for the table
                  financialRatioType: financialValue
                      .financialRatioType, // keep "0" for user-added
                  userAddedRatioType: financialValue.userAddedRatioType,
                  financialYear: financialValue.financialYear,
                  period: financialValue.period,
                  statementDate: financialValue.statementDate,
                  auditMethod: financialValue.auditMethod,
                  auditor: financialValue.auditor,
                  value: financialValue.value, // may be null
                ),
              )
              .toList();

      financialValuesForCategory.addAll(mappedFinancialValues);
    }

    return GuarantorCategoryDetail(
      financialsCategory: categoryId,
      financialsValues: financialValuesForCategory, // includes NA/null entries
      guarantorHealth: healthId,
      remarks: remarksText.isNotEmpty ? remarksText : null,
    );
  }

  ///Read statement consts (audit method / auditor) for a given entity ---
  String _getConstValueForEntity(
    int entityId,
    int statementIndex,
    int constIndex,
  ) {
    final List<Statement> statements = statementsFor(entityId);
    if (statementIndex < 0 || statementIndex >= statements.length) {
      return unavailableText;
    }
    final Statement statementHeader = statements[statementIndex];
    final List<StatementConst> statementConstants =
        statementHeader.statementConsts;
    if (constIndex < 0 || constIndex >= statementConstants.length) {
      return unavailableText;
    }
    final String statementConstantValue =
        statementConstants[constIndex].value.trim();
    if (statementConstantValue.isEmpty) {
      return unavailableText;
    }
    return statementConstantValue == ServerConstants.unqualified
        ? "Audited-$statementConstantValue"
        : statementConstantValue;
  }

  /// Returns remarks text for a guarantor entity during save.
  ///
  /// Priority:
  /// 1. Latest text from the mounted rich text editor.
  /// 2. Cached text from [_remarksTextByEntityId].
  ///
  /// This avoids losing remarks when the editor has rebuilt or is temporarily
  /// unavailable.
  Future<String> _sectionRemarksForSave(int entityId) async {
    try {
      final UnifiedEditorController remarksEditor =
          remarksEditorForEntity(entityId);

      final String editorText = remarksEditor.currentText.trim();

      if (editorText.isNotEmpty) {
        _remarksTextByEntityId[entityId] = editorText;
        return editorText;
      }
      return remarksForEntity(entityId).trim();
    } on Object catch (e) {
      logger.w(
        "Section editor not mounted for entity $entityId, using cached remarks",
        error: e,
      );
      return remarksForEntity(entityId).trim();
    }
  }

  /// Collapses the additional guarantor section and hides
  /// section-specific actions.
  void collapseExtraBox() {
    emit(
      state.copyWith(
        showExtraTab: false,
        canDeleteSection: false,
      ),
    );
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
    final int currentTabIndex = orderedVisibleTabs.indexOf(state.activeTab);

    if (currentTabIndex != -1 &&
        currentTabIndex < orderedVisibleTabs.length - 1) {
      final RemarksTabs nextTab = orderedVisibleTabs[currentTabIndex + 1];

      router.go(
        TabConstants.remarksRoutes[nextTab]!,
        extra: nextTab,
      );

      return;
    }
    // No next visible tab => hand off to the layout's next route.
    LayoutViewModel().goToNextRoute();
  }

  /// Changes the active remarks tab and loads any available draft data.
  Future<void> changeTab(RemarksTabs tab) async {
    router.go(TabConstants.remarksRoutes[tab]!, extra: tab);
    if (!isReadOnlyMode) {
      await loadDraftIfAvailable();
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the long name associated with the specified entity.
  void updateLongNameFor(int entityId, String text) {
    final String cleaned = text.trim();
    _entityLongNameByEntityId[entityId] = cleaned;

    // Keep the global longName aligned for the current (first) section
    if (state.currentEntityId == entityId) {
      longName = cleaned;
    }
  }

  /// Builds the save payload for all guarantor financial sections.
  ///
  /// The backend expects one [GuarantorFinancialDetailsResponse] containing
  /// multiple [GuarantorEntityDetail] records, one per guarantor entity.
  Future<List<GuarantorFinancialDetailsResponse>> buildSaveItems() async {
    _cacheMountedGuarantorRemarks();
    final List<GuarantorFinancialDetailsResponse> savePayloadItems = [];

    final Set<int> entityIdsToSave = {
      if (state.currentEntityId != null) state.currentEntityId!,
      ..._statementHeadersByEntityId.keys,
      ..._incomeStatementRowsByEntityId.keys,
    }..removeWhere((entityId) => entityId <= 0);

    final List<GuarantorEntityDetail> guarantorEntityDetails = [];
    String sectionRemarks = "";

    for (final int entityId in entityIdsToSave) {
      final List<IncomeStatementAnalysisRow> rows =
          _incomeStatementRowsByEntityId[entityId] ??
              const <IncomeStatementAnalysisRow>[];
      final int? healthId = _selectedHealthByEntityId[entityId]?.id;
      sectionRemarks = await _sectionRemarksForSave(entityId);

      final List<GuarantorCategoryDetail> categories = [];

      if (rows.isNotEmpty) {
        final GuarantorCategoryDetail incomeCat = _categoryBlock(
          entityId: entityId,
          categoryId: categoryIncome,
          remarksText: sectionRemarks,
          healthId: healthId,
          rows: rows,
        );

        if (incomeCat.financialsValues.isNotEmpty) {
          categories.add(incomeCat);
        }
      }

      final GuarantorEntityDetail entityBlock = GuarantorEntityDetail(
        guarantorFinancialsId: guarantorFinancialsId,
        entityId: entityId,
        entityLongName: _entityLongNameByEntityId[entityId] ?? longName ?? "",
        financialsCategory: categories,
      );

      guarantorEntityDetails.add(entityBlock);
    }

    guarantorEntityDetails
        .removeWhere((entityId) => entityId.financialsCategory.isEmpty);

    if (guarantorEntityDetails.isEmpty) {
      return const <GuarantorFinancialDetailsResponse>[];
    }

    final DateTime now = DateTime.now().toUtc();
    final GuarantorFinancialDetailsResponse singleItem =
        GuarantorFinancialDetailsResponse(
      guarantorFinancialsId: guarantorFinancialsId,
      appRefNo: Globals.request?.applicationRefNo ?? "",
      rimNo: selectedCustomer?.customerRimNo ?? 0,
      customerName: selectedCustomer?.customerName?.trim() ?? "",
      entityDetails: guarantorEntityDetails,
      createdBy: Globals.user?.name,
      createdDate: now,
      updatedBy: Globals.user?.name,
      updatedDate: now,
    );

    savePayloadItems.add(singleItem);
    return savePayloadItems;
  }

  /// Identifies and updates tabs that require mandatory remarks indicators.
  Future<void> setAsterisks() async {
    showAsteriskTabs = Utils.getMandatoryRemarksTabs(selectedCustomer);

    emit(state.copyWith(loaderStatus: state.loaderStatus));
  }

  /// Only FI types should show the "View more / View less" affordance.
  /// Country (and other non-FI) show all chips without the toggle.
  bool get showViewMore =>
      selectedCustomer?.type == CustomerType.belowInvestmentGradeBanks ||
      selectedCustomer?.type == CustomerType.investmentGradeBanks;

  void _resetGuarantorFinancialDataForRimChange() {
    _incomeStatementRowsByEntityId.clear();
    _statementHeadersByEntityId.clear();
    _entityLongNameByEntityId.clear();
    _selectedHealthByEntityId.clear();
    _remarksTextByEntityId.clear();
    _remarksEditorByEntityId.clear();
    _savedEntityIds.clear();
    _draftEntityIdBySection.clear();
    _entityInputControllersBySection.clear();

    incomeStatementRows.clear();
    incomeStatements.clear();
    incomeRows = [];

    longName = null;
    shortName = null;
    _draftEntityId = null;

    hasCreditLensData = false;
    hasSavedAnalysisData = false;
    hasExistingGuarantorDetails = false;
    guarantorFinancialsId = null;

    entityController.clear();

    emit(
      state.copyWith(
        guarantors: [
          Guarantor(
            entityId: 0,
            name: "",
            analysisHtml: "",
            spreadsmartUrl: EnvConfig.spreadSmartUrl,
          ),
        ],
        clearCurrentEntityId: true,
        firstSectionTablesVisible: false,
        nextCanDelete: false,
        showExtraTab: false,
        canDeleteSection: false,
        buttonStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Caches remarks from all currently mounted guarantor editors.
  ///
  /// Why this is needed:
  /// - The screen can rebuild when the user clicks Add Guarantor, Cancel,
  ///   Save, or Save & Continue.
  /// - Rich text editors may reinitialize from during rebuild.
  /// - If the latest editor text is not cached first, typed remarks can be lost.
  ///
  /// This method reads the current text from each mounted entity editor and stores
  /// it in [_remarksTextByEntityId].
  void _cacheMountedGuarantorRemarks() {
    final bool hasEntityBasedRemarks =
        hasCreditLensData || hasSavedAnalysisData;

    if (!hasEntityBasedRemarks) {
      return;
    }

    for (final guarantorSection in state.guarantors) {
      final int entityId = guarantorSection.entityId ?? 0;

      if (entityId <= 0) {
        continue;
      }

      final String currentRemarks =
          remarksEditorForEntity(entityId).currentText.trim();

      if (currentRemarks.isNotEmpty) {
        _remarksTextByEntityId[entityId] = currentRemarks;
      }
    }
  }
}
