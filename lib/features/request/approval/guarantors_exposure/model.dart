import "package:flutter/material.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/guarantors_exposure/state.dart";
import "package:wcas_frontend/models/request/approval/clean_exposure.dart";
import "package:wcas_frontend/models/request/approval/guarantors_exposure.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";

/// ViewModel for managing the state and logic of the Guarantors Exposure
/// screen.
///
/// This class handles initialization, mock data setup, saving actions,
/// and navigation using the BLoC pattern for state management.
class GuarantorsExposureViewModel extends SafeCubit<GuarantorsExposureState> {
  GuarantorsExposureViewModel()
      : super(GuarantorsExposureState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  ApprovalRepository? repository;

  /// Mock list of guarantor products used for demonstration or testing
  /// purposes.
  List<GuarantorsExposure> guarantorList = [];
  List<Exposure> exposureList = [];
  Map<String, String> cleanExposureValues = {};
  CleanExposure? cleanExposure;

  /// Initializes the ViewModel by setting up the repository and updating the
  /// loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  Future<void> init(context) async {
    logger.i("initialising GuarantorsExposureViewModel");
    repository = ApprovalRepository.instance;
    final repo = repository ?? ApprovalRepository.instance;
    try {
      guarantorList = await repo.getGuarantorExposure();
      await loadCleanExposureData();
      await repository?.fetchReference();
    } catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the save button press logic.
  ///
  /// Emits a loading state, shows a success toast, and optionally navigates
  /// to the Queries and Responses screen if `isContinue` is true.
  ///
  /// [context] - The build context used for navigation and toast display.
  /// [isContinue] - Whether to navigate to the next screen after saving.
  Future<void> onSavePress(
    BuildContext context, {
    bool isContinue = false,
  }) async {
    try {
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> loadCleanExposureData() async {
    try {
      cleanExposure = await repository?.getCleanExposureInfo();
      if (cleanExposure != null) {
        exposureList = cleanExposure?.exposures ?? [];
      }
      for (final Exposure exp in exposureList) {
        if (exp.updatedGuarantorExposure != null) {
          cleanExposureValues[exp.rimNo.toString()] =
              exp.updatedGuarantorExposure.toString();
        }
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error details: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
