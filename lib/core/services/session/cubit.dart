import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/warning_dialog.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/session/manager.dart";
import "package:wcas_frontend/core/services/session/session_visibility_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

/// Session Status
///
/// Represents the current session state.
enum SessionStatus {
  /// Session is active.
  active,

  /// Session is inactive.
  inactive,

  /// User has been logged out.
  loggedOut,
}

/// Session State
///
/// Holds session timing information used for inactivity
/// tracking and session timeout warnings.
class SessionState {
  /// Creates a session state instance.
  SessionState({
    this.secondsRemaining,
    this.minuteRemaining,
    this.idleMinute,
  });

  /// Remaining seconds before session expiration.
  final int? secondsRemaining;

  /// Remaining minutes before session expiration.
  final int? minuteRemaining;

  /// Minutes of user inactivity.
  final int? idleMinute;
}

/// Session Cubit
///
/// Manages user session activity, inactivity tracking,
/// warning notifications, and automatic logout handling.
class SessionCubit extends SafeCubit<SessionState> {
  /// Creates a session cubit and registers visibility listeners.
  SessionCubit() : super(SessionState()) {
    _sessionManager = SessionManager();
    _visibilityService = SessionVisibilityService(onVisible: _onTabResumed);
    _visibilityService?.register();
  }
  static final _singleton = SessionCubit();

  /// Returns the singleton instance.
  static SessionCubit get instance => _singleton;

  late SessionManager _sessionManager;
  Timer? _checkTimer;

  /// Current session status.
  SessionStatus status = SessionStatus.active;
  SessionVisibilityService? _visibilityService;

  void _onTabResumed() {
    if (status == SessionStatus.loggedOut) {
      return;
    }
    if (_checkTimer == null || !_checkTimer!.isActive) {
      return;
    }

    logger.i("Session: tab resumed, re-syncing state");
    _checkTimer!.cancel();
    _syncState();

    if (status != SessionStatus.loggedOut) {
      _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _syncState();
      });
    }
  }

  void _syncState({BuildContext? mockContext}) {
    if (status == SessionStatus.loggedOut) {
      return;
    }

    final since = _sessionManager.timeSinceLastActivity();
    final totalAllowed =
        SessionManager.sessionDuration + SessionManager.warningDuration;

    if (since >= totalAllowed) {
      logger.w(
        "Session: inactivity timeout reached (${since.inSeconds}s since "
        "last activity), logging out",
      );
      logout();
    } else if (since > SessionManager.sessionDuration) {
      if (status != SessionStatus.inactive) {
        status = SessionStatus.inactive;
        logger.w(
          "Session: went inactive after ${since.inSeconds}s, showing "
          "timeout warning (${(totalAllowed - since).inSeconds}s remaining)",
        );
        showWarningDialog(mockContext: mockContext);
      }

      final Duration remaining = totalAllowed - since;
      final int remainingSeconds = remaining.inSeconds;

      final int idleTime = SessionManager.sessionDuration.inMinutes;
      emit(
        SessionState(
          secondsRemaining: remainingSeconds % 60,
          minuteRemaining: remainingSeconds ~/ 60,
          idleMinute: idleTime,
        ),
      );
    } else if (status != SessionStatus.active) {
      status = SessionStatus.active;
      logger.i("Session: activity resumed, status back to active");
    }
  }

  /// Starts session monitoring.
  void startSession({BuildContext? mockContext}) {
    status = SessionStatus.active;
    if (_checkTimer?.isActive ?? false) {
      return; // avoid multiple timers
    }
    logger.i("Session: monitoring started");
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncState(mockContext: mockContext);
    });
  }

  /// Records a user interaction (keystroke, tap, pan) and resets the
  /// inactivity clock. This is a no-op when the warning dialog is already
  /// visible ([SessionStatus.inactive]) so that accidental keystrokes cannot
  /// silently freeze the countdown without dismissing the dialog.
  void userInteracted() {
    if (status == SessionStatus.inactive) {
      return;
    }
    _sessionManager.updateActivity();
    status = SessionStatus.active;
  }

  /// Called exclusively by the "Continue Session" button on the warning
  /// dialog. Unconditionally resets the inactivity clock and restores the
  /// session to [SessionStatus.active], bypassing the [SessionStatus.inactive]
  /// guard in [userInteracted] that would otherwise block the reset.
  void continueSession() {
    logger.i("Session: user continued session from warning dialog");
    _sessionManager.updateActivity();
    status = SessionStatus.active;
  }

  /// Displays the session timeout warning dialog.
  void showWarningDialog({BuildContext? mockContext}) {
    DialogHelper.showCustomDialog(
      barrierDismissible: false,
      title: "common.session.gracePeriodPopupTitle".tr(),
      content: const SessionWarningDialog(),
      width: 500.w,
      context: Globals.navigatorKey.currentContext ?? mockContext!,
    );
  }

  /// Stops session monitoring.
  void stopSession() {
    logger.i("Session: monitoring stopped");
    _checkTimer?.cancel();
  }

  /// Logs out the current user.
  Future<void> logout() async {
    try {
      if (status == SessionStatus.loggedOut) {
        return;
      }
      logger.i("Session: logging out (previous status=$status)");
      status = SessionStatus.loggedOut;
      await AuthRepository.instance.logout();
    } on Object catch (e) {
      logger.e("Session: logout failed: $e");
      AlertManager().showFailureToast(e.toString());
    }
  }

  @override
  Future<void> close() {
    _visibilityService?.unregister();
    return super.close();
  }
}
