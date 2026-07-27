import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Business Volume feature.
///
/// Manages the loading status during business volume operations.
class BusinessVolumeState {
  /// Creates an instance of [BusinessVolumeState].
  ///
  /// The [loaderStatus] defines the current loading state.
  const BusinessVolumeState({
    required this.loaderStatus,
  });

  /// Defines the current loading status of the feature.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  BusinessVolumeState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return BusinessVolumeState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
