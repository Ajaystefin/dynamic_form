import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/splash/state.dart";

void main() {
  group("SplashState Tests", () {
    /// Constructor tests
    test("Initial state uses provided loaderStatus", () {
      const state = SplashState(loaderStatus: LoadingStatus.loading);

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    /// copyWith tests
    test("copyWith updates loaderStatus", () {
      const state = SplashState(loaderStatus: LoadingStatus.loaded);

      final newState = state.copyWith(loaderStatus: LoadingStatus.loading);

      expect(newState.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith without arguments keeps current loaderStatus", () {
      const state = SplashState(loaderStatus: LoadingStatus.loaded);

      final newState = state.copyWith();

      expect(newState.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith returns a new instance", () {
      const state = SplashState(loaderStatus: LoadingStatus.loaded);

      final newState = state.copyWith();

      expect(newState, isNot(same(state)));
    });

    test("copyWith with same value keeps loaderStatus unchanged", () {
      const state = SplashState(loaderStatus: LoadingStatus.loaded);

      final newState = state.copyWith(loaderStatus: LoadingStatus.loaded);

      expect(newState.loaderStatus, LoadingStatus.loaded);
    });

    /// Equality tests
    test("Two SplashState objects are equal when loaderStatus is same", () {
      const state1 = SplashState(loaderStatus: LoadingStatus.loaded);
      const state2 = SplashState(loaderStatus: LoadingStatus.loaded);

      expect(state1, equals(state2));
    });

    test("Two SplashState objects are NOT equal when loaderStatus differs", () {
      const state1 = SplashState(loaderStatus: LoadingStatus.loaded);
      const state2 = SplashState(loaderStatus: LoadingStatus.loading);

      expect(state1, isNot(equals(state2)));
    });

    test("Equality works with identical object", () {
      const state = SplashState(loaderStatus: LoadingStatus.loaded);

      expect(state, equals(state));
    });

    /// hashCode tests
    test("hashCode is same for equal objects", () {
      const state1 = SplashState(loaderStatus: LoadingStatus.loaded);
      const state2 = SplashState(loaderStatus: LoadingStatus.loaded);

      expect(state1.hashCode, state2.hashCode);
    });

    test("hashCode differs for different objects", () {
      const state1 = SplashState(loaderStatus: LoadingStatus.loaded);
      const state2 = SplashState(loaderStatus: LoadingStatus.loading);

      expect(state1.hashCode, isNot(state2.hashCode));
    });
  });
}
