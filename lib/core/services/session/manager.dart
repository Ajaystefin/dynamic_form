import "package:wcas_frontend/core/env_config.dart";

/// Session Manager
///
/// Tracks user activity and manages session timeout calculations
/// based on the configured inactivity and grace period durations.
class SessionManager {
  /// Duration before a session is considered inactive.
  static Duration sessionDuration =
      Duration(seconds: EnvConfig.sessionTimeoutSeconds);

  /// Additional grace period before session expiration.
  static Duration warningDuration = Duration(
    seconds: EnvConfig.sessionGracePeriodSeconds,
  );

  DateTime _lastActivityTime = DateTime.now();

  /// Updates the last recorded user activity time.
  void updateActivity() {
    _lastActivityTime = DateTime.now();
  }

  /// Returns the elapsed time since the last user activity.
  Duration timeSinceLastActivity() {
    return DateTime.now().difference(_lastActivityTime);
  }

  /// Resets the session activity timer.
  void reset() {
    updateActivity();
  }
}
