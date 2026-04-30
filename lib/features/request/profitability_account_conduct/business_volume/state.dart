import "package:wcas_frontend/core/utils/utils.dart";

class BusinessVolumeState {
  BusinessVolumeState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  BusinessVolumeState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return BusinessVolumeState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
