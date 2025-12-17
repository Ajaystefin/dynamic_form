import 'package:wcas_frontend/core/utils/utils.dart';

class ConditionEditDialogState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus fieldStatus = LoadingStatus.loaded;

  ConditionEditDialogState({
    required this.loaderStatus,
     this.fieldStatus= LoadingStatus.loaded,
  });

  ConditionEditDialogState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? fieldStatus,
  }) {
    return ConditionEditDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      fieldStatus: fieldStatus ?? this.fieldStatus,
    );
  }
}
