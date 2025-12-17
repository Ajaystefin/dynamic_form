class LinkContract {
  final int? projectAllocationAccount;
  final String? facilityType;
  final String? limitAmountInAED;
  final String? currentOSInAED;

  LinkContract({
    this.projectAllocationAccount,
    this.facilityType,
    this.limitAmountInAED,
    this.currentOSInAED,
  });

  factory LinkContract.fromJson(Map<String, dynamic> json) {
    return LinkContract(
      projectAllocationAccount: json['ProjectAllocationAccount'],
      facilityType: json['FacilityType'],
      limitAmountInAED: json['LimitAmountInAED'],
      currentOSInAED: json['CurrentOSInAED'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProjectAllocationAccount': projectAllocationAccount,
      'FacilityType': facilityType,
      'LimitAmountInAED': limitAmountInAED,
      'CurrentOSInAED': currentOSInAED,
    };
  }
}
