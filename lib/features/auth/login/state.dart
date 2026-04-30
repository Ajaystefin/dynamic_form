import "package:wcas_frontend/core/utils/utils.dart";

class LoginState {
  LoginState({required this.loaderStatus, this.appVersion = ""});
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  String appVersion;

  LoginState copyWith({LoadingStatus? loaderStatus, String? appVersion}) {
    return LoginState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
