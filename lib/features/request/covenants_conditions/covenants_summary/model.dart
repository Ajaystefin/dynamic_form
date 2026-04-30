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
import "package:wcas_frontend/core/utils/logger.dart";
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

typedef ShowCovenantDialog = Future<void> Function({
  required BuildContext context,
  required double width,
  required String title,
  required Widget content,
});

class CovenantsSummaryViewModel extends SafeCubit<CovenantsSummaryState>
    with DraftMixin<CovenantsSummaryViewModel> {
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

  late CovenantConditionRepository repository;
  List<Covenant> covenant = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  BuildContext? context;
  Request? request;
  String? strategyComment;
  int? isCovenant = 1;
  Map<String, List<Reference>> referenceData = {};

  // Comments
  List<Comment> comments = [];
  Comment? comment = Comment();

  List<Reference>? covenantType = [];
  List<Reference>? covenantSubtype = [];
  List<Reference>? frequency = [];
  List<Reference>? action = [];
  List<Reference>? status = [];
  List<Reference>? covenantGeneralSpecific = [];

  // paging
  final int rowsPerPage = 10;

  PageMode covenantPageMode = PageMode.na;

  bool get canEdit => covenantPageMode == PageMode.edit;
  bool get isReadOnly => covenantPageMode == PageMode.view;

  bool get isFIFlow =>
      _isFIFlowOverride ??
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  bool get isEdit =>
      _isEditOverride ??
      (Globals.user?.currentRole?.rights?[RightConstants.covenantsSummary] ==
          AccessType.edit);

  TextEditingController controller = TextEditingController();
  HtmlEditorController htmlEditorController = HtmlEditorController();
  final UnifiedEditorController unifiedEditorController =
      UnifiedEditorController();
  final ScrollController scrollController = ScrollController();

  CommonRepository get _commonRepository =>
      _commonRepositoryOverride ?? CommonRepository.instance;

  ReferenceDataService get _referenceDataService =>
      _referenceDataServiceOverride ?? ReferenceDataService();

  AlertManager get _alertManager => _alertManagerOverride ?? AlertManager();

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------
  @override
  String get draftModuleKey => DraftModuleKeys.covenantsAndConditions;

  @override
  String get draftFormKey => Routes.covenantsSummary;

  @override
  DraftHandler<CovenantsSummaryViewModel> get draftHandler =>
      CovenantsSummaryDraftHandler();

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

  /// Initializes the [CovenantsSummaryViewModel] by loading necessary data.
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
    } catch (e) {
      _alertManager.showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> fetchCovenants() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    covenant = await repository.getCovenants(isCovenant);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      rethrow;
    }
  }

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

  String getReferenceName(List<Reference>? list, int? id) {
    if (list == null || id == null) return "";
    return list
            .firstWhere(
              (ref) => ref.id == id,
              orElse: () => Reference(name: ""),
            )
            .name ??
        "";
  }

  String getGeneralSpecificName(List<Reference>? list, int? id) {
    if (list == null || id == null) return "";
    return list
            .firstWhere(
              (ref) => ref.id == id,
              orElse: () => Reference(name: ""),
            )
            .name ??
        "";
  }

  void addCovenant() {
    emit(state.copyWith(covenantsSummaryLoader: LoadingStatus.loaded));
  }

  Future<void> saveComment({bool ifNavigate = false}) async {
    if (isFIFlow) {
      final String rawHtml = await _getEditorText();
      comment?.comment = rawHtml;
    }

    comment!
      ..applicationRefNo = Globals.request?.applicationRefNo
      ..userId = Globals.user?.id
      ..userRole = Globals.user?.currentRole?.roleId
      ..comment = comment?.comment
      ..categoryId =
          ServerConstants.commentTypeId[CommentsType.covenantsSummary];

    try {
      await _commonRepository.saveComment(comment!);

      if (!isReadOnly) {
        _alertManager.showSuccessToast(
          "covenantsConditions.conditionsEditDialog.savedSuccefully".tr(),
        );
      }

      await _deleteDraftHook();

      if (ifNavigate) {
        _navigateNext();
      }
    } catch (e) {
      _alertManager.showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> getComments(
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    try {
      comments = await _commonRepository.getComments(type, entityIdentifier);
      logger.d(comments);

      for (final Comment comment in comments) {
        comment.comment ??= "";
      }

      if (comments.isNotEmpty) {
        final String safe = comments.last.comment ?? "";
        controller.text = safe;
        unifiedEditorController.setText(safe);
      }
    } catch (e) {
      _alertManager.showFailureToast(e.toString());
    }
  }

  Future<void> onDeleteCovenant(
    Covenant covenatDelete,
    int index,
  ) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      covenatDelete.isDeleted = true;
      covenatDelete.isNew = false;
      covenatDelete.isCovenant = true;

      final Map<String, dynamic> raw =
          covenatDelete.toDeleteJson(Globals.request?.applicationRefNo);

      await repository.saveCovenantDetails([raw], isCovenant);

      covenant = await repository.getCovenants(isCovenant);

      if (covenant.isEmpty) {
        emit(state.copyWith(loaderStatus: LoadingStatus.error));
        return;
      }

      _alertManager.showSuccessToast(
        "covenantsConditions.conditionsEditDialog.savedSuccefully".tr(),
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      _alertManager.showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  @override
  Future<void> close() async {
    await _unregisterDraftHook();
    return super.close();
  }
}
