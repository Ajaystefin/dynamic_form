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
import "package:wcas_frontend/features/request/approval/previous_credit_approval/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class PreviousCreditApprovalViewModel
    extends SafeCubit<PreviousCreditApprovalState>
    with DraftMixin<PreviousCreditApprovalViewModel> {
  PreviousCreditApprovalViewModel()
      : super(PreviousCreditApprovalState(loaderStatus: LoadingStatus.loading));
  late ApprovalRepository repository;
  late RequestRepository requestRepository;
  late AdminRepository adminRepository;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Comment> comments = [];
  Comment? comment;
  final ScrollController scrollController = ScrollController();
  bool isReadOnly = true;
  String initialText = "";
  String reviewCommentId = "0";

  /// If this screen is accessible for edit from rights
  bool get isEdit => Globals
          .user?.currentRole?.rights?[RightConstants.previousCreditApproval] ==
      AccessType.edit;

  /// Controller to avoid `initialValue` refresh issues
  final TextEditingController commentController = TextEditingController();

  List<UserRole> userRoleList = [
    UserRole.relationshipOfficer,
    UserRole.relationshipManager,
    UserRole.businessUnitHead,
    UserRole.teamLeaderBusiness,
    UserRole.segmentHeadBusiness,
    UserRole.commercialAreaManager,
    UserRole.relationshipManagerBussiness,
  ];

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  @override
  String get draftFormKey => Routes.previousCreditApproval;

  @override
  DraftHandler<PreviousCreditApprovalViewModel> get draftHandler =>
      PreviousCreditApprovalDraftHandler();

  // ---------------------------------------------------------------------------

  Future<void> init(BuildContext context) async {
    logger.i("initialising PreviousCreditApprovalViewModel");
    repository = ApprovalRepository.instance;
    requestRepository = RequestRepository.instance;
    adminRepository = AdminRepository.instance;
    await getApplicationStrategyDetails();
    await requestRepository.getApplicationDetails();
    await repository.fetchReference();
    // String role = await repository.getInitiatedRole();

    isReadOnly = Utils.checkIfAppReadOnly() || !Utils.checkRoles(userRoleList);
    debugPrint(
      "isReadOnly : $isReadOnly ${Utils.checkIfAppReadOnly()} "
      "${!Utils.checkRoles(userRoleList)}",
    );
    // AutoSave / Draft
    if (isEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable(); // will trigger draftHandler.applyDraft
    }

    // Sync controller with current model text (after draft load or server
    // fetch)
    syncControllerFromModel();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> onSavePress({
    required BuildContext context,
    bool isContinue = false,
  }) async {
    try {
      if (initialText.isEmpty) {
        AlertManager().showFailureToast(
          "approval.previousCreditApproval.pleaseEnterRemarks".tr(),
        );
        return;
      }

      List<Comment> comments = [];

      // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      comments = [
        Comment.fromInputData(
          type: CommentsType.previousCreditApproval,
          entityType: EntityIdentifier.previousCreditApproval,
          categoryId: ServerConstants
              .approvalCategoryId[ApprovalCategory.previousCreditApproval],
          categoryType: ServerConstants
              .approvalCategoryType[ApprovalCategory.previousCreditApproval],
          strategyComment: initialText,
        ),
      ];

      unawaited(
        repository.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.previousCreditApproval],
          comments,
        ),
      );

      // Clear draft after successful save
      unawaited(deleteDraft());

      AlertManager().showSuccessToast(
        "approval.previousCreditApproval.savedSuccessfully".tr(),
      );
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (isContinue && context.mounted) {
        LayoutViewModel().goToNextRoute();
        router.go(Routes.recommendationCurrentApproval);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await repository.getApplicationStrategyDetails(
        CommentsType.previousCreditApproval,
        EntityIdentifier.previousCreditApproval,
      );

      if (comments.isNotEmpty) {
        final matched = comments.where(
          (item) =>
              ServerConstants.approvalCategoryId[
                  ApprovalCategory.previousCreditApproval] ==
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
      logger.i("previousCreditApproval - initial text: $initialText");
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
  // --------------------------- Helpers ---------------------------------------

  void syncControllerFromModel() {
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
