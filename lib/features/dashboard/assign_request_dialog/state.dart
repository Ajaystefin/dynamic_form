import "package:wcas_frontend/core/utils/utils.dart";

class AssignRequestDialogState {
  AssignRequestDialogState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  AssignRequestDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return AssignRequestDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
