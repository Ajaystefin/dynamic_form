import "package:wcas_frontend/core/constants/_server_constants.dart";

/// Represents a linked commitment number associated with a contract.
class LinkCommitmentNumber {
  /// Creates a [LinkCommitmentNumber] instance.
  LinkCommitmentNumber({
    this.projectAllocationAccount,
    this.facilityType,
    this.limitAmountInAED,
    this.currentOSInAED,
  });

  /// Creates a [LinkCommitmentNumber] instance from a JSON map.
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

  /// projectAllocationAccount
  final String? projectAllocationAccount;

  /// facilityType
  final int? facilityType;

  /// limitAmountInAED
  final double? limitAmountInAED;

  /// currentOSInAED
  final double? currentOSInAED;

  /// Converts this [LinkCommitmentNumber] instance to a JSON map.
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
