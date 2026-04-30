import "package:wcas_frontend/core/utils/utils.dart";

class FacilitySecurityLinkageState {
  FacilitySecurityLinkageState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  FacilitySecurityLinkageState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return FacilitySecurityLinkageState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
