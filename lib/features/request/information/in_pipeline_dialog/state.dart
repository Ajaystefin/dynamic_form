import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the In-Pipeline Dialog feature.
///
/// Manages the loading status during in-pipeline dialog operations.
class InPipelineDialogState {
  /// Creates an instance of [InPipelineDialogState].
  ///
  /// The [loaderStatus] defines the current loading state.
  const InPipelineDialogState({
    required this.loaderStatus,
  });

  /// Defines the current loading status of the dialog.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  InPipelineDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return InPipelineDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
