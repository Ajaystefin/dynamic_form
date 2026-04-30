import "package:wcas_frontend/core/utils/utils.dart";

class CreditAssessmentState {
  CreditAssessmentState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  CreditAssessmentState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return CreditAssessmentState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
