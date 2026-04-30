import "package:wcas_frontend/core/utils/utils.dart";

class RequestForClosureState {
  RequestForClosureState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RequestForClosureState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RequestForClosureState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
