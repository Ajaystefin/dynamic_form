import "dart:async";
import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/core/services/draft/draft_mixin.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/draft_handler.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/state.dart";
import "package:wcas_frontend/models/request/profitability/relationship_utilization.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

/// Relationship utilization view model.
class RelationshipUtilizationViewModel
    extends SafeCubit<RelationshipUtilizationState>
    with DraftMixin<RelationshipUtilizationViewModel> {
  /// Creates a relationship utilization view model.
  RelationshipUtilizationViewModel()
      : super(
          RelationshipUtilizationState(loaderStatus: LoadingStatus.loading),
        );

  /// Profitability repository instance.
  late ProfitabilityRepository repository;

  /// Form key for relationship utilization form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Relationship utilization data.
  List<RelationshipUtilization> relationshipUtilizationData = [];

  /// Indicates whether the application is FI application.
  bool isFIApplication = false;
  bool _isShowingTurnoverError = false;

  // Paging
  /// Number of rows per page.
  final int rowsPerPage = 5;

  // -----------------------------
  // Controller Store
  // -----------------------------
  final List<TextEditingController> _clientTurnoverCtrls = [];
  final List<TextEditingController> _turnoverInCbdCuaCtrls = [];
  final List<TextEditingController> _throughputPctCtrls = [];

  /// Indicates that controllers have been built from data
  bool controllersReady = false;

  /// Single fallback controller — returned only BEFORE init
  final TextEditingController _emptyController = TextEditingController();

  // -----------------------------
  // SAFE ACCESSORS
  // -----------------------------

  /// Returns client turnover controller at index.
  TextEditingController clientCtrlAt(int i) {
    if (!controllersReady) {
      return _emptyController;
    }
    if (i < 0 || i >= _clientTurnoverCtrls.length) {
      return _emptyController;
    }
    return _clientTurnoverCtrls[i];
  }

  /// Returns turnover in CBD/CUA controller at index.
  TextEditingController cbdCtrlAt(int i) {
    if (!controllersReady) {
      return _emptyController;
    }
    if (i < 0 || i >= _turnoverInCbdCuaCtrls.length) {
      return _emptyController;
    }
    return _turnoverInCbdCuaCtrls[i];
  }

  /// Returns throughput percentage controller at index.
  TextEditingController pctCtrlAt(int i) {
    if (!controllersReady) {
      return _emptyController;
    }
    if (i < 0 || i >= _throughputPctCtrls.length) {
      return _emptyController;
    }
    return _throughputPctCtrls[i];
  }

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Indicates whether page can be edited.
  bool get canEdit => pageMode == PageMode.edit;
  // -----------------------------
  // INIT (API load)
  // -----------------------------

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.profitabilityAndAccountConduct;

  @override
  String get draftFormKey => Routes.relationshipUtilization;

  @override
  DraftHandler<RelationshipUtilizationViewModel> get draftHandler =>
      RelationshipUtilizationDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the RelationshipUtilizationViewModel.
  ///
  /// This function sets up the repository, logs the initialization
  /// process, retrieves business volume data, and updates the loader status.
  ///
  /// [context] - The BuildContext, if needed for additional initialization
  /// steps.
  ///

  Future<void> init(BuildContext context) async {
    pageMode =
        AuthRepository.getPageMode(RightConstants.relationshipUtilisation);

    repository = ProfitabilityRepository.instance;

    final data = await repository.getRelationshipUtilizationData();
    relationshipUtilizationData =
        data.isEmpty ? <RelationshipUtilization>[] : data;

    isFIApplication =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    initalize();
    //if (isEdit) {
    registerDraftCallback();
    await loadDraftIfAvailable();
    //}
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // -----------------------------
  // BUILD CONTROLLERS FROM MODEL
  // -----------------------------

  /// Initializes controllers from model data.
  void initalize() {
    try {
      disposeControllers();

      _clientTurnoverCtrls.clear();
      _turnoverInCbdCuaCtrls.clear();
      _throughputPctCtrls.clear();

      for (int i = 0; i < relationshipUtilizationData.length; i++) {
        final item = relationshipUtilizationData[i];

        final TextEditingController client =
            TextEditingController(text: clean(item.clientTurnover));
        final TextEditingController cbd =
            TextEditingController(text: clean(item.turnoverInCbdCua));
        final TextEditingController pct =
            TextEditingController(text: clean(item.throughputToCbdPercentage));

        _clientTurnoverCtrls.add(client);
        _turnoverInCbdCuaCtrls.add(cbd);
        _throughputPctCtrls.add(pct);

        final int safeIndex = i;
        client.addListener(() => _recalcPercentage(safeIndex));
      }

      controllersReady = true;

      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          turnOverStatus: LoadingStatus.loaded,
        ),
      );
    } on Object {
      // Do not crash ViewModel
    }
  }

  // -----------------------------
  // % CALCULATION
  // -----------------------------
  void _recalcPercentage(int index) {
    if (!controllersReady) {
      return;
    }
    if (index < 0 || index >= relationshipUtilizationData.length) {
      return;
    }

    final item = relationshipUtilizationData[index];

    // Clamp to 15 integer + 6 decimals
    final String raw = _clientTurnoverCtrls[index].text.trim();
    final String clamped = _clampTo15_6(raw);

    // Replace text if clamped
    if (clamped != raw) {
      _clientTurnoverCtrls[index].value = TextEditingValue(
        text: clamped,
        selection: TextSelection.collapsed(offset: clamped.length),
      );
    }

    // Empty → 0%
    if (clamped.isEmpty) {
      _throughputPctCtrls[index].text = "0";
      item
        ..clientTurnover = ""
        ..throughputToCbdPercentage = "0";
      emit(state.copyWith(turnOverStatus: LoadingStatus.loaded));
      return;
    }

    final Decimal? client = Decimal.tryParse(clamped);

    // Zero or invalid → 0%
    if (client == null || client == Decimal.zero) {
      _throughputPctCtrls[index].text = "0";
      item
        ..clientTurnover = clamped
        ..throughputToCbdPercentage = "0";
      emit(state.copyWith(turnOverStatus: LoadingStatus.loaded));
      return;
    }

    final Decimal turnoverCbd =
        Decimal.tryParse((item.turnoverInCbdCua ?? "0").trim()) ?? Decimal.zero;

    // Business rule: client < turnover → 0%
    if (client < turnoverCbd) {
      _throughputPctCtrls[index].text = "0";
      item
        ..clientTurnover = clamped
        ..throughputToCbdPercentage = "0";

      _showTurnoverValidationToastOnce();

      emit(state.copyWith(turnOverStatus: LoadingStatus.loaded));
      return;
    }

    // Valid case: reset the toast guard
    _isShowingTurnoverError = false;

    // Actual calculation
    final Decimal percentage =
        (turnoverCbd / client).toDecimal(scaleOnInfinitePrecision: 20) *
            Decimal.fromInt(100);

    final String display = _stripTrailingZeros(percentage.toString());

    _throughputPctCtrls[index].text = display;
    item
      ..clientTurnover = clamped
      ..throughputToCbdPercentage = display;

    emit(state.copyWith(turnOverStatus: LoadingStatus.loaded));
  }

  /// Recalculates percentage for the given index.
  void recalcPercentage(int index) {
    _recalcPercentage(index);
    emit(state.copyWith(turnOverStatus: LoadingStatus.loaded));
  }

  // -----------------------------
  // SYNC MODEL BEFORE SAVE
  // -----------------------------

  /// Syncs controller values to model.
  void syncControllersToModel() {
    for (int i = 0; i < relationshipUtilizationData.length; i++) {
      relationshipUtilizationData[i]
        ..clientTurnover = _clientTurnoverCtrls[i].text
        ..turnoverInCbdCua = _turnoverInCbdCuaCtrls[i].text
        ..throughputToCbdPercentage = _throughputPctCtrls[i].text;
    }
  }

  // -----------------------------
  // SAVE API
  // -----------------------------

  /// Saves relationship utilization data.
  Future<void> saveRelationUtilData({
    required bool isValidate,
    bool ifNavigate = false,
  }) async {
    try {
      formKey.currentState?.save();
      // AFTER: formKey.currentState?.save();
      syncControllersToModel();

      // Minimal: block save if any row fails (client < turnover)
      final bool hasTurnoverViolation = relationshipUtilizationData.any((item) {
        final Decimal client =
            Decimal.tryParse((item.clientTurnover ?? "").trim()) ??
                Decimal.zero;
        final Decimal turnover =
            Decimal.tryParse((item.turnoverInCbdCua ?? "0").trim()) ??
                Decimal.zero;
        return client != Decimal.zero && client < turnover;
      });

      if (hasTurnoverViolation) {
        _showTurnoverValidationToastOnce();
        return; // stop save
      }
      final result = await repository
          .postRelationshipUtilizationData(relationshipUtilizationData);

      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved  // AutoSave related changes by extended team

      AlertManager().showSuccessToast(result);

      if (ifNavigate) {
        LayoutViewModel().goToNextRoute();
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  // -----------------------------
  // DISPOSE
  // -----------------------------

  /// Disposes relationship utilization controllers.
  void disposeControllers() {
    for (final TextEditingController c in _clientTurnoverCtrls) {
      c.dispose();
    }
    for (final TextEditingController c in _turnoverInCbdCuaCtrls) {
      c.dispose();
    }
    for (final TextEditingController c in _throughputPctCtrls) {
      c.dispose();
    }
  }

  // -----------------------------
  // UTILITIES
  // -----------------------------

  /// Cleans null-like values.
  String clean(Object? value) {
    if (value == null) {
      return "";
    }
    final str = value.toString();
    return (str.toLowerCase() == "null") ? "" : str;
  }

  /// Enforces max 15 integer digits and 6 fractional digits,
  /// strips trailing zeros from the fractional part, and removes a dangling
  /// dot.
  /// - Removes commas/spaces, keeps only digits and the first dot.
  /// - Truncates (does NOT round) excess digits.
  /// Examples:
  ///  "1234567890123456.1234567" -> "123456789012345.123456"
  ///  "0000123.450000"           -> "123.45"
  ///  "123."                     -> "123"
  String _clampTo15_6(String input) => _sanitize15_6(input);

  /// Core sanitizer: remove invalid characters, keep only digits + 1 dot.
  /// Also enforces max 15 integer & 6 decimal digits.
  /// Sanitizes a numeric string input with:
  /// - optional single leading '-'
  /// - max 15 digits in integer part (excluding '-')
  /// - max 6 digits in fractional part
  /// - trims trailing zeros and trailing dot
  /// - preserves user-friendly typing states: ".", "-.", "0.", "-0.", "12."
  String _sanitize15_6(String input) {
    if (input.isEmpty) {
      return "";
    }

    // Preserve easy typing states
    if (input == "." ||
        input == "0." ||
        input.endsWith(".") ||
        input == "-" ||
        input == "-." ||
        input == "-0.") {
      // But collapse spaces/commas
      final String raw = input.replaceAll(RegExp("[, ]"), "");
      // Ensure it still matches allowed typing states
      if (raw == "." ||
          raw == "0." ||
          raw.endsWith(".") ||
          raw == "-" ||
          raw == "-." ||
          raw == "-0.") {
        return raw;
      }
    }

    // Remove spaces and commas
    String value = input.replaceAll(RegExp("[, ]"), "");

    // Extract sign (only if it's the very first char)
    final bool isNegative = value.startsWith("-");
    if (isNegative) {
      value = value.substring(1);
    }

    // Keep only digits and first dot
    bool dotSeen = false;
    final StringBuffer buffer = StringBuffer();
    for (final String ch in value.split("")) {
      if (ch == ".") {
        if (dotSeen) {
          continue;
        }
        dotSeen = true;
        buffer.write(".");
      } else if (RegExp(r"\d").hasMatch(ch)) {
        buffer.write(ch);
      }
    }

    value = buffer.toString();
    if (value.isEmpty || value == ".") {
      return "";
    }

    // Split parts
    final List<String> parts = value.split(".");
    String intPart = parts[0];
    String fracPart = parts.length > 1 ? parts[1] : "";

    // Enforce lengths
    if (intPart.length > 15) {
      intPart = intPart.substring(0, 15);
    }
    if (fracPart.length > 6) {
      fracPart = fracPart.substring(0, 6);
    }

    // Recompose
    final String out = fracPart.isEmpty ? intPart : "$intPart.$fracPart";

    // Trim trailing zeros in fraction, and trailing dot if needed
    // if (out.contains('.')) {
    //   out = out.replaceFirst(
    //       RegExp(r'\.?0+$'), ''); // remove trailing zeros and optional dot
    // }

    if (out.isEmpty) {
      return ""; // avoid just '-'
    }

    return isNegative && out != "0" && out != "0.0" ? "-$out" : out;
  }

  String _stripTrailingZeros(String input) {
    final sanitized = _sanitize15_6(input);
    if (!sanitized.contains(".")) {
      return sanitized;
    }

    String s = sanitized;

    // Remove trailing zeros in fractional part
    s = s.replaceFirst(RegExp(r"0+$"), "");

    // Remove dot if no fraction remains
    s = s.replaceFirst(RegExp(r"\.$"), "");

    return s;
  }

  // AutoSave related changes by extended team
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  void _showTurnoverValidationToastOnce() {
    if (_isShowingTurnoverError) {
      return;
    }

    _isShowingTurnoverError = true;

    AlertManager().showFailureToast(
      "profitabilityAccountConduct."
              "relationshipUtilisation.turnOverValidationMsg"
          .tr(),
    );
  }
}
