import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Create Security feature.
///
/// Manages overall loading status and the loading state
/// of the security type selection.
class CreateSecurityState {
  /// Creates an instance of [CreateSecurityState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [securityTypeStatus] represents the loading status
  /// for security type operations.
  CreateSecurityState({
    required this.loaderStatus,
    this.securityTypeStatus = LoadingStatus.empty,
  });

  /// Defines the overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status for security type selection.
  LoadingStatus? securityTypeStatus = LoadingStatus.empty;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  CreateSecurityState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? securityTypeStatus,
  }) {
    return CreateSecurityState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      securityTypeStatus: securityTypeStatus ?? this.securityTypeStatus,
    );
  }
}
