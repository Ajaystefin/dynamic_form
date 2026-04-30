import "package:wcas_frontend/core/utils/utils.dart";

class RelationshipProfitabilitySummaryState {
  RelationshipProfitabilitySummaryState({
    required this.loaderStatus,
    this.tableLoaderStatus = LoadingStatus.loaded,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus tableLoaderStatus = LoadingStatus.loaded;

  RelationshipProfitabilitySummaryState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoaderStatus,
  }) {
    return RelationshipProfitabilitySummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoaderStatus: tableLoaderStatus ?? this.tableLoaderStatus,
    );
  }
}
