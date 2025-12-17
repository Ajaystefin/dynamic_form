import 'package:wcas_frontend/core/utils/utils.dart';

class CcsysCreateRequestState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  bool showSelectDialog;

  CcsysCreateRequestState(
      {required this.loaderStatus, this.showSelectDialog = false});

  CcsysCreateRequestState copyWith(
      {LoadingStatus? loaderStatus, bool? showSelectDialog}) {
    return CcsysCreateRequestState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        showSelectDialog: showSelectDialog ?? false);
  }
}
