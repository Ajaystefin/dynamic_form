import "package:wcas_frontend/core/utils/utils.dart";

class SplashState {
  SplashState({required this.loaderStatus});
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  SplashState copyWith({LoadingStatus? loaderStatus}) {
    return SplashState(loaderStatus: loaderStatus ?? this.loaderStatus);
  }
}
