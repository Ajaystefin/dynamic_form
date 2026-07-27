import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/create_project/state.dart";

void main() {
  group("CreateProjectState", () {
    test("creates state with provided loaderStatus and contractStatus", () {
      final state = CreateProjectState(
        loaderStatus: LoadingStatus.loaded,
        contractStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loaded);
      expect(state.contractStatus, LoadingStatus.loading);
    });

    test("creates state with nullable contractStatus as null", () {
      final state = CreateProjectState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.contractStatus, isNull);
    });

    test("copyWith updates loaderStatus when loaderStatus is provided", () {
      final state = CreateProjectState(
        loaderStatus: LoadingStatus.loaded,
        contractStatus: LoadingStatus.loaded,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loading,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(updatedState.contractStatus, LoadingStatus.loaded);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith updates contractStatus when contractStatus is provided", () {
      final state = CreateProjectState(
        loaderStatus: LoadingStatus.loaded,
        contractStatus: LoadingStatus.loaded,
      );

      final updatedState = state.copyWith(
        contractStatus: LoadingStatus.loading,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.contractStatus, LoadingStatus.loading);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith updates both loaderStatus and contractStatus", () {
      final state = CreateProjectState(
        loaderStatus: LoadingStatus.loaded,
        contractStatus: LoadingStatus.loaded,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loading,
        contractStatus: LoadingStatus.loading,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(updatedState.contractStatus, LoadingStatus.loading);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith keeps existing values when no values are provided", () {
      final state = CreateProjectState(
        loaderStatus: LoadingStatus.loading,
        contractStatus: LoadingStatus.loaded,
      );

      final copiedState = state.copyWith();

      expect(copiedState.loaderStatus, LoadingStatus.loading);
      expect(copiedState.contractStatus, LoadingStatus.loaded);
      expect(copiedState, isNot(same(state)));
    });

    test("copyWith keeps null contractStatus when contractStatus is already null",
        () {
      final state = CreateProjectState(
        loaderStatus: LoadingStatus.loaded,
      );

      final copiedState = state.copyWith();

      expect(copiedState.loaderStatus, LoadingStatus.loaded);
      expect(copiedState.contractStatus, isNull);
      expect(copiedState, isNot(same(state)));
    });
  });
}
