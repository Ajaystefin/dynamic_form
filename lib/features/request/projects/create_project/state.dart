import 'package:wcas_frontend/core/utils/utils.dart';

class CreateProjectState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? contractStatus = LoadingStatus.loaded;

  CreateProjectState({
    required this.loaderStatus,
    this.contractStatus,
  });

  CreateProjectState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? contractStatus,
  }) {
    return CreateProjectState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      contractStatus: contractStatus ?? this.contractStatus,
    );
  }
}
