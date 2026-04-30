import "package:wcas_frontend/core/utils/utils.dart";

class FeeStructureState {
  FeeStructureState({
    required this.loaderStatus,
    this.tableLoader = LoadingStatus.loading,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus tableLoader = LoadingStatus.loaded;

  FeeStructureState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
  }) {
    return FeeStructureState(
      tableLoader: tableLoader ?? this.tableLoader,
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
