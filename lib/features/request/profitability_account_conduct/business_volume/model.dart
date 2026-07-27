import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/profitability/business_volume.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

/// Business volume view model.
class BusinessVolumeViewModel extends SafeCubit<BusinessVolumeState>
    with DraftMixin<BusinessVolumeViewModel> {
  /// Creates a business volume view model.
  BusinessVolumeViewModel()
      : super(
          const BusinessVolumeState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Profitability repository instance.
  ProfitabilityRepository repository = ProfitabilityRepository();

  /// Customer-wise business volume data.
  Map<Customer, List<BusinessVolume>> customerWiseBusinessVolume = {};

  /// Business volume comments.
  String? comments;

  /// Form key for business volume form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Indicates whether page can be edited.
  bool get canEdit => pageMode == PageMode.edit;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.profitabilityAndAccountConduct;

  @override
  String get draftFormKey => Routes.businessVolume;

  @override
  DraftHandler<BusinessVolumeViewModel> get draftHandler =>
      BusinessVolumeDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the BusinessVolumeViewModel.
  ///
  /// This function sets up the repository, logs the initialization
  /// process, retrieves business volume data, and updates the loader status.
  ///
  /// [context] - The BuildContext, if needed for additional initialization
  /// steps.
  ///
  Future<void> init(BuildContext? context) async {
    logger.i("initialising BusinessVolumeViewModel");
    pageMode = AuthRepository.getPageMode(RightConstants.businessVolume);
    await getBusinessVolume();
    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves customer-wise business volume data asynchronously.
  ///
  /// This function fetches business volume data from the repository
  /// and assigns it to `customerWiseBusinessVolume`. If an error occurs,
  /// it updates the loader status to indicate failure.
  ///
  /// Throws:
  /// - If the repository fails to retrieve data, the loader status
  ///   is updated to `LoadingStatus.error`
  Future<void> getBusinessVolume() async {
    try {
      customerWiseBusinessVolume = await repository.getBusinessVolumes();
      comments = repository.lastBusinessVolumeComment?.comment ?? "";
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves the customer-wise business volume data and updates the loader
  /// status.
  ///
  /// This function initiates the save process by setting the loader status to
  /// `LoadingStatus.loading`. Upon successful completion, it updates the status
  /// to `LoadingStatus.loaded` and displays a success message. If an error
  /// occurs,
  /// it shows a failure toast and sets the status to `LoadingStatus.error`.
  ///
  /// [isContinue] - (Optional) Determines whether the function should proceed
  /// to another operation after saving.
  ///
  /// Throws:
  /// - Displays a failure toast in case of an exception and updates
  ///   the loader status accordingly.
  Future<void> onSavePress({bool isContinue = false}) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      formKey.currentState?.save();
      final String response = await repository.saveBusinessVolumes(
        customerWiseBusinessVolume,
        comments,
      );

      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved

      AlertManager().showSuccessToast(response);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// to save comment data
  Future<void> saveComments() async {
    try {
      final Comment commentData = Comment(comment: comments)
        ..commentId = "2"
        ..applicationRefNo = Globals.request?.applicationRefNo
        ..draft = false
        ..userId = Globals.user?.id
        ..userRole = Globals.user?.currentRole?.roleId
        ..reviewCommentId = "345"
        ..type = CommentsType.accountStats
        ..entityType = EntityIdentifier.accountStats;
      final String response =
          await CommonRepository.instance.saveComment(commentData);
      AlertManager().showSuccessToast(response);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  /// Returns the previous year label.
  String getPreviousYearLabel(BuildContext context) {
    final int currentYear = DateTime.now().year;
    final int previousYear = currentYear - 1;

    return "profitabilityAccountConduct.businessVolume.previousYear".tr(
      namedArgs: {
        "startYear": previousYear.toString(),
        "endYear": previousYear.toString(),
      },
    );
  }

  /// Returns the current year label.
  String getCurrentYearLabel(BuildContext context) {
    final int currentYear = DateTime.now().year;

    return "profitabilityAccountConduct.businessVolume.currentYear".tr(
      namedArgs: {
        "year": currentYear.toString(),
      },
    );
  }
}
