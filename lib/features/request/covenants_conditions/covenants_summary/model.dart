import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:html_editor_enhanced/html_editor.dart";
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
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/view.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/covenant_condition_repository.dart";

/// Callback used to show the covenant dialog.
typedef ShowCovenantDialog = Future<void> Function({
  required BuildContext context,
  required double width,
  required String title,
  required Widget content,
});

/// View model for the covenants summary screen.
class CovenantsSummaryViewModel extends SafeCubit<CovenantsSummaryState>
    with DraftMixin<CovenantsSummaryViewModel> {
  /// Creates a covenants summary view model.
  CovenantsSummaryViewModel({
    CovenantConditionRepository? repositoryOverride,
    CommonRepository? commonRepositoryOverride,
    ReferenceDataService? referenceDataServiceOverride,
    AlertManager? alertManagerOverride,
    bool? isEditOverride,
    bool? isFIFlowOverride,
    Future<void> Function()? registerDraftCallbackOverride,
    Future<void> Function()? loadDraftIfAvailableOverride,
    Future<void> Function()? deleteDraftOverride,
    Future<void> Function()? unregisterDraftCallbackOverride,
    void Function()? goToNextRouteOverride,
    Future<String> Function()? editorTextProviderOverride,
    ShowCovenantDialog? showCovenantDialogOverride,
    PageMode Function(String rightKey)? pageModeResolver,
  })  : _repositoryOverride = repositoryOverride,
        _commonRepositoryOverride = commonRepositoryOverride,
        _referenceDataServiceOverride = referenceDataServiceOverride,
        _alertManagerOverride = alertManagerOverride,
        _isEditOverride = isEditOverride,
        _isFIFlowOverride = isFIFlowOverride,
        _registerDraftCallbackOverride = registerDraftCallbackOverride,
        _loadDraftIfAvailableOverride = loadDraftIfAvailableOverride,
        _deleteDraftOverride = deleteDraftOverride,
        _unregisterDraftCallbackOverride = unregisterDraftCallbackOverride,
        _goToNextRouteOverride = goToNextRouteOverride,
        _editorTextProviderOverride = editorTextProviderOverride,
        _showCovenantDialogOverride = showCovenantDialogOverride,
        _pageModeResolver = pageModeResolver,
        super(
          CovenantsSummaryState(
            loaderStatus: LoadingStatus.loading,
            covenantsSummaryLoader: LoadingStatus.loaded,
          ),
        );

  final CovenantConditionRepository? _repositoryOverride;
  final CommonRepository? _commonRepositoryOverride;
  final ReferenceDataService? _referenceDataServiceOverride;
  final AlertManager? _alertManagerOverride;
  final bool? _isEditOverride;
  final bool? _isFIFlowOverride;
  final Future<void> Function()? _registerDraftCallbackOverride;
  final Future<void> Function()? _loadDraftIfAvailableOverride;
  final Future<void> Function()? _deleteDraftOverride;
  final Future<void> Function()? _unregisterDraftCallbackOverride;
  final void Function()? _goToNextRouteOverride;
  final Future<String> Function()? _editorTextProviderOverride;
  final ShowCovenantDialog? _showCovenantDialogOverride;
  final PageMode Function(String rightKey)? _pageModeResolver;

  /// Covenant condition repository.
  late CovenantConditionRepository repository;

  /// List of covenants shown on the summary screen.
  List<Covenant> covenant = [];

  /// Form key for the covenants summary form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Build context used by the view model.
  BuildContext? context;

  /// Current request details.
  Request? request;

  /// Strategy comment text.
  String? strategyComment;

  /// Covenant indicator used while fetching and saving.
  int? isCovenant = 1;

  /// Reference data mapped by reference data key.
  Map<String, List<Reference>> referenceData = {};

  /// Comments fetched for Covenants Summary.
  List<Comment> comments = [];

  /// Local comment payload used for saving.
  Comment? comment = Comment();

  /// Snapshot of the last loaded/saved comment text.
  ///
  /// Used to detect whether user has made a meaningful edit before calling
  /// SaveComment API. Prevents saving when user didn't type anythi
  String _initialComment = "";

  // set the text in the editor based on latest comment of user & user role

  /// Initial text shown in the comment editor.
  String initialText = "";

  /// Covenant type reference values.
  List<Reference>? covenantType = [];

  /// Covenant subtype reference values.
  List<Reference>? covenantSubtype = [];

  /// Frequency reference values.
  List<Reference>? frequency = [];

  /// Action reference values.
  List<Reference>? action = [];

  /// Status reference values.
  List<Reference>? status = [];

  /// Covenant general/specific reference values.
  List<Reference>? covenantGeneralSpecific = [];

  // paging

  /// Number of rows shown per page.
  final int rowsPerPage = 10;

  /// Page mode for covenants summary.
  PageMode covenantPageMode = PageMode.na;

  /// Indicates whether the page can be edited.
  bool get canEdit => covenantPageMode == PageMode.edit;

  /// Indicates whether the page is read-only.
  bool get isReadOnly => covenantPageMode == PageMode.view;

  /// Indicates whether the current flow is FI flow.
  bool get isFIFlow =>
      _isFIFlowOverride ??
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  /// Indicates whether the current user has edit access.
  bool get isEdit =>
      _isEditOverride ??
      (Globals.user?.currentRole?.rights?[RightConstants.covenantsSummary] ==
          AccessType.edit);

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
      covenantPageMode != PageMode.na;

  /// Plain text comment controller.
  TextEditingController controller = TextEditingController();

  /// HTML editor controller.
  HtmlEditorController htmlEditorController = HtmlEditorController();

  /// Unified editor controller for rich text comments.
  final UnifiedEditorController unifiedEditorController =
      UnifiedEditorController();

  /// Scroll controller for the editor.
  final ScrollController scrollController = ScrollController();

  CommonRepository get _commonRepository =>
      _commonRepositoryOverride ?? CommonRepository.instance;

  ReferenceDataService get _referenceDataService =>
      _referenceDataServiceOverride ?? ReferenceDataService();

  AlertManager get _alertManager => _alertManagerOverride ?? AlertManager();

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  /// Draft module key used for covenants and conditions drafts.
  @override
  String get draftModuleKey => DraftModuleKeys.covenantsAndConditions;

  /// Draft form key used for covenants summary drafts.
  @override
  String get draftFormKey => Routes.covenantsSummary;

  /// Draft handler used for covenants summary auto-save functionality.
  @override
  DraftHandler<CovenantsSummaryViewModel> get draftHandler =>
      CovenantsSummaryDraftHandler();

  /// Initializes the ConditionsSummaryViewModel by fetching:
  /// - Reference data
  /// - Conditions list
  /// - Comments (and populates the comment input with the latest comment)
  /// - Draft recovery (only if user has edit permission)
  ///
  /// If any step fails, an error toast is shown and the screen still loads
  /// with whatever data is available.
  Future<void> init(BuildContext context, {PageMode? pageMode}) async {
    this.context = context;
    repository = _repositoryOverride ?? CovenantConditionRepository.instance;
    covenantPageMode = pageMode ?? _resolvePageMode();

    try {
      await loadReferenceData();

      covenant = await repository.getCovenants(isCovenant);

      await getComments(
        CommentsType.covenantsSummary,
        EntityIdentifier.covenantsSummary,
      );

      request = Globals.request;

      if (isEdit) {
        await _registerDraftHook();
        await _loadDraftHook();
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      _alertManager.showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Fetches covenants from the repository.
  Future<void> fetchCovenants() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    covenant = await repository.getCovenants(isCovenant);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Loads reference data used by the covenants summary screen.
  Future<void> loadReferenceData() async {
    try {
      referenceData = await _referenceDataService.getReferenceData([
        ReferenceDataKeys.covenantType,
        ReferenceDataKeys.covenantConditionAction,
        ReferenceDataKeys.covenantConditionStatus,
        ReferenceDataKeys.covenantFrequency,
        ReferenceDataKeys.covenantAuditStatus,
        ReferenceDataKeys.covenantSubmissionTime,
        ReferenceDataKeys.covenantBasicSeperation,
        ReferenceDataKeys.covenantPeriod,
        ReferenceDataKeys.covenantSubtype,
        ReferenceDataKeys.thresholdType,
        ReferenceDataKeys.covenantGeneralSpecific,
      ]);

      covenantType = referenceData[ReferenceDataKeys.covenantType] ?? [];
      covenantSubtype = referenceData[ReferenceDataKeys.covenantSubtype] ?? [];
      frequency = referenceData[ReferenceDataKeys.covenantFrequency] ?? [];
      action = referenceData[ReferenceDataKeys.covenantConditionAction] ?? [];
      status = referenceData[ReferenceDataKeys.covenantConditionStatus] ?? [];
      covenantGeneralSpecific =
          referenceData[ReferenceDataKeys.covenantGeneralSpecific] ?? [];
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      rethrow;
    }
  }

  /// Shows the create covenant dialog and refreshes the covenant list.
  Future<void> showCovenantCreate(
    BuildContext context, {
    Covenant? condition,
  }) async {
    await _showDialog(context);

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    covenant = await repository.getCovenants(isCovenant);

    if (covenant.isEmpty) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      return;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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

  /// Returns the general/specific reference name for the given id.
  String getGeneralSpecificName(List<Reference>? list, int? id) {
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

  /// Updates the state after adding a covenant.
  void addCovenant() {
    emit(state.copyWith(covenantsSummaryLoader: LoadingStatus.loaded));
  }

  /// Saves a comment ONLY if the user has actually changed the input.
  ///
  /// Behavior:
  /// - Reads the current value from the correct editor:
  ///   - FI Flow  : Unified editor (HTML)
  ///   - Non-FI   : Plain textarea controller
  /// - Normalizes current vs initial to detect meaningful changes
  /// - If unchanged or empty -> skip API call and navigate next
  /// - If changed -> call SaveComment API, clear draft, then navigate next
  Future<void> saveComment({bool ifNavigate = false}) async {
    // Get current comment (without forcing "changed" state)
    final String currentRaw = isFIFlow
        ? await _getEditorText()
        : controller.text; // safer than relying only on onChanged

    final String currentNorm = _normalizeComment(currentRaw, isHtml: isFIFlow);
    final String initialNorm =
        _normalizeComment(_initialComment, isHtml: isFIFlow);

    // If user typed nothing OR no change → skip API
    if (currentNorm.isEmpty || currentNorm == initialNorm) {
      if (ifNavigate) {
        _navigateNext();
      }
      return;
    }

    comment?.comment = currentRaw;

    comment!
      ..applicationRefNo = Globals.request?.applicationRefNo
      ..userId = Globals.user?.id
      ..userRole = Globals.user?.currentRole?.roleId
      ..comment = comment?.comment
      ..categoryId =
          ServerConstants.commentTypeId[CommentsType.covenantsSummary];

    try {
      await _commonRepository.saveComment(comment!);

      if (!isReadOnly || canEditComments) {
        _alertManager.showSuccessToast(
          "common.commentSaveSuccess".tr(),
        );
      }

      _initialComment = currentRaw;

      await _deleteDraftHook();

      if (ifNavigate) {
        _navigateNext();
      }
    } on Object catch (e) {
      _alertManager.showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Loads comments for the provided [type]/[entityIdentifier], then:
  /// - Ensures comment text is non-null
  /// - Selects the latest comment based on createdDate
  /// - Updates both plain text controller and FI HTML editor controller
  /// - Stores [_initialComment] for "no-change" detection on Save
  Future<void> getComments(
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    try {
      comments = await _commonRepository.getComments(type, entityIdentifier);

      for (final Comment comment in comments) {
        comment.comment ??= "";
      }

      if (comments.isNotEmpty) {
        DateTime getCreatedDateOrDefault(Comment commentItem) =>
            commentItem.createdDate ?? DateTime.fromMillisecondsSinceEpoch(0);

        final Comment latestComment = comments.reduce((first, second) {
          return getCreatedDateOrDefault(first)
                  .isAfter(getCreatedDateOrDefault(second))
              ? first
              : second;
        });
        // to set the value of [initialText] by comapring the user and user role
        if (latestComment.userId == Globals.user?.id &&
            latestComment.userRole == Globals.user?.currentRole?.roleId) {
          initialText = latestComment.comment ?? "";

          controller.text = initialText;
          unifiedEditorController.setText(initialText);
          _initialComment = initialText;
        }
      } else {
        _initialComment = "";
      }
    } on Object catch (e) {
      _alertManager.showFailureToast(e.toString());
    }
  }

  /// Deletes a covenant and refreshes the covenant list.
  Future<void> onDeleteCovenant(
    Covenant covenatDelete,
    int index,
  ) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      covenatDelete
        ..isDeleted = true
        ..isNew = false
        ..isCovenant = true;

      final Map<String, dynamic> currentRawValue =
          covenatDelete.toDeleteJson(Globals.request?.applicationRefNo);

      await repository.saveCovenantDetails([currentRawValue], isCovenant);

      covenant = await repository.getCovenants(isCovenant);

      if (covenant.isEmpty) {
        emit(state.copyWith(loaderStatus: LoadingStatus.error));
        return;
      }

      _alertManager.showSuccessToast(
        "covenantsConditions.conditionsEditDialog.savedSuccefully".tr(),
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      _alertManager.showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  @override
  Future<void> close() async {
    await _unregisterDraftHook();
    return super.close();
  }

  /// Normalizes comment content for reliable comparison (plain vs HTML).
  String _normalizeComment(String value, {required bool isHtml}) {
    if (!isHtml) {
      return value.trim();
    }

    // Convert HTML to plain-ish text so we can detect "empty" and "unchanged"
    return value
        .replaceAll(RegExp("<[^>]*>"), " ") // remove tags
        .replaceAll("&nbsp;", " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }

  // ---------------------------------------------------------------------------

  Future<void> _registerDraftHook() async {
    if (_registerDraftCallbackOverride != null) {
      await _registerDraftCallbackOverride();
      return;
    }
    registerDraftCallback();
  }

  Future<void> _loadDraftHook() async {
    if (_loadDraftIfAvailableOverride != null) {
      await _loadDraftIfAvailableOverride();
      return;
    }
    await loadDraftIfAvailable();
  }

  Future<void> _deleteDraftHook() async {
    if (_deleteDraftOverride != null) {
      await _deleteDraftOverride();
      return;
    }
    unawaited(deleteDraft());
  }

  Future<void> _unregisterDraftHook() async {
    if (_unregisterDraftCallbackOverride != null) {
      await _unregisterDraftCallbackOverride();
      return;
    }
    unregisterDraftCallback();
  }

  Future<String> _getEditorText() async {
    if (_editorTextProviderOverride != null) {
      return _editorTextProviderOverride();
    }
    return unifiedEditorController.getText();
  }

  Future<void> _showDialog(BuildContext context) async {
    if (_showCovenantDialogOverride != null) {
      await _showCovenantDialogOverride(
        context: context,
        width: Scale.scaleHorizontally(800),
        title: "covenantsConditions.covenantEditDialog.covenantInfo".tr(),
        content: CovenantEditDialogView(
          isNew: true,
          overridePageMode: covenantPageMode,
        ),
      );
      return;
    }

    await DialogHelper.showCustomDialog(
      context: context,
      width: Scale.scaleHorizontally(800),
      title: "covenantsConditions.covenantEditDialog.covenantInfo".tr(),
      content: CovenantEditDialogView(
        isNew: true,
        overridePageMode: covenantPageMode,
      ),
    );
  }

  void _navigateNext() {
    if (_goToNextRouteOverride != null) {
      _goToNextRouteOverride();
      return;
    }
    LayoutViewModel().goToNextRoute();
  }

  PageMode _resolvePageMode() {
    if (_pageModeResolver != null) {
      return _pageModeResolver(RightConstants.covenantsSummary);
    }
    return AuthRepository.getPageMode(RightConstants.covenantsSummary);
  }
}
