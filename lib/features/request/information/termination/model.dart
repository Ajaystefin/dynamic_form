import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/information/customer_request_info.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class TerminationViewModel extends Cubit<TerminationState> {
  TerminationViewModel()
      : super(TerminationState(loaderStatus: LoadingStatus.loading));

  late RequestRepository repository;
  FocusNode formFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool get canEdit => true; // (pageMode == PageMode.edit);
  PageMode pageMode = PageMode.na;

  // int? reasonId;
  bool isTerminationSuccess = false;
  List<Reference> reasonForTermination = [];
  List<Response> customerInfo = [];
  List<Comment>? getReviewComments = [];
  List<Comment> comments = [];

  Map<String, List<Reference>> referenceData = {};

  /// Initialise the TerminationViewModel.
  ///
  /// This method is used to start the initialization of the view model.
  ///
  /// It first logs the initialization of the view model, then sets the
  /// [repository] to an instance of [RequestRepository].
  ///
  /// It then awaits the completion of the following three futures:
  ///
  /// - [getCustomerInfo]
  /// - [getReviewCommentsReference]
  /// - [getReferenceDatas]
  ///
  /// After the futures have completed, it updates the [state] with a
  /// [LoadingStatus] of [LoadingStatus.loaded].
  Future<void> init(context) async {
    logger.i('initialising TerminationViewModel');
    repository = RequestRepository.instance;
    pageMode = AuthRepository.getPageMode(RightConstants.terminateWithdrawal);
    await Future.wait([
      getReviewCommentsReference(
          CommentsType.terminateWithdraw, EntityIdentifier.terminateWithdraw),
      getReferenceDatas(),
    ]);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the selection of a reason for termination from the dropdown.

  /// This method takes a [Reference] object as a parameter, which represents the
  /// selected reason for termination.

  /// It then updates the [state] with a [LoadingStatus] of [LoadingStatus.loaded].

  void reasonForTerminationSelected(Reference selectedReason) {
    final comment = ensureFirstReviewCommentExists();
    comment.categoryId = selectedReason.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches review comments from the repository and updates the state.
  ///
  /// This asynchronous method retrieves review comments by calling
  /// [getReviewCommentsResponse] on the repository. If the response is
  /// not empty, it logs the length of the comments, updates the relevant
  /// and strategy comment. If the response is empty or an error occurs,
  /// it emits an error [LoadingStatus] for the state.

  Future<void> getReviewCommentsReference(
      CommentsType type, EntityIdentifier entityIdentifier) async {
    try {
      comments =
          await CommonRepository.instance.getComments(type, entityIdentifier);

      getReviewComments = comments
          .where((cmt) => (cmt.applicationRefNo
                  ?.contains(Globals.request?.applicationRefNo ?? '') ??
              false))
          .toList();

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Fetches termination reasons from the repository and updates the state.
  ///
  /// This asynchronous method retrieves termination reasons by calling
  /// [getReferenceData] on the [ReferenceDataService] with the key
  /// [ReferenceDataKeys.terminationReason]. If the response is not empty, it
  /// updates the [reasonForTermination] with the fetched list of reasons.
  /// If the response is empty or an error occurs, it emits an error
  /// [LoadingStatus] for the state.
  Future<void> getReferenceDatas() async {
    try {
      referenceData = await ReferenceDataService()
          .getReferenceData([ReferenceDataKeys.terminationReason]);
      reasonForTermination =
          referenceData[ReferenceDataKeys.terminationReason] ?? [];
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Called when the terminate button is pressed.
  ///
  /// This method validates the form by calling [FormState.validate] on the
  /// [formKey] and checks if the result is true. If the validation fails,
  /// it logs a message and returns. If the validation succeeds, it calls
  /// [showDialogUpdateTerminateStatus] to display a dialog with a warning
  /// message for the user to confirm the termination request.
  Future<void> onTerminateButtonPressed(BuildContext context) async {
    final isValid =
        !canEdit ? true : (formKey.currentState?.validate() ?? false);

    if (!isValid) {
      logger.i("Form validation failed for termination request");
      return;
    }
    showDialogUpdateTerminateStatus(context);
  }

  /// Shows a dialog with a warning message for the user to confirm the
  /// termination request. If the user presses the "Yes" button, it calls
  /// [_submitTerminateRequest] to submit the termination request. If the user
  /// presses the "Cancel" button, it simply pops the dialog.
  void showDialogUpdateTerminateStatus(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogHelper.showCustomDialog(
        width: Scale.scaleHorizontally(350),
        context: context,
        title: "requestInformation.terminateWithdrawal.warning".tr(),
        content: CustomSelectableText(
          text: "requestInformation.terminateWithdrawal.warningMsg".tr(),
        ),
        actions: [
          CustomButton(
            label: "requestInformation.terminateWithdrawal.cancel".tr(),
            onPressed: () => context.pop(),
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            label: "requestInformation.terminateWithdrawal.yes".tr(),
            isLoading: state.isButtonLoading,
            onPressed: state.isButtonLoading
                ? null
                : () async {
                    await submitTerminateRequest(context);
                  },
          ),
        ],
      );
    });
  }

  Comment ensureFirstReviewCommentExists({String? appRefNo}) {
    if (appRefNo == null) {
      Globals.request?.applicationRefNo;
    }
    final reviewComments = getReviewComments ?? [];

    // Try to find a comment for the current applicationRefNo
    final existingComment = reviewComments.firstWhere(
      (cmt) => cmt.applicationRefNo == appRefNo,
      orElse: () => Comment(
        applicationRefNo: appRefNo,
        reasonList: '',
        comment: '',
        categoryId: null,
      ),
    );

    // If it's new, add it to the list
    if (!reviewComments.contains(existingComment)) {
      reviewComments.add(existingComment);
    }

    return existingComment;
  }

  /// Submits the termination request to the repository.
  ///
  /// This method emits a [LoadingStatus.loading] state, calls
  /// [updateTerminateStatus] on the [repository], and logs the result of the
  /// request. If the request is successful, it sets [isTerminationSuccess] to
  /// true and shows a success dialog. If the request fails, it logs the error
  /// and emits a [LoadingStatus.error] state.

  Future<void> submitTerminateRequest(BuildContext context) async {
    try {
      emit(state.copyWith(isButtonLoading: true));

      if (!canEdit || (formKey.currentState?.validate() ?? false)) {
        formKey.currentState?.save();

        final comment = ensureFirstReviewCommentExists();

        String? result = await repository.updateTerminateStatus(
          comment.reasonList ?? '',
          comment.comment ?? '',
        );

        logger.i('Termination successful: $result');

        isTerminationSuccess = true;

        if (isTerminationSuccess && context.mounted) {
          context.pop();
          showDialogSuccessTerminateStatus(context);
        }
      }

      emit(state.copyWith(isButtonLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isButtonLoading: false,
        loaderStatus: LoadingStatus.error,
      ));
      logger.e('Error during save: $e');
      AlertManager().showFailureToast('$e');
    }
  }

  /// Displays a dialog indicating the success of the termination request.
  ///
  /// This method shows a dialog with an informational message about the
  /// successful termination of the request. The dialog contains an "OK"
  /// button that allows the user to dismiss it. After the dialog is shown,
  /// the [isTerminationSuccess] flag is reset to false.

  void showDialogSuccessTerminateStatus(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogHelper.showCustomDialog(
        width: Scale.scaleHorizontally(350),
        context: context,
        title: "requestInformation.terminateWithdrawal.information".tr(),
        content: CustomSelectableText(
          text:
              "${"requestInformation.terminateWithdrawal.informationMsgrequest".tr()}${Globals.request?.applicationRefNo ?? ''}${"requestInformation.terminateWithdrawal.informationMsg".tr()}",
        ),
        actions: [
          CustomButton(
            label: "requestInformation.terminateWithdrawal.ok".tr(),
            onPressed: () {
              context.pop();
              // LayoutViewModel().goToNextRoute();
              router.go(Routes.home);
            },
          ),
        ],
      );
      isTerminationSuccess = false;
    });
  }
}
