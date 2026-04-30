import "package:wcas_frontend/core/utils/utils.dart";

class PreviousCreditApprovalState {
  PreviousCreditApprovalState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  PreviousCreditApprovalState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return PreviousCreditApprovalState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
