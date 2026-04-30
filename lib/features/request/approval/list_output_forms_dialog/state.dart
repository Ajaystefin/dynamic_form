import "package:wcas_frontend/core/utils/utils.dart";

class ListOutputFormsDialogState {
  ListOutputFormsDialogState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  ListOutputFormsDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ListOutputFormsDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
