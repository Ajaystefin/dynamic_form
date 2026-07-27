import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Conditions Summary screen.
///
/// Manages overall loading status and condition summary loading state.
class ConditionsSummaryState {
  /// Creates an instance of [ConditionsSummaryState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [conditionSummaryLoader] represents the loading status
  /// for the condition summary section.
  ConditionsSummaryState({
    required this.loaderStatus,
    this.conditionSummaryLoader,
  });

  /// Defines the overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the condition summary section.
  LoadingStatus? conditionSummaryLoader = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
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
