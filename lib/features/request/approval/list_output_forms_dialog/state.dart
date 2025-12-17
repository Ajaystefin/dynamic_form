import 'package:wcas_frontend/core/utils/utils.dart';

class ListOutputFormsDialogState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  ListOutputFormsDialogState({
    required this.loaderStatus,
  });

  ListOutputFormsDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ListOutputFormsDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
