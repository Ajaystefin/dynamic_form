import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for workflow configuration.
/// 
/// Holds information about the overall loading status and
/// the table-specific loading state for workflow configuration screens.
class WorkflowConfigurationState {
  /// Creates an instance of [WorkflowConfigurationState].
  /// 
  /// Requires the current [loaderStatus] and initializes
  /// [tableLoaderStatus] with a default value to keep table headers visible.
  WorkflowConfigurationState({
    required this.loaderStatus,
    this.tableLoaderStatus = LoadingStatus.loaded,
  });

  /// Indicates the overall loading status of the workflow configuration process.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the workflow configuration table.
  /// 
  /// Keeps table headers visible even while data is loading.
  LoadingStatus tableLoaderStatus = LoadingStatus.empty;

  /// Creates a copy of this state with updated values.
  /// 
  /// If provided, [loaderStatus] and [tableLoaderStatus] will replace
  /// the current values. Otherwise, existing values are retained.
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
