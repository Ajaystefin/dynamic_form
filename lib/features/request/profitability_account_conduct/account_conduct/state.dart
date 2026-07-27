import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Account Conduct feature.
///
/// Manages the loading status during account conduct operations.
class AccountConductState {
  /// Creates an instance of [AccountConductState].
  ///
  /// The [loaderStatus] defines the current loading state.
  const AccountConductState({
    required this.loaderStatus,
  });

  /// Defines the current loading status of the feature.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  AccountConductState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return AccountConductState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
