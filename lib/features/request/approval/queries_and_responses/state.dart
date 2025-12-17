import 'package:wcas_frontend/core/utils/utils.dart';

class QueriesAndResponsesState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  QueriesAndResponsesState({
    required this.loaderStatus,
  });

  QueriesAndResponsesState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return QueriesAndResponsesState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
