import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Others Limit Dialog.
///
/// Manages overall loading status and the save button loading state.
class OthersLimitDialogState {
  /// Creates an instance of [OthersLimitDialogState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [saveButtonStatus] represents the loading state
  /// of the save button.
  OthersLimitDialogState({
    required this.loaderStatus,
    required this.saveButtonStatus,
  });

  /// Defines the overall loading status of the dialog.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the save button.
  LoadingStatus saveButtonStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  OthersLimitDialogState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? saveButtonStatus,
  }) {
    return OthersLimitDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      saveButtonStatus: saveButtonStatus ?? this.saveButtonStatus,
    );
  }
}
