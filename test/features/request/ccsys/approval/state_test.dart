import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/approval/state.dart";

void main() {
  group("CcsysApprovalState", () {
    test("creates state with provided loaderStatus", () {
      const state = CcsysApprovalState(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(state.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith updates loaderStatus when value is provided", () {
      const state = CcsysApprovalState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loading,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loaded);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith keeps existing loaderStatus when value is null", () {
      const state = CcsysApprovalState(
        loaderStatus: LoadingStatus.loading,
      );

      final copiedState = state.copyWith();

      expect(copiedState.loaderStatus, LoadingStatus.loading);
      expect(copiedState, isNot(same(state)));
    });
  });
}
