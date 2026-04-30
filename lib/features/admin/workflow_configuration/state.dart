import "package:wcas_frontend/core/utils/utils.dart";

class WorkflowConfigurationState {
  WorkflowConfigurationState({
    required this.loaderStatus,
    this.tableLoaderStatus = LoadingStatus.loaded, // always show headers
  });

  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus tableLoaderStatus = LoadingStatus.empty;

  WorkflowConfigurationState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoaderStatus,
  }) {
    return WorkflowConfigurationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoaderStatus: tableLoaderStatus ?? this.tableLoaderStatus,
    );
  }
}
