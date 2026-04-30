import "package:wcas_frontend/core/utils/utils.dart";

class ClosedRequestsState {
  ClosedRequestsState({
    required this.loaderStatus,
    this.tableLoader = LoadingStatus.empty,
    this.appRefIndex,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus tableLoader = LoadingStatus.empty;
  int? appRefIndex = -1;

  ClosedRequestsState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
    int? appRefIndex,
  }) {
    return ClosedRequestsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoader: tableLoader ?? this.tableLoader,
      appRefIndex: appRefIndex ?? this.appRefIndex,
    );
  }
}
