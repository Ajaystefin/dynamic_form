import "package:wcas_frontend/core/utils/utils.dart";

class SelectFacilitiesDialogState {
  SelectFacilitiesDialogState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  SelectFacilitiesDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return SelectFacilitiesDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
