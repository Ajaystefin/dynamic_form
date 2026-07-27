import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Covenants Summary screen.
///
/// Manages overall loading status and the loading state
/// of the covenants summary section.
class CovenantsSummaryState {
  /// Creates an instance of [CovenantsSummaryState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [covenantsSummaryLoader] represents the loading status
  /// for the covenants summary data.
  CovenantsSummaryState({
    required this.loaderStatus,
    this.covenantsSummaryLoader,
  });

  /// Defines the overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the covenants summary section.
  LoadingStatus? covenantsSummaryLoader = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  CovenantsSummaryState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? covenantsSummaryLoader,
  }) {
    return CovenantsSummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      covenantsSummaryLoader:
          covenantsSummaryLoader ?? this.covenantsSummaryLoader,
    );
  }
}
