import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/limit_caps/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/approval/limit_detail.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";

/// ViewModel for managing the state and logic of the Limit Caps screen.
class LimitCapsViewModel extends SafeCubit<LimitCapsState> {
  /// Constructor initializes the state with a loading status.
  LimitCapsViewModel()
      : super(const LimitCapsState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling approval-related operations.
  ApprovalRepository repository = ApprovalRepository();

  /// Number of rows to display per page in the limit caps table.
  int rowsPerPage = 5;

  /// Filtered limit detail records displayed in the table.
  List<LimitDetail?> filteredlimitDetail = [];

  /// Full list of limit detail records loaded from the repository.
  List<LimitDetail?> limitDetail = [];

  /// Current RIM filter value entered by the user.
  String? filterRim;

  /// Indicates whether the current user has edit access for limit caps.
  bool isEdit = Globals.user?.currentRole?.rights?[RightConstants.limitCaps] ==
      AccessType.edit;

  /// Initializes the ViewModel by loading company limit details and references.
  Future<void> init(BuildContext? context) async {
    logger.i("initialising LimitCapsViewModel");
    try {
      await getCompanyLimitDetails();
      await repository.fetchReference();
    } on Object catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Gets company limit details from the repository.
  Future<void> getCompanyLimitDetails() async {
    try {
      limitDetail = await repository.getCompanyLimitDetails();
      filteredlimitDetail = limitDetail;
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Filters limit details using the entered RIM value.
  void onFilter({required String value}) {
    filterRim = value;
    filteredlimitDetail = [];
    filteredlimitDetail = limitDetail
        .where((data) => (data?.rimNo?.toString() ?? "").contains(value))
        .toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the save button press and optionally navigates to the next route.
  Future<void> onSavePress({bool isContinue = false}) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      // String response =
      //     await repository.saveBussinessVoumes(customerWiseBusinessVolume);
      // AlertManager().showSuccessToast(response);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
