import 'package:wcas_frontend/core/utils/utils.dart';

class CreateSecurityState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  LoadingStatus? securityTypeStatus = LoadingStatus.empty;

  CreateSecurityState({
    required this.loaderStatus,
    this.securityTypeStatus = LoadingStatus.empty,
  });

  CreateSecurityState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? securityTypeStatus,
  }) {
    return CreateSecurityState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      securityTypeStatus: securityTypeStatus ?? this.securityTypeStatus,
    );
  }
}
