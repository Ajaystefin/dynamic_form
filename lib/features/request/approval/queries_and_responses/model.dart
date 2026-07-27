import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
// import "package:flutter_bloc/flutter_bloc.dart";
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
import "package:wcas_frontend/features/request/approval/queries_and_responses/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/queries_and_responses/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing the state and logic of the Queries and Responses screen.
class QueriesAndResponsesViewModel extends SafeCubit<QueriesAndResponsesState>
    with DraftMixin<QueriesAndResponsesViewModel> {
  /// Constructor initializes the state with a loading status.
  QueriesAndResponsesViewModel()
      : super(
          const QueriesAndResponsesState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository instance for handling approval-related operations.
  late ApprovalRepository repository;

  /// Repository instance for handling common comment-related operations.
  late CommonRepository commonRepository;

  /// Repository instance for handling request-related operations.
  late RequestRepository requestRepository;

  /// Number of rows to display per page.
  int? rowsPerPage = 5;

  /// List of query and response comments loaded for the request.
  List<Comment> comments = [];

  /// Current query and response comment.
  Comment? comment = Comment();

  /// Controller for the rich text editor used to enter comments.
  UnifiedEditorController controller = UnifiedEditorController();

  /// Scroll controller used by the queries and responses screen.
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

  /// Indicates whether the current user has edit access for this screen.
  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.businessVolume] ==
          AccessType.edit;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  /// Module key used for saving and loading approval draft data.
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  /// Form key used to uniquely identify the queries and responses draft.
  @override
  String get draftFormKey => Routes.queriesAndResponses;

  /// Draft handler used to build and apply queries and responses draft data.
  @override
  DraftHandler<QueriesAndResponsesViewModel> get draftHandler =>
      QueriesAndResponsesDraftHandler();

  /// Placeholder form key getter.
  void get formKey {}

  // ---------------------------------------------------------------------------

  /// Initializes the BusinessVolumeViewModel.
  ///
  /// This function sets up the repository, logs the initialization
  /// process, retrieves business volume data, and updates the loader status.
  ///
  /// [context] - The BuildContext, if needed for additional initialization
  /// steps.
  ///
  Future<void> init(BuildContext context) async {
    logger.i("initialising QueriesAndResponsesViewModel");
    repository = ApprovalRepository.instance;
    commonRepository = CommonRepository.instance;
    requestRepository = RequestRepository.instance;
    await getComments();
    await requestRepository.getApplicationDetails();
    await repository.fetchReference();
    isReadOnly = Utils.checkIfAppReadOnly();
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Saves the current query and response comment.
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
          "approval.queriesResponses.pleaseEnterRemarks".tr(),
        );
        return;
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      comment = Comment.fromInputData(
        type: CommentsType.queriesResponses,
        entityType: EntityIdentifier.queriesResponses,
        categoryId:
            ServerConstants.commentTypeId[CommentsType.queriesResponses],
        reviewCommentId: reviewCommentId,
        comment: rawHtml,
      );

      await repository.saveReviewComments(comment!);

      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved

      AlertManager()
          .showSuccessToast("approval.creditAssessment.savedSuccessfully".tr());
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
        if (Utils.checkRequestType(RequestType.fullCA)) {
          router.go(Routes.previousCreditApproval);
        }
      }
      await getComments();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      // if (context.mounted) {
      //   await context.read<QueriesAndResponsesViewModel>().init(context);
      // }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Gets query and response comments for the current request.
  Future<void> getComments() async {
    try {
      comments = await commonRepository.getComments(
        CommentsType.queriesResponses,
        EntityIdentifier.queriesResponses,
      );
      if (comments.isNotEmpty) {
        if (comments.length == 1) {
          isCommentVisible = comments.first.userId != Globals.user?.id ||
              comments.first.userRole != Globals.user?.currentRole?.roleId;
          logger.i("isCommentVisible : $isCommentVisible");
        } else {
          isCommentVisible = true;
        }

        if (comments.length > 1) {
          comment = comments
              .reduce((a, b) => a.createdDate!.isAfter(b.createdDate!) ? a : b);
        }
        if (comments.length == 1 && comments.firstOrNull != null) {
          comment = comments.first;
        }

        if (comment != null) {
          if (comment?.userId == Globals.user?.id &&
              comment?.userRole == Globals.user?.currentRole?.roleId) {
            reviewCommentId = comment?.reviewCommentId ?? "0";
            initialText = comment?.comment ?? "";
            controller.setText(initialText);
            comments.removeWhere(
              (userComment) =>
                  comment?.reviewCommentId == userComment.reviewCommentId,
            );
          }
        }
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Closes the view model and unregisters draft callbacks.
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
