import 'package:wcas_frontend/core/utils/utils.dart';

class AppendixState {
  final LoadingStatus loaderStatus;

  const AppendixState({
    this.loaderStatus = LoadingStatus.loaded,
  });

  AppendixState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return AppendixState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
