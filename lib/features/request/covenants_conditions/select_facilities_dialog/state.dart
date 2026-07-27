import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for the select facilities dialog.
///
/// Holds information related to the loading status while selecting facilities.
class SelectFacilitiesDialogState {
  /// Creates an instance of [SelectFacilitiesDialogState].
  ///
  /// Requires the current [loaderStatus].
  const SelectFacilitiesDialogState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the select facilities dialog.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  SelectFacilitiesDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return SelectFacilitiesDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
