import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
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
import "package:wcas_frontend/features/request/information/present_request/draft_handler.dart";
import "package:wcas_frontend/features/request/information/present_request/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class PresentRequestViewModel extends SafeCubit<PresentRequestState>
    with DraftMixin<PresentRequestViewModel> {
  PresentRequestViewModel({required List<dynamic> comments})
      : super(PresentRequestState(loaderStatus: LoadingStatus.loading));

  RequestRepository repository = RequestRepository();
  CommonRepository repositoryCommon = CommonRepository();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // bool get canEdit => (pageMode == PageMode.edit);
  PageMode pageMode = PageMode.na;
  // Comments
  Comment comment = Comment();
  List<Comment>? comments = [];
  //Autosave implementation by Extended team
  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.presentRequest] ==
          AccessType.edit;

  bool get canEdit => isEdit; // && Utils.canEditApplication();

  @override
  String get draftModuleKey =>
      DraftModuleKeys.requestInformation; // The backend category
  @override
  String get draftFormKey => Routes.presentRequest; // The specific UI screen
  @override
  DraftHandler<PresentRequestViewModel> get draftHandler =>
      PresentRequestDraftHandler();

  /// Initialises the view model with the application strategy details from the
  /// database.
  ///
  /// This method is called when the view is first loaded. It retrieves the
  /// application strategy details from the repository, and updates the state
  /// with the fetched details. If an error occurs during the process, the
  /// loader status is set to [LoadingStatus.error].
  Future<void> init(context) async {
    logger.i("initialising PresentRequestViewModel");
    pageMode = AuthRepository.getPageMode(RightConstants.presentRequest);
    await getApplicationStrategyDetails();
    //Autosave implementation by Extended team
    // if (isEdit) {
    // Register this ViewModel to listen to the SideMenu "navigate away" events
    registerDraftCallback();

    // Override the live data with the recovered draft data (if a draft exists)
    await loadDraftIfAvailable();
    // }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches strategy-related comments for the current application.
  ///
  /// This asynchronous method performs the following steps:
  /// 1. Emits a loading state to indicate data retrieval is in progress.
  /// 2. Retrieves all comments of type `securityPerfection` and entity
  /// `securityPerfection`
  ///    from the `CommonRepository`.
  /// 3. Filters the retrieved comments to find those matching the
  /// `securityCategoryID`.
  /// 4. Updates the first comment's `strategyComment` field with the relevant
  /// strategy comment,
  ///    or sets it to an empty string if none are found.
  ///
  ///
  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await repositoryCommon.getApplicationStrategyDetails(
        CommentsType.presentRequest,
        EntityIdentifier.presentRequest,
      );
      final commentItem = comments
          ?.where(
            (item) =>
                item.categoryId == ServerConstants.presentRequestCategoryID,
          )
          .toList();

      if (comments != null && comments!.isNotEmpty) {
        comments?[0].strategyComment =
            commentItem != null && commentItem.isNotEmpty
                ? commentItem.first.strategyComment
                : "";
      }

      logger.i("Strategy comment: $comments?[0].strategyComment");
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Handles the logic when the save button is pressed.
  ///
  /// This asynchronous method performs the following steps:
  /// 1. Sets the button loading state to true.
  /// 2. Validates and saves the form if editing is allowed or the form is
  /// valid.
  /// 3. Logs the strategy comment being saved.
  /// 4. Populates the `comment` object with necessary metadata such as
  /// application reference number,
  ///    user ID, role, comment type, entity type, category ID and type, and the
  /// strategy comment.
  /// 5. Saves the comment using `CommonRepository`.
  /// 6. Logs the result of the save operation.
  /// 7. Emits a new state with loading set to false.
  ///
  Future<void> onSaveButtonPressed() async {
    emit(state.copyWith(isButtonLoading: true));
    formKey.currentState?.save();

    try {
      if (!canEdit || (formKey.currentState?.validate() ?? false)) {
        comment = Comment.fromInputData(
          type: CommentsType.presentRequest,
          strategyComment: comment.strategyComment,
          entityType: EntityIdentifier.presentRequest,
          categoryId: ServerConstants.presentRequestCategoryID,
          categoryType: ServerConstants.presentRequestCategoryType,
          strategyCategory: ServerConstants.presentRequestCategoryType,
          id: comment.id,
        );

        final String? result =
            await repositoryCommon.saveApplicationStrategyDetails(
          ServerConstants.presentRequestStrategyCommentsType,
          ServerConstants.presentRequestAppStrategyCommentsId,
          comment,
        );

        logger.i("onSaveButtonPressed: $result");
        //Autosave implementation by Extended team
        unawaited(deleteDraft());
        AlertManager().showSuccessToast(
          "requestInformation.securityPerfection.savedSuccessfully".tr(),
        );
        LayoutViewModel().goToNextRoute();
      }

      emit(state.copyWith(isButtonLoading: false));
    } catch (e) {
      logger.e("Error during save: $e");
      AlertManager().showFailureToast(e.toString());
      emit(
        state.copyWith(
          isButtonLoading: false,
          loaderStatus: LoadingStatus.error,
        ),
      );
    }
  }

  void syncCommentFromController(String value) {
    comment.strategyComment = value;
    if (comments?.isNotEmpty ?? false) {
      comments!.first.strategyComment = value;
    }
  }

  //Autosave implementation by Extended team
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
