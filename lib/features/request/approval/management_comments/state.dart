import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for management comments.
/// 
/// Holds information related to the loading status during the
/// management comments processing.
class ManagementCommentsState {
  /// Creates an instance of [ManagementCommentsState].
  /// 
  /// Requires the current [loaderStatus].
  ManagementCommentsState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of management comments.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  ManagementCommentsState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ManagementCommentsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
