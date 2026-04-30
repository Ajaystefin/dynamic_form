import "package:wcas_frontend/core/utils/utils.dart";

class CreateFacilityState {
  CreateFacilityState({
    required this.loaderStatus,
    this.navigateToCreateFacility,
    this.isButtonLoading = false,
    this.isSaveLoading = false,
    this.isPolicyDeviation = false,
    this.isSaveAndContinueLoading = false,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? navigateToCreateFacility = LoadingStatus.loaded;
  final bool isButtonLoading;
  final bool isSaveLoading;
  final bool isSaveAndContinueLoading;
  bool? isPolicyDeviation;

  CreateFacilityState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? navigateToCreateFacility,
    bool? isButtonLoading,
    bool? isSaveLoading,
    bool? isPolicyDeviation,
    bool? isSaveAndContinueLoading,
  }) {
    return CreateFacilityState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isPolicyDeviation: isPolicyDeviation ?? this.isPolicyDeviation,
      navigateToCreateFacility:
          navigateToCreateFacility ?? this.navigateToCreateFacility,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
      isSaveLoading: isSaveLoading ?? this.isSaveLoading,
      isSaveAndContinueLoading:
          isSaveAndContinueLoading ?? this.isSaveAndContinueLoading,
    );
  }
}

enum CurrencyField {
  presentLimit,
  presentOutstanding,
  proposedBycc,
  proposedLimit,
  revisedBankLimitProposedByFi,
  excessOverMaxLimitAllowanceProposedByFi,
  cbdEquityTier325Percent,
  counterpartyEquity5Percent,
  counterpartyTotalAssets2Percent,
  revisedBankLimitRecommendedByCredit,
  excessOverMaxLimitAllowanceRecommendedByCredit,
}
