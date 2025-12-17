import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
// import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/security_perfection.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class SecurityPerfectionViewModel extends Cubit<SecurityPerfectionState> {
  SecurityPerfectionViewModel()
      : super(SecurityPerfectionState(loaderStatus: LoadingStatus.loading));

  late final RequestRepository repository;
  late final CommonRepository repositoryCommon;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool get canEdit => true;//(pageMode == PageMode.edit);
  PageMode pageMode = PageMode.na;

  List<Comment>? comments;
  Comment? comment;
  SecurityPerfection securityDeferral = SecurityPerfection();

  /// Initialises the view model with the application strategy details from the database.
  ///
  /// This method is called when the view is first loaded. It retrieves the
  /// application strategy details from the repository, and updates the state
  /// with the fetched details. If an error occurs during the process, the
  /// loader status is set to [LoadingStatus.error].
  void init(BuildContext context) async {
    logger.i('Initializing SecurityPerfectionViewModel');
    repository = RequestRepository.instance;
    repositoryCommon = CommonRepository.instance;
    pageMode = AuthRepository.getPageMode(RightConstants.securityPerfection);
    await getApplicationStrategyDetails();
    await getSecurityDeferralDetails();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves security deferral details for the current application.
  ///
  /// This asynchronous method:
  /// 1. Emits a loading state to indicate the start of the data fetch.
  /// 2. Calls the repository to retrieve security deferral details and assigns
  ///    the result to the `securityDeferral` variable.
  ///
  Future<void> getSecurityDeferralDetails() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      securityDeferral = await repository.getSecurityDeferralDetails();
    } catch (e) {
      logger.e('Error fetching strategy details: $e');
      AlertManager().showFailureToast(
        '$e',
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Fetches strategy-related comments for the current application.
  ///
  /// This asynchronous method performs the following steps:
  /// 1. Emits a loading state to indicate data retrieval is in progress.
  /// 2. Retrieves all comments of type `securityPerfection` and entity `securityPerfection`
  ///    from the `CommonRepository`.
  /// 3. Filters the retrieved comments to find those matching the `securityCategoryID`.
  /// 4. Updates the first comment's `strategyComment` field with the relevant strategy comment,
  ///    or sets it to an empty string if none are found.
  ///
  Future<void> getApplicationStrategyDetails() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      comments = await repositoryCommon.getApplicationStrategyDetails(
          CommentsType.securityPerfection, EntityIdentifier.securityPerfection);

      final relevantComments = comments
              ?.where((item) =>
                  item.categoryId == ServerConstants.securityCategoryID)
              .toList() ??
          [];

      comments?[0].strategyComment = relevantComments.isNotEmpty
          ? relevantComments.first.strategyComment
          : "";
    } catch (e) {
      logger.e('Error fetching strategy details: $e');
      // AlertManager().showFailureToast(
      //   '$e',
      // );
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      comments = [Comment(strategyComment: 'Test')];
    }
  }

  /// Handles the logic when the save button is pressed.
  ///
  /// This asynchronous method performs the following steps:
  /// 1. Sets the button loading state to true.
  /// 2. Validates and saves the form if editing is allowed or the form is valid.
  /// 3. Logs the strategy comment being saved.
  /// 4. Populates the `comment` object with necessary metadata such as application reference number,
  ///    user ID, role, comment type, entity type, category ID and type, and the strategy comment.
  /// 5. Saves the comment using `CommonRepository`.
  /// 6. Logs the result of the save operation.
  /// 7. Emits a new state with loading set to false.
  ///
  Future<void> onSaveButtonPressed() async {
    try {
      emit(state.copyWith(isButtonLoading: true));

      // if (!canEdit || (formKey.currentState?.validate() ?? false)) {
      //   formKey.currentState?.save();

      //   logger.i('Saving strategyComment: $comments?[0].strategyComment');

      //   comment?.applicationRefNo = Globals.request?.applicationRefNo;
      //   comment?.draft = false;
      //   comment?.userId = Globals.user?.id;
      //   comment?.userRole = Globals.user?.currentRole?.roleId;
      //   comment?.type = CommentsType.securityPerfection;
      //   comment?.entityType = EntityIdentifier.securityPerfection;
      //   comment?.categoryId = ServerConstants.securityCategoryID; //4256,
      //   comment?.categoryType =
      //       ServerConstants.securityCategoryType; //"Security Perfection",
      //   comment?.strategyComment = comments?[0].strategyComment;

      //   String? result = await repositoryCommon.saveApplicationStrategyDetails(
      //       ServerConstants.securityStrategyCommentsType,
      //       ServerConstants.securityAppStrategyCommentsId,
      //       comment!);
      //   logger.i('Save result: $result');
      LayoutViewModel().goToNextRoute();
      // }
      emit(state.copyWith(isButtonLoading: false));
    } catch (e) {
      logger.e('Error during save: $e');
      AlertManager().showSuccessToast(
        'requestInformation.securityPerfection.savedSuccessfully'.tr(),
      );
      emit(state.copyWith(
        isButtonLoading: false,
        loaderStatus: LoadingStatus.error,
      ));
    }
  }

  /// Updates the UI state after table-related changes.
  ///
  /// This method sets the button loading indicator to false and updates
  /// the loader status to `LoadingStatus.loaded`, indicating that the
  /// data has been successfully loaded and the UI can reflect the updated state.
  void updateTableStateChanges() {
    emit(state.copyWith(
      isButtonLoading: false,
      loaderStatus: LoadingStatus.loaded,
    ));
  }

  void onSavePressedLinkedFacilities(BuildContext context) {
    context.pop();
  }
}
