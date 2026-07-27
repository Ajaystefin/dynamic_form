import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for group position.
/// 
/// Holds information related to the loading status during the
/// group position processing.
class GroupPositionState {
  /// Creates an instance of [GroupPositionState].
  /// 
  /// Requires the current [loaderStatus].
  const GroupPositionState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the group position process.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  GroupPositionState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return GroupPositionState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
