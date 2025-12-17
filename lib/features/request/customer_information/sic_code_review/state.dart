import 'package:wcas_frontend/core/utils/utils.dart';

class SicCodeReviewState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  SicCodeReviewState({
    required this.loaderStatus,
  });

  SicCodeReviewState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return SicCodeReviewState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
