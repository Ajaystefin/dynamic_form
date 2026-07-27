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

/// ViewModel for managing previous credit approval comments and draft data.
class PreviousCreditApprovalViewModel
    extends SafeCubit<PreviousCreditApprovalState>
    with DraftMixin<PreviousCreditApprovalViewModel> {
  /// Constructor initializes the state with a loading status.
  PreviousCreditApprovalViewModel()
      : super(PreviousCreditApprovalState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling approval-related operations.
  late ApprovalRepository repository;

  /// Repository instance for handling request-related operations.
  late RequestRepository requestRepository;

  /// Repository instance for handling admin-related operations.
  late AdminRepository adminRepository;

  /// Global key for validating the previous credit approval form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// List of comments loaded or saved for previous credit approval.
  List<Comment> comments = [];

  /// Current previous credit approval comment.
  Comment? comment;

  /// Scroll controller used by the previous credit approval screen.
  final ScrollController scrollController = ScrollController();

  /// Indicates whether the previous credit approval screen is read-only.
  bool isReadOnly = true;

  /// Initial text loaded into the comments field.
  String initialText = "";

  /// Review comment identifier used for previous credit approval.
  String reviewCommentId = "0";

  /// If this screen is accessible for edit from rights
  bool get isEdit =>
      Globals
          .user?.currentRole?.rights?[RightConstants.previousCreditApproval] ==
      AccessType.edit;

  /// Controller to avoid `initialValue` refresh issues
  final TextEditingController commentController = TextEditingController();

  /// List of Roles that can edit
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

  /// Module key used for saving and loading approval draft data.
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  /// Form key used to uniquely identify the previous credit approval draft.
  @override
  String get draftFormKey => Routes.previousCreditApproval;

  /// Draft handler used to build and apply previous credit approval draft data.
  @override
  DraftHandler<PreviousCreditApprovalViewModel> get draftHandler =>
      PreviousCreditApprovalDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes repositories, loads existing comments, references, and draft.
  Future<void> init(BuildContext context) async {
    logger.i("initialising PreviousCreditApprovalViewModel");
    repository = ApprovalRepository.instance;
    requestRepository = RequestRepository.instance;
    adminRepository = AdminRepository.instance;
    await getApplicationStrategyDetails();
    await requestRepository.getApplicationDetails();
    await repository.fetchReference();

    isReadOnly = Utils.checkIfAppReadOnly() || !Utils.checkRoles(userRoleList);
    logger.i(
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

  /// Saves previous credit approval comments and optionally continues navigation.
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Gets application strategy details for previous credit approval.
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // --------------------------- Helpers ---------------------------------------

  /// Synchronizes the text controller with the current model text.
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
