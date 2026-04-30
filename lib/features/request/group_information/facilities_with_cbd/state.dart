import "package:wcas_frontend/core/utils/utils.dart";

class FacilitiesWithCbdState {
  FacilitiesWithCbdState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loading;

  FacilitiesWithCbdState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return FacilitiesWithCbdState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
