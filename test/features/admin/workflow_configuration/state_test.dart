import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/state.dart";

void main() {
  group("WorkflowConfigurationState", () {
    test("constructor sets loaderStatus and default tableLoaderStatus", () {
      final state = WorkflowConfigurationState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);

      // Constructor default value should be loaded.
      expect(state.tableLoaderStatus, LoadingStatus.loaded);
    });

    test("constructor sets custom tableLoaderStatus when provided", () {
      final state = WorkflowConfigurationState(
        loaderStatus: LoadingStatus.loaded,
        tableLoaderStatus: LoadingStatus.empty,
      );

      expect(state.loaderStatus, LoadingStatus.loaded);
      expect(state.tableLoaderStatus, LoadingStatus.empty);
    });

    test("copyWith updates loaderStatus only", () {
      final state = WorkflowConfigurationState(
        loaderStatus: LoadingStatus.loading,
        tableLoaderStatus: LoadingStatus.empty,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.tableLoaderStatus, LoadingStatus.empty);

      // Original state should remain unchanged.
      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.tableLoaderStatus, LoadingStatus.empty);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith updates tableLoaderStatus only", () {
      final state = WorkflowConfigurationState(
        loaderStatus: LoadingStatus.loading,
        tableLoaderStatus: LoadingStatus.empty,
      );

      final updatedState = state.copyWith(
        tableLoaderStatus: LoadingStatus.loaded,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(updatedState.tableLoaderStatus, LoadingStatus.loaded);

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.tableLoaderStatus, LoadingStatus.empty);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith updates both loaderStatus and tableLoaderStatus", () {
      final state = WorkflowConfigurationState(
        loaderStatus: LoadingStatus.loading,
        tableLoaderStatus: LoadingStatus.empty,
      );

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        tableLoaderStatus: LoadingStatus.loaded,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.tableLoaderStatus, LoadingStatus.loaded);
    });

    test("copyWith keeps existing values when no values are provided", () {
      final state = WorkflowConfigurationState(
        loaderStatus: LoadingStatus.loading,
      );

      final updatedState = state.copyWith();

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(updatedState.tableLoaderStatus, LoadingStatus.loaded);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith keeps existing loaderStatus when loaderStatus is null", () {
      final state = WorkflowConfigurationState(
        loaderStatus: LoadingStatus.loaded,
        tableLoaderStatus: LoadingStatus.empty,
      );

      final updatedState = state.copyWith(
        
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.tableLoaderStatus, LoadingStatus.empty);
    });

    test("copyWith keeps existing tableLoaderStatus when tableLoaderStatus is null", () {
      final state = WorkflowConfigurationState(
        loaderStatus: LoadingStatus.loading,
      );

      final updatedState = state.copyWith(
        
      );

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(updatedState.tableLoaderStatus, LoadingStatus.loaded);
    });
  });
}
