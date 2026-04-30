import "package:wcas_frontend/core/utils/utils.dart";

class GroupPositionState {
  GroupPositionState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  GroupPositionState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return GroupPositionState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
