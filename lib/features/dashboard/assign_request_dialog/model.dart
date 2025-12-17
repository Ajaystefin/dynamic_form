import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';

import 'package:wcas_frontend/repositories/dashboard_repository.dart';
import 'state.dart';

class AssignRequestDialogViewModel extends Cubit<AssignRequestDialogState> {
  AssignRequestDialogViewModel()
      : super(AssignRequestDialogState(loaderStatus: LoadingStatus.loading));
  late DashboardRepository repository;

  Future<void> init(context) async {
    logger.i('initialising AssignRequestDialogViewModel');
    repository = DashboardRepository.instance;
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
