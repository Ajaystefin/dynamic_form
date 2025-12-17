import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/approval/group_position.dart';
import 'package:wcas_frontend/models/request/approval/proposed_facilities.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'state.dart';

class ProposedFacilitiesViewModel extends Cubit<ProposedFacilitiesState> {
  ProposedFacilitiesViewModel()
      : super(ProposedFacilitiesState(loaderStatus: LoadingStatus.loading));
  ApprovalRepository? approvalRepository;
  int rowsPerPage = 5;

  // Local variable to store the list of GroupPosition records.
  GroupPosition? groupPositionList = GroupPosition();
  List<ProposedFacilities>? pipelineRequests = [];

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
  /// - [context]: The build context used for accessing dependencies or navigation.
  void init(context) async {
    logger.i('initialising ProposedFacilitiesViewModel');
    approvalRepository = ApprovalRepository.instance;
    await getGroupPositionDetails();
    await getPipelineRequestDetails();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
      groupPositionList = await approvalRepository?.getGroupPositionDetails();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e('Error details: $e');
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves pipeline request details from the request repository.
  ///
  /// This asynchronous method fetches a list of pipeline requests by calling
  /// `getPipelineRequestDetails()` from the `RequestRepository`. Upon successful
  /// retrieval, it updates the state to indicate that loading has completed.
  ///
  /// If an error occurs during the fetch operation, it logs the error and
  /// updates the state to reflect a loading error.
  ///
  /// This method is typically used during the initialization phase of the
  /// view model to populate pipeline-related data for the UI.
  Future<void> getPipelineRequestDetails() async {
    try {
      var rimNo = Globals.request?.customerRimNo;
      pipelineRequests =
          await approvalRepository?.getPipelineRequestDetails(rimNo);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e('Error details: $e');
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  void onSavePress({bool isContinue = false}) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      // String response =
      //     await repository.saveBussinessVoumes(customerWiseBusinessVolume);
      // AlertManager().showSuccessToast(response);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
