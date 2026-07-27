import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Create Request feature.
///
/// Manages loading status and controls the visibility
/// of the selection dialog.
class CreateRequestState {
  /// Creates an instance of [CreateRequestState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [showSelectDialog] controls dialog visibility.
  CreateRequestState({
    required this.loaderStatus,
    this.showSelectDialog = false,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Controls whether the selection dialog is visible.
  bool showSelectDialog;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  CreateRequestState copyWith({
    LoadingStatus? loaderStatus,
    bool? showSelectDialog,
  }) {
    return CreateRequestState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      showSelectDialog: showSelectDialog ?? false,
    );
  }
}
