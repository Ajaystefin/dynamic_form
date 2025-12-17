import 'package:wcas_frontend/core/utils/utils.dart';

class ClosedRequestsState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus tableLoader = LoadingStatus.empty;

  ClosedRequestsState({
    required this.loaderStatus,
    this.tableLoader = LoadingStatus.empty,
  });

  ClosedRequestsState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
  }) {
    return ClosedRequestsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoader: tableLoader ?? this.tableLoader,
    );
  }
}
