/// Represents share of wallet information for a customer.
class ShareOfWallet {
  /// Creates a [ShareOfWallet] instance.
  ShareOfWallet({
    required this.customerRimNo,
    required this.customerName,
    required this.facilitiesWithAllBanksLimitsA,
    required this.facilitiesWithAllBanksOutstandingC,
    required this.facilitiesWithCbdLimitsB,
    required this.facilitiesWithCbdOutstandingD,
    required this.shareOfWalletLimits,
    required this.shareOfWalletOutstanding,
  });

  /// Creates a [ShareOfWallet] instance from a JSON map.
  factory ShareOfWallet.fromJson(Map<String, dynamic> json) {
    return ShareOfWallet(
      customerRimNo: json["customerRimNo"],
      customerName: json["customerName"],
      facilitiesWithAllBanksLimitsA:
          (json["facilitiesWithAllBanksLimitsA"] as num).toDouble(),
      facilitiesWithAllBanksOutstandingC:
          (json["facilitiesWithAllBanksOutstandingC"] as num).toDouble(),
      facilitiesWithCbdLimitsB:
          (json["facilitiesWithCbdLimitsB"] as num).toDouble(),
      facilitiesWithCbdOutstandingD:
          (json["facilitiesWithCbdOutstandingD"] as num).toDouble(),
      shareOfWalletLimits: (json["shareOfWalletLimits"] as num).toDouble(),
      shareOfWalletOutstanding:
          (json["shareOfWalletOutstanding"] as num).toDouble(),
    );
  }

  /// Customer RIM number.
  final int customerRimNo;

  /// Customer name.
  final String customerName;

  /// Facilities with all banks limits (A).
  final double facilitiesWithAllBanksLimitsA;

  /// Facilities with all banks outstanding amount (C).
  final double facilitiesWithAllBanksOutstandingC;

  /// Facilities with CBD limits (B).
  final double facilitiesWithCbdLimitsB;

  /// Facilities with CBD outstanding amount (D).
  final double facilitiesWithCbdOutstandingD;

  /// Share of wallet limits percentage.
  final double shareOfWalletLimits;

  /// Share of wallet outstanding percentage.
  final double shareOfWalletOutstanding;

  /// Converts this [ShareOfWallet] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "customerRimNo": customerRimNo,
      "customerName": customerName,
      "facilitiesWithAllBanksLimitsA": facilitiesWithAllBanksLimitsA,
      "facilitiesWithAllBanksOutstandingC": facilitiesWithAllBanksOutstandingC,
      "facilitiesWithCbdLimitsB": facilitiesWithCbdLimitsB,
      "facilitiesWithCbdOutstandingD": facilitiesWithCbdOutstandingD,
      "shareOfWalletLimits": shareOfWalletLimits,
      "shareOfWalletOutstanding": shareOfWalletOutstanding,
    };
  }
}
