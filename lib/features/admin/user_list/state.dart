import 'package:wcas_frontend/core/utils/utils.dart';

class UserListState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? tableLoader = LoadingStatus.empty;

  UserListState({required this.loaderStatus, this.tableLoader});

  UserListState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
  }) {
    return UserListState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        tableLoader: tableLoader ?? LoadingStatus.empty);
  }
}
