import 'package:wcas_frontend/core/utils/utils.dart';

class CreateRequestState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  bool showSelectDialog;

  CreateRequestState(
      {required this.loaderStatus, this.showSelectDialog = false});

  CreateRequestState copyWith(
      {LoadingStatus? loaderStatus, bool? showSelectDialog}) {
    return CreateRequestState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        showSelectDialog: showSelectDialog ?? false);
  }
}
