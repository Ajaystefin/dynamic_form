import 'package:wcas_frontend/core/utils/utils.dart';

class RequestInformationState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RequestInformationState({
    required this.loaderStatus,
  });

  RequestInformationState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RequestInformationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
