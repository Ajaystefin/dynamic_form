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

class RequestForClosureViewModel extends SafeCubit<RequestForClosureState>
    with DraftMixin<RequestForClosureViewModel> {
  RequestForClosureViewModel()
      : super(RequestForClosureState(loaderStatus: LoadingStatus.loading));

  // --- DRAFT IDENTITY ---
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  // Create a unique form key based on the route, customer string identifier,
  // and the active tab's name
  @override
  String get draftFormKey => Routes.requestForClosure;

  @override
  DraftHandler<RequestForClosureViewModel> get draftHandler =>
      RequestClosureDraftHandler();

  /// Repository instance for handling request-related operations.
  late RequestRepository requestRepository;
  late ApprovalRepository repository;
  late CommonRepository commonRepository;
  String? strategyComment;
  int? rowsPerPage = 5;
  UserRole? userRole = Globals.user?.currentRole!.userRole;
  bool canSubmit = false;
  bool isReadOnly = true;
  bool isInitByUser = false;
  Role? assignedRole;
  String reviewCommentId = "0";

  // Comments
  List<Comment>? comments = [];
  Comment? comment;

  Future<void> init(context) async {
    logger.i("initialising RequestForFolViewModel");
    repository = ApprovalRepository.instance;
    requestRepository = RequestRepository.instance;
    commonRepository = CommonRepository.instance;
    await requestRepository.getApplicationDetails();
    // isReadOnly = Globals.checkIsAllReadOnly();
    final String role = await repository.getInitiatedRole();
    isInitByUser =
        (role == Globals.user?.currentRole?.code) && Globals.checkIsInitiated();
    isReadOnly =
        !(Globals.checkCurrentStatus([RequestStatus.approved]) && isInitByUser);
    debugPrint("isReadOnly closure : $isReadOnly");
    await getComments(CommentsType.approval, EntityIdentifier.approval);
    // await repository.fetchReference();
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onTextChange(String plainText) {
    canSubmit = plainText.trim().isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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
    } catch (e) {
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

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
    } catch (e) {
      logger.e("Error details: $e");
      AlertManager()
          .showFailureToast("approval.comments.applicationFailed".tr());
      return description;
    }
  }
}
