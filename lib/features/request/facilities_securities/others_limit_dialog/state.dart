import "package:wcas_frontend/core/utils/utils.dart";

class OthersLimitDialogState {
  OthersLimitDialogState({
    required this.loaderStatus,
    required this.saveButtonStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus saveButtonStatus = LoadingStatus.loaded;

  OthersLimitDialogState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? saveButtonStatus,
  }) {
    return OthersLimitDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      saveButtonStatus: saveButtonStatus ?? this.saveButtonStatus,
    );
  }
}
