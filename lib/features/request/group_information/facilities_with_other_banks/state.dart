import 'package:wcas_frontend/core/utils/utils.dart';

class FacilitiesWithOtherBanksState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus tableLoader = LoadingStatus.empty;

  FacilitiesWithOtherBanksState({
    required this.loaderStatus,
    this.tableLoader = LoadingStatus.empty,
  });

  FacilitiesWithOtherBanksState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
  }) {
    return FacilitiesWithOtherBanksState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoader: tableLoader ?? this.tableLoader,
    );
  }
}
