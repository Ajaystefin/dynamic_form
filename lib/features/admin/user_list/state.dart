import "package:wcas_frontend/core/utils/utils.dart";

class UserListState {
  UserListState({required this.loaderStatus, this.tableLoader});
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? tableLoader = LoadingStatus.empty;

  UserListState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
  }) {
    return UserListState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoader: tableLoader ?? LoadingStatus.empty,
    );
  }
}
