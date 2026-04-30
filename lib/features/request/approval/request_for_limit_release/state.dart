import "package:wcas_frontend/core/utils/utils.dart";

class RequestForLimitReleaseState {
  RequestForLimitReleaseState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RequestForLimitReleaseState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RequestForLimitReleaseState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
