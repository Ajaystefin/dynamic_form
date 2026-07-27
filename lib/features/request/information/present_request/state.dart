import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Present Request feature.
///
/// Manages the overall loading status and button loading
/// state during request presentation.
class PresentRequestState {
  /// Creates an instance of [PresentRequestState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [isButtonLoading] indicates whether the action button is loading.
  PresentRequestState({
    required this.loaderStatus,
    this.isButtonLoading = false,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Indicates whether the button is in a loading state.
  final bool isButtonLoading;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  PresentRequestState copyWith({
    LoadingStatus? loaderStatus,
    bool? isButtonLoading,
  }) {
    return PresentRequestState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
    );
  }
}
