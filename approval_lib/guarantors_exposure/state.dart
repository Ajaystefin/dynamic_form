import 'package:wcas_frontend/core/utils/utils.dart';

class GuarantorsExposureState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  GuarantorsExposureState({
    required this.loaderStatus,
  });

  GuarantorsExposureState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return GuarantorsExposureState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
