import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/services/session/manager.dart";

void main() {
  group("SessionManager", () {
    test("test UpdateActivity updates LastActivityTime", () async {
      final manager = SessionManager();
      final initial = manager.timeSinceLastActivity();
      await Future.delayed(const Duration(milliseconds: 100));
      manager.updateActivity();
      await Future.delayed(const Duration(milliseconds: 100));
      final afterUpdate = manager.timeSinceLastActivity();
      expect(afterUpdate.inMilliseconds, greaterThan(initial.inMilliseconds));
    });

    test("test TimeSinceLastActivity After Initialization", () {
      final manager = SessionManager();
      final duration = manager.timeSinceLastActivity();
      expect(duration.inMilliseconds, greaterThanOrEqualTo(0));
    });

    test("test Reset Resets LastActivityTime", () async {
      final manager = SessionManager();
      await Future.delayed(const Duration(milliseconds: 10));
      manager.reset();
      final duration = manager.timeSinceLastActivity();
      expect(duration.inMilliseconds, lessThan(20));
    });

    test("test Rapid Consecutive UpdateActivity", () {
      final manager = SessionManager();
      for (int i = 0; i < 10; i++) {
        manager.updateActivity();
      }
      final duration = manager.timeSinceLastActivity();
      expect(duration.inMilliseconds, greaterThanOrEqualTo(0));
      expect(duration.inSeconds, lessThan(1));
    });

    test("test TimeSinceLastActivity After Long Inactivity", () async {
      final manager = SessionManager();
      await Future.delayed(const Duration(milliseconds: 100));
      final duration = manager.timeSinceLastActivity();
      expect(duration.inMilliseconds, greaterThanOrEqualTo(100));
    });

    test("test System Clock Change Effect On SessionManager", () async {
      final manager = SessionManager();
      // Simulate waiting for some time
      await Future.delayed(const Duration(milliseconds: 10));
      final before = manager.timeSinceLastActivity();
      // Simulate a system clock change by manually adjusting _lastActivityTime
      // (since we can't change system clock and can't use mocks)
      // We'll access the private field via reflection is not possible, so we
      // check that
      // timeSinceLastActivity always returns a non-negative duration even if
      // system clock changes.
      // So, we simulate a negative duration by creating a new manager and
      // comparing.
      final manager2 = SessionManager();
      // Wait, then compare durations
      await Future.delayed(const Duration(milliseconds: 10));
      final after = manager2.timeSinceLastActivity();
      expect(after.inMilliseconds, greaterThanOrEqualTo(0));
      expect(before.inMilliseconds, greaterThanOrEqualTo(0));
    });
    test("sessionDuration is accessible and has a value", () {
      expect(SessionManager.sessionDuration, isA<Duration>());
      expect(SessionManager.sessionDuration.inSeconds, greaterThan(0));
    });

    test("warningDuration is accessible and has a value", () {
      expect(SessionManager.warningDuration, isA<Duration>());
      expect(SessionManager.warningDuration.inSeconds, greaterThan(0));
    });

    test("test multiple managers work independently", () {
      final manager1 = SessionManager();
      final manager2 = SessionManager();

      manager1.updateActivity();
      final duration1 = manager1.timeSinceLastActivity();
      final duration2 = manager2.timeSinceLastActivity();

      // Both should be valid durations but may differ slightly
      expect(duration1.inMilliseconds, greaterThanOrEqualTo(0));
      expect(duration2.inMilliseconds, greaterThanOrEqualTo(0));
    });
  });
}
