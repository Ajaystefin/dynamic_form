import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Request Information screen.
///
/// Holds loading status and button loading state.
class RequestInformationState {
  /// Creates an instance of [RequestInformationState].
  ///
  /// Requires [loaderStatus] and optionally accepts
  /// button loading state.
  RequestInformationState({
    required this.loaderStatus,
    this.isButtonLoading = false,
  });

  /// Overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Indicates whether the button is in loading state.
  final bool isButtonLoading;

  /// Creates a copy of this state with updated values.
  ///
  /// Only provided values will be replaced,
  /// others will retain existing values.
  RequestInformationState copyWith({
    LoadingStatus? loaderStatus,
    bool? isButtonLoading,
  }) {
    return RequestInformationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
    );
  }
}
