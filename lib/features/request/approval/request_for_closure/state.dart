import 'package:wcas_frontend/core/utils/utils.dart';

class RequestForClosureState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RequestForClosureState({
    required this.loaderStatus,
  });

  RequestForClosureState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RequestForClosureState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
