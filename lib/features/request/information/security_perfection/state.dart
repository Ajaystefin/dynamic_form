import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Security Perfection feature.
///
/// Manages loading status, button loading state,
/// and refresh control for UI updates.
class SecurityPerfectionState {
  /// Creates an instance of [SecurityPerfectionState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// [isButtonLoading] indicates whether the action button is loading,
  /// and [refreshKey] is used to trigger UI refresh.
  const SecurityPerfectionState({
    required this.loaderStatus,
    this.isButtonLoading = false,
    this.refreshKey = 0,
  });

  /// Defines the overall loading status of the feature.
  final LoadingStatus loaderStatus;

  /// Indicates whether the action button is in a loading state.
  final bool isButtonLoading;

  /// Used as a key to trigger UI refresh or rebuild.
  final int refreshKey;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  SecurityPerfectionState copyWith({
    LoadingStatus? loaderStatus,
    bool? isButtonLoading,
    int? refreshKey,
  }) {
    return SecurityPerfectionState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
      refreshKey: refreshKey ?? this.refreshKey,
    );
  }
}
