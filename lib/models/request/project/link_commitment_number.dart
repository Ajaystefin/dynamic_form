import "package:wcas_frontend/core/constants/_server_constants.dart";

class LinkCommitmentNumber {
  LinkCommitmentNumber({
    this.projectAllocationAccount,
    this.facilityType,
    this.limitAmountInAED,
    this.currentOSInAED,
  });

  factory LinkCommitmentNumber.fromJson(Map<String, dynamic> json) {
    final num? rawPresentLimitAED =
        (json["currency"] != ServerConstants.aedCurrency
            ? json["presentLimitAED"]
            : json["presentLimit"]) as num?;
    final num? rawPresentOutstanding = json["presentOutstanding"] as num?;

    return LinkCommitmentNumber(
      // commitmentAccountNumber: json['commitmentAccountNumber'],
      projectAllocationAccount: json["commitmentAccountNumber"],
      facilityType: json["limitDescription"],
      limitAmountInAED: rawPresentLimitAED?.toDouble(),
      currentOSInAED: rawPresentOutstanding?.toDouble(),
    );
  }
  final String? projectAllocationAccount;
  final int? facilityType;
  final double? limitAmountInAED;
  final double? currentOSInAED;

  Map<String, dynamic> toJson() {
    return {
      // 'commitmentAccountNumber': commitmentAccountNumber,
      "commitmentAccountNumber": projectAllocationAccount,
      "limitDescription": facilityType,
      "presentLimitAED": limitAmountInAED,
      "presentOutstanding": currentOSInAED,
    };
  }

  // New: additive helper
  LinkCommitmentNumber copyWith({
    String? projectAllocationAccount,
    int? facilityType,
    double? limitAmountInAED,
    double? currentOSInAED,
  }) {
    return LinkCommitmentNumber(
      projectAllocationAccount:
          projectAllocationAccount ?? this.projectAllocationAccount,
      facilityType: facilityType ?? this.facilityType,
      limitAmountInAED: limitAmountInAED ?? this.limitAmountInAED,
      currentOSInAED: currentOSInAED ?? this.currentOSInAED,
    );
  }
}
