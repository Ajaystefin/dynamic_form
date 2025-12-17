import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/login/role.dart';

import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'state.dart';

class SelectRoleViewModel extends Cubit<SelectRoleState> {
  SelectRoleViewModel()
      : super(SelectRoleState(loaderStatus: LoadingStatus.loading));
  late AuthRepository repository;
  Role? userRole;
  String? errorMessage;

  void init() {
    repository = AuthRepository.instance;
  }

  Future<void> selectRole() async {
    try {
      errorMessage = null;
      if (userRole == null) {
        throw "auth.selectRole.noRoleSelected".tr();
      }
      emit(state.copyWith(selectRoleStatus: LoadingStatus.loading));
      await AuthRepository.instance.changeRole(userRole!);
      // router.go(Routes.home);
      routeAfterRoleChange(userRole?.userRole);
    } catch (e) {
      errorMessage = e.toString();
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(selectRoleStatus: LoadingStatus.loaded));
  }

  void routeAfterRoleChange(UserRole? userRole) {
    if (userRole == UserRole.icsAdmin) {
      router.go(Routes.userList);
    } else if (userRole == UserRole.admin) {
      router.go(Routes.manageReference);
    } else {
      router.go(Routes.home);
    }
  }
}
