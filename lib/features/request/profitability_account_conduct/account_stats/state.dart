import "package:wcas_frontend/core/utils/utils.dart";

class AccountStatsState {
  AccountStatsState({
    required this.loaderStatus,
    this.saveButtonLoading,
    this.continueButtonLoading,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? saveButtonLoading = LoadingStatus.loaded;
  LoadingStatus? continueButtonLoading = LoadingStatus.loaded;

  AccountStatsState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? saveButtonLoading,
    LoadingStatus? continueButtonLoading,
  }) {
    return AccountStatsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      saveButtonLoading: saveButtonLoading ?? this.saveButtonLoading,
      continueButtonLoading:
          continueButtonLoading ?? this.continueButtonLoading,
    );
  }
}
