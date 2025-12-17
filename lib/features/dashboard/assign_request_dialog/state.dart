import 'package:wcas_frontend/core/utils/utils.dart';

class AssignRequestDialogState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  AssignRequestDialogState({
    required this.loaderStatus,
  });

  AssignRequestDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return AssignRequestDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
