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
                canDelete: false,
              ),
            ],
          ),
        );

  /// Repository for fetching and persisting financial analysis data.
  RemarksRepository? repository;

  /// Service for fetching reference data.
  ReferenceDataService? _referenceDataService;

// --- NEW: per-entity storage ---
// comment: holds rows for each guarantor entity (instead of a single global
// list)
  final Map<int, List<IncomeStatementAnalysisRow>> _incomeRowsByEntity = {};

// comment: holds headers (dates + consts) per entity
  final Map<int, List<Statement>> _statementsByEntity = {};

// comment: holds longName per entity to render the first stacked header cell
  final Map<int, String> _longNameByEntity = {};

// comment: holds the selected health dropdown item per entity
  final Map<int, Reference?> _healthByEntity = {};

// NEW: per-entity editor controllers (one editor per section)
  final Map<int, UnifiedEditorController> _editorsByEntity = {};

// NEW: per-entity remarks cache (used to prefill editors and for save)
  final Map<int, String> _remarksByEntity = {};

// NEW: helper to get/create an editor for an entity
  UnifiedEditorController editorForEntity(int entityId) {
    return _editorsByEntity.putIfAbsent(
      entityId,
      UnifiedEditorController.new,
    );
  }

//Keep a set of entityIds that exist in backend (saved/persisted)
  final Set<int> _savedEntityIds = <int>{};

// NEW: helper to read a cached remark for an entity (used as initial text)
  String remarksForEntity(int entityId) => _remarksByEntity[entityId] ?? "";

// comment: small helper getters (kept very lightweight)
  List<IncomeStatementAnalysisRow> incomeRowsFor(int entityId) =>
      _incomeRowsByEntity[entityId] ?? const [];

  List<Statement> statementsFor(int entityId) =>
      _statementsByEntity[entityId] ?? const [];

  String? longNameFor(int entityId) => _longNameByEntity[entityId];

  Reference? selectedHealthFor(int entityId) => _healthByEntity[entityId];

  /// HTML editor controller used in the formatted text area.
  final UnifiedEditorController controller = UnifiedEditorController();
  TextEditingController entityController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  /// Primary form key for validating and saving the main add‐guarantor tables.
  final GlobalKey<FormState> primaryFormKey = GlobalKey<FormState>();

  /// Secondary form key for validating and saving the add‐guarantor section.
  final GlobalKey<FormState> secondaryFormKey = GlobalKey<FormState>();

  static const int categoryIncome = 234; // Income statement Analysis

  /// Currently selected customer from the dropdown.
  Customer? selectedCustomer =
      Globals.selectedCustomer ?? Globals.request?.customers?.first;

  List<Customer>? customerList = [];

  /// List of all available customers from the global request.
  List<Customer> get customers => Globals.request?.customers ?? [];

  /// Guard against overlapping calls when changing the customer selection.
  bool isChangingCustomer = false;
  bool hasCreditLensData = false;
  String? longName;
  String? shortName;
  int? _draftEntityId;

  /// Indicates whether the Income Statement table should show an action column.
  bool get hasActionColumn => incomeStatementRows.any((r) => r.isNew);

  /// Data rows for the Income Statement analysis table.
  final List<IncomeStatementAnalysisRow> incomeStatementRows = [];
  List<Statement> incomeStatements = [];
  List<Reference>? financialCategory = [];
  List<Reference>? financialRatioType = [];
  List<Reference>? financialHealth = [];
  List<Reference>? guarantorsHealth = [];
  List<IncomeStatementAnalysisRow>? incomeRows = [];

  /// Data rows for the Balance Sheet analysis table.
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

  Reference? selectedBalanceSheetHealth = Reference(name: "Select");
  List<Reference> balanceSheetHealth = [];
  List<RemarksTabs> showAsteriskTabs = [];
  Comment? commentData = Comment();
  bool hasSavedAnalysisData = false;
  PageMode pageMode = PageMode.na;
  bool get isReadOnlyMode => pageMode == PageMode.view;
  int? guarantorFinancialsId;
  String? guarantorRemarks;
  bool hasExistingGuarantorDetails = false;
  final bool isFirstSection = false;

// Holds the user-typed entity id per section (_tabView)
  final Map<int, int> _draftEntityIdBySection = <int, int>{}; //  NEW
  bool isFI = false;

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
  Future<void> init(context) async {
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

  Future<void> loadReferenceData() async {
    try {
      final service = _referenceDataService ?? ReferenceDataService();
      final Map<String, List<Reference>> referenceData =
          await service.getReferenceData([
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

//get child rim list for rim dropdown
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
    } catch (e) {
      logger.i("Error fetching getChildRimsForGroup : $e");
      defaultSelectedCustomer();
      rethrow;
    }
  }

  void defaultSelectedCustomer() {
    selectedCustomer = ((Globals.request?.borrowers ?? []).isNotEmpty)
        ? Globals.request?.borrowers?.first
        : Globals.request?.customers?.first;
  }

  Future<void> getRemarks() async {
    try {
      commentData = await RequestRepository.instance.getRemarkStrategyData(
            selectedCustomer,
            ServerConstants.commentTypeId[CommentsType.remarks],
            ServerConstants.remarksTabId[state.activeTab],
          ) ??
          Comment();

      final String? descComment = commentData?.strategyComment;
      final String trimmedStrategyComment =
          (descComment == null) ? "" : descComment.trim();
      final String displayStrategyComment = (trimmedStrategyComment.isEmpty ||
              trimmedStrategyComment.toLowerCase() == "null")
          ? ""
          : trimmedStrategyComment;

      controller.setText(displayStrategyComment);
    } catch (e) {
      commentData = Comment();
      AlertManager().showFailureToast(e.toString());
    }
  }

  void populateIncomeStatementRows(FinancialDetailsResponse resp) {
    incomeStatementRows.clear();

    final List<Statement> headers = _canonicalHeaders(resp.statements);
    incomeStatements = headers;

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

    final List<IncomeStatementAnalysisRow> mergedRows = incomeRefs.map((ref) {
      final String key = ref.reference2 ?? "";
      final List<MacroItem> items =
          (key.isNotEmpty) ? (resp.macros[key] ?? const []) : const [];

      final IncomeStatementAnalysisRow row = IncomeStatementAnalysisRow(
        id: key.isNotEmpty
            ? key
            : DateTime.now().millisecondsSinceEpoch.toString(),
        incomePositions: ref.name ?? "",
        audited1: unavailableText,
        audited2: unavailableText,
        audited3: unavailableText,
        inhouse: unavailableText,
        estimated: unavailableText, // 5th column
        isNew: false,
      );

      for (int i = 0; i < headers.length && i < 5; i++) {
        final Statement s = headers[i];
        final String v = _valForByDate(items, s, unavailableText);
        if (i == 0) {
          row.audited1 = v;
        } else if (i == 1) {
          row.audited2 = v;
        } else if (i == 2) {
          row.audited3 = v;
        } else if (i == 3) {
          row.inhouse = v;
        } else if (i == 4) {
          row.estimated = v;
        }
      }

      return row;
    }).toList();

    // Persist for the active entity (single-table path)
    final int entity = resp.entityId;
    _incomeRowsByEntity[entity] = mergedRows;
    _statementsByEntity[entity] = headers;
    _longNameByEntity[entity] = resp.longName;

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
        final int idx = state.guarantors
            .indexWhere((g) => (g.entityId ?? 0) == sectionEntityId);
        if (idx >= 0) prevId = state.guarantors[idx].entityId;
      }

      if (prevId != null && prevId > 0 && prevId != typedId) {
        _incomeRowsByEntity.remove(prevId);
        _statementsByEntity.remove(prevId);
        _longNameByEntity.remove(prevId);
        _healthByEntity.remove(prevId);
        _remarksByEntity.remove(prevId);
        _editorsByEntity.remove(prevId);
      }

      final UnifiedEditorController sourceCtrl =
          (hasCreditLensData || hasSavedAnalysisData)
              ? editorForEntity(
                  sectionEntityId,
                ) // already per-entity on this section
              : controller; // global editor before first search
      try {
        final String raw = await sourceCtrl
            .getText()
            .timeout(const Duration(milliseconds: 500));
        if (raw.isNotEmpty) {
          _remarksByEntity[typedId] = raw;
          editorForEntity(typedId).setText(raw);
        }
      } catch (_) {}

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
        final int idx =
            list.indexWhere((g) => (g.entityId ?? 0) == sectionEntityId);
        if (idx >= 0) {
          final g = list[idx];
          list[idx] = Guarantor(
            entityId: typedId,
            name: g.name,
            analysisHtml: g.analysisHtml,
            spreadsmartUrl: g.spreadsmartUrl,
            canDelete: g.canDelete,
          );
          emit(state.copyWith(guarantors: list));
        }
      }

      emit(state.copyWith(buttonStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(buttonStatus: LoadingStatus.loaded));
    }
  }

  //populate credit lens data into the table
  void _populateCreditLensForSection(
    int sectionEntityId,
    FinancialDetailsResponse resp,
  ) {
    final List<Statement> headers = _canonicalHeaders(resp.statements);
    _statementsByEntity[sectionEntityId] = headers;
    _longNameByEntity[sectionEntityId] = resp.longName;

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

    final List<IncomeStatementAnalysisRow> mergedRows = incomeRefs.map((ref) {
      final String key = ref.reference2 ?? "";
      final List<MacroItem> items =
          (key.isNotEmpty) ? (resp.macros[key] ?? const []) : const [];

      final IncomeStatementAnalysisRow row = IncomeStatementAnalysisRow(
        id: key,
        incomePositions: ref.name ?? "",
        audited1: unavailableText,
        audited2: unavailableText,
        audited3: unavailableText,
        inhouse: unavailableText,
        estimated: unavailableText,
        isNew: false,
      );

      for (int i = 0; i < headers.length && i < 5; i++) {
        final Statement s = headers[i];
        final String v = _valForByDate(items, s, unavailableText);
        if (i == 0) {
          row.audited1 = v;
        } else if (i == 1) {
          row.audited2 = v;
        } else if (i == 2) {
          row.audited3 = v;
        } else if (i == 3) {
          row.inhouse = v;
        } else if (i == 4) {
          row.estimated = v;
        }
      }

      return row;
    }).toList();

    _incomeRowsByEntity[sectionEntityId] = mergedRows;

    if (state.currentEntityId == sectionEntityId) {
      incomeStatementRows
        ..clear()
        ..addAll(mergedRows);
      incomeStatements = headers;
    }
  }

  /// Build canonical headers from CreditLens statements:
  /// - group by year
  /// - pick the latest month within the year
  /// - take the latest 5 years
  /// - order ascending (oldest → newest)
  List<Statement> _canonicalHeaders(List<Statement> input) {
    if (input.isEmpty) return const <Statement>[];
    final Map<int, Statement> latestPerYear = {};
    for (final s in input) {
      final int y = s.date.year;
      final Statement? existing = latestPerYear[y];
      if (existing == null || s.date.isAfter(existing.date)) {
        latestPerYear[y] = s;
      }
    }
    final List<Statement> perYear = latestPerYear.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // oldest → newest

    final int n = perYear.length;
    return (n <= 5) ? perYear : perYear.sublist(n - 5, n);
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
    if (items.isEmpty) return unavailableText;

    // Exact date match
    final MacroItem exact = items.firstWhere(
      (it) => it.stmtDate.isAtSameMomentAs(header.date),
      orElse: () => MacroItem(stmtID: -1, stmtDate: DateTime(1970), value: ""),
    );
    if (exact.stmtID != -1) {
      final String raw = exact.value.trim();
      if (raw.isEmpty || raw.toLowerCase() == "nan") return unavailableText;
      final double? roundedStr = double.tryParse(raw);
      if (roundedStr == null) return unavailableText;
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
      if (raw.isEmpty || raw.toLowerCase() == "nan") return unavailableText;
      final double? roundedStr = double.tryParse(raw);
      if (roundedStr == null) return unavailableText;
      return roundedStr.toStringAsFixed(2);
    }

    return unavailableText;
  }

// Returns a stable controller for a section and sets an initial text once
  TextEditingController textControllerForSection(int sectionEntityId) {
    return _entityInputControllersBySection.putIfAbsent(
      sectionEntityId,
      () {
        final c = TextEditingController();
        if (sectionEntityId > 0) {
          c.text = sectionEntityId.toString(); // first render seed
        }
        return c;
      },
    );
  }

  late GuarantorFinancialDetailsResponse guarantorFinancialDetails;

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
      } catch (e, st) {
        logger.w(
          "Parsed empty saved details (responseData: [])."
          " Falling back to getRemarks().",
          error: e,
          stackTrace: st,
        );
        hasSavedAnalysisData = false; // : tables should not render
        await getRemarks(); // : fetch strategy comment here (not in init)
        return;
      }
      if (guarantorFinancialDetails.entityDetails.isEmpty) {
        hasSavedAnalysisData = false; // : tables should not render

        _savedEntityIds.clear(); // no saved entities this session

        await getRemarks(); // fetch strategy comment here (not in init)
        return;
      }

      _savedEntityIds
        ..clear()
        ..addAll(
          guarantorFinancialDetails.entityDetails.map((e) => e.entityId),
        );

      guarantorFinancialsId = guarantorFinancialDetails.guarantorFinancialsId ??
          guarantorFinancialsId;

      final List<Guarantor> sections = <Guarantor>[];
      for (int i = 0; i < guarantorFinancialDetails.entityDetails.length; i++) {
        final GuarantorEntityDetail ed =
            guarantorFinancialDetails.entityDetails[i];
        final int incomeIdx = ed.financialsCategory
            .indexWhere((c) => c.financialsCategory == categoryIncome);
        if (incomeIdx != -1) {
          final GuarantorCategoryDetail incomeCat =
              ed.financialsCategory[incomeIdx];

          final String remark = (incomeCat.remarks ?? "").trim();
          if (remark.isNotEmpty) {
            _remarksByEntity[ed.entityId] = remark; // NEW
            editorForEntity(ed.entityId).setText(remark); // NEW
          }

          final int? healthId = incomeCat.guarantorHealth;
          final List<Reference> healthOptions = guarantorsHealth ?? [];
          if (healthId != null && healthOptions.isNotEmpty) {
            final int healthIndex =
                healthOptions.indexWhere((r) => r.id == healthId);
            _healthByEntity[ed.entityId] =
                (healthIndex >= 0) ? healthOptions[healthIndex] : null; // NEW
          } else {
            _healthByEntity[ed.entityId] = null; // NEW
          }
        }

        sections.add(
          Guarantor(
            entityId: ed.entityId,
            name: "",
            analysisHtml: "",
            spreadsmartUrl: EnvConfig.spreadSmartUrl,
            canDelete: i > 0, // first section not deletable; others can delete
          ),
        );
      }

      final int firstId =
          guarantorFinancialDetails.entityDetails.first.entityId;

      entityController.text = firstId.toString(); // <-- ADD THIS LINE

      emit(
        state.copyWith(
          guarantors: sections, // NEW: render one _tabView per entity
          currentEntityId: firstId, // NEW: first section uses real entity id
          canDeleteSection: true, // keep delete button logic
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
    } catch (e, st) {
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

// NEW: populate headers + rows for each entity in a multi-entity saved response
  void populateIncomeStatementRowsFromSavedMulti(
    GuarantorFinancialDetailsResponse gResp,
  ) {
    for (final GuarantorEntityDetail ed in gResp.entityDetails) {
      _populateSavedForEntity(ed); // per-entity fill (below)
    }
  }

  void addIncomeRowForEntity(int entityId) {
    final List<IncomeStatementAnalysisRow> list =
        List<IncomeStatementAnalysisRow>.from(
      _incomeRowsByEntity[entityId] ?? const [],
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
    _incomeRowsByEntity[entityId] = list;
    if (state.currentEntityId == entityId) {
      incomeStatementRows
        ..clear()
        ..addAll(list);
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// delete table rows created by user (per-entity)
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
        _incomeRowsByEntity[entityId] ?? const [],
      );
      _incomeRowsByEntity[entityId] = list..removeWhere((r) => r.id == row.id);

      if (state.currentEntityId == entityId) {
        incomeStatementRows
          ..clear()
          ..addAll(list);
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showSuccessToast("Deleted successfully");
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  // NEW: per-entity fill used by the multi-entity helper
  void _populateSavedForEntity(GuarantorEntityDetail ed) {
    final int entityId = ed.entityId;
    final int idx = ed.financialsCategory
        .indexWhere((c) => c.financialsCategory == categoryIncome);
    if (idx == -1) return;

    final GuarantorCategoryDetail incomeCat = ed.financialsCategory[idx];
    final List<GuarantorFinancialValue> vals = incomeCat.financialsValues;

    final Map<String, GuarantorFinancialValue> uniq = {};
    for (final v in vals) {
      final String keyPart = (v.financialRatioType?.trim().isNotEmpty == true)
          ? v.financialRatioType!.trim()
          : (v.userAddedRatioType ?? "").trim();
      if (keyPart.isEmpty) continue;
      final int months = _parsePeriodMonths(v.period);
      final String dedupeKey = "$keyPart|${v.financialYear}|$months";
      uniq[dedupeKey] = v; // last wins
    }
    final List<GuarantorFinancialValue> deduped = uniq.values.toList();
    final List<Statement> headers = _buildStatementsFromSaved(deduped);
    _statementsByEntity[entityId] = headers; // NEW
    _longNameByEntity[entityId] = ed.entityLongName; // NEW

    final int? healthId = incomeCat.guarantorHealth;
    final List<Reference> healthOptions = guarantorsHealth ?? [];
    if (healthId != null && healthOptions.isNotEmpty) {
      final int healthIndex = healthOptions.indexWhere((r) => r.id == healthId);
      _healthByEntity[entityId] =
          (healthIndex >= 0) ? healthOptions[healthIndex] : null;
    } else {
      _healthByEntity[entityId] = null;
    }

    final String remark = (incomeCat.remarks ?? "").trim();
    if (remark.isNotEmpty) {
      _remarksByEntity[entityId] = remark; // NEW
      editorForEntity(entityId).setText(remark); // NEW
    }

    // Build per-entity rows
    String displayNameFor(String key) {
      final ref = (financialRatioType ?? []).firstWhere(
        (r) => (r.reference2 ?? "") == key,
        orElse: () => Reference(name: ""),
      );
      return (ref.name?.isNotEmpty == true) ? ref.name! : key;
    }

    final Map<String, List<GuarantorFinancialValue>> byKey = {};
    for (final v in deduped) {
      final String k = (v.financialRatioType?.trim().isNotEmpty == true)
          ? v.financialRatioType!.trim()
          : (v.userAddedRatioType ?? "").trim();
      if (k.isEmpty) continue;
      byKey.putIfAbsent(k, () => []).add(v);
    }

    final List<IncomeStatementAnalysisRow> rowsForEntity = [];
    final int maxCols = headers.length.clamp(0, 5);
    for (final entry in byKey.entries) {
      final String key = entry.key;
      final List<GuarantorFinancialValue> items = entry.value;
      final String firstCode = (items.first.financialRatioType ?? "").trim();
      final bool isCodeRow =
          firstCode.isNotEmpty && firstCode.toLowerCase() != "null";
      final row = IncomeStatementAnalysisRow(
        id: key,
        incomePositions: displayNameFor(key),
        audited1: unavailableText,
        audited2: unavailableText,
        audited3: unavailableText,
        inhouse: unavailableText,
        estimated: unavailableText,
        isNew: !isCodeRow,
      );

      for (int i = 0; i < maxCols; i++) {
        final Statement s = headers[i];
        final int months = s.periods;
        final int year = s.date.year;
        String fmtStmtDate(DateTime d) => DateFormat("yyyy-MM-dd").format(d);

        final GuarantorFinancialValue v = items.firstWhere(
          (x) =>
              x.financialYear == year && _parsePeriodMonths(x.period) == months,
          orElse: () => GuarantorFinancialValue(
            financialsCategory: categoryIncome,
            financialRatioType: items.first.financialRatioType,
            userAddedRatioType: items.first.userAddedRatioType,
            statementDate: fmtStmtDate(s.date),
            financialYear: year,
            period: "${months}M",
            auditMethod: "",
            auditor: "",
            value: null,
          ),
        );
        final String valueStr = _formatSavedValue(v.value);
        if (i == 0) {
          row.audited1 = valueStr;
        } else if (i == 1) {
          row.audited2 = valueStr;
        } else if (i == 2) {
          row.audited3 = valueStr;
        } else if (i == 3) {
          row.inhouse = valueStr;
        } else if (i == 4) {
          row.estimated = valueStr;
        }
      }
      rowsForEntity.add(row);
    }

    _incomeRowsByEntity[entityId] = rowsForEntity;

    if (state.currentEntityId == entityId) {
      incomeStatements = headers;
      incomeStatementRows
        ..clear()
        ..addAll(rowsForEntity);
    }
  }

  int _parsePeriodMonths(String period) {
    final m = RegExp(r"(\d+)").firstMatch(period);
    if (m != null) return int.tryParse(m.group(1)!) ?? 0;
    return 0;
  }

  DateTime _dateFromSaved(GuarantorFinancialValue fv) {
    final String? sd = fv.statementDate;
    if (sd != null && sd.trim().isNotEmpty) {
      try {
        return DateTime.parse(
          sd.trim(),
        ); // full fidelity: uses the real month/day
      } catch (_) {
        // fall through to the period-based fallback
      }
    }
    int months(String period) {
      final m = RegExp(r"(\d+)").firstMatch(period);
      return (m != null) ? int.tryParse(m.group(1)!) ?? 0 : 0;
    }

    final int mths = months(fv.period);
    final int month = (mths == 12) ? 12 : mths.clamp(1, 12);
    return DateTime(fv.financialYear, month, 1);
  }

  /// Build canonical headers from saved values:
  /// - group by year
  /// - pick the latest month within the year
  /// - take the latest 5 years
  /// - order oldest → newest (for column display)
  List<Statement> _buildStatementsFromSaved(
    List<GuarantorFinancialValue> values,
  ) {
    if (values.isEmpty) return const <Statement>[];

    int months0(String period) {
      final m = RegExp(r"(\d+)").firstMatch(period);
      return (m != null) ? int.tryParse(m.group(1)!) ?? 0 : 0;
    }

    // latest value per year (by month)
    final Map<int, GuarantorFinancialValue> latestPerYear = {};
    for (final v in values) {
      final int y = v.financialYear;
      final GuarantorFinancialValue? existing = latestPerYear[y];
      final bool newer =
          (existing == null) || (months0(v.period) > months0(existing.period));
      if (newer) latestPerYear[y] = v;
    }

    // sort oldest → newest and keep last 5
    final List<GuarantorFinancialValue> perYear = latestPerYear.values.toList()
      ..sort((a, b) {
        if (a.financialYear != b.financialYear) {
          return a.financialYear.compareTo(b.financialYear);
        }
        return months0(a.period).compareTo(months0(b.period));
      });

    final int n = perYear.length;
    final List<GuarantorFinancialValue> lastFive =
        (n <= 5) ? perYear : perYear.sublist(n - 5, n);

    return List<Statement>.generate(lastFive.length, (i) {
      final GuarantorFinancialValue fv = lastFive[i];
      final int months = months0(fv.period);
      final DateTime headerDate = _dateFromSaved(fv); //  use statementDate
      return Statement(
        id: i + 1,
        date: headerDate, // real month from API
        periods: months,
        statementConsts: [
          StatementConst(id: 0, value: fv.auditMethod), // audit method
          StatementConst(id: 1, value: fv.auditor ?? ""), // auditor can be ""
        ],
      );
    });
  }

  String _formatSavedValue(double? savedValue) {
    if (savedValue == null) return unavailableText;
    final double truncated = (savedValue * 100).truncate() / 100.0;
    return truncated.toStringAsFixed(2);
  }

  void setSelectedHealthFor(int entityId, Reference? r) {
    _healthByEntity[entityId] = r;
  }

  /// Populate IncomeStatement rows from saved guarantor response (robust/deduped)
  void populateIncomeStatementRowsFromSaved(
    GuarantorFinancialDetailsResponse gResp,
  ) {
    incomeStatementRows.clear();

    final List<GuarantorCategoryDetail> allCats =
        gResp.entityDetails.expand((e) => e.financialsCategory).toList();
    final int idx =
        allCats.indexWhere((c) => c.financialsCategory == categoryIncome);
    final GuarantorCategoryDetail? incomeCat =
        (idx == -1) ? null : allCats[idx];

    if (incomeCat == null || incomeCat.financialsValues.isEmpty) {
      return; // nothing to populate
    }

    final int entityId = gResp.entityDetails.first.entityId; // NEW

    final List<GuarantorFinancialValue> vals = incomeCat.financialsValues;

    final Map<String, GuarantorFinancialValue> uniq = {};
    for (final value in vals) {
      final String keyPart =
          (value.financialRatioType?.trim().isNotEmpty == true)
              ? value.financialRatioType!.trim()
              : (value.userAddedRatioType ?? "").trim();
      if (keyPart.isEmpty) continue;

      final int months = _parsePeriodMonths(value.period);
      final String dedupeKey = "$keyPart|${value.financialYear}|$months";
      uniq[dedupeKey] = value; // last wins
    }
    final List<GuarantorFinancialValue> deduped = uniq.values.toList();

    incomeStatements = _buildStatementsFromSaved(deduped);
    final List<Statement> headers = _buildStatementsFromSaved(deduped);
    final List<IncomeStatementAnalysisRow> rowsForEntity = [];

    _incomeRowsByEntity[entityId] = rowsForEntity;
    _statementsByEntity[entityId] = headers;
    _longNameByEntity[entityId] = gResp.entityDetails.first.entityLongName;

    _incomeRowsByEntity[entityId] = rowsForEntity;
    _statementsByEntity[entityId] = headers;
    _longNameByEntity[entityId] = gResp.entityDetails.first.entityLongName;

    final int? healthId = incomeCat.guarantorHealth;
    if (healthId != null && balanceSheetHealth.isNotEmpty) {
      final int idx = balanceSheetHealth.indexWhere((r) => r.id == healthId);
      _healthByEntity[entityId] = (idx >= 0) ? balanceSheetHealth[idx] : null;
    } else {
      _healthByEntity[entityId] = null;
    }

    if (state.currentEntityId == entityId) {
      incomeStatementRows
        ..clear()
        ..addAll(rowsForEntity);
      incomeStatements = headers;
      selectedBalanceSheetHealth = _healthByEntity[entityId];
    }

    String displayNameFor(String key) {
      final Reference ref = (financialRatioType ?? []).firstWhere(
        (val) => (val.reference2 ?? "") == key,
        orElse: () => Reference(name: ""),
      );
      return (ref.name?.isNotEmpty == true) ? ref.name! : key;
    }

    final Map<String, List<GuarantorFinancialValue>> byKey = {};
    for (final GuarantorFinancialValue value in deduped) {
      final String ratioType =
          (value.financialRatioType?.trim().isNotEmpty == true)
              ? value.financialRatioType!.trim()
              : (value.userAddedRatioType ?? "").trim();
      if (ratioType.isEmpty) continue;
      byKey.putIfAbsent(ratioType, () => []).add(value);
    }
    for (final MapEntry<String, List<GuarantorFinancialValue>> entry
        in byKey.entries) {
      final String key = entry.key;
      final List<GuarantorFinancialValue> items = entry.value;

      final bool isCodeBased =
          items.first.financialRatioType?.trim().isNotEmpty == true;

      final IncomeStatementAnalysisRow row = IncomeStatementAnalysisRow(
        id: isCodeBased
            ? key
            : DateTime.now().millisecondsSinceEpoch.toString(),
        incomePositions: displayNameFor(key),
        audited1: unavailableText,
        audited2: unavailableText,
        audited3: unavailableText,
        inhouse: unavailableText,
        estimated: unavailableText, // API doesn't carry a 5th period
        isNew: !isCodeBased, // user-added rows remain editable
      );

      final int maxCols = incomeStatements.length.clamp(0, 5);
      for (int colIndex = 0; colIndex < maxCols; colIndex++) {
        final Statement s = incomeStatements[colIndex];
        final int months = s.periods;
        final int year = s.date.year;
        String fmtStmtDate(DateTime d) => DateFormat("yyyy-MM-dd").format(d);

        final GuarantorFinancialValue v = items.firstWhere(
          (x) =>
              x.financialYear == year && _parsePeriodMonths(x.period) == months,
          orElse: () => GuarantorFinancialValue(
            financialsCategory: categoryIncome,
            financialRatioType: items.first.financialRatioType,
            userAddedRatioType: items.first.userAddedRatioType,
            financialYear: year,
            statementDate: fmtStmtDate(s.date),
            period: "${months}M",
            auditMethod: "",
            auditor: "",
            value: null,
          ),
        );

        final String valueStr = _formatSavedValue(v.value);

        if (colIndex == 0) {
          row.audited1 = valueStr;
        } else if (colIndex == 1) {
          row.audited2 = valueStr;
        } else if (colIndex == 2) {
          row.audited3 = valueStr;
        } else if (colIndex == 3) {
          row.inhouse = valueStr;
        } else if (colIndex == 4) {
          row.estimated = valueStr;
        }
      }

      incomeStatementRows.add(row);
    }

    final List<IncomeStatementAnalysisRow> newRows =
        incomeStatementRows.where((r) => r.isNew).toList();
    incomeRows = [...incomeStatementRows, ...newRows];
    hasSavedAnalysisData = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //set Column data from api response in income statement
  String getConstValue(int statementIndex, int constIndex) {
    final List<Statement> statements = incomeStatements;
    if (statementIndex < 0 || statementIndex >= statements.length) {
      return unavailableText;
    }
    final Statement statement = statements[statementIndex];
    final List<StatementConst> constList = statement.statementConsts;
    if (constIndex < 0 || constIndex >= constList.length) {
      return unavailableText;
    }
    final String rawValue = constList[constIndex].value.trim();
    if (rawValue.isEmpty) {
      return unavailableText;
    }
    if (rawValue == ServerConstants.unqualified) {
      return "Audited-$rawValue";
    }
    return rawValue;
  }

  /// Formats “MMM-yyyy (nM)” or fallback if out of range.
  String getHeaderDate(int index) {
    if (index < 0 || index >= incomeStatements.length) return unavailableText;
    final Statement s = incomeStatements[index];
    return "${DateFormat('MMM-yyyy').format(s.date)} (${s.periods}M)";
  }

  Future<void> deleteGuarantorSection(int entityId) async {
    try {
      repository ??= RemarksRepository.instance;
      final int rimNo = selectedCustomer?.customerRimNo ?? 0;
      final int idx =
          state.guarantors.indexWhere((g) => (g.entityId ?? 0) == entityId);

      final bool isFirstSection =
          (idx == 0) || (entityId == (state.currentEntityId ?? -1));

      final bool isPersisted = _savedEntityIds.contains(entityId);

      if (!isPersisted) {
        // ---------- UNSAVED SECTION ----------
        if (isFirstSection) {
          _incomeRowsByEntity.remove(entityId);
          _healthByEntity.remove(entityId);
          _remarksByEntity.remove(entityId);
          _remarksByEntity[entityId] = "";

          if (state.currentEntityId == entityId) {
            incomeStatementRows.clear();
          }
          hasCreditLensData = false;
          hasSavedAnalysisData = false;
          entityController.text = "";
          editorForEntity(entityId).setText("");
          entityController.clear();

          emit(
            state.copyWith(
              loaderStatus: LoadingStatus.loading, // pulse
              buttonStatus: LoadingStatus.loading,
              currentEntityId: null,
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
          final List<Guarantor> list = List<Guarantor>.from(state.guarantors)
            ..removeWhere((g) => (g.entityId ?? 0) == entityId);

          _incomeRowsByEntity.remove(entityId);
          _statementsByEntity.remove(entityId);
          _longNameByEntity.remove(entityId);
          _healthByEntity.remove(entityId);
          _remarksByEntity.remove(entityId);
          _editorsByEntity.remove(entityId);

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

        AlertManager().showSuccessToast("Deleted Successfully");
        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loaded, // settle
          ),
        );
        return; //  done; no backend call for unsaved
      }

      // ---------- SAVED SECTION ----------
      await repository!.deleteGuarantorDetailsByEntityId(
        entityId: entityId,
        rimNo: rimNo,
      );
      _savedEntityIds.remove(entityId);

      if (isFirstSection) {
        _incomeRowsByEntity.remove(entityId);
        _statementsByEntity.remove(entityId);
        _longNameByEntity.remove(entityId);
        _healthByEntity.remove(entityId);
        _remarksByEntity.remove(entityId);
        _remarksByEntity[entityId] = "";

        if (state.currentEntityId == entityId) {
          incomeStatementRows.clear();
          incomeStatements.clear();
        }

        editorForEntity(entityId).setText("");
        entityController.clear();
        final bool hasAnyData =
            _incomeRowsByEntity.isNotEmpty || _statementsByEntity.isNotEmpty;
        hasCreditLensData = hasAnyData;
        hasSavedAnalysisData = hasAnyData;
        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loading, // pulse
            buttonStatus: LoadingStatus.loading,
            currentEntityId: null,
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

        _incomeRowsByEntity.remove(entityId);
        _statementsByEntity.remove(entityId);
        _longNameByEntity.remove(entityId);
        _healthByEntity.remove(entityId);
        _remarksByEntity.remove(entityId);
        _editorsByEntity.remove(entityId);

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
    } catch (e) {
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
    entityController.text = "";
    state.currentEntityId = null;
    entityController.clear();
    await fetchSavedGuarantorFinancialDetails();
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  void updatePendingEntityId(int sectionEntityId, String text) {
    _draftEntityIdBySection[sectionEntityId] = int.tryParse(text.trim()) ?? 0;
  }

  void updateEntityId(String text, {int? sectionEntityId}) {
    final int id = int.tryParse(text.trim()) ?? 0;
    if (sectionEntityId != null) {
      _draftEntityIdBySection[sectionEntityId] = id;
    } else {
      _draftEntityId = id;
    }
  }

// Keep the add-guarantor draft field separate
  void updateEntityIdDraft(String text) {
    _draftEntityId = int.tryParse(text.trim());
  }

  /// Arms the Add‐Guarantor section, showing its search field and button.
  void onAddTap() {
    emit(
      state.copyWith(
        nextCanDelete: true,
      ),
    );
  }

// Collapse the Add‑Guarantor UI and refresh with a loader pulse
  void cancelAddGuarantor() {
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
      } catch (_) {}
      return;
    }

    //block duplicates across all sections (ignore placeholder 0)
    final Set<int> existingIds = {
      if (state.currentEntityId != null) state.currentEntityId!,
      ...state.guarantors.map((g) => g.entityId ?? 0),
    }..removeWhere((e) => e <= 0);

    if (existingIds.contains(entityId)) {
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

      final Guarantor newItem = Guarantor(
        entityId: entityId,
        name: "",
        analysisHtml: """ """,
        spreadsmartUrl: EnvConfig.spreadSmartUrl,
        canDelete: state.nextCanDelete,
      );
      emit(
        state.copyWith(
          guarantors: [...state.guarantors, newItem],
          currentEntityId: extraSection ? state.currentEntityId : entityId,
          nextCanDelete: false,
          showExtraTab: extraSection,
          canDeleteSection: extraSection,
        ),
      );
    } catch (e) {
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

  Future<void> onSavePress(bool isContinue, BuildContext context) async {
    try {
      final Set<int> entityIds = {
        if (state.currentEntityId != null) state.currentEntityId!,
        ..._statementsByEntity.keys,
        ..._incomeRowsByEntity.keys,
      }..removeWhere((e) => e <= 0);

      final bool hasAnyEntity = entityIds.isNotEmpty;

      if (!hasExistingGuarantorDetails && !hasAnyEntity) {
        final String descComment = await controller.getText();
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
        AlertManager().showSuccessToast(
          "remarks.guarantorFinancials.savedSuccessfully".tr(),
        );
        if (isContinue) navigate();
        return;
      } else {
        final List<GuarantorFinancialDetailsResponse> items =
            await buildSaveItems();
        final bool noEntityData =
            items.isEmpty || items.first.entityDetails.isEmpty;
        if (noEntityData) {
          navigate();
          return;
        }
        await repository!.saveGuarantorFinancialDetails(items: items);
        AlertManager().showSuccessToast(
          "remarks.guarantorFinancials.savedSuccessfully".tr(),
        );
        if (isContinue) navigate();
      }

      unawaited(deleteDraft());
    } catch (error, stack) {
      logger.e(
        "Error saving guarantor financial details",
        error: error,
        stackTrace: stack,
      );
      AlertManager().showFailureToast(error.toString());
    }
  }

  //No Use for testing.
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
    final String audtorRow = auditorRaw.trim();
    if (audtorRow.isEmpty ||
        audtorRow.toLowerCase() == unavailableText.toLowerCase() ||
        audtorRow.toLowerCase() == "data not available") {
      return ""; // optional: make it empty string instead of null
    }
    return audtorRow;
  }

  /// Build one GuarantorFinancialValue per visible column for a row:
  /// - 5 columns: audited1, audited2, audited3, inhouse, estimated
  /// - Do NOT skip NA/empty/NaN cells; we still emit a value with value=null.
  /// - Periods and year are taken from the per-entity headers
  /// (statementsFor(entityId)).
  List<GuarantorFinancialValue> _valuesFromRow({
    required int entityId,
    required String? ratioCode, // "101" for API rows; "0" for user-added
    required String? userAddedType, // label for user-added rows
    required List<String>
        cols, // [audited1, audited2, audited3, inhouse, estimated]
  }) {
    final List<GuarantorFinancialValue> out = <GuarantorFinancialValue>[];

    for (int colIndex = 0;
        colIndex < cols.length &&
            colIndex < statementsFor(entityId).length &&
            colIndex < 5;
        colIndex++) {
      final Statement s = statementsFor(entityId)[colIndex];
      final String raw = cols[colIndex].trim();
      final bool isNa = raw.isEmpty || raw.toLowerCase() == "nan";
      final double? valueDouble = isNa ? null : double.tryParse(raw);

      final String auditMethod =
          _auditMethodForSave(_getConstValueForEntity(entityId, colIndex, 0));
      final String? auditor =
          _auditorForSave(_getConstValueForEntity(entityId, colIndex, 1));
      final String stmtDate = DateFormat("yyyy-MM-dd").format(s.date);

      out.add(
        GuarantorFinancialValue(
          financialsCategory: 0, // stamped later in _categoryBlock
          financialRatioType: ratioCode, // "101" (API) or "0" (user-added)
          userAddedRatioType: userAddedType, // label for user-added rows
          financialYear: s.date.year,
          period: "${s.periods}M", // e.g., "12M", "6M", "9M"
          auditMethod: auditMethod,
          statementDate: stmtDate,
          auditor: auditor, // may be null/empty
          value: valueDouble, // null allowed
        ),
      );
    }

    return out;
  }

  void removeGuarantor(int index) {
    if (state.guarantors.length <= 1) return;

    final removedEntityId = state.guarantors[index].entityId ?? 0;

    final list = List<Guarantor>.from(state.guarantors)..removeAt(index);
    emit(state.copyWith(guarantors: list));
    _incomeRowsByEntity.remove(removedEntityId);
    _statementsByEntity.remove(removedEntityId);
    _longNameByEntity.remove(removedEntityId);
    _healthByEntity.remove(removedEntityId);
  }

  Future<void> deleteUserAddedIncomeRow(IncomeStatementAnalysisRow row) async {
    try {
      repository ??= RemarksRepository.instance;
      final rimNo = selectedCustomer?.customerRimNo ?? 0;
      final entityId = state.currentEntityId ?? 0;
      await repository!.deleteGuarantorDetails(
        rimNo: rimNo,
        entityId: entityId,
        financialsCategory: categoryIncome,
        userAddedRatioType: row.incomePositions, // the label user typed
      );
      deleteIncomeRow(row.id);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  GuarantorCategoryDetail _categoryBlock({
    required int entityId,
    required int categoryId,
    required String remarksText,
    required int? healthId,
    required List<dynamic> rows,
  }) {
    final List<GuarantorFinancialValue> allValues = <GuarantorFinancialValue>[];

    for (final row in rows) {
      final String label =
          (row.incomePositions ?? row.balanceSheet ?? row.cashFlowItems ?? "")
              .trim();
      final String code =
          (!row.isNew && (row.id?.isNotEmpty == true)) ? row.id! : "0";

      final String? userAdded =
          (row.isNew && code == "0") ? (label.isNotEmpty ? label : null) : null;

      final List<String> cols = <String>[
        row.audited1 ?? "",
        row.audited2 ?? "",
        row.audited3 ?? "",
        row.inhouse ?? "",
        row.estimated ?? "", // send the 5th column too
      ];

      //Skip untouched user‑added rows (no label AND all cells empty)
      final bool isEmptyNewRow = row.isNew == true &&
          code == "0" &&
          label.isEmpty &&
          cols.every((c) => c.trim().isEmpty);

      if (isEmptyNewRow) {
        continue; // ← do not emit values for this row; keeps payload clean
      }

      final List<GuarantorFinancialValue> mapped = _valuesFromRow(
        entityId: entityId,
        ratioCode: code, // "101" for API rows; "0" for user-added rows
        userAddedType: userAdded, // label when user-added
        cols: cols,
      )
          .map(
            (v) => GuarantorFinancialValue(
              financialsCategory: categoryId, // stamp category for the table
              financialRatioType:
                  v.financialRatioType, // keep "0" for user-added
              userAddedRatioType: v.userAddedRatioType,
              financialYear: v.financialYear,
              period: v.period,
              statementDate: v.statementDate,
              auditMethod: v.auditMethod,
              auditor: v.auditor,
              value: v.value, // may be null
            ),
          )
          .toList();

      allValues.addAll(mapped);
    }

    return GuarantorCategoryDetail(
      financialsCategory: categoryId,
      financialsValues: allValues, // includes NA/null entries
      guarantorHealth: healthId,
      remarks: remarksText.isNotEmpty ? remarksText : null,
    );
  }

// --- NEW: read statement consts (audit method / auditor) for a given entity ---
  String _getConstValueForEntity(
    int entityId,
    int statementIndex,
    int constIndex,
  ) {
    final List<Statement> statements =
        statementsFor(entityId); // per-entity header  // turn17search2
    if (statementIndex < 0 || statementIndex >= statements.length) {
      return unavailableText;
    }
    final Statement s = statements[statementIndex];
    final List<StatementConst> consts = s.statementConsts;
    if (constIndex < 0 || constIndex >= consts.length) return unavailableText;
    final String raw = consts[constIndex].value.trim();
    if (raw.isEmpty) return unavailableText;
    return raw == ServerConstants.unqualified ? "Audited-$raw" : raw;
  }

// SAFE reader for per-entity remarks.
// - try the editor (with a 1s timeout)
// - if empty or fails, use cached _remarksByEntity[entityId]
  Future<String> _sectionRemarksForSave(int entityId) async {
    final UnifiedEditorController ctrl = editorForEntity(entityId);
    try {
      final String txt =
          await ctrl.getText().timeout(const Duration(milliseconds: 1000));

      if (txt.isNotEmpty) {
        _remarksByEntity[entityId] = txt; // cache per section
        return txt;
      }
      return remarksForEntity(entityId).trim(); // per-section fallback only
    } catch (e) {
      logger.w(
        "Section editor not mounted for entity $entityId, using cached remarks",
        error: e,
      );
      return remarksForEntity(entityId).trim(); // per-section fallback only
    }
  }

  void collapseExtraBox() {
    emit(
      state.copyWith(
        showExtraTab: false,
        canDeleteSection: false,
      ),
    );
  }

  void navigate() {
    bool isCurrentRouteFound = false;
    for (final MapEntry<RemarksTabs, String> entry
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

  Future<void> changeTab(RemarksTabs tab) async {
    router.go(TabConstants.remarksRoutes[tab]!, extra: tab);
    if (!isReadOnlyMode) {
      await loadDraftIfAvailable();
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateLongNameFor(int entityId, String text) {
    final String cleaned = text.trim();
    _longNameByEntity[entityId] = cleaned;

    // Keep the global longName aligned for the current (first) section
    if (state.currentEntityId == entityId) {
      longName = cleaned;
    }
  }

  //build payload for save api saveGuarantorFinancialDetails
  Future<List<GuarantorFinancialDetailsResponse>> buildSaveItems() async {
    final List<GuarantorFinancialDetailsResponse> items = [];

    final Set<int> entityIds = {
      if (state.currentEntityId != null) state.currentEntityId!,
      ..._statementsByEntity.keys,
      ..._incomeRowsByEntity.keys,
    }..removeWhere((e) => e <= 0);

    final List<GuarantorEntityDetail> allEntityBlocks = [];
    String sectionRemarks = "";

    for (final entityId in entityIds) {
      final rows =
          _incomeRowsByEntity[entityId] ?? const <IncomeStatementAnalysisRow>[];
      final int? healthId = _healthByEntity[entityId]?.id;
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

      final entityBlock = GuarantorEntityDetail(
        guarantorFinancialsId: guarantorFinancialsId,
        entityId: entityId,
        entityLongName: _longNameByEntity[entityId] ?? longName ?? "",
        financialsCategory: categories,
      );

      allEntityBlocks.add(entityBlock);
    }

    allEntityBlocks.removeWhere((e) => e.financialsCategory.isEmpty);

    if (allEntityBlocks.isEmpty) {
      return const <GuarantorFinancialDetailsResponse>[];
    }

    final now = DateTime.now().toUtc();
    final GuarantorFinancialDetailsResponse singleItem =
        GuarantorFinancialDetailsResponse(
      guarantorFinancialsId: guarantorFinancialsId,
      appRefNo: Globals.request?.applicationRefNo ?? "",
      rimNo: selectedCustomer?.customerRimNo ?? 0,
      customerName: selectedCustomer?.customerName?.trim() ?? "",
      entityDetails: allEntityBlocks,
      createdBy: Globals.user?.name,
      createdDate: now,
      updatedBy: Globals.user?.name,
      updatedDate: now,
    );

    items.add(singleItem);
    return items;
  }

  Future<void> setAsterisks() async {
    showAsteriskTabs = Utils.getMandatoryRemarksTabs(selectedCustomer);
  }

  /// Only FI types should show the "View more / View less" affordance.
  /// Country (and other non-FI) show all chips without the toggle.
  bool get showViewMore =>
      selectedCustomer?.type == CustomerType.belowInvestmentGradeBanks ||
      selectedCustomer?.type == CustomerType.investmentGradeBanks;
}
