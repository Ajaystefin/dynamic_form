import 'package:wcas_frontend/core/utils/utils.dart';

class FileAttachmentState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? documentsLoaderStatus = LoadingStatus.loaded;
  bool? showUploadButton = false;
  bool? showUploadForm = false;
  String? documentListErrorMessage;

  FileAttachmentState(
      {required this.loaderStatus,
      this.documentsLoaderStatus,
      this.showUploadButton,
      this.showUploadForm,
      this.documentListErrorMessage});

  FileAttachmentState copyWith(
      {LoadingStatus? loaderStatus,
      LoadingStatus? documentsLoaderStatus,
      bool? showUploadButton,
      bool? showUploadForm,
      String? documentListErrorMessage}) {
    return FileAttachmentState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        documentsLoaderStatus:
            documentsLoaderStatus ?? this.documentsLoaderStatus,
        showUploadButton: showUploadButton ?? this.showUploadButton,
        showUploadForm: showUploadForm ?? this.showUploadForm,
        documentListErrorMessage:
            documentListErrorMessage ?? this.documentListErrorMessage);
  }
}
