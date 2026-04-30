import "package:wcas_frontend/core/utils/utils.dart";

class AppendixState {
  const AppendixState({
    this.loaderStatus = LoadingStatus.loaded,
  });
  final LoadingStatus loaderStatus;

  AppendixState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return AppendixState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
