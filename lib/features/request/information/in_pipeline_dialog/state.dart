import "package:wcas_frontend/core/utils/utils.dart";

class InPipelineDialogState {
  InPipelineDialogState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  InPipelineDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return InPipelineDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
