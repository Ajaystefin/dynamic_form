import "package:wcas_frontend/core/utils/utils.dart";

class CustomerInformationState {
  CustomerInformationState({
    required this.loaderStatus,
    this.customerSelectedStatus,
    this.partnerShareholderStatus,
    this.borrowerSubsidiary = false,
    this.legalEntityIdentifier = false,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? partnerShareholderStatus = LoadingStatus.loaded;
  LoadingStatus? customerSelectedStatus = LoadingStatus.loaded;
  final bool borrowerSubsidiary, legalEntityIdentifier;

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
      borrowerSubsidiary: borrowerSubsidiary ?? this.borrowerSubsidiary,
      legalEntityIdentifier:
          legalEntityIdentifier ?? this.legalEntityIdentifier,
      customerSelectedStatus:
          customerSelectedStatus ?? this.customerSelectedStatus,
    );
  }
}
