import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the File Attachment feature.
///
/// Manages loading states for documents, uploads, and digital files,
/// along with UI flags and error messaging.
class FileAttachmentState {
  /// Creates an instance of [FileAttachmentState].
  ///
  /// The [loaderStatus] defines the overall loading state.
  /// Other parameters represent document loading, upload status,
  /// UI visibility flags, and error messages.
  FileAttachmentState({
    required this.loaderStatus,
    this.documentsLoaderStatus,
    this.legacyLoaderStatus,
    this.uploadStatus,
    this.digitalFilesStatus,
    this.showUploadButton,
    this.showUploadForm,
    this.documentListErrorMessage,
  });

  /// Defines the overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of document list retrieval.
  LoadingStatus? documentsLoaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of file upload operations.
  LoadingStatus? uploadStatus = LoadingStatus.loaded;

  /// Represents the loading status of digital file processing.
  LoadingStatus? digitalFilesStatus = LoadingStatus.loaded;

  LoadingStatus? legacyLoaderStatus = LoadingStatus.loaded;

  /// Indicates whether the upload button should be visible.
  bool? showUploadButton = false;

  /// Indicates whether the upload form should be visible.
  bool? showUploadForm = false;

  /// Stores any error message related to document list operations.
  String? documentListErrorMessage;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  FileAttachmentState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? documentsLoaderStatus,
    LoadingStatus? uploadStatus,
    LoadingStatus? digitalFilesStatus,
    LoadingStatus? legacyLoaderStatus,
    bool? showUploadButton,
    bool? showUploadForm,
    String? documentListErrorMessage,
  }) {
    return FileAttachmentState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      documentsLoaderStatus:
          documentsLoaderStatus ?? this.documentsLoaderStatus,
      legacyLoaderStatus: legacyLoaderStatus ?? this.legacyLoaderStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      digitalFilesStatus: digitalFilesStatus ?? this.digitalFilesStatus,
      showUploadButton: showUploadButton ?? this.showUploadButton,
      showUploadForm: showUploadForm ?? this.showUploadForm,
      documentListErrorMessage:
          documentListErrorMessage ?? this.documentListErrorMessage,
    );
  }
}
