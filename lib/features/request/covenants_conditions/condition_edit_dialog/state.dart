import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Condition Edit Dialog.
///
/// Manages loading status and field-level loading state
/// within the dialog.
class ConditionEditDialogState {
  /// Creates an instance of [ConditionEditDialogState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [fieldStatus] represents the field-level loading state.
  ConditionEditDialogState({
    required this.loaderStatus,
    this.fieldStatus = LoadingStatus.loaded,
  });

  /// Defines the overall loading status of the dialog.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of individual fields.
  LoadingStatus fieldStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  ConditionEditDialogState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? fieldStatus,
  }) {
    return ConditionEditDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      fieldStatus: fieldStatus ?? this.fieldStatus,
    );
  }
}
