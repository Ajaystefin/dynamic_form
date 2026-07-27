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
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/view.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/covenant_condition_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// View model for the conditions summary screen.
class ConditionsSummaryViewModel extends SafeCubit<ConditionsSummaryState>
    with DraftMixin<ConditionsSummaryViewModel> {
  /// Creates a conditions summary view model.
  ConditionsSummaryViewModel()
      : super(ConditionsSummaryState(loaderStatus: LoadingStatus.loading));

  /// Covenant condition repository.
  CovenantConditionRepository repository = CovenantConditionRepository();

  /// Common repository.
  CommonRepository commonRepo = CommonRepository();

  /// Request repository.
  RequestRepository requestRepo = RequestRepository();

  /// Form key used by the conditions summary form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Build context associated with the screen.
  BuildContext? context;

  /// Strategy comment text.
  String? strategyComment = "";

  /// Covenant indicator value.
  int? isCovenant = 0;

  /// Current request data.
  Request? request;

  /// Covenant condition list.
  List<CovenantCondition> conditions = [];

  /// All comments fetched from backend for the current screen/entity.
  /// This list is also used to render the Comment History table.
  List<Comment> comments = [];

  /// Local comment holder used by non-FI flow (plain textarea) updates.
  Comment comment = Comment();

  /// Snapshot of the last loaded/saved comment text.
  /// Why we need this:
  /// - In FI flow, the HTML editor can return a non-null HTML string even if the
  ///   user did not type anything (e.g., empty HTML markup).
  /// - We must avoid calling saveComment API unless the user actually changed
  ///   something.
  /// We compare the normalized current value with this snapshot on Save.
  String _initialComment = "";

  // set the text in the editor based on latest comment of user & user role

  /// Initial text shown in the comments editor.
  String initialText = "";

  /// Reference data service.
  ReferenceDataService referenceDataService = ReferenceDataService();

  /// Reference data mapped by reference data key.
  Map<String, List<Reference>> referenceData = {};

  //paging

  /// Number of rows displayed per page.
  final int rowsPerPage = 10;

  /// Indicates whether the screen can be edited.
  bool get canEdit => pageMode == PageMode.edit;

  /// Page mode for the conditions summary screen.
  PageMode pageMode = PageMode.na;

  /// Indicates whether the current flow is FI flow.
  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  /// Indicates whether the current role has edit access.
  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.conditionsSummary] ==
          AccessType.edit;

  /// Indicates whether the application is a cancellation application.
  bool get isCancellationApp =>
      Utils.checkApplicationType(ApplicationType.cancellation);

  // Allow comment edit only for Cancellation apps when the application is
  // editable for the current user (assigned + active task), AND the
  //screen is at least visible.

  /// Indicates whether comments can be edited.
  bool get canEditComments =>
      isCancellationApp &&
      Utils.canEditApplication() &&
      pageMode != PageMode.na;

  /// Text controller for comments.
  TextEditingController controller = TextEditingController();

  /// Unified editor controller for rich text comments.
  final UnifiedEditorController unifiedEditorController =
      UnifiedEditorController();

  /// Scroll controller for the screen.
  final ScrollController scrollController = ScrollController();

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------
  //"" Autosave related changes by extended team"

  /// Draft module key used for covenants and conditions drafts.
  @override
  String get draftModuleKey => DraftModuleKeys.covenantsAndConditions;

  /// Draft form key used for conditions summary drafts.
  @override
  String get draftFormKey => Routes.conditionsSummary;

  /// Draft handler used for conditions summary auto-save functionality.
  @override
  DraftHandler<ConditionsSummaryViewModel> get draftHandler =>
      ConditionsSummaryDraftHandler();

  /// Initializes the `CovenantsSummaryViewModel` by fetching covenant
  /// conditions,
  /// comments, and top section details from the repository.
  ///
  /// This method sets up the repository instance and attempts to retrieve
  /// the necessary data asynchronously. If any error occurs during the
  /// data fetching process, it logs the error and updates the state to reflect
  /// a loading error.
  ///
  /// Emits:
  /// - Updated state with fetched data on success.
  /// - Updated state with `LoadingStatus.error` on failure.
  ///
  /// Logs:
  /// - Initialization start and any errors encountered.
  Future<void> init(BuildContext context, {PageMode? pagemode}) async {
    logger.i("initialising CovenantsSummaryViewModel");
    repository = CovenantConditionRepository();
    commonRepo = CommonRepository();
    requestRepo = RequestRepository();
    pageMode = pagemode ??
        AuthRepository.getPageMode(RightConstants.conditionsSummary);
    await loadReferenceData();
    try {
      await getConditions();
      await getComments(
        CommentsType.conditionsSummary,
        EntityIdentifier.conditionsSummary,
      );
      request = Globals.request;
      //" Autosave related changes by extended team"
      // BEST PRACTICE: Only enable autosave if the user has edit permissions.
      if (isEdit) {
        // Register this ViewModel to listen to the SideMenu "navigate away"
        // events
        registerDraftCallback();

        // Override the live data with the recovered draft data (if a draft
        // exists)
        await loadDraftIfAvailable();
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      logger.e("Error Fetching : $e");

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showFailureToast("common.error".tr());
    }
  }

  /// Fetches covenant conditions.
  Future<void> getConditions() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    conditions = await repository.getConditions();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches comments for a given entity and comment type.
  ///
  /// This asynchronous method retrieves comments from the [CommonRepository]
  /// based on the specified [type] and [entityIdentifier]. If the fetch fails,
  /// an error toast is displayed using [AlertManager].
  ///
  /// Parameters:
  /// - [type]: The type of comments to retrieve (e.g., general, feedback).
  /// - [entityIdentifier]: The identifier for the entity associated with the
  /// comments.
  ///
  /// Returns:
  /// - A [Future] that completes when the comments are successfully fetched or
  ///   an error is handled.
  Future<void> getComments(
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    try {
      comments = await commonRepo.getComments(type, entityIdentifier);

      for (final Comment c in comments) {
        c.comment ??= "";
      }

      if (comments.isNotEmpty) {
        DateTime getCreatedDateOrDefault(Comment commentItem) =>
            commentItem.createdDate ?? DateTime.fromMillisecondsSinceEpoch(0);

        final Comment latest = comments.reduce((first, second) {
          return getCreatedDateOrDefault(first)
                  .isAfter(getCreatedDateOrDefault(second))
              ? first
              : second;
        });

        // to set the value of [initialText] by comapring the user and user role
        if (latest.userId == Globals.user?.id &&
            latest.userRole == Globals.user?.currentRole?.roleId) {
          initialText = latest.comment ?? "";
          controller.text = initialText;
          unifiedEditorController.setText(initialText);

          //store initial comment for "no change" check
          _initialComment = initialText;
        }
      } else {
        _initialComment = "";
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Validates and saves the strategy comment using the repository.
  ///
  /// This method first checks if the form is valid. If validation passes,
  /// it saves the form state and sends the comment to the backend via the
  /// `saveComments` API. If an error occurs during the process, it displays
  /// a failure toast and updates the state to reflect an error.
  ///
  /// Parameters:
  /// - [`ifNavigate`] (optional): A flag indicating whether to navigate after
  /// saving. Defaults to `false`.
  ///
  /// Emits:
  /// - Updated state with `LoadingStatus.error` if an exception occurs.
  ///
  /// Logs:
  /// - The comment being saved.
  ///
  /// Shows:
  /// - A failure toast if an exception is thrown.
  Future<void> saveComment() async {
    final String currentRaw =
        isFIFlow ? await unifiedEditorController.getText() : controller.text;

    final String currentNorm = _normalizeComment(currentRaw, isHtml: isFIFlow);
    final String initialNorm =
        _normalizeComment(_initialComment, isHtml: isFIFlow);

    // If user typed nothing OR no change -> DON'T call API, just navigate
    if (currentNorm.isEmpty || currentNorm == initialNorm) {
      LayoutViewModel().goToNextRoute();
      return;
    }

    try {
      final Comment saveComment = Comment.fromInputData(
        type: CommentsType.conditionsSummary,
        entityType: EntityIdentifier.conditionsSummary,
        comment: currentRaw,
        categoryId:
            ServerConstants.commentTypeId[CommentsType.conditionsSummary],
      );

      comment.draft = false;

      await CommonRepository.instance.saveComment(
        saveComment,
      );

      _initialComment = currentRaw;

      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved
      AlertManager().showSuccessToast("common.commentSaveSuccess".tr());
      //Nav to next page
      LayoutViewModel().goToNextRoute();
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes a specified covenant condition and refreshes the condition list.
  ///
  /// This method attempts to delete the provided [conditionData] by marking
  /// it deleted and saving it via the repository's `saveConditionDetails`
  /// method. Upon successful deletion,
  /// it shows a success toast and refreshes the list of covenant conditions.
  /// If an error occurs, it displays a failure toast and updates the state
  /// to reflect an error.
  ///
  /// Parameters:
  /// - [conditionData]: The `CovenantCondition` object to be deleted.
  ///
  /// Emits:
  /// - Updated state with `LoadingStatus.error` if an exception occurs.
  ///
  /// Logs:
  /// - The condition data being deleted.
  ///
  /// Shows:
  /// - A success toast on successful deletion.
  /// - A failure toast if an exception is thrown.
  Future<void> onDeleteCondition(
    CovenantCondition conditionData,
    int index,
  ) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      logger.i(conditionData);
      conditionData
        ..isDeleted = true
        ..isCovenant = false
        ..isNew = false
        ..mode = TypeMode.edit.name.capitalizeFirstLetter();
      final String result =
          await requestRepo.saveConditionDetails(conditionData);
      AlertManager().showSuccessToast(result);
      conditions.removeAt(index);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(
        e.toString(),
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  //To show the condition information create / Update dialogue

  /// Shows the condition create or update dialog.
  Future<void> showConditionCreate(
    BuildContext context, {
    CovenantCondition? condition,
  }) async {
    try {
      await DialogHelper.showCustomDialog(
        context: context,
        width: Scale.scaleHorizontally(800),
        title: "covenantsConditions.conditionsEditDialog.conditionInfo".tr(),
        content: ConditionEditDialogView(
          overridePageMode: pageMode,
          condition: condition,
        ),
      );
      await getConditions();
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showFailureToast("common.error".tr());
    }
  }

  /// Returns the reference name for the given id.
  String getReferenceName(List<Reference>? list, int? id) {
    if (list == null || id == null) {
      return "";
    }
    return list
            .firstWhere(
              (ref) => ref.id == id,
              orElse: () => Reference(name: ""),
            )
            .name ??
        "";
  }

  /// Loads reference data for search criteria, segment types, region list,
  /// advance request types, and role types. Populates the [referenceData] map
  /// with the fetched data. If an error occurs during the fetching process,
  /// it updates the loader status to [LoadingStatus.error].
  Future<void> loadReferenceData() async {
    try {
      referenceData = await referenceDataService.getReferenceData([
        ReferenceDataKeys.conditionDescriptionTemplate,
        ReferenceDataKeys.conditionAction,
        ReferenceDataKeys.conditionFrequency,
        ReferenceDataKeys.conditionGeneral,
        ReferenceDataKeys.conditionStandard,
        ReferenceDataKeys.conditionStatus,
        ReferenceDataKeys.covenantConditionType,
      ]);
    } on Object {
      AlertManager().showFailureToast("common.error".tr());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      rethrow;
    }
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  /// Normalizes comment content for reliable comparison.
  ///
  /// Purpose:
  /// - Prevent false "changes" caused by formatting-only differences,
  ///   especially for FI (HTML) editor output.
  /// - Treats whitespace-only or empty HTML (e.g., `<p><br></p>`) as empty.
  ///
  /// [value] is the raw editor/textarea content.
  /// [isHtml] indicates whether the input may contain HTML markup.
  String _normalizeComment(String value, {required bool isHtml}) {
    if (!isHtml) {
      return value.trim();
    }

    // HTML editor output normalization:
    // 1) Strip tags
    // 2) Convert non-breaking spaces
    // 3) Collapse whitespace
    return value
        .replaceAll(RegExp("<[^>]*>"), " ") // remove HTML tags
        .replaceAll("&nbsp;", " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }
}
