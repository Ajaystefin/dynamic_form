import 'package:wcas_frontend/core/utils/utils.dart';

class CovenantsSummaryState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? covenantsSummaryLoader = LoadingStatus.loaded;

  CovenantsSummaryState({
    required this.loaderStatus,
    this.covenantsSummaryLoader,
  });

  CovenantsSummaryState copyWith(
      {LoadingStatus? loaderStatus, LoadingStatus? covenantsSummaryLoader}) {
    return CovenantsSummaryState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        covenantsSummaryLoader:
            covenantsSummaryLoader ?? this.covenantsSummaryLoader);
  }
}

