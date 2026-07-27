import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/recommend_for_current_approval/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/recommend_for_current_approval/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing recommendation for current approval comments.
class RecommendCurrentApprovalViewModel
    extends SafeCubit<RecommendCurrentApprovalState>
    with DraftMixin<RecommendCurrentApprovalViewModel> {
  /// Constructor initializes the state with a loading status.
  RecommendCurrentApprovalViewModel()
      : super(
          RecommendCurrentApprovalState(loaderStatus: LoadingStatus.loading),
        );

  /// Repository instance for handling approval-related operations.
  late ApprovalRepository repository;

  /// Repository instance for handling request-related operations.
  late RequestRepository requestRepository;

  /// Global key for validating the recommendation current approval form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Number of rows to display per page.
  int? rowsPerPage = 5;

  /// List of recommendation current approval comments loaded for the request.
  List<Comment> comments = [];

  /// Current recommendation current approval comment.
  Comment? comment;

  /// Controller for the rich text editor used to enter comments.
  UnifiedEditorController controller = UnifiedEditorController();

  /// Scroll controller used by the recommendation current approval screen.
  final ScrollController scrollController = ScrollController();

  /// Indicates whether the screen is in read-only mode.
  bool isReadOnly = true;

  /// Initial text loaded into the editor.
  String initialText = "";

  /// Indicates whether submit actions are allowed.
  bool canSubmit = false;

  /// Indicates whether previous comments should be visible.
  bool isCommentVisible = false;

  /// Review comment identifier used for updating existing comments.
  String reviewCommentId = "0";

  /// Indicates whether the current user can edit this screen.
  bool canEdit = false;

  /// Check if applicaiton is initialized by CA
  bool isInitByCA = false;

  /// Check if applicaiton is initialized by CCOOD
  bool isInitByCCOOD = false;

  /// Indicates whether the current application was initiated as risk rating.
  bool isRiskRatingInit = false;

  /// If this screen is accessible for edit from rights
  bool get isEdit =>
      Globals.user?.currentRole
          ?.rights?[RightConstants.recommendationCurrentApproval] ==
      AccessType.edit;

  /// Controller to avoid `initialValue` refresh issues
  // final TextEditingController commentController = TextEditingController();

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  /// Module key used for saving and loading approval draft data.
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  /// Form key used to uniquely identify the recommendation current approval draft.
  @override
  String get draftFormKey => Routes.recommendationCurrentApproval;

  /// Draft handler used to build and apply recommendation current approval data.
  @override
  DraftHandler<RecommendCurrentApprovalViewModel> get draftHandler =>
      RecommendCurrentApprovalDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes repositories, loads saved recommendation details, and drafts.
  Future<void> init(BuildContext context) async {
    logger.i("initialising RecommendCurrentApprovalViewModel");
    repository = ApprovalRepository.instance;
    requestRepository = RequestRepository.instance;
    await getApplicationStrategyDetails();
    await requestRepository.getApplicationDetails();
    await repository.fetchReference();
    final String role = await repository.getInitiatedRole();
    isInitByCCOOD =
        (role == ServerConstants.userRoleCode[UserRole.creditCordinator]);
    logger.i("isInitByCCOOD : $isInitByCCOOD");
    isInitByCA = (role == ServerConstants.userRoleCode[UserRole.creditAnalyst]);
    logger.i("isInitByCA : $isInitByCA");
    isRiskRatingInit = Globals.checkAppSubStatus(
      ServerConstants.applicationSubType[ApplicationSubType.riskRating] ?? "",
    );

    /// Roles with CCOOD and above can not edit it
    canEdit = (ServerConstants.userRoleId[UserRole.creditCordinator] ?? 0) >
        (Globals.user?.currentRole?.roleId ?? 0);

    /// But if initialized by CA or CCOOD can edit it
    if (Utils.checkRole(UserRole.creditAnalyst)) {
      canEdit = isInitByCA && isRiskRatingInit;
    } else if (Utils.checkRole(UserRole.creditCordinator)) {
      canEdit = isInitByCCOOD && isRiskRatingInit;
    }
    logger.i(
      "canEdit : $canEdit "
      "${ServerConstants.userRoleId[UserRole.creditCordinator]} "
      "> ${Globals.user?.currentRole?.roleId}",
    );

    isReadOnly = Utils.checkIfAppReadOnly() || !canEdit;
    logger.i("canEdit : $isReadOnly");
    // AutoSave / Draft
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable(); // will trigger draftHandler.applyDraft
    }

    // Sync controller with current model text (after draft load or server
    // fetch)
    // _syncControllerFromModel();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Saves recommendation current approval comments and optionally continues.
  Future<void> onSavePress({
    required BuildContext context,
    bool isContinue = false,
  }) async {
    try {
      final String rawHtml = await controller.getText();

      /// [text] to check with validtion only and not to pass as parameter
      final String text = rawHtml
          .replaceAll(RegExp("<[^>]*>"), "") // remove HTML tags
          .replaceAll("&nbsp;", " ") // handle non-breaking spaces
          .trim();
      if (text.isEmpty) {
        AlertManager().showFailureToast(
          "approval.recommendationCurrentApproval.pleaseEnterRemarks".tr(),
        );
        return;
      }

      List<Comment> comments = [];

      // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      comments = [
        Comment.fromInputData(
          type: CommentsType.recommendCurrentApproval,
          categoryId: ServerConstants
              .approvalCategoryId[ApprovalCategory.recommendCurrentApproval],
          categoryType: ServerConstants
              .approvalCategoryType[ApprovalCategory.recommendCurrentApproval],
          strategyComment: rawHtml,
        ),
      ];

      await repository.saveApplicationStrategyDetails(
        ServerConstants.commentTypeId[CommentsType.recommendCurrentApproval],
        comments,
      );

      // Clear draft after successful save
      unawaited(deleteDraft());

      AlertManager().showSuccessToast(
        "approval.recommendationCurrentApproval.savedSuccessfully".tr(),
      );
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (isContinue && context.mounted) {
        LayoutViewModel().goToNextRoute();
        router.go(Routes.comments);
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Gets application strategy details for recommendation current approval.
  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await repository.getApplicationStrategyDetails(
        CommentsType.recommendCurrentApproval,
        EntityIdentifier.recommendCurrentApproval,
      );

      if (comments.isNotEmpty) {
        final matched = comments.where(
          (item) =>
              ServerConstants.approvalCategoryId[
                  ApprovalCategory.recommendCurrentApproval] ==
              item.categoryId,
        );

        // Attach matched category comment to first item (if any)
        if (comments.firstOrNull != null) {
          comments.first.strategyComment =
              matched.isNotEmpty ? matched.first.strategyComment : "";
        }

        // If first is present, set initialText
        if (comments.firstOrNull != null) {
          initialText = comments.first.strategyComment ?? "";
        }
      }
      logger.i("RecommendCurrentApproval - initial text: $initialText");
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
  // --------------------------- Helpers ---------------------------------------

  // void _syncControllerFromModel() {
  //   // ensure UI reflects current model text
  //   if (controller.currentText != initialText) {
  //     controller.setText(initialText);
  //   }
  // }

  // --------------------------- Lifecycle -------------------------------------

  /// Closes the view model and unregisters draft callbacks.
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
