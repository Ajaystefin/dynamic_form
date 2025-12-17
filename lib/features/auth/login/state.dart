import 'package:wcas_frontend/core/utils/utils.dart';

class LoginState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  String appVersion;

  LoginState({required this.loaderStatus, this.appVersion = ""});

  LoginState copyWith({LoadingStatus? loaderStatus, String? appVersion}) {
    return LoginState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        appVersion: appVersion ?? this.appVersion);
  }
}
