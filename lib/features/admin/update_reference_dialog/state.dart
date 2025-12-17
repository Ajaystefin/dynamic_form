import 'package:wcas_frontend/core/utils/utils.dart';

class UpdateReferenceDialogState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus saveButtonStatus = LoadingStatus.loaded;

  UpdateReferenceDialogState(
      {required this.loaderStatus, required this.saveButtonStatus});

  UpdateReferenceDialogState copyWith(
      {LoadingStatus? loaderStatus, LoadingStatus? saveButtonStatus}) {
    return UpdateReferenceDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      saveButtonStatus: saveButtonStatus ?? this.saveButtonStatus,
    );
  }
}
