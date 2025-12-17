import 'package:wcas_frontend/core/utils/utils.dart';

class CreditAssessmentState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  CreditAssessmentState({
    required this.loaderStatus,
  });

  CreditAssessmentState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return CreditAssessmentState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
