import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Upload Document Dialog.
///
/// Manages overall loading status and the upload button loading state
/// during document upload operations.
class UploadDocumentDialogState {
  /// Creates an instance of [UploadDocumentDialogState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [uploadButtonStatus] represents the loading state
  /// of the upload button.
  UploadDocumentDialogState({
    required this.loaderStatus,
    required this.uploadButtonStatus,
  });

  /// Defines the overall loading status of the dialog.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the upload button.
  LoadingStatus uploadButtonStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  UploadDocumentDialogState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? uploadButtonStatus,
  }) {
    return UploadDocumentDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      uploadButtonStatus: uploadButtonStatus ?? this.uploadButtonStatus,
    );
  }
}
