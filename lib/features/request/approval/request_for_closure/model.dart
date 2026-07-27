import "dart:async";
import "package:collection/collection.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/state.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing request for closure comments and submission.
class RequestForClosureViewModel extends SafeCubit<RequestForClosureState>
    with DraftMixin<RequestForClosureViewModel> {
  /// Constructor initializes the state with a loading status.
  RequestForClosureViewModel()
      : super(RequestForClosureState(loaderStatus: LoadingStatus.loading));

  // --- DRAFT IDENTITY ---

  /// Module key used for saving and loading approval draft data.
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  // Create a unique form key based on the route, customer string identifier,
  // and the active tab's name

  /// Form key used to uniquely identify the request for closure draft.
  @override
  String get draftFormKey => Routes.requestForClosure;

  /// Draft handler used to build and apply request closure draft data.
  @override
  DraftHandler<RequestForClosureViewModel> get draftHandler =>
      RequestClosureDraftHandler();

  /// Repository instance for handling request-related operations.
  late RequestRepository requestRepository;

  /// Repository instance for handling approval-related operations.
  late ApprovalRepository repository;

  /// Repository instance for handling common comment-related operations.
  late CommonRepository commonRepository;

  /// Strategy comment entered for request closure.
  String? strategyComment;

  /// Number of rows to display per page.
  int? rowsPerPage = 5;

  /// Current user role.
  UserRole? userRole = Globals.user?.currentRole!.userRole;

  /// Indicates whether the closure action can be submitted.
  bool canSubmit = false;

  /// Indicates whether the request closure screen is read-only.
  bool isReadOnly = true;

  /// Indicates whether the current request was initiated by the current user.
  bool isInitByUser = false;

  /// Last assigned role information for the request.
  Role? assignedRole;

  /// Review comment identifier used for saving or updating comments.
  String reviewCommentId = "0";

  // Comments

  /// List of comments loaded for request closure.
  List<Comment>? comments = [];

  /// Current request closure comment.
  Comment? comment;

  /// Initializes repositories, loads application details, comments, and drafts.
  Future<void> init(BuildContext context) async {
    logger.i("initialising RequestForFolViewModel");
    repository = ApprovalRepository.instance;
    requestRepository = RequestRepository.instance;
    commonRepository = CommonRepository.instance;
    await requestRepository.getApplicationDetails();
    isInitByUser = Globals.checkIsInitiated();
    isReadOnly =
        !(Globals.checkCurrentStatus([RequestStatus.approved]) && isInitByUser);
    logger.i("isReadOnly closure : $isReadOnly");
    await getComments(CommentsType.approval, EntityIdentifier.approval);
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates submit availability based on entered closure comment text.
  void onTextChange(String plainText) {
    canSubmit = plainText.trim().isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Saves the closure comment and submits the close application action.
  Future<List<String>> saveCommentAndClose() async {
    List<String> description = [];

    try {
      comment = Comment.fromInputData(
        type: CommentsType.requestForClosure,
        entityType: EntityIdentifier.requestForClosure,
        categoryId: ServerConstants
            .commentCategoryId[CommentsCategory.requestForClosure],
        reviewCommentId: reviewCommentId,
        comment: strategyComment,
      );

      reviewCommentId = await repository.saveReviewComments(comment!);
      description = await submitApplication(UserAction.acceptCloseApplication);
      unawaited(deleteDraft());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return description;
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    return [];
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
  ///   an error is handled.
  Future<void> getComments(
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    try {
      comments = await commonRepository.getComments(type, entityIdentifier);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Submits the selected user action for closing the application.
  Future<List<String>> submitApplication(UserAction userAction) async {
    final List<String> description = [];
    int commentId = 0;
    commentId = int.tryParse(reviewCommentId) ?? 0;
    final int? actionId = Globals.userAction.firstWhereOrNull(
      (map) => map.containsKey(ServerConstants.userActionList[userAction]),
    )?[ServerConstants.userActionList[userAction]];
    try {
      AppResponse response;
      response = await repository.submitApplication(
        null,
        commentId,
        actionId,
      );
      if (response.status == ResponseStatus.success) {
        AlertManager().showSuccessToast(
          "approval.comments.applicationSuccessfulSubmitted".tr(),
        );
        description.addAll([
          "layout.topmenu.comfirmation".tr(),
          "approval.comments.applicationStatus".tr(
            namedArgs: {
              "refno": Globals.request?.applicationRefNo ?? "",
              "status": "approval.comments.acceptClosed".tr(),
            },
          ),
        ]);

        return description;
      } else {
        AlertManager()
            .showFailureToast("approval.comments.applicationFailed".tr());
        return description;
      }
    } on Object catch (e) {
      logger.e("Error details: $e");
      AlertManager()
          .showFailureToast("approval.comments.applicationFailed".tr());
      return description;
    }
  }
}
