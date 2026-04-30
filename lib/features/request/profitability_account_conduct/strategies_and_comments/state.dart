import "package:wcas_frontend/core/utils/utils.dart";

class StrategiesAndCommentsState {
  StrategiesAndCommentsState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  StrategiesAndCommentsState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return StrategiesAndCommentsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
