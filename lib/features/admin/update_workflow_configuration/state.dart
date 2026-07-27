import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for updating workflow configuration.
///
/// Holds information related to overall loading status and table-specific
/// loading status during workflow configuration updates.
class UpdateWorkflowConfigurationState {
  /// Creates an instance of [UpdateWorkflowConfigurationState].
  ///
  /// Requires the current [loaderStatus] and optionally accepts
  /// [tableLoaderStatus] for managing table-specific loading state.
  UpdateWorkflowConfigurationState({
    required this.loaderStatus,
    this.tableLoaderStatus = LoadingStatus.loaded,
  });

  /// Indicates the overall loading status of the workflow configuration process.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the configuration table.
  ///
  /// Keeps table headers visible even while data is loading.
  LoadingStatus tableLoaderStatus = LoadingStatus.empty;

  /// Creates a copy of this state with updated values.
  ///
  /// If provided, [loaderStatus] and [tableLoaderStatus] will replace
  /// the current values. Otherwise, existing values are retained.
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
