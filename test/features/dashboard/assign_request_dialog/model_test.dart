import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/assign_request_dialog/model.dart";
import "package:wcas_frontend/features/dashboard/assign_request_dialog/state.dart";
import "package:wcas_frontend/repositories/dashboard_repository.dart";

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  group("AssignRequestDialogViewModel", () {
    late AssignRequestDialogViewModel viewModel;

    setUp(() {
      viewModel = AssignRequestDialogViewModel();
    });

    test("initial state is correct", () {
      expect(viewModel.state, isA<AssignRequestDialogState>());
    });
  });

  group("AssignRequestDialogState", () {
    test("constructor creates state with correct loaderStatus", () {
      final state =
          AssignRequestDialogState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith returns a new state with updated loaderStatus", () {
      final originalState =
          AssignRequestDialogState(loaderStatus: LoadingStatus.loading);
      final newState =
          originalState.copyWith(loaderStatus: LoadingStatus.loaded);
      expect(newState.loaderStatus, LoadingStatus.loaded);
      expect(originalState.loaderStatus, LoadingStatus.loading);
      expect(newState, isNot(equals(originalState)));
    });

    test("copyWith returns a new state with same loaderStatus if not provided",
        () {
      final originalState =
          AssignRequestDialogState(loaderStatus: LoadingStatus.loading);
      final newState = originalState.copyWith();
      expect(newState.loaderStatus, LoadingStatus.loading);
      expect(newState, isNot(equals(originalState)));
    });

    test("inequality holds for two states with different loaderStatus", () {
      final state1 =
          AssignRequestDialogState(loaderStatus: LoadingStatus.loading);
      final state2 =
          AssignRequestDialogState(loaderStatus: LoadingStatus.loaded);
      expect(state1, isNot(equals(state2)));
      expect(state1.hashCode, isNot(equals(state2.hashCode)));
    });
  });
}
