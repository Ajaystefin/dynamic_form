import 'package:wcas_frontend/core/env_config.dart';

class SessionManager {
  static Duration sessionDuration =
      Duration(seconds: EnvConfig.sessionTimeoutSeconds);
  static Duration warningDuration = Duration(
    seconds: EnvConfig.sessionGracePeriodSeconds,
  );

  DateTime _lastActivityTime = DateTime.now();

  /// Updates the last activity time to the current time.
  /// This function should be called whenever there is user activity
  /// to ensure the session remains active and does not expire prematurely.
  void updateActivity() {
    _lastActivityTime = DateTime.now();
  }

  /// Returns the duration since the last recorded user activity.
  /// This can be used to determine how long the user has been inactive.
  Duration timeSinceLastActivity() {
    return DateTime.now().difference(_lastActivityTime);
  }

  void reset() {
    updateActivity();
  }
}
