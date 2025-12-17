import 'package:wcas_frontend/core/utils/utils.dart';

class InPipelineDialogState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  InPipelineDialogState({
    required this.loaderStatus,
  });

  InPipelineDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return InPipelineDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
