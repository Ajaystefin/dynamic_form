import "package:wcas_frontend/core/utils/utils.dart";

class ConditionsSummaryState {
  ConditionsSummaryState({
    required this.loaderStatus,
    this.conditionSummaryLoader,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? conditionSummaryLoader = LoadingStatus.loaded;

  ConditionsSummaryState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? conditionSummaryLoader,
  }) {
    return ConditionsSummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      conditionSummaryLoader:
          conditionSummaryLoader ?? this.conditionSummaryLoader,
    );
  }
}
