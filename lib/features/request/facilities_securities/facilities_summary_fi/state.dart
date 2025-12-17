import 'package:wcas_frontend/core/utils/utils.dart';

class FacilitiesSummaryFiState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? tableLoaderStatus = LoadingStatus.loaded;
  FacilitiesSummaryFiState({
    required this.loaderStatus,
    this.tableLoaderStatus,
  });

  FacilitiesSummaryFiState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoaderStatus,
  }) {
    return FacilitiesSummaryFiState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoaderStatus: tableLoaderStatus ?? this.tableLoaderStatus,
    );
  }
}
