import "package:wcas_frontend/core/utils/utils.dart";

class CreditAssessmentFIState {
  CreditAssessmentFIState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  CreditAssessmentFIState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return CreditAssessmentFIState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
