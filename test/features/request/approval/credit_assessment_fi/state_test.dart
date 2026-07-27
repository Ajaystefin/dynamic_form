import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/state.dart";

void main() {
  group("CreditAssessmentFIState", () {
    test("initializes with given loaderStatus", () {
      const state = CreditAssessmentFIState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith updates loaderStatus when provided", () {
      const state = CreditAssessmentFIState(
        loaderStatus: LoadingStatus.loading,
      );

      final updated = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(updated.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith keeps existing loaderStatus when null passed", () {
      const state = CreditAssessmentFIState(
        loaderStatus: LoadingStatus.loading,
      );

      final updated = state.copyWith(); // no params

      expect(updated.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith returns a new instance", () {
      const state = CreditAssessmentFIState(
        loaderStatus: LoadingStatus.loading,
      );

      final updated = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(identical(state, updated), false);
    });
  });
}
