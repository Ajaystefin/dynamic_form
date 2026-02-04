import 'package:wcas_frontend/core/utils/utils.dart';

class GroupPositionState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  GroupPositionState({
    required this.loaderStatus,
  });

  GroupPositionState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return GroupPositionState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
