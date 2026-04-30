import "package:wcas_frontend/core/utils/utils.dart";

class GuarantorsExposureState {
  GuarantorsExposureState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  GuarantorsExposureState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return GuarantorsExposureState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
