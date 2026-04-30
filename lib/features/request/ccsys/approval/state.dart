import "package:wcas_frontend/core/utils/utils.dart";

class CcsysApprovalState {
  CcsysApprovalState({required this.loaderStatus});
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  CcsysApprovalState copyWith({LoadingStatus? loaderStatus}) {
    return CcsysApprovalState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
