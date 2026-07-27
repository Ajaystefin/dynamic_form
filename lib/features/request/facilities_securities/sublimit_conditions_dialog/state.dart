import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Sub-Limit Conditions feature.
///
/// Manages the loading status during sub-limit condition processing.
class SubLimitConditionsState {
  /// Creates an instance of [SubLimitConditionsState].
  ///
  /// The [loaderStatus] indicates the current loading state.
  const SubLimitConditionsState({
    required this.loaderStatus,
  });

  /// Defines the current loading status of sub-limit conditions.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  SubLimitConditionsState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return SubLimitConditionsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
