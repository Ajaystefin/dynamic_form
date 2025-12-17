import 'package:wcas_frontend/core/utils/utils.dart';

class AccountStatsState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? saveButtonLoading = LoadingStatus.loaded;
  LoadingStatus? continueButtonLoading = LoadingStatus.loaded;

  AccountStatsState({required this.loaderStatus, this.saveButtonLoading, this.continueButtonLoading});

  AccountStatsState copyWith(
      {LoadingStatus? loaderStatus, LoadingStatus? saveButtonLoading,LoadingStatus? continueButtonLoading}) {
    return AccountStatsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      saveButtonLoading: saveButtonLoading ?? this.saveButtonLoading,
      continueButtonLoading: continueButtonLoading ?? this.continueButtonLoading,
    );
  }
}
