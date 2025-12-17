import 'package:wcas_frontend/core/utils/utils.dart';

class FacilitySecurityLinkageState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  FacilitySecurityLinkageState({
    required this.loaderStatus,
  });

  FacilitySecurityLinkageState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return FacilitySecurityLinkageState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
