import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/warning_dialog.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/session/manager.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';

enum SessionStatus { active, inactive, loggedOut }

class SessionState {
  final int? secondsRemaining;
  final int? minuteRemaining;
  final int? idleMinute;
  SessionState({
    this.secondsRemaining,
    this.minuteRemaining,
    this.idleMinute,
  });
}

class SessionCubit extends Cubit<SessionState> {
  static final _singleton = SessionCubit();
  static SessionCubit get instance => _singleton;

  late SessionManager _sessionManager;
  Timer? _checkTimer;
  Timer? _autoLogoutTimer;
  SessionStatus status = SessionStatus.active;

  SessionCubit() : super(SessionState()) {
    _sessionManager = SessionManager();
  }

  /// Starts a timer that checks every second if the user has been
  /// inactive for more than [SessionManager.sessionDuration]. If so, it logs
  /// the user out. If the user has been inactive for more than
  /// [SessionManager.sessionDuration] but less than
  /// [SessionManager.sessionDuration] + [SessionManager.warningDuration], it
  /// shows a warning dialog and starts a countdown timer until the user is
  /// logged out.
  void startSession({BuildContext? mockContext}) {
    status = SessionStatus.active;
    if (_checkTimer?.isActive ?? false) return; // avoid multiple timers
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final since = _sessionManager.timeSinceLastActivity();
      if (since >
          SessionManager.sessionDuration + SessionManager.warningDuration) {
        logout();

        _autoLogoutTimer?.cancel();
      } else if (since > SessionManager.sessionDuration) {
        if (status != SessionStatus.inactive) {
          status = SessionStatus.inactive;
          startAutoLogoutCountdown();
          showWarningDialog(mockContext: mockContext);
        }
      }
    });
  }

  /// Cancels any existing auto logout timer and starts a new one that counts
  /// down from [SessionManager.warningDuration] and logs the user out when
  /// it reaches 0. While the countdown is running, it emits a state with the
  /// remaining seconds.
  void startAutoLogoutCountdown() {
    _autoLogoutTimer?.cancel();
    int totalSeconds = SessionManager.warningDuration.inSeconds;
    int idleTime = SessionManager.sessionDuration.inMinutes;
    emit(SessionState(
      secondsRemaining: totalSeconds % 60,
      minuteRemaining: totalSeconds ~/ 60,
      idleMinute: idleTime,
    ));
    _autoLogoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      totalSeconds--;

      if (totalSeconds <= 0) {
        timer.cancel();
        AuthRepository.instance.logout();
      } else {
        emit(SessionState(
          secondsRemaining: totalSeconds % 60,
          minuteRemaining: totalSeconds ~/ 60,
          idleMinute: idleTime,
        ));
      }
    });
  }

  /// Call this whenever the user interacts with the app. It resets the session
  /// inactivity timer and cancels any auto logout timer that may have been
  /// started.
  void userInteracted() {
    _sessionManager.updateActivity();
    status = SessionStatus.active;
    _autoLogoutTimer?.cancel();
  }

  void showWarningDialog({BuildContext? mockContext}) {
    DialogHelper.showCustomDialog(
      barrierDismissible: false,
      title: 'common.session.gracePeriodPopupTitle'.tr(),
      content: const SessionWarningDialog(),
      width: 500.w,
      context: Globals.navigatorKey.currentContext ?? mockContext!,
    );
  }

  void stopSession() {
    _checkTimer?.cancel();
    _autoLogoutTimer?.cancel();
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
}
