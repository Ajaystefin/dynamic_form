import "package:wcas_frontend/core/utils/utils.dart";

class IncomeSummaryState {
  IncomeSummaryState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  IncomeSummaryState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return IncomeSummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
