import 'package:wcas_frontend/core/utils/utils.dart';

class CcsysApprovalState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  CcsysApprovalState({required this.loaderStatus});

  CcsysApprovalState copyWith({LoadingStatus? loaderStatus}) {
    return CcsysApprovalState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
