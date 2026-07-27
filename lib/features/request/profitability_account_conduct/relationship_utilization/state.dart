import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Relationship Utilization feature.
///
/// Manages overall loading status and turnover-related loading state.
class RelationshipUtilizationState {
  /// Creates an instance of [RelationshipUtilizationState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [turnOverStatus] represents the loading status
  /// for turnover-related operations.
  RelationshipUtilizationState({
    required this.loaderStatus,
    this.turnOverStatus = LoadingStatus.loaded,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of turnover-related data or operations.
  LoadingStatus turnOverStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  RelationshipUtilizationState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? turnOverStatus,
  }) {
    return RelationshipUtilizationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      turnOverStatus: turnOverStatus ?? this.turnOverStatus,
    );
  }
}
