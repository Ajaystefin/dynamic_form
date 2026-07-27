import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Facilities with Other Banks feature.
///
/// Manages loading states for overall processing, CBRB table,
/// and other bank-related data.
class FacilitiesWithOtherBanksState {
  /// Creates an instance of [FacilitiesWithOtherBanksState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// while [cbrbTableLoader] and [otherBankLoader] represent
  /// loading states for their respective sections.
  FacilitiesWithOtherBanksState({
    required this.loaderStatus,
    this.cbrbTableLoader = LoadingStatus.empty,
    this.otherBankLoader = LoadingStatus.empty,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the CBRB table.
  LoadingStatus cbrbTableLoader = LoadingStatus.empty;

  /// Represents the loading status of other bank data.
  LoadingStatus otherBankLoader = LoadingStatus.empty;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
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
