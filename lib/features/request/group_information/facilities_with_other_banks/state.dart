import "package:wcas_frontend/core/utils/utils.dart";

class FacilitiesWithOtherBanksState {
  FacilitiesWithOtherBanksState({
    required this.loaderStatus,
    this.cbrbTableLoader = LoadingStatus.empty,
    this.otherBankLoader = LoadingStatus.empty,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus cbrbTableLoader = LoadingStatus.empty;
  LoadingStatus otherBankLoader = LoadingStatus.empty;

  FacilitiesWithOtherBanksState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? cbrbTableLoader,
    LoadingStatus? otherBankLoader,
  }) {
    return FacilitiesWithOtherBanksState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      cbrbTableLoader: cbrbTableLoader ?? this.cbrbTableLoader,
      otherBankLoader: otherBankLoader ?? this.otherBankLoader,
    );
  }
}
