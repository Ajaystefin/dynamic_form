import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions_dialog/state.dart";

void main() {
  group("SubLimitConditionsState", () {
    test("constructor sets loaderStatus", () {
      const state = SubLimitConditionsState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith updates loaderStatus when value is provided", () {
      const state = SubLimitConditionsState(
        loaderStatus: LoadingStatus.loading,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(state.loaderStatus, LoadingStatus.loading);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith keeps existing loaderStatus when value is null", () {
      const state = SubLimitConditionsState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updatedState = state.copyWith();

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith supports empty loaderStatus", () {
      const state = SubLimitConditionsState(
        loaderStatus: LoadingStatus.loading,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.empty,
      );

      expect(updatedState.loaderStatus, LoadingStatus.empty);
    });

    test("copyWith supports error loaderStatus", () {
      const state = SubLimitConditionsState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.error,
      );

      expect(updatedState.loaderStatus, LoadingStatus.error);
    });
  });
}
