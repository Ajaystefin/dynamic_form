import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Customer Information screen.
///
/// Holds loading statuses and flags related to customer selection,
/// partner/shareholder data, and entity attributes.
class CustomerInformationState {
  /// Creates an instance of [CustomerInformationState].
  ///
  /// Requires [loaderStatus] and optionally accepts
  /// various loading states and boolean flags.
  CustomerInformationState({
    required this.loaderStatus,
    this.customerSelectedStatus,
    this.partnerShareholderStatus,
    this.borrowerSubsidiary = false,
    this.legalEntityIdentifier = false,
  });

  /// Overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Loading status for partner/shareholder data.
  LoadingStatus? partnerShareholderStatus = LoadingStatus.loaded;

  /// Loading status for selected customer details.
  LoadingStatus? customerSelectedStatus = LoadingStatus.loaded;

  /// Indicates whether the borrower is a subsidiary.
  final bool borrowerSubsidiary;

  /// Indicates whether a legal entity identifier is present.
  final bool legalEntityIdentifier;

  /// Creates a copy of this state with updated values.
  ///
  /// Only provided values will be replaced,
  /// others will retain existing values.
  CustomerInformationState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? customerSelectedStatus,
    LoadingStatus? partnerShareholderStatus,
    bool? borrowerSubsidiary,
    bool? legalEntityIdentifier,
  }) {
    return CustomerInformationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      partnerShareholderStatus:
          partnerShareholderStatus ?? this.partnerShareholderStatus,
      customerSelectedStatus:
          customerSelectedStatus ?? this.customerSelectedStatus,
      borrowerSubsidiary: borrowerSubsidiary ?? this.borrowerSubsidiary,
      legalEntityIdentifier:
          legalEntityIdentifier ?? this.legalEntityIdentifier,
    );
  }
}
