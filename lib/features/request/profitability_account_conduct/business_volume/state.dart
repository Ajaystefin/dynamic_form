import 'package:wcas_frontend/core/utils/utils.dart';

class BusinessVolumeState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  BusinessVolumeState({
    required this.loaderStatus,
  });

  BusinessVolumeState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return BusinessVolumeState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
