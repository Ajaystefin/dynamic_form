import "package:wcas_frontend/core/utils/utils.dart";

class FileAttachmentState {
  FileAttachmentState({
    required this.loaderStatus,
    this.documentsLoaderStatus,
    this.uploadStatus,
    this.showUploadButton,
    this.showUploadForm,
    this.documentListErrorMessage,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? documentsLoaderStatus = LoadingStatus.loaded;
  LoadingStatus? uploadStatus = LoadingStatus.loaded;
  bool? showUploadButton = false;
  bool? showUploadForm = false;
  String? documentListErrorMessage;

  FileAttachmentState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? documentsLoaderStatus,
    LoadingStatus? uploadStatus,
    bool? showUploadButton,
    bool? showUploadForm,
    String? documentListErrorMessage,
  }) {
    return FileAttachmentState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      documentsLoaderStatus:
          documentsLoaderStatus ?? this.documentsLoaderStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      showUploadButton: showUploadButton ?? this.showUploadButton,
      showUploadForm: showUploadForm ?? this.showUploadForm,
      documentListErrorMessage:
          documentListErrorMessage ?? this.documentListErrorMessage,
    );
  }
}
