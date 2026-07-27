import "dart:async";

import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/core/services/draft/draft_mixin.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/draft_handler.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/group_information/facilities_with_cbd.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/group_information_repository.dart";

/// View model for the Facilities with CBD section.
class FacilitiesWithCbdViewModel extends SafeCubit<FacilitiesWithCbdState>
    with
        DraftMixin<
            // AutoSave related changes by extended team
            FacilitiesWithCbdViewModel> {
  /// Creates a [FacilitiesWithCbdViewModel].
  FacilitiesWithCbdViewModel()
      : super(FacilitiesWithCbdState(loaderStatus: LoadingStatus.loading));

  /// Group information repository instance.
  GroupInformationRepository? repository;

  /// Form key used for validation and submission.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Facilities with CBD associated with the group.
  List<FacilitiesWithCbd> groupFacilitiesWithCDB = [];

  /// Comments associated with the application strategy.
  List<Comment>? comments;

  /// Current comment for the Facilities with CBD section.
  Comment? comment;

  /// Indicates whether the user has edit access.
  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.facilitiesWithCbd] ==
          AccessType.edit;

  /// Indicates whether the application is a cancellation application.
  bool get isCancellationApp =>
      Utils.checkApplicationType(ApplicationType.cancellation);

  /// Indicates whether the section can be edited.
  bool get canEdit => pageMode == PageMode.edit && !isCancellationApp;

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Controller for the comments field.
  final TextEditingController commentController = TextEditingController();

  // AutoSave related changes by extended team
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.groupInformation;

  @override
  String get draftFormKey => Routes.facilitiesWithCbd;

  @override
  DraftHandler<FacilitiesWithCbdViewModel> get draftHandler =>
      FacilitiesWithCbdDraftHandler();

  // ---------------------------------------------------------------------------

  /// It first logs the initialization of the view model, then sets the
  /// [repository] to an instance of [GroupInformationRepository]. Finally, it
  /// awaits
  /// the completion of the following two futures:
  ///
  /// - [getApplicationStrategyDetails]
  /// - [getGroupInformation]
  Future<void> init(BuildContext context) async {
    logger.i("initialising FacilitiesWithCbdViewModel");
    repository ??= GroupInformationRepository.instance;
    commentController.addListener(() {
      comment ??= Comment();
      comment!.comment = commentController.text;
    });

    pageMode = AuthRepository.getPageMode(RightConstants.facilitiesWithCbd);

    await Future.wait([
      getApplicationStrategyDetails(),
      getGroupInformation(),
    ]);
    // AutoSave related changes by extended team
    if (isEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
  }

  /// Fetches application strategy details and updates state.
  ///
  /// This method retrieves the application strategy details from the repository
  /// and logs the fetched details. It filters the `commentList` to find
  /// comments
  /// with the category type "GROUP INFORMATION" and updates `strategyComment`
  /// with
  /// the first matching comment's strategyComment. If an error occurs during
  /// the
  /// process, the loading status is set to error.
  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await CommonRepository.instance.getApplicationStrategyDetails(
        CommentsType.facilitiesWithCbd,
        EntityIdentifier.facilitiesWithCbd,
      );
      final List<Comment>? commentItem = comments
          ?.where((item) => item.categoryId == ServerConstants.groupCategoryID)
          .toList();

      comment ??= Comment();
      if (commentItem != null && commentItem.isNotEmpty) {
        comment!.comment = commentItem.first.strategyComment;
      } else {
        comment!.comment = "";
      }

      commentController.text = comment!.comment ?? "";
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves the group facilities with CBD from the repository and updates
  /// the state.
  ///
  /// This method is called when the page is first loaded. It retrieves the
  /// group
  /// facilities with CBD from the repository and logs the fetched details. If
  /// the
  /// fetch is successful, it updates the state with the fetched details. If an
  /// error occurs during the process, the loading status is set to error.
  Future<void> getGroupInformation() async {
    try {
      groupFacilitiesWithCDB = await repository!.getGroupInformation();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves the present request form data to the server.
  /// If the form is valid, it saves the form data, and then calls
  /// [`GroupInformationRepository.saveGroupFacilitiesWithCbd`] to save the form
  /// data to
  /// the server. If there is an error, it emits a new [FacilitiesWithCbdState]
  /// with
  /// the loader status set to [LoadingStatus.error].
  ///
  /// If the save is successful, it navigates to the next page.
  Future<void> onSaveComment() async {
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState?.save();

        comment ??= Comment();
        comment!.comment = commentController.text;

        emit(state.copyWith(loaderStatus: LoadingStatus.loading));

        final Comment saveComment = Comment.fromInputData(
          type: CommentsType.facilitiesWithCbd,
          entityType: EntityIdentifier.facilitiesWithCbd,
          comment: comment?.comment,
          categoryType: ServerConstants.groupCategoryType,
          categoryId: ServerConstants.groupCategoryID,
        );

        // await CommonRepository.instance.saveComment(saveComment);

        final String? response =
            await CommonRepository.instance.saveApplicationStrategyDetails(
          ServerConstants.groupStrategyCommentsType,
          ServerConstants.groupAppStrategyCommentsId,
          saveComment,
        );

        unawaited(
          deleteDraft(),
        ); // fire-and-forget: remove backend draft now that data is saved  // AutoSave related changes by extended team

        AlertManager().showSuccessToast(response.toString());
        LayoutViewModel().goToNextRoute();
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  // AutoSave related changes by extended team
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
