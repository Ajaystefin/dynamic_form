import "package:wcas_frontend/core/utils/utils.dart";

class SicCodeReviewState {
  SicCodeReviewState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  SicCodeReviewState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return SicCodeReviewState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
