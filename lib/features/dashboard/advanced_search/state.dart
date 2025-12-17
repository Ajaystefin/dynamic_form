import 'package:wcas_frontend/core/utils/utils.dart';

class AdvancedSearchState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus tableloader = LoadingStatus.empty;

  AdvancedSearchState(
      {required this.loaderStatus, this.tableloader = LoadingStatus.empty});

  AdvancedSearchState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableloader,
  }) {
    return AdvancedSearchState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        tableloader: tableloader ?? this.tableloader);
  }
}
