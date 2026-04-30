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

class LimitCapsViewModel extends SafeCubit<LimitCapsState> {
  LimitCapsViewModel()
      : super(LimitCapsState(loaderStatus: LoadingStatus.loading));
  ApprovalRepository repository = ApprovalRepository();
  int rowsPerPage = 5;
  List<LimitDetail?> filteredlimitDetail = [];
  List<LimitDetail?> limitDetail = [];

  String? filterRim;
  bool isEdit = Globals.user?.currentRole?.rights?[RightConstants.limitCaps] ==
      AccessType.edit;

  Future<void> init(context) async {
    logger.i("initialising LimitCapsViewModel");
    try {
      await getCompanyLimitDetails();
      await repository.fetchReference();
    } catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getCompanyLimitDetails() async {
    try {
      limitDetail = await repository.getCompanyLimitDetails();
      filteredlimitDetail = limitDetail;
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void onFilter({required String value}) {
    filterRim = value;
    filteredlimitDetail = [];
    filteredlimitDetail = limitDetail
        .where((data) => (data?.rimNo?.toString() ?? "").contains(value))
        .toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
