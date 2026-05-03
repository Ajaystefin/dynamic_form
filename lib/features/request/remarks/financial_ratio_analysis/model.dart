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

/// Cubit responsible for managing financial ratio analysis data and UI state.
///
/// Handles initialization, row population for three statements (Income,
/// Cashflow, Balance), add/delete of rows, entity search logic,
/// and customer-change events.
class FinancialRatioAnalysisViewModel
    extends SafeCubit<FinancialRatioAnalysisState>
    with DraftMixin<FinancialRatioAnalysisViewModel> {
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

  /// Repository for fetching and persisting financial analysis data.
  RemarksRepository? repository;

  // --- DRAFT IDENTITY ---
  @override
  String get draftModuleKey => DraftModuleKeys.remarks;

  @override
  String get draftFormKey =>
      "${Routes.financialRatiosAnalysis}_${selectedCustomer?.customerRimNo}";

  @override
  DraftHandler<FinancialRatioAnalysisViewModel> get draftHandler =>
      FinancialRatioAnalysisDraftHandler();
  // ----------------------

  /// Service for fetching reference data.
  final ReferenceDataService? _referenceDataService;

  /// Controller for the rich‐text HTML editor.
  final UnifiedEditorController balanceSheetcontroller =
      UnifiedEditorController();

  /// Controller for the rich‐text HTML editor.
  final UnifiedEditorController cashflowController = UnifiedEditorController();

  /// Controller for the rich‐text HTML editor.
  final UnifiedEditorController incomeStatementController =
      UnifiedEditorController();

  /// Controller for the rich‐text HTML editor.
  final UnifiedEditorController descTextController = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();

  /// Form key for validating and saving the analysis form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Comment? commentData = Comment();

  /// Currently selected customer.
  Customer? selectedCustomer =
      Globals.selectedCustomer ?? Globals.request?.customers?.first;

  /// List of all customers from the global request object.
  List<Customer> get customers => Globals.request?.customers ?? [];

  /// Row data for the Income Statement table.
  final List<IncomeStatementAnalysisRow> incomeStatementRows = [];

  /// Row data for the Cashflow Statement table.
  final List<CashFlowSheetAnalysisRow> cashflowSheetRows = [];

// These IDs come from your working save request/response samples.
  static const int categoryIncome = 234; // Income statement Analysis
  static const int categoryCashflow = 236; // Cash Flow statement Analysis
  static const int categoryBalance = 237; // Cash Flow statement Analysis

  /// Row data for the Balance Sheet table.
  final List<BalanceSheetAnalysisRow> balanceSheetRows = [];

  /// Indicates whether the Income Statement table should show an action column.
  bool get hasActionColumn => incomeStatementRows.any((r) => r.isNew);

  /// Indicates whether the Cashflow Statement table shows an action column.
  bool get hasActionColumnCashflow => cashflowSheetRows.any((r) => r.isNew);

  /// Indicates whether the Balance Sheet table shows an action column.
  bool get hasActionColumnBalanceSheet => balanceSheetRows.any((r) => r.isNew);

  //health dropdowns
  Reference? selectedBalanceSheetHealth = Reference(name: "Select");
  Reference? selectedIncomeHealth = Reference(name: "Select");
  Reference? selectedCashFlowHealth = Reference(name: "Select");
  List<Reference>? financialCategory = [];
  List<Reference>? financialRatioType = [];
  List<Reference>? cashflowHealth = [];
  List<Reference>? incomeHealth = [];
  List<Reference>? balanceHealth = [];

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
    RemarksTabs.financialRatiosAndAnalysis,
  ];
  bool hasSavedAnalysisData = false;
  int? entityId;
  PageMode pageMode = PageMode.na;

  bool get isReadOnlyMode => pageMode == PageMode.view;

  //description of accounts
  String? description;
  String? incomeDescription;
  String? cashflowDescription;
  String? balanceSheetdescription;
  TextEditingController entityController = TextEditingController();
  bool hasExistingFinancialDetails = false;

  List<Customer>? customerList = [];
  bool isFI = false;

  /// Initializes repository and pre‐populates all three statement tables.
  ///
  /// Emits a loading state, populates default rows, then emits loaded.
  Future<void> init(context) async {
    logger.i("Initializing FinancialRatioAnalysisViewModel");
    pageMode = AuthRepository.getPageMode(RightConstants.remarksCommentary);
    // for checkup with request type creditRisk
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

  Future<void> fetchSavedFinancialAnalysis() async {
    try {
      repository ??= RemarksRepository.instance;
      final rimNo = selectedCustomer?.customerRimNo ??
          selectedCustomer?.customerRimNo ??
          0;
      if (rimNo <= 0) {
        hasSavedAnalysisData = false;
        return;
      }
      final FinancialRatioAnalysisResponse resp =
          await repository!.getFinancialRatioAnalysisDetails(rimNo: rimNo);
      description = resp.descOfAccounts ?? "";
      hasExistingFinancialDetails = true;

      if (description!.isNotEmpty) {
        descTextController.setText(description!);
      }
      if (resp.entityDetails.isNotEmpty) {
        final firstEntity = resp.entityDetails.first;
        entityController.text = firstEntity.entityId.toString();
        final cats = firstEntity.financialsCategory;
        for (final cat in cats) {
          final String text = (cat.remarks ?? "").trim();
          switch (cat.financialsCategory) {
            case categoryIncome: // 234 → Income Statement
              if (text.isNotEmpty) {
                incomeDescription = text;
                incomeStatementController.setText(text);
              }
              selectedIncomeHealth =
                  healthRefById(cat.financialHealth, incomeHealth);

            case categoryCashflow: // 236 → Cash Flow
              if (text.isNotEmpty) {
                cashflowDescription = text;
                cashflowController.setText(text);
              }
              selectedCashFlowHealth =
                  healthRefById(cat.financialHealth, cashflowHealth);

            case categoryBalance: // 237 → Balance Sheet
              if (text.isNotEmpty) {
                balanceSheetdescription = text;
                balanceSheetcontroller.setText(text);
              }
              selectedBalanceSheetHealth =
                  healthRefById(cat.financialHealth, balanceHealth);

            default:
              break;
          }
        }

        longName = firstEntity.entityLongName;
        entityId = firstEntity.entityId;

        final incomeCat = cats.firstWhere(
          (c) => c.financialsCategory == categoryIncome,
          orElse: () => FinancialCategoryDetail(
            financialsCategory: categoryIncome,
            financialsValues: const [],
            financialHealth: null,
            remarks: null,
          ),
        );
        final cashflowCat = cats.firstWhere(
          (c) => c.financialsCategory == categoryCashflow,
          orElse: () => FinancialCategoryDetail(
            financialsCategory: categoryCashflow,
            financialsValues: const [],
            financialHealth: null,
            remarks: null,
          ),
        );
        final balanceCat = cats.firstWhere(
          (c) => c.financialsCategory == categoryBalance,
          orElse: () => FinancialCategoryDetail(
            financialsCategory: categoryBalance,
            financialsValues: const [],
            financialHealth: null,
            remarks: null,
          ),
        );

        final headerSource = incomeCat.financialsValues.isNotEmpty
            ? incomeCat.financialsValues
            : (cashflowCat.financialsValues.isNotEmpty
                ? cashflowCat.financialsValues
                : balanceCat.financialsValues);

        incomeStatements = buildStatementsFromSavedValues(
          headerSource,
        ); // shared header for all 3 tables

        // ===== Populate Income table from saved =====
        incomeStatementRows.clear();
        if (incomeCat.financialsValues.isNotEmpty) {
          final Map<String, List<FinancialValue>> byKey = {};
          for (final rowFieldValue in incomeCat.financialsValues) {
            final String codeRaw = rowFieldValue.financialRatioType
                .trim(); // "101", "74", "", "null"
            final String labelRaw = (rowFieldValue.userAddedRatioType ?? "")
                .trim(); // e.g., "incomesuser"
            final bool isUserAdded =
                codeRaw.isEmpty || codeRaw.toLowerCase() == "null"; // NEW
            final String key = isUserAdded ? labelRaw : codeRaw;
            if (key.isEmpty) continue;
            (byKey[key] ??= <FinancialValue>[]).add(rowFieldValue);
          }

          for (final e in byKey.entries) {
            incomeStatementRows.add(
              mkIncomeRowFromSaved(e.key, e.value, unavailableText),
            );
          }
          final newRows = incomeStatementRows.where((r) => r.isNew).toList();
          incomeRows = [...incomeStatementRows, ...newRows];
        }

        cashflowSheetRows.clear();
        if (cashflowCat.financialsValues.isNotEmpty) {
          final Map<String, List<FinancialValue>> byKey = {};
          for (final v in cashflowCat.financialsValues) {
            final String codeRaw = v.financialRatioType.trim();
            final String labelRaw = (v.userAddedRatioType ?? "").trim();
            final bool isUserAdded =
                codeRaw.isEmpty || codeRaw.toLowerCase() == "null"; // NEW
            final String key = isUserAdded ? labelRaw : codeRaw;
            if (key.isEmpty) continue;
            (byKey[key] ??= <FinancialValue>[]).add(v);
          }

          final merged = <CashFlowSheetAnalysisRow>[];
          for (final e in byKey.entries) {
            merged.add(mkCashflowRowFromSaved(e.key, e.value, unavailableText));
          }
          cashflowSheetRows.addAll(merged);
          final newRows = cashflowSheetRows.where((r) => r.isNew).toList();
          cashflowRows = [...merged, ...newRows];
        }

        // ===== Populate Balance table from saved =====
        balanceSheetRows.clear();
        if (balanceCat.financialsValues.isNotEmpty) {
          final Map<String, List<FinancialValue>> byKey = {};
          for (final v in balanceCat.financialsValues) {
            final String codeRaw = v.financialRatioType.trim();
            final String labelRaw = (v.userAddedRatioType ?? "").trim();
            final bool isUserAdded =
                codeRaw.isEmpty || codeRaw.toLowerCase() == "null"; //  NEW
            final String key = isUserAdded ? labelRaw : codeRaw;
            if (key.isEmpty) continue;
            (byKey[key] ??= <FinancialValue>[]).add(v);
          }

          final merged = <BalanceSheetAnalysisRow>[];
          for (final e in byKey.entries) {
            merged.add(mkBalanceRowFromSaved(e.key, e.value, unavailableText));
          }
          balanceSheetRows.addAll(merged);
          final newRows = balanceSheetRows.where((r) => r.isNew).toList();
          balanceRows = [...merged, ...newRows];
        }

        emit(state.copyWith(currentEntityId: firstEntity.entityId));
        hasSavedAnalysisData = true;
      } else {
        hasSavedAnalysisData = false;
      }
    } catch (e) {
      hasSavedAnalysisData = false;
      hasExistingFinancialDetails = false;
      await getRemarks();
    }
  }

  // Map a saved health id to the corresponding Reference item
  Reference? healthRefById(int? id, List<Reference>? list) {
    if (id == null) return null;
    final healthList = list ?? const <Reference>[];
    final idx = healthList.indexWhere((r) => r.id == id);
    return (idx >= 0) ? healthList[idx] : null;
  }

  /// Validates the current entity ID and triggers search logic.
  ///
  /// Emits loading, shows warning if ID is empty, then re‐emits loaded.
  Future<void> searchEntity() async {
    repository ??= RemarksRepository.instance;
    final searchedEntityId = state.currentEntityId;
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
    } catch (e) {
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
    if (input.isEmpty) return const <Statement>[];

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
    if (items.isEmpty) return unavailableText;

    // 1) Exact match by date
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
      if (raw.isEmpty || raw.toLowerCase() == "nan") return unavailableText;
      final double? roundedStr = double.tryParse(raw);
      if (roundedStr == null) return unavailableText;
      return roundedStr.toStringAsFixed(2);
    }

    return unavailableText;
  }

  void populateIncomeStatementRows(FinancialDetailsResponse resp) {
    incomeStatementRows.clear();
    incomeStatements = _canonicalHeaders(resp.statements);

    final List<Reference> incomeRefs = financialRatioType
            ?.where(
              (row) =>
                  row.reference1 == ServerConstants.incomeStatementAnalysis,
            )
            .toList() ??
        [];

    final List<IncomeStatementAnalysisRow> mergedRows = incomeRefs.map((ref) {
      final String key = ref.reference2 ?? "";
      final List<MacroItem> items =
          (key.isNotEmpty) ? (resp.macros[key] ?? const []) : const [];

      final row = IncomeStatementAnalysisRow(
        id: key.isNotEmpty
            ? key
            : DateTime.now().millisecondsSinceEpoch.toString(),
        incomePositions: ref.name ?? "",
        audited1: unavailableText,
        audited2: unavailableText,
        audited3: unavailableText,
        inhouse: unavailableText,
        estimated: unavailableText, // 5th column slot
        isNew: false,
      );

      for (int colIndex = 0;
          colIndex < incomeStatements.length && colIndex < 5;
          colIndex++) {
        final Statement statement = incomeStatements[colIndex];
        final String value = _valForByDate(items, statement, unavailableText);
        if (colIndex == 0) {
          row.audited1 = value;
        } else if (colIndex == 1) {
          row.audited2 = value;
        } else if (colIndex == 2) {
          row.audited3 = value;
        } else if (colIndex == 3) {
          row.inhouse = value;
        } else if (colIndex == 4) {
          row.estimated = value;
        }
      }
      return row;
    }).toList();

    incomeStatementRows.addAll(mergedRows);
    final List<IncomeStatementAnalysisRow> newRows =
        incomeStatementRows.where((row) => row.isNew).toList();
    incomeRows = [...mergedRows, ...newRows];
  }

  void populateBalanceSheetRows(FinancialDetailsResponse resp) {
    if (incomeStatements.isEmpty) {
      incomeStatements = _canonicalHeaders(resp.statements);
    }
    final List<Statement> headers = incomeStatements;

    final List<Reference> balanceRefs = financialRatioType
            ?.where(
              (row) => row.reference1 == ServerConstants.balanceSheetAnalysis,
            )
            .toList() ??
        [];

    final List<BalanceSheetAnalysisRow> mergedRows = balanceRefs.map((ref) {
      final BalanceSheetAnalysisRow apiRow = balanceSheetRows.firstWhere(
        (row) => row.id == (ref.reference2 ?? ""),
        orElse: () => BalanceSheetAnalysisRow(
          id: ref.reference2 ?? "",
          balanceSheet: ref.name ?? "",
          audited1: "",
          audited2: "",
          audited3: "",
          inhouse: "",
          estimated: "",
          isNew: false,
        ),
      )..balanceSheet = ref.name ?? "";
      final String key = ref.reference2 ?? "";
      final List<MacroItem> items =
          (key.isNotEmpty) ? (resp.macros[key] ?? const []) : const [];

      if (headers.isNotEmpty && items.isNotEmpty) {
        for (int colIndex = 0;
            colIndex < headers.length && colIndex < 5;
            colIndex++) {
          final Statement statement = headers[colIndex];
          final String value = _valForByDate(items, statement, unavailableText);
          if (colIndex == 0) {
            apiRow.audited1 = value;
          } else if (colIndex == 1) {
            apiRow.audited2 = value;
          } else if (colIndex == 2) {
            apiRow.audited3 = value;
          } else if (colIndex == 3) {
            apiRow.inhouse = value;
          } else if (colIndex == 4) {
            apiRow.estimated = value;
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

  void populateCashflowRows(FinancialDetailsResponse resp) {
    if (incomeStatements.isEmpty) {
      incomeStatements = _canonicalHeaders(resp.statements);
    }
    final List<Statement> headers = incomeStatements;
    final List<Reference> cashflowRefs = financialRatioType
            ?.where((row) => row.reference1 == ServerConstants.cashFlowAnalysis)
            .toList() ??
        [];
    final List<CashFlowSheetAnalysisRow> mergedRows = cashflowRefs.map((ref) {
      final CashFlowSheetAnalysisRow apiRow = cashflowSheetRows.firstWhere(
        (row) => row.id == (ref.reference2 ?? ""),
        orElse: () => CashFlowSheetAnalysisRow(
          id: ref.reference2 ?? "",
          cashFlowItems: ref.name ?? "",
          audited1: "",
          audited2: "",
          audited3: "",
          inhouse: "",
          estimated: "",
          isNew: false,
        ),
      )..cashFlowItems = ref.name ?? "";

      final String key = ref.reference2 ?? "";
      final List<MacroItem> items =
          (key.isNotEmpty) ? (resp.macros[key] ?? const []) : const [];

      if (headers.isNotEmpty && items.isNotEmpty) {
        for (int colIndex = 0;
            colIndex < headers.length && colIndex < 5;
            colIndex++) {
          final Statement statement = headers[colIndex];
          final String value = _valForByDate(items, statement, unavailableText);
          if (colIndex == 0) {
            apiRow.audited1 = value;
          } else if (colIndex == 1) {
            apiRow.audited2 = value;
          } else if (colIndex == 2) {
            apiRow.audited3 = value;
          } else if (colIndex == 3) {
            apiRow.inhouse = value;
          } else if (colIndex == 4) {
            apiRow.estimated = value;
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

    final List<CashFlowSheetAnalysisRow> newRows =
        cashflowSheetRows.where((row) => row.isNew).toList();
    cashflowRows = [...mergedRows, ...newRows];
  }

  // Parse "6M"/"12M" etc.
  int parseSavedMonths(String period) {
    final m = RegExp(r"(\d+)").firstMatch(period);
    return m != null ? int.tryParse(m.group(1)!) ?? 0 : 0;
  }

  // Prefer the API-provided statementDate (full fidelity: real month/day)
  DateTime dateFromSaved(FinancialValue value) {
    final String? statementDate = value.statementDate;
    if (statementDate != null && statementDate.trim().isNotEmpty) {
      try {
        return DateTime.parse(
          statementDate.trim(),
        ); // full fidelity: uses the real month/day
      } catch (_) {
        // fall through to the period-based fallback
      }
    }
    int monthsFromPeriod(String period) {
      final RegExpMatch? match = RegExp(r"(\d+)").firstMatch(period);
      return (match != null) ? int.tryParse(match.group(1)!) ?? 0 : 0;
    }

    final int periodMonths = monthsFromPeriod(value.period);
    final int month = (periodMonths == 12) ? 12 : periodMonths.clamp(1, 12);
    return DateTime(value.financialYear, month, 1);
  }

  /// Build canonical headers from saved FinancialValue entries:
  /// - group by year
  /// - pick the latest month within the year
  /// - take the latest 5 years
  /// - order ascending (oldest → newest)
  List<Statement> buildStatementsFromSavedValues(List<FinancialValue> values) {
    if (values.isEmpty) return const <Statement>[];

    int monthsFromPeriod(String period) {
      final match = RegExp(r"(\d+)").firstMatch(period);
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
      if (isNewer) latestPerYear[year] = value;
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

  // Display name for a ratio code (fallback to code itself)
  String displayNameForCode(String code) {
    final ref = (financialRatioType ?? []).firstWhere(
      (r) => (r.reference2 ?? "") == code,
      orElse: () => Reference(name: ""),
    );
    return (ref.name?.isNotEmpty == true) ? ref.name! : code;
  }

  IncomeStatementAnalysisRow mkIncomeRowFromSaved(
    String ratioKey,
    List<FinancialValue> items,
    String unavailableText,
  ) {
    final String firstCode = items.first.financialRatioType.trim();
    final bool isCodeBased =
        firstCode.isNotEmpty && firstCode.toLowerCase() != "null";

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

    final int maxCols = incomeStatements.length.clamp(0, 5);
    for (int colIndex = 0; colIndex < maxCols; colIndex++) {
      final Statement header = incomeStatements[colIndex];
      String fmtStmtDate(DateTime d) => DateFormat("yyyy-MM-dd").format(d);
      final FinancialValue matchedValue = items.firstWhere(
        (x) =>
            x.financialYear == header.date.year &&
            parseSavedMonths(x.period) == header.periods,
        orElse: () => FinancialValue(
          financialsCategory: 234,
          financialRatioType: ratioKey,
          userAddedRatioType: null,
          financialYear: header.date.year,
          statementDate: fmtStmtDate(header.date),
          period: "${header.periods}M",
          auditMethod: "",
          auditor: "",
          value: null,
        ),
      );
      final double? val = matchedValue.value;
      final String valueStr =
          (val == null) ? unavailableText : val.toStringAsFixed(2);
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
    return row;
  }

  CashFlowSheetAnalysisRow mkCashflowRowFromSaved(
    String key,
    List<FinancialValue> items,
    String unavailableText,
  ) {
    final String firstCode = items.first.financialRatioType.trim();
    final bool isCodeBased =
        firstCode.isNotEmpty && firstCode.toLowerCase() != "null";

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

    final int maxCols = incomeStatements.length.clamp(0, 5);
    for (int colIndex = 0; colIndex < maxCols; colIndex++) {
      final Statement header = incomeStatements[colIndex];
      String fmtStmtDate(DateTime d) => DateFormat("yyyy-MM-dd").format(d);
      final FinancialValue matchedValue = items.firstWhere(
        (x) =>
            x.financialYear == header.date.year &&
            parseSavedMonths(x.period) == header.periods,
        orElse: () => FinancialValue(
          financialsCategory: 236,
          financialRatioType: key,
          userAddedRatioType: null,
          financialYear: header.date.year,
          statementDate: fmtStmtDate(header.date),
          period: "${header.periods}M",
          auditMethod: "",
          auditor: "",
          value: null,
        ),
      );
      final double? val = matchedValue.value;
      final String valueStr =
          (val == null) ? unavailableText : val.toStringAsFixed(2);
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
    return row;
  }

  BalanceSheetAnalysisRow mkBalanceRowFromSaved(
    String key,
    List<FinancialValue> items,
    String unavailableText,
  ) {
    final String firstCode = items.first.financialRatioType.trim();
    final bool isCodeBased =
        firstCode.isNotEmpty && firstCode.toLowerCase() != "null";

    final BalanceSheetAnalysisRow row = BalanceSheetAnalysisRow(
      id: key,
      balanceSheet: displayNameForCode(key),
      audited1: unavailableText,
      audited2: unavailableText,
      audited3: unavailableText,
      inhouse: unavailableText,
      estimated: unavailableText,
      isNew: !isCodeBased,
    );

    final int maxVisibleColumns = incomeStatements.length.clamp(0, 5);
    for (int colIndex = 0; colIndex < maxVisibleColumns; colIndex++) {
      String fmtStmtDate(DateTime d) => DateFormat("yyyy-MM-dd").format(d);
      final Statement financialValues = incomeStatements[colIndex];
      final FinancialValue rowValue = items.firstWhere(
        (x) =>
            x.financialYear == financialValues.date.year &&
            parseSavedMonths(x.period) == financialValues.periods,
        orElse: () => FinancialValue(
          financialsCategory: 237,
          financialRatioType: key,
          userAddedRatioType: null,
          financialYear: financialValues.date.year,
          statementDate: fmtStmtDate(financialValues.date),
          period: "${financialValues.periods}M",
          auditMethod: "",
          auditor: "",
          value: null,
        ),
      );
      final double? val = rowValue.value;
      final String valueStr =
          (val == null) ? unavailableText : val.toStringAsFixed(2);
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
    return row;
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

  String rowValue(String? value, {bool isNew = false, int? rowIndex}) {
    final String trimmed = value?.trim() ?? "";
    if (isNew) return trimmed;

    return trimmed.isNotEmpty ? trimmed : unavailableText;
  }

  /// Loads reference data required for dropdowns and labels.
  ///
  /// Fetches data from the `ReferenceDataService` and populates local lists.
  Future<void> loadReferenceData() async {
    try {
      final service = _referenceDataService ?? ReferenceDataService();
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> changeTab(RemarksTabs tab) async {
    router.go(TabConstants.remarksRoutes[tab]!, extra: tab);
  }

// --- Income ---
  void addIncomeRow() {
    final int userAddedCount = incomeStatementRows.where((r) => r.isNew).length;
    if (userAddedCount >= 10) {
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

// --- Cashflow ---
  void addCashflowRow() {
    final int userAddedCount = cashflowSheetRows.where((r) => r.isNew).length;
    if (userAddedCount >= 10) {
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

// --- Balance Sheet ---
  void addBalanceRow() {
    final int userAddedCount = balanceSheetRows.where((r) => r.isNew).length;
    if (userAddedCount >= 10) {
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
    incomeStatementRows.removeWhere((row) => row.id == id);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes the Cashflow Statement row with the given [id].
  void deleteCashflowRow(String id) {
    cashflowSheetRows.removeWhere((row) => row.id == id);
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
    Globals.selectedCustomer = customer;
    entityController.text = "";
    await setAsterisks(); // NEW
    await fetchSavedFinancialAnalysis();
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  // UPDATED: take String, convert to int
  void updateEntityId(String text) {
    final int id = int.tryParse(text.trim()) ?? 0;
    emit(state.copyWith(currentEntityId: id));
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

      descTextController.setText(displayStrategyComment);
    } catch (e) {
      commentData = Comment();
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> onSavePress(bool isContinue, BuildContext context) async {
    try {
      repository ??= RemarksRepository.instance;
      final String descComment = await descTextController.getText();
      if (descComment.isEmpty) {
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
        unawaited(deleteDraft()); // Fire-and-forget
        AlertManager().showSuccessToast(
          "remarks.financialRatiosAnalysis.savedSuccessfully".tr(),
        );
        if (isContinue) navigate();
        return;
      } else {
        final items = await buildSaveItems(descComment);
        await repository!.saveFinancialRatioAnalysisDetails(items: items);
        unawaited(deleteDraft()); // Fire-and-forget

        AlertManager().showSuccessToast(
          "remarks.financialRatiosAnalysis.savedSuccessfully".tr(),
        );
        if (isContinue) {
          navigate();
        }
      }
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Strip the "Audited-" prefix the save API doesn't accept.
  String auditMethodForSave(String method) {
    final removePrefix = method.trim();
    return removePrefix.startsWith("Audited-")
        ? removePrefix.replaceFirst("Audited-", "")
        : removePrefix;
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

    for (int colIndex = 0;
        colIndex < cols.length &&
            colIndex < incomeStatements.length &&
            colIndex < 5;
        colIndex++) {
      final Statement s = incomeStatements[colIndex];
      final String raw = cols[colIndex].trim();
      final double? valueDouble = double.tryParse(raw);
      final String auditMethod = auditMethodForSave(getConstValue(colIndex, 0));
      final String auditor = auditorForSave(getConstValue(colIndex, 1));
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

  Future<List<FinancialRatioAnalysisResponse>> buildSaveItems(
    String descComment,
  ) async {
    final bool tablesVisible = hasCreditLensData || hasSavedAnalysisData;

    final String incomeStatementComment =
        tablesVisible ? await incomeStatementController.getText() : "";
    final String cashFlowComment =
        tablesVisible ? await cashflowController.getText() : "";
    final String balanceSheetComment =
        tablesVisible ? await balanceSheetcontroller.getText() : "";

    final List<IncomeStatementAnalysisRow> incomeRowsList =
        List<IncomeStatementAnalysisRow>.from(incomeStatementRows);
    final List<CashFlowSheetAnalysisRow> cashflowRowsList =
        List<CashFlowSheetAnalysisRow>.from(cashflowSheetRows);
    final List<BalanceSheetAnalysisRow> balanceRowsList =
        List<BalanceSheetAnalysisRow>.from(balanceSheetRows);

    final List<FinancialCategoryDetail> categories = [];

    if (incomeRowsList.isNotEmpty) {
      categories.add(
        categoryBlock(
          categoryId: categoryIncome,
          remarksText: incomeStatementComment,
          healthId: selectedIncomeHealth?.id, // if you have per-category health
          rows: incomeRowsList, // ← live list
        ),
      );
    }

    if (cashflowRowsList.isNotEmpty) {
      categories.add(
        categoryBlock(
          categoryId: categoryCashflow,
          remarksText: cashFlowComment,
          healthId: selectedCashFlowHealth?.id,
          rows: cashflowRowsList, // ← live list
        ),
      );
    }

    if (balanceRowsList.isNotEmpty) {
      categories.add(
        categoryBlock(
          categoryId: categoryBalance,
          remarksText: balanceSheetComment,
          healthId: selectedBalanceSheetHealth?.id,
          rows: balanceRowsList, // ← live list
        ),
      );
    }

    final int entityId = state.currentEntityId ?? 0;

    final EntityDetail entityBlock = EntityDetail(
      customerFinancialsId: null,
      entityId: entityId,
      entityLongName: longName ?? "",
      financialsCategory: categories,
    );

    final DateTime now = DateTime.now().toUtc();
    final FinancialRatioAnalysisResponse item = FinancialRatioAnalysisResponse(
      customerFinancialsId: null,
      appRefNo: Globals.request?.applicationRefNo ?? "",
      rimNo: selectedCustomer?.customerRimNo ?? 0,
      customerName: (selectedCustomer?.customerName?.trim().isNotEmpty == true)
          ? selectedCustomer!.customerName!.trim()
          : "",
      descOfAccounts: descComment,
      entityDetails: [entityBlock],
      createdBy: Globals.user?.name,
      createdDate: now,
      updatedBy: Globals.user?.name,
      updatedDate: now,
    );

    return [item];
  }

  void updateLongName(String text) {
    longName = text.trim(); // keep it clean; no state emit needed
  }

  FinancialCategoryDetail categoryBlock({
    required int categoryId, // 234 / 236 / 237
    required String remarksText,
    required int? healthId,
    required List<dynamic> rows, // income / cashflow / balance rows
  }) {
    final List<FinancialValue> allValues = <FinancialValue>[];

    for (final dynamic row in rows) {
      final String code =
          (!row.isNew && (row.id?.isNotEmpty == true)) ? row.id! : "0";

      // final String label = labelForRow(row);

      final String rawLabel = labelForRow(row);

      final String label = rawLabel.isNotEmpty
          ? rawLabel
          : (row is CashFlowSheetAnalysisRow
              ? row.cashFlowItems
              : row is IncomeStatementAnalysisRow
                  ? row.incomePositions
                  : row is BalanceSheetAnalysisRow
                      ? row.balanceSheet
                      : "");

      final List<String> cols = <String>[
        row.audited1 ?? "",
        row.audited2 ?? "",
        row.audited3 ?? "",
        row.inhouse ?? "",
        row.estimated ?? "", //  new: send the last column too
      ];

      //Skip untouched user‑added rows (no label AND all cells empty)
      final bool isEmptyNewRow = row.isNew == true &&
          code == "0" &&
          label.isEmpty &&
          cols.every((c) => c.trim().isEmpty);

      if (isEmptyNewRow) {
        continue; // ← do not emit values for this row; keeps payload clean
      }

      final List<FinancialValue> mapped = valuesFromRow(
        ratioCode:
            code == "0" ? null : code, // user-added → null (we stamp "0" below)
        userAddedType: (row.isNew && code == "0") ? label : null,
        cols: cols,
        categoryId: categoryId,
      )
          .map(
            (v) => FinancialValue(
              financialsCategory: categoryId,
              financialRatioType: (code == "0")
                  ? "0"
                  : v.financialRatioType, // force "0" for user-added rows
              userAddedRatioType: v.userAddedRatioType,
              financialYear: v.financialYear,
              statementDate: v.statementDate,
              period: v.period,
              auditMethod: v.auditMethod,
              auditor: v.auditor,
              value: v.value, // null allowed
            ),
          )
          .toList();

      allValues.addAll(mapped);
    }

    return FinancialCategoryDetail(
      financialsCategory: categoryId,
      financialsValues: allValues, // includes NA/null entries
      financialHealth: healthId,
      remarks: remarksText.isNotEmpty ? remarksText : null,
    );
  }

  //set labels in table cols
  String labelForRow(dynamic row) {
    if (row is IncomeStatementAnalysisRow) return row.incomePositions;
    if (row is CashFlowSheetAnalysisRow) return row.cashFlowItems;
    if (row is BalanceSheetAnalysisRow) return row.balanceSheet;
    return "";
  }

  // Income: already present — keep it, but ensure it removes just that row
  Future<void> deleteUserAddedIncomeRow(IncomeStatementAnalysisRow row) async {
    try {
      final bool isUnsaved = row.id.startsWith("u-");

      if (!isUnsaved) {
        repository ??= RemarksRepository.instance;
        final int rimNo = selectedCustomer?.customerRimNo ?? 0;
        final int entity = state.currentEntityId ?? 0;
        await repository!.deleteFinancialRatioAnalysisDetails(
          rimNo: rimNo,
          entityId: entity,
          financialsCategory: categoryIncome, // 234
          userAddedRatioType: row.incomePositions, // label user typed
        );
      }
      incomeStatementRows.removeWhere((r) => r.id == row.id);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showSuccessToast("Deleted successfully");
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  // Cashflow: NEW
  Future<void> deleteUserAddedCashflowRow(CashFlowSheetAnalysisRow row) async {
    try {
      final bool isUnsaved = row.id.startsWith("u-");
      if (!isUnsaved) {
        repository ??= RemarksRepository.instance;
        final int rimNo = selectedCustomer?.customerRimNo ?? 0;
        final int entity = state.currentEntityId ?? 0;
        await repository!.deleteFinancialRatioAnalysisDetails(
          rimNo: rimNo,
          entityId: entity,
          financialsCategory: categoryCashflow, // 236
          userAddedRatioType: row.cashFlowItems, // label user typed
        );
      }
      cashflowSheetRows.removeWhere((r) => r.id == row.id);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showSuccessToast("Deleted successfully");
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  // Balance: NEW
  Future<void> deleteUserAddedBalanceRow(BalanceSheetAnalysisRow row) async {
    try {
      final bool isUnsaved = row.id.startsWith("u-");
      if (!isUnsaved) {
        repository ??= RemarksRepository.instance;
        final int rimNo = selectedCustomer?.customerRimNo ?? 0;
        final int entity = state.currentEntityId ?? 0;
        await repository!.deleteFinancialRatioAnalysisDetails(
          rimNo: rimNo,
          entityId: entity,
          financialsCategory: categoryBalance, // 237
          userAddedRatioType: row.balanceSheet, // label user typed
        );
      }
      balanceSheetRows.removeWhere((r) => r.id == row.id);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showSuccessToast("Deleted successfully");
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void navigate() {
    bool isCurrentRouteFound = false;
    for (final MapEntry<RemarksTabs, String> entry
        in TabConstants.remarksRoutes.entries) {
      if (isCurrentRouteFound) {
        changeTab(entry.key);
        return;
      }
      if (entry.key == state.activeTab) {
        isCurrentRouteFound = true;
      }
    }
    LayoutViewModel().goToNextRoute();
  }

  Future<void> setAsterisks() async {
    showAsteriskTabs = Utils.getMandatoryRemarksTabs(selectedCustomer);
  }

  /// Only FI types should show the "View more / View less" affordance.
  /// Country (and other non-FI) show all chips without the toggle.
  bool get showViewMore =>
      selectedCustomer?.type == CustomerType.belowInvestmentGradeBanks ||
      selectedCustomer?.type == CustomerType.investmentGradeBanks;

  void changeEntityIdExternally(int entityId) {
    emit(state.copyWith(currentEntityId: entityId));
  }
}
