import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
// import 'package:package_info_plus/package_info_plus.dart';
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/login/state.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

class LoginViewModel extends SafeCubit<LoginState> {
  LoginViewModel() : super(LoginState(loaderStatus: LoadingStatus.loaded));
  AuthRepository repository = AuthRepository();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? username;
  String? password;
  String? errorText;
  bool isPasswordVisible = false;
  bool hasPasswordInput = false;
  bool? hasNoRoles = false;

  Future<void> init() async {
    await getVersion();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the submission of the login form.
  Future<void> onSubmitPressed() async {
    errorText = null;
    try {
      {
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));
        formKey.currentState?.save();

        final String? result =
            await repository.login(username: username!, password: password!);
        hasNoRoles = Globals.user?.segments?.isEmpty;
        if (!hasNoRoles!) {
          AlertManager().showSuccessToast(result ?? "");
          (Globals.user?.availableRoles?.length == 1
              ? router.go(Routes.home)
              : router.go(Routes.selectRole));
        } else {
          AlertManager()
              .showFailureToast("auth.login.errorMessageNoRoles".tr());
        }
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void refresh() {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    Globals.user = null;
    hasNoRoles = false;
    router.refresh();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onPasswordChanged(String value) {
    hasPasswordInput = value.isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getVersion() async {
    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    emit(state.copyWith(appVersion: "version".tr()));
  }
}
