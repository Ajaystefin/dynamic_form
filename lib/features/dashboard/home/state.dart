import 'package:wcas_frontend/core/utils/utils.dart';

class HomeState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? tableLoader = LoadingStatus.loaded;
  LoadingStatus? graphLoader = LoadingStatus.loaded;
  bool? refreshLoader = false;
  LoadingStatus? requestLoader = LoadingStatus.loaded;
  int? appRefIndex = -1;

  HomeState({
    required this.loaderStatus,
    this.tableLoader,
    this.graphLoader,
    this.refreshLoader,
    this.appRefIndex,
  });

  HomeState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
    LoadingStatus? graphLoader,
    bool? refreshLoader,
    int? appRefIndex,
  }) {
    return HomeState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoader: tableLoader ?? this.tableLoader,
      graphLoader: graphLoader ?? this.graphLoader,
      appRefIndex: appRefIndex ?? this.appRefIndex,
      refreshLoader: refreshLoader ?? this.refreshLoader,
    );
  }
}
