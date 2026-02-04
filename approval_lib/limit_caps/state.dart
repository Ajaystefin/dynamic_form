import 'package:wcas_frontend/core/utils/utils.dart';

class LimitCapsState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  LimitCapsState({
    required this.loaderStatus,
  });

  LimitCapsState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return LimitCapsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
