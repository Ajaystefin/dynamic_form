import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/search_project/state.dart";

void main() {
  group("SearchProjectState", () {
    test("initial values are set correctly", () {
      final state = SearchProjectState();

      expect(state.loaderStatus, LoadingStatus.loaded);
      expect(state.showCustomerTypeField, false);
      expect(state.showDataTable, false);
    });

    test("custom constructor values are assigned correctly", () {
      final state = SearchProjectState(
        loaderStatus: LoadingStatus.loading,
        showCustomerTypeField: true,
        showDataTable: true,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(state.showCustomerTypeField, true);
      expect(state.showDataTable, true);
    });

    test("copyWith updates all fields when provided", () {
      final state = SearchProjectState();

      final updated = state.copyWith(
        loaderStatus: LoadingStatus.loading,
        showCustomerTypeField: true,
        showDataTable: true,
      );

      expect(updated.loaderStatus, LoadingStatus.loading);
      expect(updated.showCustomerTypeField, true);
      expect(updated.showDataTable, true);
    });

    test("copyWith handles null and non-null combinations correctly", () {
      final state = SearchProjectState(
        loaderStatus: LoadingStatus.loading,
        showCustomerTypeField: true,
      );

      final updated = state.copyWith(
        showCustomerTypeField: false,
      );

      expect(updated.loaderStatus, LoadingStatus.loading);
      expect(updated.showCustomerTypeField, false);
      expect(updated.showDataTable, false);
    });

    test("copyWith keeps existing values when null passed", () {
      final state = SearchProjectState(
        loaderStatus: LoadingStatus.loading,
        showCustomerTypeField: true,
      );

      final updated = state.copyWith();

      expect(updated.loaderStatus, LoadingStatus.loading);
      expect(updated.showCustomerTypeField, true);
      expect(updated.showDataTable, false);
    });

    test("copyWith partially updates fields", () {
      final state = SearchProjectState();

      final updated = state.copyWith(
        showCustomerTypeField: true,
      );

      expect(updated.loaderStatus, LoadingStatus.loaded);
      expect(updated.showCustomerTypeField, true);
      expect(updated.showDataTable, false);
    });

    test("copyWith returns a new instance", () {
      final state = SearchProjectState();

      final updated = state.copyWith(
        showDataTable: true,
      );

      expect(identical(state, updated), false);
    });
  });
}
