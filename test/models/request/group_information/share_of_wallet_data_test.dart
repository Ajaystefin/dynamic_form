import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/group_information/share_of_wallet_data.dart";

void main() {
  group("ShareOfWalletData", () {
    test("fromJson creates a valid object from JSON", () {
      final Map<String, dynamic> json = {
        "rim": 12345,
        "customerName": "Test Customer",
        "allBankTotalLimit": 100000,
        "allBankTotalOutstanding": 50000,
        "cbdTotalLimit": 70000,
        "cbdTotalOutstanding": 30000,
      };

      final shareOfWalletData = ShareOfWalletData.fromJson(json);

      expect(shareOfWalletData, isA<ShareOfWalletData>());
      expect(shareOfWalletData.rim, 12345);
      expect(shareOfWalletData.customerName, "Test Customer");
      expect(shareOfWalletData.allBankTotalLimit, 100000);
      expect(shareOfWalletData.allBankTotalOutstanding, 50000);
      expect(shareOfWalletData.cbdTotalLimit, 70000);
      expect(shareOfWalletData.cbdTotalOutstanding, 30000);
    });

    test("toJson converts a valid object to JSON", () {
      final shareOfWalletData = ShareOfWalletData(
        rim: 12345,
        customerName: "Test Customer",
        allBankTotalLimit: 100000,
        allBankTotalOutstanding: 50000,
        cbdTotalLimit: 70000,
        cbdTotalOutstanding: 30000,
        shareOfWalletLimit: 70,
        shareOfWalletOutstanding: 60,
      );

      final json = shareOfWalletData.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json["rim"], 12345);
      expect(json["customerName"], "Test Customer");
      expect(json["allBankTotalLimit"], 100000);
      expect(json["allBankTotalOutstanding"], 50000);
      expect(json["cbdTotalLimit"], 70000);
      expect(json["cbdTotalOutstanding"], 30000);
      expect(json["shareOfWalletLimit"], 70);
      expect(json["shareOfWalletOutstanding"], 60);
    });

    test("fromJson handles null values", () {
      final Map<String, dynamic> json = {};
      final shareOfWalletData = ShareOfWalletData.fromJson(json);

      expect(shareOfWalletData.rim, isNull);
      expect(shareOfWalletData.customerName, isNull);
      expect(shareOfWalletData.allBankTotalLimit, isNull);
      expect(shareOfWalletData.allBankTotalOutstanding, isNull);
      expect(shareOfWalletData.cbdTotalLimit, isNull);
      expect(shareOfWalletData.cbdTotalOutstanding, isNull);
      expect(shareOfWalletData.shareOfWalletLimit, isNull);
      expect(shareOfWalletData.shareOfWalletOutstanding, isNull);
    });

    test("toJson handles null values", () {
      final shareOfWalletData = ShareOfWalletData();
      final json = shareOfWalletData.toJson();

      expect(json["rim"], isNull);
      expect(json["customerName"], isNull);
      expect(json["allBankTotalLimit"], isNull);
      expect(json["allBankTotalOutstanding"], isNull);
      expect(json["cbdTotalLimit"], isNull);
      expect(json["cbdTotalOutstanding"], isNull);
      expect(json["shareOfWalletLimit"], isNull);
      expect(json["shareOfWalletOutstanding"], isNull);
    });
  });
}
