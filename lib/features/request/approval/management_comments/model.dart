import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
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
import "package:wcas_frontend/features/request/approval/management_comments/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/management_comments/state.dart";
import "package:wcas_frontend/features/request/approval/utils/approval_utils.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing the state and logic of the Management Comments
/// screen.
///
/// This class handles initialization, form validation, and saving of various
/// management-level comments using the BLoC pattern for state management.
class ManagementCommentsViewModel extends SafeCubit<ManagementCommentsState>
    with DraftMixin<ManagementCommentsViewModel> {
  /// Constructor initializes the state with a loading status.
  ManagementCommentsViewModel()
      : super(ManagementCommentsState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Repository instance for handling approval-related operations.
  late ApprovalRepository approvalRepository;

  /// Global key for validating the management comments form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Management comment fields

  /// Initial recommendation from the Credit Committee.
  String creditCommitteeRecommendations = "";

  /// Comments from the Chief Credit Officer (CCO).
  String ccoComments = "";

  /// Comments from the Chief Executive Officer (CEO).
  String ceoComments = "";

  /// Comments from the BCIC (Board Credit Investment Committee).
  String bcicComments = "";

  /// Indicates whether all required management comments are available to submit.
  bool canSubmit = false;

  /// List of management comments loaded or saved for the request.
  List<Comment> comments = [];

  /// Indicates whether the management comments screen is read-only.
  bool isReadOnly = true;

  /// Indicates whether the management comments section is visible.
  bool visibilityStatus = false; // check app status

  /// Current route name used for accessibility checks.
  String route = "";

  // --- DRAFT IDENTITY ---

  /// Module key used for saving and loading approval draft data.
  @override
  String get draftModuleKey => DraftModuleKeys.approval; // The backend category

  /// Form key used to uniquely identify the management comments draft.
  @override
  String get draftFormKey =>
      Routes.managementComments; // The specific UI screen

  /// Draft handler used to build and apply management comments draft data.
  @override
  DraftHandler<ManagementCommentsViewModel> get draftHandler =>
      ManagementCommentsDraftHandler();

  // ----------------------

  /// Initializes the ViewModel by setting up the repository and updating the
  /// loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  Future<void> init(BuildContext context) async {
    // final String route = GoRouterState.of(context).name ?? "";
    try {
      logger.i("initialising ManagementCommentsViewModel");
      repository = RequestRepository.instance;
      approvalRepository = ApprovalRepository.instance;
      await getApplicationStrategyDetails();
      await repository.getApplicationDetails();
      if (context.mounted) {
        route = GoRouterState.of(context).name ?? "";
      }
      final bool hasAccess = ApprovalUtils.checkMasterAccessibilityForRoute(
        route,
        forReadOnly: true,
      );
      logger.i("hasAccess : $route $hasAccess");
      isReadOnly = Utils.checkIfAppReadOnly() || !hasAccess;
      await approvalRepository.fetchReference();
      // AutoSave related changes by extended team
      if (!isReadOnly) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
    } on Object catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the corresponding management comment value when text changes.
  void onTextChange(String plainText, int type) {
    if (type == 1) {
      creditCommitteeRecommendations = plainText;
    } else if (type == 2) {
      ccoComments = plainText;
    } else if (type == 3) {
      ceoComments = plainText;
    } else if (type == 4) {
      bcicComments = plainText;
    }
    canSubmit = creditCommitteeRecommendations.trim().isNotEmpty &&
        ccoComments.trim().isNotEmpty &&
        ceoComments.trim().isNotEmpty &&
        bcicComments.trim().isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the save button press logic for management comments.
  ///
  /// Validates the form, saves the input, and shows a success toast.
  /// Updates the loader status accordingly.
  Future<void> onSave() async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        AlertManager().showSuccessToast(
          "approval.managementComments.savedSuccessfully".tr(),
        );
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves management comments and refreshes saved strategy details.
  Future<void> onSavePress({
    required BuildContext context,
    bool isContinue = false,
  }) async {
    try {
      if (Globals.request?.applicationSubType != ServerConstants.manualEntry) {
        if (creditCommitteeRecommendations.isEmpty ||
            ccoComments.isEmpty ||
            ceoComments.isEmpty ||
            bcicComments.isEmpty) {
          AlertManager().showFailureToast(
            "approval.groupSummary.pleaseEnterSummary".tr(),
          );
          return;
        }
      } else {
        canSubmit = true;
      }

      List<Comment> comments;

      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));
        comments = [
          Comment.fromInputData(
            type: CommentsType.approval,
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditCommittee],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.creditCommittee],
            strategyComment: creditCommitteeRecommendations,
          ),
          Comment.fromInputData(
            type: CommentsType.approval,
            categoryId:
                ServerConstants.approvalCategoryId[ApprovalCategory.ccoComment],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.ccoComment],
            strategyComment: ccoComments,
          ),
          Comment.fromInputData(
            type: CommentsType.approval,
            categoryId:
                ServerConstants.approvalCategoryId[ApprovalCategory.ceoComment],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.ceoComment],
            strategyComment: ceoComments,
          ),
          Comment.fromInputData(
            type: CommentsType.approval,
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.bcicComment],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.bcicComment],
            strategyComment: bcicComments,
          ),
        ];

        await approvalRepository.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.managementComment],
          comments,
        );
        unawaited(deleteDraft());
        AlertManager().showSuccessToast(
          "approval.groupSummary.savedSuccessfully".tr(),
        );
        if (isContinue && context.mounted) {
          LayoutViewModel().goToNextRouteAccess(context);
        }
        await getApplicationStrategyDetails();
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Gets application strategy details for management comments.
  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await approvalRepository.getApplicationStrategyDetails(
        CommentsType.managementComment,
        EntityIdentifier.managementComment,
      );

      final List<int?> categoryIds = [
        ServerConstants.approvalCategoryId[ApprovalCategory.creditCommittee],
        ServerConstants.approvalCategoryId[ApprovalCategory.groupOverview],
        ServerConstants.approvalCategoryId[ApprovalCategory.groupRisk],
        ServerConstants.approvalCategoryId[ApprovalCategory.groupStrategy],
      ];

      final List<Comment> commentItem = comments
          .where((item) => categoryIds.contains(item.categoryId))
          .toList();

      if (comments.isNotEmpty) {
        comments[0].strategyComment = commentItem.isNotEmpty
            ? commentItem.first.strategyComment
            : "comment item not matched";
      }

      if (comments.isNotEmpty) {
        if (comments.length >= 4) {
          creditCommitteeRecommendations = comments[0].strategyComment ?? "";
          ccoComments = comments[1].strategyComment ?? "";
          ceoComments = comments[2].strategyComment ?? "";
          bcicComments = comments[3].strategyComment ?? "";
          canSubmit = true;
        }
      }

      logger.i("Strategy comment: $comments?[0].strategyComment");
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }
}
