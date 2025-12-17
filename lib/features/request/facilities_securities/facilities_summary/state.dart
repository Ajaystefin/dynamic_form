import 'package:wcas_frontend/core/utils/utils.dart';

class FacilitiesSummaryState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? tableLoaderStatus = LoadingStatus.loaded;
  FacilitiesSummaryState({
    required this.loaderStatus,
    this.tableLoaderStatus,
  });

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
