import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/state.dart";

void main() {
  group("ListOutputFormsDialogState", () {
    test("constructor should set loaderStatus with provided value", () {
      const state = ListOutputFormsDialogState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("constructor should support loaded status", () {
      const state = ListOutputFormsDialogState(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(state.loaderStatus, LoadingStatus.loaded);
    });

    test("constructor should support error status", () {
      const state = ListOutputFormsDialogState(
        loaderStatus: LoadingStatus.error,
      );

      expect(state.loaderStatus, LoadingStatus.error);
    });

    test("copyWith should update loaderStatus when value is provided", () {
      const state = ListOutputFormsDialogState(
        loaderStatus: LoadingStatus.loading,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith should keep existing loaderStatus when value is null", () {
      const state = ListOutputFormsDialogState(
        loaderStatus: LoadingStatus.error,
      );

      final updatedState = state.copyWith();

      expect(updatedState.loaderStatus, LoadingStatus.error);
    });

    test("copyWith should return new instance", () {
      const state = ListOutputFormsDialogState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updatedState = state.copyWith();

      expect(updatedState, isA<ListOutputFormsDialogState>());
      expect(identical(state, updatedState), isFalse);
    });
  });
}
