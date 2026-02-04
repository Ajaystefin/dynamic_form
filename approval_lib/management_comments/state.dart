import 'package:wcas_frontend/core/utils/utils.dart';

class ManagementCommentsState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  ManagementCommentsState({
    required this.loaderStatus,
  });

  ManagementCommentsState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ManagementCommentsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
