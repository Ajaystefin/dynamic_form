import 'package:wcas_frontend/core/utils/utils.dart';

class RequestForLimitReleaseState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RequestForLimitReleaseState({
    required this.loaderStatus,
  });

  RequestForLimitReleaseState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RequestForLimitReleaseState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
