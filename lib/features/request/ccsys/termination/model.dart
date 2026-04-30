import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/termination/draft_handler.dart";
import "package:wcas_frontend/features/request/ccsys/termination/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/information/customer_request_info.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class CcsysTerminationViewModel extends SafeCubit<TerminationState>
    with
        DraftMixin<
            // AutoSave related changes by extended team
            CcsysTerminationViewModel> {
  CcsysTerminationViewModel()
      : super(TerminationState(loaderStatus: LoadingStatus.loading));

  late RequestRepository repository;
  late CommonRepository commonRepository;
  FocusNode formFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // int? reasonId;
  bool isTerminationSuccess = false;
  List<Reference> reasonForTermination = [];
  List<Response> customerInfo = [];
  List<Comment>? getReviewComments = [];
  List<Comment> comments = [];
  Comment? comment = Comment();

  Map<String, List<Reference>> referenceData = {};

  bool canEdit = false;
  // State
  PageMode pageMode = PageMode.na;

  void initRightsAndMode(Request request) {
    final bool rights = (request.ccsysCanEditReadOnly ?? true);
    pageMode =
        AuthRepository.getPageMode(RightConstants.ccsysTerminationWithdrawal);
    if (!rights) {
      canEdit = false;
      return;
    }
    canEdit = pageMode == PageMode.edit;
  }

  final TextEditingController remarksController = TextEditingController();
  // AutoSave related changes by extended team
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.ccsys;

  @override
  String get draftFormKey => Routes.ccsysTerminateWithdraw;

  @override
  DraftHandler<CcsysTerminationViewModel> get draftHandler =>
      CcsysTerminationDraftHandler();

  // ---------------------------------------------------------------------------

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
    logger.i("initialising TerminationViewModel");
    repository = RequestRepository.instance;
    commonRepository = CommonRepository.instance;
    initRightsAndMode(Globals.request ?? Request());

    await Future.wait([
      getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      ),
      getReferenceDatas(),
    ]);
    // AutoSave related changes by extended team
    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the selection of a reason for termination from the dropdown.

  /// This method takes a [Reference] object as a parameter, which represents
  /// the
  /// selected reason for termination.

  /// It then updates the [state] with a [LoadingStatus] of
  /// [LoadingStatus.loaded].

  void reasonForTerminationSelected(Reference selectedReason) {
    comment?.categoryId = selectedReason.id;
    comment?.reasonList = selectedReason.id.toString();
    if ((getReviewComments ?? []).isNotEmpty) {
      getReviewComments?.first.reasonList = selectedReason.id.toString();
    }
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
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    try {
      comments = await commonRepository.getComments(type, entityIdentifier);

      getReviewComments = comments
          .where(
            (cmt) => (cmt.applicationRefNo
                    ?.contains(Globals.request?.applicationRefNo ?? "") ??
                false),
          )
          .toList();
      if ((getReviewComments ?? []).isNotEmpty) {
        comment = getReviewComments?.first;
      }

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
  /// [ReferenceDataKeys.ccsysTerminationReason]. If the response is not empty,
  /// it
  /// updates the [reasonForTermination] with the fetched list of reasons.
  /// If the response is empty or an error occurs, it emits an error
  /// [LoadingStatus] for the state.
  Future<void> getReferenceDatas() async {
    try {
      referenceData = await ReferenceDataService()
          .getReferenceData([ReferenceDataKeys.ccsysTerminationReason]);
      reasonForTermination =
          referenceData[ReferenceDataKeys.ccsysTerminationReason] ?? [];
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
      AlertManager().showFailureToast(
        "requestInformation.terminateWithdrawal.requiredFeild".tr(),
      );
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

        final String? result = await repository.updateTerminateStatus(
          comment?.reasonList ?? "",
          comment?.comment ?? "",
        );

        unawaited(
          deleteDraft(),
        ); // fire-and-forget: remove backend draft now that data is saved  // AutoSave related changes by extended team

        logger.i("Termination successful: $result");

        isTerminationSuccess = true;

        if (isTerminationSuccess && context.mounted) {
          context.pop();
          showDialogSuccessTerminateStatus(context);
        }
      }

      emit(state.copyWith(isButtonLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isButtonLoading: false,
          loaderStatus: LoadingStatus.error,
        ),
      );
      logger.e("Error during save: $e");
      AlertManager().showFailureToast("$e");
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
        content: Builder(
          builder: (_) {
            // Build info message: "{prefix}{refNo}{suffix}"
            const String k1 =
                "requestInformation.terminateWithdrawal"
                ".informationMsgrequest";
            const String k2 =
                "requestInformation.terminateWithdrawal"
                ".informationMsg";
            final String refNo =
                Globals.request?.applicationRefNo ?? "";
            return CustomSelectableText(
              text: "${k1.tr()}$refNo${k2.tr()}",
            );
          },
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

  // AutoSave related changes by extended team
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
