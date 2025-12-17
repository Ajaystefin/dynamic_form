import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/approval/limit_detail.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'state.dart';

class LimitCapsViewModel extends Cubit<LimitCapsState> {
  LimitCapsViewModel()
      : super(LimitCapsState(loaderStatus: LoadingStatus.loading));
  ApprovalRepository repository = ApprovalRepository();
  int rowsPerPage = 5;
  List<LimitDetail?> filteredlimitDetail = [];
  List<LimitDetail?> limitDetail = [];

  String? filterRim;

  Future<void> init(context) async {
    logger.i('initialising LimitCapsViewModel');
    await getCompanyLimitDetails();
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
