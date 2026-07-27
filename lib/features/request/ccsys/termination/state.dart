import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the termination feature.
///
/// Manages the loading status and button interaction state
/// during the termination process.
class TerminationState {
  /// Creates a [TerminationState] instance.
  ///
  /// The [loaderStatus] defines the overall loading state
  /// of the termination process.
  const TerminationState({
    required this.loaderStatus,
    this.isButtonLoading = false,
  });

  /// Defines the overall loading status of the termination process.
  final LoadingStatus loaderStatus;

  /// Indicates whether the action button is currently in a loading state.
  final bool isButtonLoading;

  /// Creates a new instance of [TerminationState] with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  TerminationState copyWith({
    LoadingStatus? loaderStatus,
    bool? isButtonLoading,
  }) {
    return TerminationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
    );
  }
}
