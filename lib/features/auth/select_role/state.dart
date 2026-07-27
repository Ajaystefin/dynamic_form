import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Select Role screen.
///
/// Holds information related to overall loading status and
/// the role selection action status.
class SelectRoleState {
  /// Creates an instance of [SelectRoleState].
  ///
  /// Requires the current [loaderStatus] and optionally accepts
  /// the role selection status.
  const SelectRoleState({
    required this.loaderStatus,
    this.selectRoleStatus,
  });

  /// Indicates the general loading status of the screen.
  final LoadingStatus loaderStatus;

  /// Indicates the status of the role selection process.
  final LoadingStatus? selectRoleStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// If provided, [loaderStatus] and [selectRoleStatus] will replace
  /// the current values. Otherwise, existing values are retained.
  SelectRoleState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? selectRoleStatus,
  }) {
    return SelectRoleState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      selectRoleStatus: selectRoleStatus ?? this.selectRoleStatus,
    );
  }
}
