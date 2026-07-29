import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/select_role/state.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

/// View model responsible for role selection and navigation.
class SelectRoleViewModel extends SafeCubit<SelectRoleState> {
  /// Creates a [SelectRoleViewModel].
  SelectRoleViewModel()
      : super(
          const SelectRoleState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Authentication repository instance.
  late AuthRepository repository;

  /// Currently selected user role.
  Role? userRole;

  /// Error message displayed when role selection fails.
  String? errorMessage;

  /// Initializes the view model.
  Future<void> init() async {
    repository = AuthRepository.instance;
  }

  /// Validates and submits the selected role.
  Future<void> selectRole() async {
    try {
      errorMessage = null;
      if (userRole == null) {
        throw ApiException(
          "auth.selectRole.noRoleSelected".tr(),
        );
      }
      emit(state.copyWith(selectRoleStatus: LoadingStatus.loading));
      await AuthRepository.instance.changeRole(userRole!);
      // router.go(Routes.home);
      routeAfterRoleChange(userRole?.userRole);
    } on Object catch (e) {
      errorMessage = e.toString();
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(selectRoleStatus: LoadingStatus.loaded));
  }

  /// Navigates the user to the appropriate screen after role selection.
  void routeAfterRoleChange(UserRole? userRole) {
    router.go(AuthRepository.landingRoute(userRole));
  }
}
