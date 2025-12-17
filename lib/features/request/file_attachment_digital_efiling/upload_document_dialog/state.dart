import 'package:wcas_frontend/core/utils/utils.dart';

class UploadDocumentDialogState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus uploadButtonStatus = LoadingStatus.loaded;

  UploadDocumentDialogState(
      {required this.loaderStatus, required this.uploadButtonStatus});

  UploadDocumentDialogState copyWith(
      {LoadingStatus? loaderStatus, LoadingStatus? uploadButtonStatus}) {
    return UploadDocumentDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      uploadButtonStatus: uploadButtonStatus ?? this.uploadButtonStatus,
    );
  }
}
