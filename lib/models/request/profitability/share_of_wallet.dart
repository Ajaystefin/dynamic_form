class ShareOfWallet {
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
  final int customerRimNo;
  final String customerName;
  final double facilitiesWithAllBanksLimitsA;
  final double facilitiesWithAllBanksOutstandingC;
  final double facilitiesWithCbdLimitsB;
  final double facilitiesWithCbdOutstandingD;
  final double shareOfWalletLimits;
  final double shareOfWalletOutstanding;

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
