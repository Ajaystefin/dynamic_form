import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
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

class RecommendCurrentApprovalViewModel
    extends SafeCubit<RecommendCurrentApprovalState>
    with DraftMixin<RecommendCurrentApprovalViewModel> {
  RecommendCurrentApprovalViewModel()
      : super(
          RecommendCurrentApprovalState(loaderStatus: LoadingStatus.loading),
        );
  late ApprovalRepository repository;
  late RequestRepository requestRepository;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int? rowsPerPage = 5;
  List<Comment> comments = [];
  Comment? comment;
  // UnifiedEditorController controller = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();
  bool isReadOnly = true;
  String initialText = "";
  bool canSubmit = false;
  bool isCommentVisible = false;
  String reviewCommentId = "0";
  bool canEdit = false;
  bool isInitByCA = false;
  bool isInitByCCOOD = false;
  bool isRiskRatingInit = false;

  /// If this screen is accessible for edit from rights
  bool get isEdit => Globals.user?.currentRole
          ?.rights?[RightConstants.recommendationCurrentApproval] ==
      AccessType.edit;

  /// Controller to avoid `initialValue` refresh issues
  final TextEditingController commentController = TextEditingController();

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  @override
  String get draftFormKey => Routes.recommendationCurrentApproval;

  @override
  DraftHandler<RecommendCurrentApprovalViewModel> get draftHandler =>
      RecommendCurrentApprovalDraftHandler();

  // ---------------------------------------------------------------------------

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
    debugPrint("isInitByCCOOD : $isInitByCCOOD");
    isInitByCA = (role == ServerConstants.userRoleCode[UserRole.creditAnalyst]);
    debugPrint("isInitByCA : $isInitByCA");
    isRiskRatingInit = Globals.checkAppSubStatus(
      ServerConstants.applicationSubType[ApplicationSubType.riskRating] ?? "",
    );
    // roles with ccood and above can not edit it
    canEdit = (ServerConstants.userRoleId[UserRole.creditCommittee] ?? 0) >
        (Globals.user?.currentRole?.roleId ?? 0);
    if (Utils.checkRole(UserRole.creditAnalyst)) {
      canEdit = isInitByCA && isRiskRatingInit;
    } else if (Utils.checkRole(UserRole.creditCordinator)) {
      canEdit = isInitByCCOOD && isRiskRatingInit;
    }
    debugPrint(
      "canEdit : $canEdit "
      "${ServerConstants.userRoleId[UserRole.creditCommittee]} "
      "> ${Globals.user?.currentRole?.roleId}",
    );

    isReadOnly = Utils.checkIfAppReadOnly() || !canEdit;
    debugPrint("canEdit : $isReadOnly");
    // AutoSave / Draft
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable(); // will trigger draftHandler.applyDraft
    }

    // Sync controller with current model text (after draft load or server
    // fetch)
    _syncControllerFromModel();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> onSavePress({
    required BuildContext context,
    bool isContinue = false,
  }) async {
    try {
      if (initialText.isEmpty) {
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
          strategyComment: initialText,
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
  // --------------------------- Helpers ---------------------------------------

  void _syncControllerFromModel() {
    // ensure UI reflects current model text
    if (commentController.text != initialText) {
      commentController.text = initialText;
    }
  }

  // --------------------------- Lifecycle -------------------------------------

  @override
  Future<void> close() {
    unregisterDraftCallback();
    commentController.dispose();
    return super.close();
  }
}
