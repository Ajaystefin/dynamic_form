import "package:wcas_frontend/core/utils/utils.dart";

class UpdateReferenceDialogState {
  UpdateReferenceDialogState({
    required this.loaderStatus,
    required this.saveButtonStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus saveButtonStatus = LoadingStatus.loaded;

  UpdateReferenceDialogState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? saveButtonStatus,
  }) {
    return UpdateReferenceDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      saveButtonStatus: saveButtonStatus ?? this.saveButtonStatus,
    );
  }
}
