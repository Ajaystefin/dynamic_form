import 'package:wcas_frontend/core/utils/utils.dart';

class FeeStructureState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus tableLoader = LoadingStatus.loaded;

  FeeStructureState(
      {required this.loaderStatus, this.tableLoader = LoadingStatus.loading});

  FeeStructureState copyWith(
      {LoadingStatus? loaderStatus, LoadingStatus? tableLoader}) {
    return FeeStructureState(
      tableLoader: tableLoader ?? this.tableLoader,
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
