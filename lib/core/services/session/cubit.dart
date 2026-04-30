import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/warning_dialog.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/session/manager.dart";
import "package:wcas_frontend/core/services/session/session_visibility_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

enum SessionStatus { active, inactive, loggedOut }

class SessionState {
  SessionState({
    this.secondsRemaining,
    this.minuteRemaining,
    this.idleMinute,
  });
  final int? secondsRemaining;
  final int? minuteRemaining;
  final int? idleMinute;
}

class SessionCubit extends SafeCubit<SessionState> {
  SessionCubit() : super(SessionState()) {
    _sessionManager = SessionManager();
    _visibilityService = SessionVisibilityService(onVisible: _onTabResumed);
    _visibilityService?.register();
  }
  static final _singleton = SessionCubit();
  static SessionCubit get instance => _singleton;

  late SessionManager _sessionManager;
  Timer? _checkTimer;
  SessionStatus status = SessionStatus.active;
  SessionVisibilityService? _visibilityService;

  void _onTabResumed() {
    if (status == SessionStatus.loggedOut) return;
    if (_checkTimer == null || !_checkTimer!.isActive) return;

    _checkTimer!.cancel();
    _syncState();

    if (status != SessionStatus.loggedOut) {
      _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _syncState();
      });
    }
  }

  void _syncState({BuildContext? mockContext}) {
    if (status == SessionStatus.loggedOut) return;

    final since = _sessionManager.timeSinceLastActivity();
    final totalAllowed =
        SessionManager.sessionDuration + SessionManager.warningDuration;

    if (since >= totalAllowed) {
      logout();
    } else if (since > SessionManager.sessionDuration) {
      if (status != SessionStatus.inactive) {
        status = SessionStatus.inactive;
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
    }
  }

  void startSession({BuildContext? mockContext}) {
    status = SessionStatus.active;
    if (_checkTimer?.isActive ?? false) return; // avoid multiple timers
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncState(mockContext: mockContext);
    });
  }

  /// Records a user interaction (keystroke, tap, pan) and resets the
  /// inactivity clock. This is a no-op when the warning dialog is already
  /// visible ([SessionStatus.inactive]) so that accidental keystrokes cannot
  /// silently freeze the countdown without dismissing the dialog.
  void userInteracted() {
    if (status == SessionStatus.inactive) return;
    _sessionManager.updateActivity();
    status = SessionStatus.active;
  }

  /// Called exclusively by the "Continue Session" button on the warning
  /// dialog. Unconditionally resets the inactivity clock and restores the
  /// session to [SessionStatus.active], bypassing the [SessionStatus.inactive]
  /// guard in [userInteracted] that would otherwise block the reset.
  void continueSession() {
    _sessionManager.updateActivity();
    status = SessionStatus.active;
  }

  void showWarningDialog({BuildContext? mockContext}) {
    DialogHelper.showCustomDialog(
      barrierDismissible: false,
      title: "common.session.gracePeriodPopupTitle".tr(),
      content: const SessionWarningDialog(),
      width: 500.w,
      context: Globals.navigatorKey.currentContext ?? mockContext!,
    );
  }

  void stopSession() {
    _checkTimer?.cancel();
  }

  Future<void> logout() async {
    try {
      if (status == SessionStatus.loggedOut) return;
      status = SessionStatus.loggedOut;
      await AuthRepository.instance.logout();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  @override
  Future<void> close() {
    _visibilityService?.unregister();
    return super.close();
  }
}
