import 'package:wcas_frontend/core/utils/utils.dart';

class RequestForFolState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RequestForFolState({
    required this.loaderStatus,
  });

  RequestForFolState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RequestForFolState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
