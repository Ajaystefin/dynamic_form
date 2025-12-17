import 'package:wcas_frontend/core/utils/utils.dart';

class ConditionsSummaryState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? conditionSummaryLoader = LoadingStatus.loaded;

  ConditionsSummaryState({
    required this.loaderStatus,
    this.conditionSummaryLoader,
  });

  ConditionsSummaryState copyWith(
      {LoadingStatus? loaderStatus, LoadingStatus? conditionSummaryLoader}) {
    return ConditionsSummaryState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        conditionSummaryLoader:
            conditionSummaryLoader ?? this.conditionSummaryLoader);
  }
}
