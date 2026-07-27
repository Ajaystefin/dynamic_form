import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/recommend_for_current_approval/state.dart";

void main() {
  group("RecommendCurrentApprovalState", () {
    test("initializes with given loaderStatus", () {
      final state = RecommendCurrentApprovalState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith updates loaderStatus when provided", () {
      final state = RecommendCurrentApprovalState(
        loaderStatus: LoadingStatus.loading,
      );

      final updated = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(updated.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith retains old value when no param is passed", () {
      final state = RecommendCurrentApprovalState(
        loaderStatus: LoadingStatus.loading,
      );

      final updated = state.copyWith();

      expect(updated.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith creates a new instance", () {
      final state = RecommendCurrentApprovalState(
        loaderStatus: LoadingStatus.loading,
      );

      final updated = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(identical(state, updated), false);
    });
  });
}
