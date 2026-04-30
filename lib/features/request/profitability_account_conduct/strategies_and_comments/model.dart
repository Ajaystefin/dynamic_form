import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/core/services/draft/draft_mixin.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/draft_handler.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

class StrategiesAndCommentsViewModel
    extends SafeCubit<StrategiesAndCommentsState>
    with
        DraftMixin<
            // AutoSave related changes by extended team
            StrategiesAndCommentsViewModel> {
  StrategiesAndCommentsViewModel()
      : super(StrategiesAndCommentsState(loaderStatus: LoadingStatus.loading));

  // Renamed for clarity
  late ProfitabilityRepository profitabilityRepository;

  /// Existing
  Map<int, String> commentTextByCategoryId = {}; // plain text version
  Map<int, int> existingCommentRecordIdsByCategoryId = {}; // from server
  List<Map<String, dynamic>> commentCategories = [];

  /// Replace single controller with a controller per category
  final Map<int, UnifiedEditorController> _controllersByCategory = {};

  final ScrollController scrollController =
      ScrollController(keepScrollOffset: false);

  // AutoSave related changes by extended team
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.profitabilityAndAccountConduct;

  @override
  String get draftFormKey => Routes.strategiesAndComments;

  @override
  DraftHandler<StrategiesAndCommentsViewModel> get draftHandler =>
      StrategiesAndCommentsDraftHandler();

  // ---------------------------------------------------------------------------

  PageMode pageMode = PageMode.na;
  bool get canEdit => (pageMode == PageMode.edit);

  // New name: initialize()
  Future<void> initialize(context) async {
    logger.i("initialising StrategiesAndCommentsViewModel");
    pageMode = AuthRepository.getPageMode(RightConstants.strategiesComments);
    profitabilityRepository = ProfitabilityRepository.instance;
    await loadCommentCategoryData();
  }

  Future<void> init(context) async {
    await initialize(context);
    // AutoSave related changes by extended team
    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
  }

  // New name: fetchCommentCategoryMaster()
  Future<Map<String, List<Reference>>> fetchCommentCategoryMaster() async {
    return ReferenceDataService().getReferenceData(
      [ReferenceDataKeys.strategyCommentsCategory],
    );
  }

  // ---- Compatibility wrapper (kept original method name) ----
  Future<Map<String, List<Reference>>> fetchReferenceMaster() async {
    return fetchCommentCategoryMaster();
  }

  // New name: selectAllowedCategories()
  List<Map<String, dynamic>> selectAllowedCategories(
    List<Reference> allCategoriesFromMaster,
  ) {
    const allowedIds = <int>{
      ServerConstants.relationshipStrategyCommentCategoryId,
      ServerConstants.depositsStrategyCommentCategoryId,
      ServerConstants.transactionalBankingCommentCategoryId,
      ServerConstants.tradeFinanceCommentCategoryId,
      ServerConstants.treasuryCommentCategoryId,
      ServerConstants.ermCommentsCategoryId,
      ServerConstants.esgCommentsCategoryId,
    };
    return allCategoriesFromMaster
        .where((r) => r.id != null && allowedIds.contains(r.id))
        .map(
          (r) => {
            "id": r.id!,
            "name": r.name ?? "",
          },
        )
        .toList();
  }

  // ---- Compatibility wrapper (kept original method name) ----
  List<Map<String, dynamic>> filterAndProjectReferences(
    List<Reference> allRefs,
  ) {
    return selectAllowedCategories(allRefs);
  }

  // ---------------------------
  // Step 3: Fetch existing comments
  // ---------------------------

  // New name: fetchExistingStrategyComments()
  Future<List<dynamic>> fetchExistingStrategyComments() async {
    return CommonRepository.instance.getApplicationStrategyDetails(
      CommentsType.strategyComments,
      EntityIdentifier.strategyComments,
    );
  }

  // ---- Compatibility wrapper (kept original method name) ----
  Future<List<dynamic>> fetchExistingComments() async {
    return fetchExistingStrategyComments();
  }

  // New name: getCategoryId()
  int? getCategoryId(dynamic item) => item?.categoryId;

  // New name: indexExistingCommentsByCategoryId()
  Map<int, dynamic> indexExistingCommentsByCategoryId(
    List<dynamic> existingCommentsList,
  ) {
    final Map<int, dynamic> commentsByCategoryId = <int, dynamic>{};
    for (final Comment item in existingCommentsList) {
      final int? id = getCategoryId(item);
      if (id != null) {
        commentsByCategoryId[id] = item; // last occurrence wins
      }
    }
    return commentsByCategoryId;
  }

  // ---- Compatibility wrappers (kept original method names) ----
  int? extractCategoryId(dynamic item) => getCategoryId(item);

  Map<int, dynamic> normalizeByCategoryId(List<dynamic> existingList) {
    return indexExistingCommentsByCategoryId(existingList);
  }

  // New name: buildCommentTextByCategoryId()
  Map<int, String> buildCommentTextByCategoryId(
    List<Map<String, dynamic>> categories,
    Map<int, dynamic> commentsByCategoryId,
  ) {
    return {
      for (final Map<String, dynamic> category in categories)
        category["id"] as int:
            (commentsByCategoryId[category["id"] as int]?.strategyComment) ??
                "",
    };
  }

  // ---- Compatibility wrapper (kept original method name) ----
  Map<int, String> buildCommentTextMap(
    List<Map<String, dynamic>> refs,
    Map<int, dynamic> byId,
  ) {
    return buildCommentTextByCategoryId(refs, byId);
  }

  // ------------------------------------------------------------
  // Step 4b: Build existingAppStrategyCommentsIds (safe int conversion)
  // ------------------------------------------------------------

  // New name: buildExistingRecordIdsByCategoryId()
  Map<int, int> buildExistingRecordIdsByCategoryId(
    List<Map<String, dynamic>> categories,
    Map<int, dynamic> commentsByCategoryId,
  ) {
    return {
      for (final Map<String, dynamic> category in categories)
        if (commentsByCategoryId[category["id"] as int]
                ?.appStrategyCommentsId !=
            null)
          category["id"] as int: (commentsByCategoryId[category["id"] as int]!
                  .appStrategyCommentsId) ??
              0,
    };
  }

  // ---- Compatibility wrapper (kept original method name) ----
  Map<int, int> buildExistingIdsMap(
    List<Map<String, dynamic>> refs,
    Map<int, dynamic> byId,
  ) {
    return buildExistingRecordIdsByCategoryId(refs, byId);
  }

  // -------------------------------------------------------------
  // Step 4c: Enrich references with "type" from API (categoryType)
  // -------------------------------------------------------------

  // New name: attachCategoryTypeFromApi()
  List<Map<String, dynamic>> attachCategoryTypeFromApi(
    List<Map<String, dynamic>> categories,
    Map<int, dynamic> commentsByCategoryId,
  ) {
    return categories.map((category) {
      final int categoryId = category["id"] as int;
      final String? categoryType =
          commentsByCategoryId[categoryId]?.categoryType;
      return {
        ...category,
        "type": categoryType, // store string type for save payload
      };
    }).toList();
  }

  // ---- Compatibility wrapper (kept original method name) ----
  List<Map<String, dynamic>> enrichReferencesWithType(
    List<Map<String, dynamic>> refs,
    Map<int, dynamic> byId,
  ) {
    return attachCategoryTypeFromApi(refs, byId);
  }

  // --------------------------------------------
  // Orchestrator: loadCommentCategoryData()
  // --------------------------------------------
  Future<void> loadCommentCategoryData() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      // 1) Fetch reference master
      final Map<String, List<Reference>> referenceData =
          await fetchCommentCategoryMaster();

      // 2) Convert to dynamic maps & filter allowed IDs
      final List<Reference> allCategoriesFromMaster =
          referenceData[ReferenceDataKeys.strategyCommentsCategory] ?? [];
      commentCategories = selectAllowedCategories(allCategoriesFromMaster);

      // 3) Fetch existing comments
      final List<dynamic> existingCommentsList =
          await fetchExistingStrategyComments();

      // 3a) Normalize to map keyed by categoryId
      final Map<int, dynamic> commentsByCategoryId =
          indexExistingCommentsByCategoryId(existingCommentsList);

      // 4) Build maps used by the UI
      commentTextByCategoryId =
          buildCommentTextByCategoryId(commentCategories, commentsByCategoryId);
      existingCommentRecordIdsByCategoryId = buildExistingRecordIdsByCategoryId(
        commentCategories,
        commentsByCategoryId,
      );
      commentCategories =
          attachCategoryTypeFromApi(commentCategories, commentsByCategoryId);

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  // ---- Compatibility wrapper (kept original orchestrator name) ----
  Future<void> getReferenceData() async {
    await loadCommentCategoryData();
  }

  // Save all comments (dynamic maps, no model)
  // New name: saveAllStrategyComments()

  String resolveCategoryTypeLabel(int categoryId, {String? existing}) {
    if (existing != null && existing.trim().isNotEmpty) {
      return existing.trim();
    }
    switch (categoryId) {
      case ServerConstants.relationshipStrategyCommentCategoryId:
        return ServerConstants.relationshipStrategyCommentCategoryType;
      case ServerConstants.depositsStrategyCommentCategoryId:
        return ServerConstants.depositsStrategyCommentCategoryType;
      case ServerConstants.transactionalBankingCommentCategoryId:
        return ServerConstants.transactionalBankingCommentCategoryType;
      case ServerConstants.tradeFinanceCommentCategoryId:
        return ServerConstants.tradeFinanceCommentCategoryType;
      case ServerConstants.treasuryCommentCategoryId:
        return ServerConstants.treasuryFinanceCommentCategoryType;
      case ServerConstants.esgCommentsCategoryId:
        return ServerConstants.esgCommentCategoryType;
      case ServerConstants.ermCommentsCategoryId:
        return ServerConstants.ermCommentCategoryType;

      default:
        return "Strategy Comments"; // safe fallback
    }
  }

  /// Save ALL – without listeners:
  /// - read each controller
  /// - compare with lastSaved
  /// - skip unchanged
  /// - skip empty values if an existing record exists (to avoid wiping)
  Future<void> saveComments({bool isContinue = false}) async {
    try {
      final List<Map<String, dynamic>> payloadItems = [];

      for (final category in commentCategories) {
        final int categoryId = category["id"] as int;
        final ctrl = _controllersByCategory[categoryId];
        if (ctrl == null) continue;

        final clean = await readEditorPlain(categoryId);
        final lastSaved = (lastSavedPlainByCategoryId[categoryId] ?? "").trim();

        // If unchanged, skip
        if (clean == lastSaved) continue;

        final existingRecordId =
            existingCommentRecordIdsByCategoryId[categoryId] ?? 0;

        // If empty and we already have a record, skip to avoid wiping
        if (clean.isEmpty && existingRecordId > 0) continue;

        final categoryType = resolveCategoryTypeLabel(
          categoryId,
          existing: (category["type"] as String?),
        );

        payloadItems.add({
          "appStrategyCommentsId": existingRecordId,
          "categoryId": categoryId,
          "strategyComment": clean, // plain text
          "categoryType": categoryType,
        });
      }

      if (payloadItems.isEmpty) {
        // Nothing to save
        // No change in state needed
        if (isContinue) {
          LayoutViewModel().goToNextRoute();
        }
      }

      final isSaved =
          await profitabilityRepository.saveApplicationStrategyDetailsDynamic(
        type: CommentsType.strategyComments,
        commentList: payloadItems,
      );

      if (isSaved) {
        // Update lastSaved with the new values we just sent
        for (final item in payloadItems) {
          final id = item["categoryId"] as int;
          final text = item["strategyComment"] as String;
          lastSavedPlainByCategoryId[id] = text;
        }
        AlertManager().showSuccessToast(
          "profitabilityAccountConduct.strategiesComments."
                  "strategiesUpdatedSuccessfully"
              .tr(),
        );

        unawaited(
          deleteDraft(),
        ); // fire-and-forget: remove backend draft now that data is saved  // AutoSave related changes by extended team

        if (isContinue) {
          LayoutViewModel().goToNextRoute();
        } else {
          // Emit a state with loaded status to ensure UI is refreshed if needed
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        }
      } else {
        AlertManager().showFailureToast(
          "profitabilityAccountConduct."
                  "strategiesComments.failedToUpdateStrategies"
              .tr(),
        );
        // Do not emit LoadingStatus.error to avoid hiding the form
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      // Do not emit LoadingStatus.error to avoid hiding the form
    }
  }

  /// Last saved (plain) text from server (used to avoid wiping and diff
  /// detection)
  final Map<int, String> lastSavedPlainByCategoryId = {};

  /// Track that we've already seeded the editor once to avoid re-seeding on
  /// rebuilds
  final Set<int> _seedApplied = {};

  /// HTML -> plain text (same logic you showed in getCleanText)
  String cleanHtml(String rawHtml) {
    return rawHtml
        .replaceAll(RegExp("<[^>]*>"), "") // Remove HTML tags
        .replaceAll("&nbsp;", " ")
        .replaceAll("&amp;nbsp;", " ")
        .replaceAll("\u00A0", " ")
        .trim();
  }

  /// Get or create a controller; seed content once (no listeners used)
  UnifiedEditorController getControllerFor(
    int categoryId, {
    String? initialContent, // can be plain or HTML depending on your editor
    bool contentIsHtml = false,
  }) {
    return _controllersByCategory.putIfAbsent(categoryId, () {
      final c = UnifiedEditorController();

      // Seed once with the best known content (from server) if available
      final seed =
          (initialContent ?? lastSavedPlainByCategoryId[categoryId] ?? "")
              .trim();
      if (seed.isNotEmpty) {
        // If your editor expects HTML, you can wrap plain text: <p>...</p>
        c.setText(contentIsHtml ? seed : seed);
      }
      _seedApplied.add(categoryId);
      return c;
    });
  }

  /// Provide initial text only the FIRST time a field is built.
  /// (Use this to feed the widget's `initialText` once and then return '')
  String initialTextOnceFor(int categoryId) {
    if (_seedApplied.contains(categoryId)) return "";
    _seedApplied.add(categoryId);
    return (lastSavedPlainByCategoryId[categoryId] ??
            commentTextByCategoryId[categoryId] ??
            "")
        .trim();
  }

  /// Read plain text from editor on demand (no listener)
  Future<String> readEditorPlain(int categoryId) async {
    final ctrl = _controllersByCategory[categoryId];
    if (ctrl == null) return "";
    final String richTextOutput = await ctrl.getText(); // returns HTML always
    // (Optional) keep a local cache; not required for saving
    commentTextByCategoryId[categoryId] = richTextOutput;
    return richTextOutput;
  }

  /// Bulk read helpers
  Future<Map<int, String>> readAllEditorsPlain(Iterable<int> ids) async {
    final result = <int, String>{};
    for (final id in ids) {
      result[id] = await readEditorPlain(id);
    }
    return result;
  }

  /// For compatibility with your code path that uses onChanged
  void updateCommentTextForCategory(int categoryId, String commentText) {
    commentTextByCategoryId[categoryId] = commentText;
    emit(state.copyWith());
  }

  /// Optional wrapper
  void updateComment(int refId, String value) {
    updateCommentTextForCategory(refId, value);
  }

  /// Call this once after loading server data
  /// `serverPlainTextById` should be plain text (if you store HTML on server,
  /// pass HTML and set contentIsHtml=true)
  void seedInitialFromServer({
    required List<Map<String, dynamic>> categories,
    required Map<int, String> serverPlainTextById,
    required Map<int, int> serverRecordIdsByCategoryId,
    bool contentIsHtml = false,
  }) {
    commentCategories = categories;
    lastSavedPlainByCategoryId
      ..clear()
      ..addAll(serverPlainTextById.map((k, v) => MapEntry(k, (v).trim())));
    existingCommentRecordIdsByCategoryId
      ..clear()
      ..addAll(serverRecordIdsByCategoryId);

    // Prepare controllers with initial content—but do not attach any listeners
    for (final cat in categories) {
      final id = cat["id"] as int;
      final seed = serverPlainTextById[id] ?? "";
      getControllerFor(id, initialContent: seed, contentIsHtml: contentIsHtml);
    }
    emit(state.copyWith());
  }

  /// Allows restored draft text to be supplied again through
  /// initialTextOnceFor().
  void resetSeedForDraftCategories(Iterable<int> categoryIds) {
    _seedApplied.removeAll(categoryIds.toSet());
  }

  /// Push restored draft text only into controllers that already exist.
  /// Do NOT create new controllers during draft restore.
  void applyDraftTextToMountedEditors(Map<int, String> textByCategoryId) {
    for (final entry in textByCategoryId.entries) {
      final UnifiedEditorController? ctrl = _controllersByCategory[entry.key];
      if (ctrl == null) continue;

      try {
        ctrl.setText(entry.value);
      } catch (_) {
        // Editor may not be mounted yet.
      }
    }
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();

    for (final c in _controllersByCategory.values) {
      logger.i(c);
      // HtmlEditorController / RichTextController usually have their own dispose()
      // If your wrappers expose dispose, call it here.
      // (UnifiedEditorController does not define dispose; safe to ignore.)
    }
    scrollController.dispose();
    return super.close();
  }
}
