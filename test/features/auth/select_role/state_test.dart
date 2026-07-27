import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/select_role/state.dart";

void main() {
  group("SelectRoleState", () {
    test("constructor sets loaderStatus and selectRoleStatus", () {
      const state = SelectRoleState(
        loaderStatus: LoadingStatus.loading,
        selectRoleStatus: LoadingStatus.empty,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.selectRoleStatus, LoadingStatus.empty);
    });

    test("constructor uses default selectRoleStatus when not provided", () {
      const state = SelectRoleState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.selectRoleStatus, isNull);
    });

    test("copyWith updates loaderStatus only", () {
      const state = SelectRoleState(
        loaderStatus: LoadingStatus.loading,
        selectRoleStatus: LoadingStatus.empty,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.selectRoleStatus, LoadingStatus.empty);

      // original state should not change
      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.selectRoleStatus, LoadingStatus.empty);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith updates selectRoleStatus only", () {
      const state = SelectRoleState(
        loaderStatus: LoadingStatus.loading,
        selectRoleStatus: LoadingStatus.empty,
      );

      final updatedState = state.copyWith(
        selectRoleStatus: LoadingStatus.loaded,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(updatedState.selectRoleStatus, LoadingStatus.loaded);

      // original state should not change
      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.selectRoleStatus, LoadingStatus.empty);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith updates both loaderStatus and selectRoleStatus", () {
      const state = SelectRoleState(
        loaderStatus: LoadingStatus.loading,
        selectRoleStatus: LoadingStatus.empty,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        selectRoleStatus: LoadingStatus.loaded,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.selectRoleStatus, LoadingStatus.loaded);
    });

    test("copyWith keeps existing values when no values are provided", () {
      const state = SelectRoleState(
        loaderStatus: LoadingStatus.loading,
        selectRoleStatus: LoadingStatus.empty,
      );

      final updatedState = state.copyWith();

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(updatedState.selectRoleStatus, LoadingStatus.empty);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith keeps existing loaderStatus when loaderStatus is null", () {
      const state = SelectRoleState(
        loaderStatus: LoadingStatus.loaded,
        selectRoleStatus: LoadingStatus.empty,
      );

      final updatedState = state.copyWith();

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.selectRoleStatus, LoadingStatus.empty);
    });

    test(
        "copyWith keeps existing selectRoleStatus when selectRoleStatus is null",
        () {
      const state = SelectRoleState(
        loaderStatus: LoadingStatus.loading,
      );

      final updatedState = state.copyWith();

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(updatedState.selectRoleStatus, isNull);
    });

    test("copyWith supports nullable selectRoleStatus existing value", () {
      const state = SelectRoleState(
        loaderStatus: LoadingStatus.loading,
      );

      final updatedState = state.copyWith();

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(updatedState.selectRoleStatus, isNull);
    });
  });
}
