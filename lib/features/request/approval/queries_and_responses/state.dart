import "package:wcas_frontend/core/utils/utils.dart";

class QueriesAndResponsesState {
  QueriesAndResponsesState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  QueriesAndResponsesState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return QueriesAndResponsesState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
