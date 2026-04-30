import "package:wcas_frontend/core/utils/utils.dart";

class LimitCapsState {
  LimitCapsState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  LimitCapsState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return LimitCapsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
