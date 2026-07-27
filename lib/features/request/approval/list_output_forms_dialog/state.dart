import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for the list output forms dialog.
/// 
/// Holds information related to the loading status while managing output forms.
class ListOutputFormsDialogState {
  /// Creates an instance of [ListOutputFormsDialogState].
  /// 
  /// Requires the current [loaderStatus].
  const ListOutputFormsDialogState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the list output forms dialog.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  ListOutputFormsDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ListOutputFormsDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
