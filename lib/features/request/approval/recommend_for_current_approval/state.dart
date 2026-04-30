import "package:wcas_frontend/core/utils/utils.dart";

class RecommendCurrentApprovalState {
  RecommendCurrentApprovalState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RecommendCurrentApprovalState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RecommendCurrentApprovalState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
