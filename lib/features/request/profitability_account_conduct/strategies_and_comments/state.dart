import 'package:wcas_frontend/core/utils/utils.dart';

class StrategiesAndCommentsState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  StrategiesAndCommentsState({
    required this.loaderStatus,
  });

  StrategiesAndCommentsState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return StrategiesAndCommentsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
