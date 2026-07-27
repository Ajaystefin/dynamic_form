import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Risk Rating feature.
///
/// Manages overall loading status and loading states
/// for external table data and refresh operations.
class RiskRatingState {
  /// Creates an instance of [RiskRatingState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// [externalTableStatus] represents the loading status of
  /// external table data, and [refreshLoader] indicates
  /// the loading state of refresh actions.
  RiskRatingState({
    required this.loaderStatus,
    this.externalTableStatus,
    this.refreshLoader,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of external table data.
  LoadingStatus? externalTableStatus = LoadingStatus.loaded;

  /// Represents the loading status of refresh operations.
  LoadingStatus? refreshLoader = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  RiskRatingState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? externalTableStatus,
    LoadingStatus? refreshLoader,
  }) {
    return RiskRatingState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      externalTableStatus: externalTableStatus ?? this.externalTableStatus,
      refreshLoader: refreshLoader ?? this.refreshLoader,
    );
  }
}
