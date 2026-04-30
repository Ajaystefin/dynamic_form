import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/assign_request_dialog/state.dart";
import "package:wcas_frontend/repositories/dashboard_repository.dart";

class AssignRequestDialogViewModel extends SafeCubit<AssignRequestDialogState> {
  AssignRequestDialogViewModel()
      : super(AssignRequestDialogState(loaderStatus: LoadingStatus.loading));
  late DashboardRepository repository;

  Future<void> init(context) async {
    logger.i("initialising AssignRequestDialogViewModel");
    repository = DashboardRepository.instance;
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
