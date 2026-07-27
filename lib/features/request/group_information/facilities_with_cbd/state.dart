import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Facilities with CBD feature.
///
/// Manages the loading status during facilities retrieval
/// or processing with CBD integration.
class FacilitiesWithCbdState {
  /// Creates an instance of [FacilitiesWithCbdState].
  ///
  /// The [loaderStatus] defines the overall loading state.
  FacilitiesWithCbdState({
    required this.loaderStatus,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loading;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  FacilitiesWithCbdState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return FacilitiesWithCbdState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
