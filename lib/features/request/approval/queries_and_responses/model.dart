import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
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

class QueriesAndResponsesViewModel extends SafeCubit<QueriesAndResponsesState>
    with DraftMixin<QueriesAndResponsesViewModel> {
  QueriesAndResponsesViewModel()
      : super(QueriesAndResponsesState(loaderStatus: LoadingStatus.loading));
  late ApprovalRepository repository;
  late CommonRepository commonRepository;
  late RequestRepository requestRepository;
  int? rowsPerPage = 5;
  List<Comment> comments = [];
  Comment? comment = Comment();
  UnifiedEditorController controller = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();
  bool isReadOnly = true;
  String initialText = "";
  bool canSubmit = false;
  bool isCommentVisible = false;
  String reviewCommentId = "0";
  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.businessVolume] ==
          AccessType.edit;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  @override
  String get draftFormKey => Routes.queriesAndResponses;

  @override
  DraftHandler<QueriesAndResponsesViewModel> get draftHandler =>
      QueriesAndResponsesDraftHandler();

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
  Future<void> init(context) async {
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

  Future<void> onSavePress({
    required BuildContext context,
    bool isContinue = false,
  }) async {
    try {
      final String rawHtml = await controller.getText();

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

      if (context.mounted) {
        await context.read<QueriesAndResponsesViewModel>().init(context);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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
          debugPrint("isCommentVisible : $isCommentVisible");
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
