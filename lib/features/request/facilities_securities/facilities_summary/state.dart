import "package:wcas_frontend/core/utils/utils.dart";

class FacilitiesSummaryState {
  FacilitiesSummaryState({
    required this.loaderStatus,
    this.tableLoaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? tableLoaderStatus = LoadingStatus.loaded;

  FacilitiesSummaryState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoaderStatus,
  }) {
    return FacilitiesSummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoaderStatus: tableLoaderStatus ?? this.tableLoaderStatus,
    );
  }
}
