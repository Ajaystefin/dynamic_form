import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/splash/state.dart";

void main() {
  group("SplashState Tests", () {
    test("Initial state uses provided loaderStatus", () {
      final state = SplashState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith updates loaderStatus", () {
      final state = SplashState(loaderStatus: LoadingStatus.loaded);

      final newState = state.copyWith(loaderStatus: LoadingStatus.loading);

      expect(newState.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith without arguments keeps current loaderStatus", () {
      final state = SplashState(loaderStatus: LoadingStatus.loaded);

      final newState = state.copyWith();

      expect(newState.loaderStatus, LoadingStatus.loaded);
    });
  });
}
