import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/share_of_wallet.dart";

void main() {
  group("ShareOfWallet", () {
    test("fromJson creates a valid instance", () {
      final Map<String, dynamic> json = {
        "customerRimNo": 123,
        "customerName": "Test Customer",
        "facilitiesWithAllBanksLimitsA": 100000.0,
        "facilitiesWithAllBanksOutstandingC": 80000.0,
        "facilitiesWithCbdLimitsB": 50000.0,
        "facilitiesWithCbdOutstandingD": 40000.0,
        "shareOfWalletLimits": 50.0,
        "shareOfWalletOutstanding": 50.0,
      };

      final shareOfWallet = ShareOfWallet.fromJson(json);

      expect(shareOfWallet.customerRimNo, 123);
      expect(shareOfWallet.customerName, "Test Customer");
      expect(shareOfWallet.facilitiesWithAllBanksLimitsA, 100000.0);
      expect(shareOfWallet.facilitiesWithAllBanksOutstandingC, 80000.0);
      expect(shareOfWallet.facilitiesWithCbdLimitsB, 50000.0);
      expect(shareOfWallet.facilitiesWithCbdOutstandingD, 40000.0);
      expect(shareOfWallet.shareOfWalletLimits, 50.0);
      expect(shareOfWallet.shareOfWalletOutstanding, 50.0);
    });

    test("toJson converts instance to JSON correctly", () {
      final shareOfWallet = ShareOfWallet(
        customerRimNo: 123,
        customerName: "Test Customer",
        facilitiesWithAllBanksLimitsA: 100000,
        facilitiesWithAllBanksOutstandingC: 80000,
        facilitiesWithCbdLimitsB: 50000,
        facilitiesWithCbdOutstandingD: 40000,
        shareOfWalletLimits: 50,
        shareOfWalletOutstanding: 50,
      );

      final json = shareOfWallet.toJson();

      expect(json["customerRimNo"], 123);
      expect(json["customerName"], "Test Customer");
      expect(json["facilitiesWithAllBanksLimitsA"], 100000.0);
      expect(json["facilitiesWithAllBanksOutstandingC"], 80000.0);
      expect(json["facilitiesWithCbdLimitsB"], 50000.0);
      expect(json["facilitiesWithCbdOutstandingD"], 40000.0);
      expect(json["shareOfWalletLimits"], 50.0);
      expect(json["shareOfWalletOutstanding"], 50.0);
    });
  });
}
