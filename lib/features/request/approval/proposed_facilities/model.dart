import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/approval/clean_exposure.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";
import "package:wcas_frontend/models/request/approval/proposed_facilities.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class ProposedFacilitiesViewModel extends SafeCubit<ProposedFacilitiesState>
    with DraftMixin<ProposedFacilitiesViewModel> {
  ProposedFacilitiesViewModel()
      : super(ProposedFacilitiesState(loaderStatus: LoadingStatus.loading));
  late ApprovalRepository approvalRepository;
  late RequestRepository repository;
  int rowsPerPage = 5;
  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.proposedFacilities] ==
          AccessType.edit;
  // Local variable to store the list of GroupPosition records.
  GroupPosition? groupPositionList = GroupPosition();
  List<ProposedFacilities>? pipelineRequests = [];
  AppResponse? appResponse;
  Map<String, TextEditingController>? cleanExposureControllers = {};
  Map<String, String> cleanExposureValues = {};
  Map<int, Exposure> groupedExposure = {};
  List<Exposure> exposureList = [];
  CleanExposure? cleanExposure;
  double totalProposedExposure = 0;

  @override
  String get draftModuleKey => DraftModuleKeys.approval;
// Use the correct module bucket → adjust if you have a specific constant

  @override
  String get draftFormKey => Routes.proposedFacilities;
// This must be the exact route string used for this screen

  @override
  DraftHandler<ProposedFacilitiesViewModel> get draftHandler =>
      ProposedFacilitiesDraftHandler();

  /// Initializes the `ProposedFacilitiesViewModel`.
  ///
  /// This method sets up the required repositories and fetches initial data
  /// needed for the view model. Specifically, it:
  /// - Logs the initialization process.
  /// - Initializes `approvalRepository` instance.
  /// - Retrieves group position details via `getGroupPositionDetails()`.
  /// - Retrieves pipeline request details via `getPipelineRequestDetails()`.
  /// - Updates the state to indicate that loading is complete.
  ///
  /// This method should be called during the view model's setup phase,
  /// typically when the corresponding UI component is initialized.
  ///
  /// Parameters:
  /// - [context]: The build context used for accessing dependencies or
  /// navigation.
  Future<void> init(context) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    logger.i("initialising ProposedFacilitiesViewModel");
    approvalRepository = ApprovalRepository.instance;
    repository = RequestRepository.instance;
    try {
      await repository.getApplicationDetails();
      await getGroupPositionDetails();
      await loadCleanExposureData();
      await getPipelineRequestDetails();
      await approvalRepository.fetchReference();
      debugPrint("isEdit $isEdit");
      if (isEdit) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> loadCleanExposureData() async {
    try {
      cleanExposure = await approvalRepository.getCleanExposureInfo();
      if (cleanExposure != null) {
        exposureList = cleanExposure?.exposures ?? [];
        exposureList.add(
          Exposure(rimNo: 0),
        ); // for shared rim to map with group position
        totalProposedExposure = cleanExposure?.totalProposedExposure ?? 0;
      }
      for (final Exposure exp in exposureList) {
        groupedExposure[exp.rimNo ?? 0] = exp;
        final String presentKey = "${exp.rimNo}_present";
        final String proposedKey = "${exp.rimNo}_proposed";
        cleanExposureControllers?[presentKey] = TextEditingController();
        cleanExposureControllers?[proposedKey] = TextEditingController();
        if (exp.rimNo == 0) {
          if (cleanExposure?.totalSharedLimitPresent != null) {
            final String value =
                cleanExposure?.totalSharedLimitPresent.toString() ?? "0";
            cleanExposureControllers?[presentKey]?.text = value;
            cleanExposureValues[presentKey] = value;
            updateExposureField(1, exp.rimNo, value, false);
          }
          if (cleanExposure?.totalSharedLimitProposed != null) {
            final String value =
                cleanExposure?.totalSharedLimitProposed.toString() ?? "0";
            cleanExposureControllers?[proposedKey]?.text = value;
            cleanExposureValues[proposedKey] = value;
            updateExposureField(2, exp.rimNo, value, true);
          }
        } else {
          if (exp.updatedPresentExposure != null) {
            cleanExposureControllers?[presentKey] = TextEditingController(
              text: exp.updatedPresentExposure.toString(),
            );
            updateExposureField(
              3,
              exp.rimNo,
              exp.updatedPresentExposure.toString(),
              false,
            );
          }
          if (exp.updatedProposedExposure != null) {
            cleanExposureControllers?[proposedKey] = TextEditingController(
              text: exp.updatedProposedExposure.toString(),
            );
            updateExposureField(
              4,
              exp.rimNo,
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
      }
    } catch (e) {
      debugPrint("load exception $e");
      logger.e("Error Fetching : $e");
    }
  }

  /// Fetches group position details from the approval repository.
  ///
  /// This asynchronous method attempts to retrieve a list of group position
  /// details by calling the `getGroupPositionDetails()` method from the
  /// `ApprovalRepository`. Upon successful retrieval, it updates the state
  /// to indicate that loading is complete.
  ///
  /// If an error occurs during the fetch operation, it logs the error and
  /// updates the state to reflect a loading error.
  ///
  /// This method is typically used during the initialization phase of the
  /// view model to populate data required for the UI.
  Future<void> getGroupPositionDetails() async {
    try {
      appResponse = await approvalRepository.getGroupPositionDetails();
      groupPositionList = await approvalRepository
          .transformGroupPositionFacilitiesData(appResponse);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error details: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves pipeline request details from the request repository.
  ///
  /// This asynchronous method fetches a list of pipeline requests by calling
  /// `getPipelineRequestDetails()` from the `RequestRepository`. Upon
  /// successful
  /// retrieval, it updates the state to indicate that loading has completed.
  ///
  /// If an error occurs during the fetch operation, it logs the error and
  /// updates the state to reflect a loading error.
  ///
  /// This method is typically used during the initialization phase of the
  /// view model to populate pipeline-related data for the UI.
  Future<void> getPipelineRequestDetails() async {
    try {
      final rimNo = Globals.request?.customerRimNo;
      pipelineRequests =
          await approvalRepository.getPipelineRequestDetails(rimNo);
      // debugPrint("pipelineRequests lenght : ${pipelineRequests?.length}");
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error details: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> onSavePress({bool isContinue = false}) async {
    try {
      debugPrint(
        "groupedExposure : "
        "${groupedExposure.values.where((exp) => exp.rimNo != 0)}",
      );
      exposureList.addAll(groupedExposure.values.toSet().toList());
      if (exposureList.isNotEmpty) {
        await approvalRepository
            .insertCleanExposureInfo(exposureList.toSet().toList());
        AlertManager().showSuccessToast(
          "approval.proposedFacilities.savedSuccessfully".tr(),
        );
      }
      unawaited(deleteDraft());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
        if (!Utils.isGroupApplication()) {
          router.go(Routes.limitCaps);
        }
      }
      await loadCleanExposureData();
    } catch (e) {
      // AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateExposureField(
    int index,
    int? rimNo,
    String newValue,
    bool isProposed,
  ) {
    try {
      // if (pipelineRequests == null || index >= (pipelineRequests?.length ??
      // 0)) {
      //   return;
      // }
      // await Future.delayed(const Duration(milliseconds: 50));
      groupedExposure.putIfAbsent(
        rimNo ?? 0,
        () => Exposure(rimNo: rimNo ?? 0),
      );
      groupedExposure[rimNo]?.appRefNo = Globals.request?.applicationRefNo;
      if (rimNo == 0) {
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
      // debugPrint("groupedExposure : ${groupedExposure[rimNo]?.rimNo}");
    } catch (e) {
      debugPrint("groupedExposure exception : $e");
      logger.e("Error Updating : $e");
    }
    // String type = (isProposed) ? "proposed" : "present";
    // String key = "${rimNo}_$type";
    // cleanExposureValues[key] = newValue;
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> close() {
    unregisterDraftCallback(); // Prevent memory leaks
    return super.close();
  }
}
