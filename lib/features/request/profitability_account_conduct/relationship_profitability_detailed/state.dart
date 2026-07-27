import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Relationship Profitability Detailed feature.
///
/// Manages the loading status during detailed profitability operations.
class RelationshipProfitabilityDetailedState {
  /// Creates an instance of [RelationshipProfitabilityDetailedState].
  ///
  /// The [loaderStatus] defines the current loading state.
  const RelationshipProfitabilityDetailedState({
    required this.loaderStatus,
  });

  /// Defines the current loading status of the feature.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  RelationshipProfitabilityDetailedState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RelationshipProfitabilityDetailedState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
