import "package:wcas_frontend/core/utils/utils.dart";

class RequestForFolState {
  RequestForFolState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RequestForFolState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RequestForFolState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
