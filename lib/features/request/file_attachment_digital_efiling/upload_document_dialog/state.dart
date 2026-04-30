import "package:wcas_frontend/core/utils/utils.dart";

class UploadDocumentDialogState {
  UploadDocumentDialogState({
    required this.loaderStatus,
    required this.uploadButtonStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus uploadButtonStatus = LoadingStatus.loaded;

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
