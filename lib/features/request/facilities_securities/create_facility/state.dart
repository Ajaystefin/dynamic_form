import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Create Facility screen.
class CreateFacilityState {
  /// Creates an instance of [CreateFacilityState].
  ///
  /// [loaderStatus] is required and indicates the current loading state.
  const CreateFacilityState({
    required this.loaderStatus,
    this.navigateToCreateFacility,
    this.isButtonLoading = false,
    this.isSaveLoading = false,
    this.isPolicyDeviation = false,
    this.isSaveAndContinueLoading = false,
  });

  /// The current loading status.
  final LoadingStatus loaderStatus;

  /// Navigation status for create facility flow.
  final LoadingStatus? navigateToCreateFacility;

  /// Indicates if the button is in loading state.
  final bool isButtonLoading;

  /// Indicates if the save action is in progress.
  final bool isSaveLoading;

  /// Indicates if "save and continue" is loading.
  final bool isSaveAndContinueLoading;

  /// Indicates whether policy deviation exists.
  final bool? isPolicyDeviation;

  /// Creates a copy of this state with updated values.
  ///
  /// If a parameter is null, the existing value is retained.
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

/// Enum representing different currency-related fields.
enum CurrencyField {
  /// Current sanctioned limit.
  presentLimit,

  /// Current outstanding amount.
  presentOutstanding,

  /// Proposed limit by business/credit committee.
  proposedBycc,

  /// Proposed facility limit.
  proposedLimit,

  /// Revised limit proposed by financial institution.
  revisedBankLimitProposedByFi,

  /// Excess limit over allowed maximum (FI proposal).
  excessOverMaxLimitAllowanceProposedByFi,

  /// Tier 3/25% equity exposure.
  cbdEquityTier325Percent,

  /// Counterparty equity exposure (5%).
  counterpartyEquity5Percent,

  /// Counterparty total assets exposure (2%).
  counterpartyTotalAssets2Percent,

  /// Revised limit recommended by credit team.
  revisedBankLimitRecommendedByCredit,

  /// Excess limit over allowed maximum (credit recommendation).
  excessOverMaxLimitAllowanceRecommendedByCredit,
}
