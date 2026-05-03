import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/group_position/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/group_position/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/approval/clean_exposure.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing the state and logic of the Group Position screen.
///
/// This class is responsible for initializing data, managing pagination,
/// and updating the UI state using the BLoC pattern.
class GroupPositionViewModel extends SafeCubit<GroupPositionState>
    with DraftMixin<GroupPositionViewModel> {
  /// Constructor initializes the state with a loading status.
  GroupPositionViewModel()
      : super(GroupPositionState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Number of rows to display per page in a paginated table or list.
  int rowsPerPage = 12;
  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.groupPosition] ==
          AccessType.edit;
  // Add this property so `viewModel.groups` exists:
  List<CustomerPosition> groups = [];
  GroupPosition? groupPositionList = GroupPosition();
  ApprovalRepository? approvalRepository;
  AppResponse? appResponse;
  Map<String, TextEditingController> cleanExposureControllers = {};
  Map<String, String> cleanExposureValues = {};
  Map<String, Exposure> groupedExposure = {};
  List<Exposure> exposureList = [];
  CleanExposure? cleanExposure;
  double totalProposedExposure = 0;
  double totalPresentExposure = 0;

  @override
  String get draftModuleKey => DraftModuleKeys.approval;
// Use the correct module bucket → adjust if you have a specific constant

  @override
  String get draftFormKey => Routes.groupPosition;
// This must be the exact route string used for this screen

  @override
  DraftHandler<GroupPositionViewModel> get draftHandler =>
      GroupPositionDraftHandler();

  /// Initializes the ViewModel by setting up the repository and simulating a
  /// loading delay.
  ///
  /// Logs the initialization process and updates the loader status to `loaded`
  /// after a 2-second delay to simulate data fetching.
  ///
  /// [context] - The build context used for localization or navigation if
  /// needed.
  Future<void> init(context) async {
    logger.i("initialising GroupPositionViewModel");
    repository = RequestRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    try {
      await repository.getApplicationDetails();
      await approvalRepository?.fetchReference();
      await getGroupPositionDetails();
      await loadCleanExposureData();
    } catch (e) {
      logger.e("Error details: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    if (isEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> loadCleanExposureData() async {
    try {
      cleanExposure = await approvalRepository?.getCleanExposureInfo();
      if (cleanExposure != null) {
        exposureList = cleanExposure?.exposures ?? [];
        exposureList.add(
          Exposure(rimNo: 0),
        ); // for shared rim to map with group position
        totalProposedExposure = cleanExposure?.totalProposedExposure ?? 0;
        totalPresentExposure = cleanExposure?.totalPresentExposure ?? 0;
      }
      for (final Exposure exp in exposureList) {
        groupedExposure[exp.rimNo.toString()] = exp;
        final String presentKey = "${exp.rimNo}_present";
        final String proposedKey = "${exp.rimNo}_proposed";
        cleanExposureControllers[presentKey] = TextEditingController();
        cleanExposureControllers[proposedKey] = TextEditingController();
        if (exp.rimNo == 0) {
          if (cleanExposure?.totalSharedLimitPresent != null) {
            final String value =
                cleanExposure?.totalSharedLimitPresent.toString() ?? "0";
            cleanExposureControllers[presentKey]?.text = value;
            cleanExposureValues[presentKey] = value;
            updateExposureField(1, exp.rimNo.toString(), value, false);
          }
          if (cleanExposure?.totalSharedLimitProposed != null) {
            final String value =
                cleanExposure?.totalSharedLimitProposed.toString() ?? "0";
            cleanExposureControllers[proposedKey]?.text = value;
            cleanExposureValues[proposedKey] = value;
            updateExposureField(2, exp.rimNo.toString(), value, true);
          }
        } else {
          if (exp.updatedPresentExposure != null) {
            cleanExposureControllers[presentKey]?.text =
                exp.updatedPresentExposure.toString();
            updateExposureField(
              3,
              exp.rimNo.toString(),
              exp.updatedPresentExposure.toString(),
              false,
            );
          }
          if (exp.updatedProposedExposure != null) {
            cleanExposureControllers[proposedKey]?.text =
                exp.updatedProposedExposure.toString();
            updateExposureField(
              4,
              exp.rimNo.toString(),
              exp.updatedProposedExposure.toString(),
              true,
            );
          }
          if (exp.calculatedPresentExposure != null) {
            cleanExposureValues[presentKey] =
                exp.calculatedPresentExposure.toString();
          }
          if (exp.calculatedProposedExposure != null) {
            cleanExposureValues[proposedKey] =
                exp.calculatedProposedExposure.toString();
          }
        }
        debugPrint(
          "groupedExposure : $proposedKey "
          "${cleanExposureControllers[proposedKey]?.text} "
          "$presentKey "
          "${cleanExposureControllers[presentKey]?.text}",
        );
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error details: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> getGroupPositionDetails() async {
    try {
      appResponse = await approvalRepository?.getGroupPositionDetails();
      groupPositionList = await approvalRepository
          ?.transformGroupPositionFacilitiesData(appResponse);
      groups = approvalRepository?.groups ?? [];
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error details: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
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
      exposureList.addAll(groupedExposure.values.toSet().toList());
      if (exposureList.isNotEmpty) {
        await approvalRepository
            ?.insertCleanExposureInfo(exposureList.toSet().toList());
        AlertManager().showSuccessToast(
          "approval.guarantorsExposure.savedSuccessfully".tr(),
        );
      }
      unawaited(deleteDraft());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
      await loadCleanExposureData();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateExposureField(
    int index,
    String rimNo,
    String newValue,
    bool isProposed,
  ) {
    groupedExposure.putIfAbsent(
      rimNo,
      () => Exposure(rimNo: int.tryParse(rimNo) ?? 0),
    );
    groupedExposure[rimNo]?.appRefNo = Globals.request?.applicationRefNo;
    if (rimNo == "0") {
      if (isProposed) {
        groupedExposure[rimNo]?.updatedSharedLimitProposed =
            double.tryParse(newValue);
      } else {
        groupedExposure[rimNo]?.updatedSharedLimitPresent =
            double.tryParse(newValue);
      }
    } else {
      if (isProposed) {
        groupedExposure[rimNo]?.updatedProposedExposure =
            double.tryParse(newValue);
      } else {
        groupedExposure[rimNo]?.updatedPresentExposure =
            double.tryParse(newValue);
      }
    }
  }
}
