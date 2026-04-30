import "package:wcas_frontend/core/utils/utils.dart";

class CreateRequestState {
  CreateRequestState({
    required this.loaderStatus,
    this.showSelectDialog = false,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  bool showSelectDialog;

  CreateRequestState copyWith({
    LoadingStatus? loaderStatus,
    bool? showSelectDialog,
  }) {
    return CreateRequestState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      showSelectDialog: showSelectDialog ?? false,
    );
  }
}
