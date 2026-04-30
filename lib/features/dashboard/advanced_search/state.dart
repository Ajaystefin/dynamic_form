import "package:wcas_frontend/core/utils/utils.dart";

class AdvancedSearchState {
  AdvancedSearchState({
    required this.loaderStatus,
    this.fieldLoader = false,
    this.tableloader = LoadingStatus.empty,
    this.appRefIndex,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  bool fieldLoader = false;
  LoadingStatus tableloader = LoadingStatus.empty;
  int? appRefIndex = -1;

  AdvancedSearchState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableloader,
    bool? fieldLoader,
    int? appRefIndex,
  }) {
    return AdvancedSearchState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableloader: tableloader ?? this.tableloader,
      fieldLoader: fieldLoader ?? this.fieldLoader,
      appRefIndex: appRefIndex ?? this.appRefIndex,
    );
  }
}
