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

/// View model responsible for handling login-related business logic.
class LoginViewModel extends SafeCubit<LoginState> {
  /// Creates a [LoginViewModel].
  LoginViewModel()
      : super(const LoginState(loaderStatus: LoadingStatus.loaded));

  /// Authentication repository used for login operations.
  AuthRepository repository = AuthRepository();

  /// Form key used to validate and save the login form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Username entered by the user.
  String? username;

  /// Password entered by the user.
  String? password;

  /// Error message displayed on login failure.
  String? errorText;

  /// Controls password visibility state.
  bool isPasswordVisible = false;

  /// Indicates whether the password field has input.
  bool hasPasswordInput = false;

  /// Indicates whether the logged-in user has any roles assigned.
  bool? hasNoRoles = false;

  /// Initializes the view model.
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
          if (Globals.user?.availableRoles?.length == 1) {
            router.go(Routes.home);
          } else {
            router.go(Routes.selectRole);
          }
        } else {
          AlertManager()
              .showFailureToast("auth.login.errorMessageNoRoles".tr());
        }
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Resets the login state and refreshes the application routing.
  void refresh() {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    Globals.user = null;
    hasNoRoles = false;
    router.refresh();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Toggles password visibility in the password field.
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates password input state when the password value changes.
  void onPasswordChanged(String value) {
    hasPasswordInput = value.isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves and sets the application version.
  Future<void> getVersion() async {
    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    emit(state.copyWith(appVersion: "version".tr()));
  }
}
