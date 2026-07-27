import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Termination feature.
///
/// Manages the loading status and button interaction state
/// during the termination process.
class TerminationState {
  /// Creates an instance of [TerminationState].
  ///
  /// The [loaderStatus] defines the current loading state,
  /// and [isButtonLoading] indicates whether the action button is loading.
  const TerminationState({
    required this.loaderStatus,
    this.isButtonLoading = false,
  });

  /// Defines the current loading status of the termination process.
  final LoadingStatus loaderStatus;

  /// Indicates whether the action button is in a loading state.
  final bool isButtonLoading;

  /// Creates a copy of this state with updated values.
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
