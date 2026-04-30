import "package:wcas_frontend/core/utils/utils.dart";

class ManagementCommentsState {
  ManagementCommentsState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  ManagementCommentsState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ManagementCommentsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
