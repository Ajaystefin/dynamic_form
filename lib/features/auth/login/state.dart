import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the login screen.
///
/// Holds information related to loading status and application version.
class LoginState {
  /// Creates an instance of [LoginState].
  ///
  /// Requires the current [loaderStatus] and optionally accepts
  /// the application version.
  const LoginState({
    required this.loaderStatus,
    this.appVersion = "",
  });

  /// Indicates the current loading status of the login process.
  final LoadingStatus loaderStatus;

  /// Represents the current application version displayed on the login screen.
  final String appVersion;

  /// Creates a copy of this state with updated values.
  ///
  /// If provided, [loaderStatus] and [appVersion] will replace the current values.
  /// Otherwise, existing values are retained.
  LoginState copyWith({
    LoadingStatus? loaderStatus,
    String? appVersion,
  }) {
    return LoginState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
