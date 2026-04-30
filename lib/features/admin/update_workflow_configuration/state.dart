import "package:wcas_frontend/core/utils/utils.dart";

class UpdateWorkflowConfigurationState {
  UpdateWorkflowConfigurationState({
    required this.loaderStatus,
    this.tableLoaderStatus = LoadingStatus.loaded, // always show headers
  });

  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus tableLoaderStatus = LoadingStatus.empty;

  UpdateWorkflowConfigurationState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoaderStatus,
  }) {
    return UpdateWorkflowConfigurationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoaderStatus: tableLoaderStatus ?? this.tableLoaderStatus,
    );
  }
}
