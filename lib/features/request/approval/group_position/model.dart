import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/approval/group_position.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

/// ViewModel for managing the state and logic of the Group Position screen.
///
/// This class is responsible for initializing data, managing pagination,
/// and updating the UI state using the BLoC pattern.
class GroupPositionViewModel extends Cubit<GroupPositionState> {
  /// Constructor initializes the state with a loading status.
  GroupPositionViewModel()
      : super(GroupPositionState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Number of rows to display per page in a paginated table or list.
  int rowsPerPage = 12;

  // Add this property so `viewModel.groups` exists:
  List<CustomerPosition> groups = [];

  /// Initializes the ViewModel by setting up the repository and simulating a loading delay.
  ///
  /// Logs the initialization process and updates the loader status to `loaded`
  /// after a 2-second delay to simulate data fetching.
  ///
  /// [context] - The build context used for localization or navigation if needed.
  Future<void> init(context) async {
    logger.i('initialising GroupPositionViewModel');
    repository = RequestRepository.instance;
    await Future.delayed(const Duration(seconds: 2));

    // Initialize dummy data: three groups
    groups = List.generate(
      3,
      (g) => CustomerPosition(
        customerName: 'Customer ${g + 1}',
        presentRowValues: List.generate(9, (i) => '${g + 1}${i + 1}'),
        proposedRowValues: List.generate(9, (i) => '${g + 1}${i + 1}'),
      ),
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the save button press logic.
  ///
  /// Emits a loading state, shows a success toast, and optionally navigates
  /// to the Queries and Responses screen if `isContinue` is true.
  ///
  /// [context] - The build context used for navigation and toast display.
  /// [isContinue] - Whether to navigate to the next screen after saving.
  void onSavePress(BuildContext context, {bool isContinue = false}) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      AlertManager().showSuccessToast(
        "approval.guarantorsExposure.savedSuccessfully".tr(),
      );
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
