import "dart:async";

import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/profitability_data.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/raroc_info.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/realtionship_profitability.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_summary.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

/// Enum for identifying which RORAC field is being updated.
enum RoracFieldType { realizedRaroc, proposedRaroc, finalRaroc, comments }

/// ViewModel for managing and summarizing relationship profitability data.
///
/// Extends SafeCubit to handle loading, error, and loaded states while
/// fetching,
/// computing, updating, and saving summary data and RORAC information.
class RelationshipProfitabilitySummaryViewModel
    extends SafeCubit<RelationshipProfitabilitySummaryState>
    with DraftMixin<RelationshipProfitabilitySummaryViewModel> {
  /// Initializes the state with a loading indicator.
  RelationshipProfitabilitySummaryViewModel()
      : super(
          RelationshipProfitabilitySummaryState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository for fetching and posting profitability and comment data.
  late ProfitabilityRepository repository;

  /// Form key for validating and saving form data.
  late GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Holds the main summary data fetched from the repository.
  RelationshipProfitabilitySummary? relationshipProfitabilitySummaryData =
      RelationshipProfitabilitySummary();

  /// Flutter BuildContext, assigned during initialization if needed.
  BuildContext? context;

  /// Request object from global state, set during initialization.
  Request? request;

  /// User-entered comments for the summary, bound to the form.
  String? summaryComments;
  Comment? commentData;
  final TextEditingController summaryCommentsController =
      TextEditingController();
  // Comments
  List<Comment> comments = [];
  Comment? comment;
  bool isFIApplication = false;

  /// Number of rows per page.
  final int rowsPerPage = 5;

  /// When computed, holds the summed profitability data.
  /// When no data is available, an instance is assigned with all fields as
  /// null.
  ProfitabilityData? sumProfitabilityData;
  String? groupComments;
  // Controller lists for RORAC fields.
  List<TextEditingController>? realizedRarocControllers;
  List<TextEditingController>? proposedRarocControllers;
  List<TextEditingController>? finalRarocControllers;
  List<TextEditingController>? commentsControllers;

  bool canEditFinalRAROC = Utils.checkRoles([
    // roles that can edit the field
    UserRole.creditAnalyst,
    UserRole.creditCommitteeProxy,
    UserRole.boardDirectorProxy,
  ]);
// AutoSave related changes by extended team
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.profitabilityAndAccountConduct;

  @override
  String get draftFormKey => Routes.relationshipProfitabilitySummary;

  @override
  DraftHandler<RelationshipProfitabilitySummaryViewModel> get draftHandler =>
      RelationshipProfitabilitySummaryDraftHandler();

  // ---------------------------------------------------------------------------

  PageMode pageMode = PageMode.na;
  bool get canEdit => (pageMode == PageMode.edit);

  /// In
  Future<void> init(BuildContext context) async {
    logger.i("Initializing RelationshipProfitabilitySummaryViewModel");
    pageMode = AuthRepository.getPageMode(
      RightConstants.relationshipProfitabilitySummary,
    );
    repository = ProfitabilityRepository.instance;
    summaryCommentsController.text = summaryComments ?? "";

    // If your repository needs Globals (auth/appRef), make sure they’re ready
    request = Globals.request;
    if (request == null) {
      logger.w(
        "Globals.request is null at init. Delaying"
        " network call until it’s ready.",
      );
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final data = await repository.getRelationshipProfitabilitySummaryData();

      // Guard against nulls
      relationshipProfitabilitySummaryData = data;

      // Emit loaded before using the data in UI
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      await getComments();

      // Initialize controllers based on fetched data
      await initializeControllers();

      // Compute totals after data is in
      await computeTotalProfitability();

      await initializeProfitabilityControllers();

      // Business segment check (if it reads Globals, do it after Globals are
      // ready)
      isFIApplication =
          Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

      logger.i(
        "Init completed: "
        "entries=$relationshipProfitabilitySummaryData"
            "?.relationshipProfitability?.length ?? 0}",
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      //emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
  }

  /// Fetch application strategy details (existing comment) for Relationship
  /// Profitability Detailed.
  Future<void> getComments() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      final List<Comment> commentList =
          await CommonRepository.instance.getApplicationStrategyDetails(
        CommentsType.rarocCommonComments,
        EntityIdentifier.rarocCommonComments,
      );
      if (commentList.isNotEmpty) {
        comments = commentList
            .where(
              (item) =>
                  item.categoryId == ServerConstants.rAROCCommentCategoryId,
            )
            .toList();

        final String existing =
            comments.isNotEmpty ? (comments.first.strategyComment ?? "") : "";
        summaryComments = existing;
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e, st) {
      logger.e("Error fetching strategy details: $e", stackTrace: st);
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  Timer? _profitDebounce;

  TextEditingController getTextController(String key, [String initial = ""]) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  FocusNode getFocusedNode(String key) =>
      _focusNodes.putIfAbsent(key, FocusNode.new);

  /// Initialize controllers from fetched data
  Future<void> initializeProfitabilityControllers() async {
    final relationshipProfitabilityList =
        relationshipProfitabilitySummaryData?.relationshipProfitability ?? [];
    for (int index = 0; index < relationshipProfitabilityList.length; index++) {
      final proj = relationshipProfitabilityList[index].projectedNext12Months;
      final real = relationshipProfitabilityList[index].realizedLastYear;

      // Projected
      getTextController("proj_nii_$index", (proj?.nii)?.toString() ?? "");
      getTextController("proj_nfi_$index", (proj?.nfi)?.toString() ?? "");
      getTextController(
        "proj_exp_$index",
        (proj?.expectedNetIncome)?.toString() ?? "",
      );
      getTextController("proj_casa_$index", (proj?.avgCasa)?.toString() ?? "");
      getTextController("proj_rwa_$index", (proj?.rwa)?.toString() ?? "");
      getFocusedNode("proj_nii_$index");
      getFocusedNode("proj_nfi_$index");
      getFocusedNode("proj_casa_$index");
      getFocusedNode("proj_rwa_$index");

      // Realized
      getTextController("real_nii_$index", (real?.nii)?.toString() ?? "");
      getTextController("real_nfi_$index", (real?.nfi)?.toString() ?? "");
      getTextController(
        "real_exp_$index",
        (real?.expectedNetIncome)?.toString() ?? "",
      );
      getTextController("real_casa_$index", (real?.avgCasa)?.toString() ?? "");
      getTextController("real_rwa_$index", (real?.rwa)?.toString() ?? "");
      getFocusedNode("real_nii_$index");
      getFocusedNode("real_nfi_$index");
      getFocusedNode("real_casa_$index");
      getFocusedNode("real_rwa_$index");
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  String currentGroupName() {
    // this is the same `request` you passed into TopSectionDetails
    final grp = Globals.request?.groupName;
    return (grp != null && grp.isNotEmpty) ? grp : "";
  }

  /// -------- Helpers --------
  Future<void> saveRelationProfitDetailSumData() async {
    try {
      formKey.currentState?.save();
      await repository.postRelationshipProfitabilitySummaryData(
        relationshipProfitabilitySummaryData,
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves user comments and updates the ViewModel state.
  /// Calls the repository method to persist the comment text.
  /// On success, shows a success toast; on failure, updates loaderStatus to
  /// error.
  Future<void> onSaveAndContinue(
    bool isContinue, {
    required BuildContext context,
  }) async {
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState?.save();
        await saveComments();
        await saveRelationProfitDetailSumData();
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        AlertManager().showSuccessToast(
          "profitabilityAccountConduct."
                  "relationshipProfitabilitySummary.savedSuccessfully"
              .tr(),
        );
        unawaited(
          deleteDraft(),
        ); // fire-and-forget: remove backend draft now that data is saved  // AutoSave related changes by extended team

        if (isContinue) {
          LayoutViewModel().goToNextRoute();
        }
      }
    } catch (error) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Validates and saves comments, then navigates to the next screen.
  ///
  /// Shows a success toast on successful save or an error toast on failure.
  /// Navigates to the relationship profitability screen if the context is still
  /// mounted
  /// Save comment data for Relationship Profitability Detailed (strategy
  /// comment).
  Future<void> saveComments() async {
    try {
      // Optional: trim/normalize
      summaryComments = summaryComments?.trim();

      // Optional validation: if required or max length
      // if ((strategyComment ?? '').isEmpty) {
      //   AlertManager().showFailureToast('Please enter a comment');
      //   return;
      // }

      //Keep the comment type consistent with the screen
      commentData = Comment.fromInputData(
        type: CommentsType.rarocCommonComments,
        strategyComment: summaryComments,
        entityType: EntityIdentifier.rarocCommonComments,
        categoryId: ServerConstants.rAROCCommentCategoryId,
        categoryType: ServerConstants.rAROCCommentCategoryType,
      );

      // 📨 Use the correct commentTypeId for RelationshipProfitabilityDetailed
      final int typeId =
          ServerConstants.commentTypeId[CommentsType.rarocCommonComments]!;

      // If API expects a single typeId:

      await CommonRepository.instance.saveApplicationStrategyDetails(
        typeId,
        typeId, // or remove this param if the method signature allows
        commentData,
      );
    } catch (e, st) {
      logger.e("saveComments failed: $e", stackTrace: st);
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Computes the total profitability by summing values across relationship
  /// entries.
  /// If there are no entries, sumProfitabilityData is set to an instance with
  /// all fields null.
  Future<void> computeTotalProfitability() async {
    final List<RelationshipProfitability>? entries =
        relationshipProfitabilitySummaryData?.relationshipProfitability;
    if (entries == null || entries.isEmpty) {
      sumProfitabilityData = ProfitabilityData(
        nii: null,
        nfi: null,
        expectedNetIncome: null,
        avgCasa: null,
        rwa: null,
        realizedNii: null,
        realizedNfi: null,
        realizedExpectedNetIncome: null,
        realizedAvgCasa: null,
        realizedRwa: null,
      );
      return; // caller will _pulseTable()
    }

    Decimal projNii = Decimal.zero,
        projNfi = Decimal.zero,
        projExpNI = Decimal.zero,
        projAvgCasa = Decimal.zero,
        projRwa = Decimal.zero;
    Decimal realNii = Decimal.zero,
        realNfi = Decimal.zero,
        realExpNI = Decimal.zero,
        realAvgCasa = Decimal.zero,
        realRwa = Decimal.zero;

    for (final RelationshipProfitability rimData in entries) {
      projNii += _decimalCheck(rimData.projectedNext12Months?.nii);
      projNfi += _decimalCheck(rimData.projectedNext12Months?.nfi);
      projExpNI +=
          _decimalCheck(rimData.projectedNext12Months?.expectedNetIncome);
      projAvgCasa += _decimalCheck(rimData.projectedNext12Months?.avgCasa);
      projRwa += _decimalCheck(rimData.projectedNext12Months?.rwa);

      realNii += _decimalCheck(rimData.realizedLastYear?.nii);
      realNfi += _decimalCheck(rimData.realizedLastYear?.nfi);
      realExpNI += _decimalCheck(rimData.realizedLastYear?.expectedNetIncome);
      realAvgCasa += _decimalCheck(rimData.realizedLastYear?.avgCasa);
      realRwa += _decimalCheck(rimData.realizedLastYear?.rwa);
    }

    groupComments = entries
        .map((e) => e.comments)
        .whereType<String>()
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .join(", ");

    String s(Decimal d) => d.toString();

    sumProfitabilityData = ProfitabilityData(
      nii: s(projNii),
      nfi: s(projNfi),
      expectedNetIncome: s(projExpNI),
      avgCasa: s(projAvgCasa),
      rwa: s(projRwa),
      realizedNii: s(realNii),
      realizedNfi: s(realNfi),
      realizedExpectedNetIncome: s(realExpNI),
      realizedAvgCasa: s(realAvgCasa),
      realizedRwa: s(realRwa),
    );
  }

  void debouncedTotals() {
    _profitDebounce?.cancel();
    _profitDebounce = Timer(const Duration(milliseconds: 200), () async {
      await computeTotalProfitability(); // sums both Projected & Realized
      _pulseTable(); // refresh consolidated totals row/section
    });
  }

  void calculateExpNetIncome(int rimIndex, int rowIndex) {
    final RelationshipProfitability? entry =
        relationshipProfitabilitySummaryData
            ?.relationshipProfitability?[rimIndex];
    if (entry == null) return;

    final ProfitabilityData data = (rowIndex == 0)
        ? (entry.projectedNext12Months ??= ProfitabilityData())
        : (entry.realizedLastYear ??= ProfitabilityData());

    final Decimal nii = _parseDecimal(data.nii);
    final Decimal nfi = _parseDecimal(data.nfi);
    final String result = (nii + nfi).toString();

    data.expectedNetIncome = result;

    // Update the read-only controller so it repaints immediately
    final String id =
        rowIndex == 0 ? "proj_exp_$rimIndex" : "real_exp_$rimIndex";
    getTextController(id).text = result;

    // Fast UI pulse for the row; group totals come via debouncedTotals()
    _pulseTable();
  }

  void _pulseTable() {
    // 1) signal “loading” to create a state change
    emit(state.copyWith(tableLoaderStatus: LoadingStatus.loading));
    // 2) immediately flip back to “loaded” in a microtask
    Future.microtask(() {
      emit(state.copyWith(tableLoaderStatus: LoadingStatus.loaded));
    });
  }

// If you want to expose it:
  void forceTableRefresh() => _pulseTable();

  Decimal _decimalCheck(Object? v) => _parseDecimal(v);

  /// Safe Decimal parser for string-like values.
  /// Accepts null/empty -> 0; trims; rejects non-numeric gracefully.
  Decimal _parseDecimal(Object? value) {
    if (value == null) return Decimal.zero;
    final s = value.toString().trim();
    if (s.isEmpty) return Decimal.zero;
    final cleaned = s.replaceAll(",", ""); // tolerate pasted commas
    final isNumeric = RegExp(r"^-?\d+(\.\d+)?$").hasMatch(cleaned);
    if (!isNumeric) return Decimal.zero;
    return Decimal.tryParse(cleaned) ?? Decimal.zero;
  }

  /// Initializes the text controllers for the RORAC fields.
  /// If no rarocInformation is present, the controller lists are empty.
  Future<void> initializeControllers() async {
    final List<RarocInformation> dataList =
        relationshipProfitabilitySummaryData?.rarocInformation ?? [];
    if (dataList.isEmpty) {
      logger.w("No RORAC data available, skipping controller initialization.");
      realizedRarocControllers = [];
      proposedRarocControllers = [];
      finalRarocControllers = [];
      commentsControllers = [];
      return;
    }
    realizedRarocControllers = List.generate(
      dataList.length,
      (index) => TextEditingController(
        text: dataList[index].existingRealizedRarocPercent?.toString() ?? "",
      ),
    );
    proposedRarocControllers = List.generate(
      dataList.length,
      (index) => TextEditingController(
        text: dataList[index]
                .proposedRarocPercentProposedByCoverage
                ?.toString() ??
            "",
      ),
    );
    finalRarocControllers = List.generate(
      dataList.length,
      (index) => TextEditingController(
        text:
            dataList[index].proposedFinalRarocPercentExAnteRaroc?.toString() ??
                "",
      ),
    );

    // --- existing code above ---
    commentsControllers = List.generate(
      dataList.length,
      (index) => TextEditingController(text: dataList[index].comments ?? ""),
    );

    // >>> Add this block: build a single string with all comments joined by ' |
    // '
    final String allComments = dataList
        .map((e) => (e.comments ?? "").trim())
        .where((c) => c.isNotEmpty)
        .join(" | ");
    // You can now use `allComments` as needed (e.g., store in state, log, etc.)
    logger.i("All Comments: $allComments");
    groupComments = allComments;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates a RORAC field at [index] with [newValue] based on [fieldType].
  /// If the index is invalid, logs an error and ignores the update.
  Future<void> updateRoracField(
    int index,
    String newValue,
    RoracFieldType fieldType,
  ) async {
    if (relationshipProfitabilitySummaryData?.rarocInformation == null ||
        index >=
            relationshipProfitabilitySummaryData!.rarocInformation!.length) {
      logger.e("Invalid index access in updateRoracField: $index");
      return;
    }
    final RarocInformation data =
        relationshipProfitabilitySummaryData!.rarocInformation![index];
    await Future.delayed(const Duration(milliseconds: 50));
    switch (fieldType) {
      case RoracFieldType.realizedRaroc:
        data.existingRealizedRarocPercent = newValue;
      case RoracFieldType.proposedRaroc:
        data.proposedRarocPercentProposedByCoverage = newValue;
      case RoracFieldType.finalRaroc:
        data.proposedFinalRarocPercentExAnteRaroc = newValue;
      case RoracFieldType.comments:
        data.comments = newValue;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> close() {
    summaryCommentsController.dispose();
    _profitDebounce?.cancel();

    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    realizedRarocControllers?.forEach((c) => c.dispose());
    proposedRarocControllers?.forEach((c) => c.dispose());
    finalRarocControllers?.forEach((c) => c.dispose());
    commentsControllers?.forEach((c) => c.dispose());

    return super.close();
  }
}
