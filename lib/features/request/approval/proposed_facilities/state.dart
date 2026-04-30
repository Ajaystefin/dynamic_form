import "package:wcas_frontend/core/utils/utils.dart";

class ProposedFacilitiesState {
  ProposedFacilitiesState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  ProposedFacilitiesState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ProposedFacilitiesState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
