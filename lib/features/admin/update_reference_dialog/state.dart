import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for updating reference dialog.
/// 
/// Holds information related to loading status and the save button state
/// during reference update operations.
class UpdateReferenceDialogState {
  /// Creates an instance of [UpdateReferenceDialogState].
  /// 
  /// Requires the current [loaderStatus] and [saveButtonStatus].
  UpdateReferenceDialogState({
    required this.loaderStatus,
    required this.saveButtonStatus,
  });

  /// Indicates the current loading status of the dialog.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading/status state of the save button.
  LoadingStatus saveButtonStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  /// 
  /// If provided, [loaderStatus] and [saveButtonStatus] will replace
  /// the current values. Otherwise, existing values are retained.
  UpdateReferenceDialogState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? saveButtonStatus,
  }) {
    return UpdateReferenceDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      saveButtonStatus: saveButtonStatus ?? this.saveButtonStatus,
    );
  }
}
