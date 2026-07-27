import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Strategies and Comments feature.
///
/// Manages the loading status during strategies and comments operations.
class StrategiesAndCommentsState {
  /// Creates an instance of [StrategiesAndCommentsState].
  ///
  /// The [loaderStatus] defines the current loading state.
  const StrategiesAndCommentsState({
    required this.loaderStatus,
  });

  /// Defines the current loading status of the feature.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  StrategiesAndCommentsState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return StrategiesAndCommentsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
