import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/group_information/cbrb_data.dart";
import "package:wcas_frontend/models/request/group_information/risk_bureau.dart";
import "package:wcas_frontend/models/request/group_information/share_of_wallet_data.dart";

void main() {
  group("RiskBureau", () {
    test("fromJson creates a valid RiskBureau object", () {
      final Map<String, dynamic> json = {
        "cbrbDataList": [
          {
            "rimNo": 1,
            "customerName": "CBRB 1",
          }
        ],
        "shareOfWalletList": [
          {
            "rim": 1,
            "customerName": "SOW 1",
          }
        ],
      };

      final riskBureau = RiskBureau.fromJson(json);

      expect(riskBureau, isNotNull);
      expect(riskBureau.cbrbDataList, isA<List<CBRB>>());
      expect(riskBureau.cbrbDataList!.length, 1);
      expect(riskBureau.cbrbDataList![0].rimNo, 1);
      expect(riskBureau.shareOfWalletList, isA<List<ShareOfWalletData>>());
      expect(riskBureau.shareOfWalletList!.length, 1);
      expect(riskBureau.shareOfWalletList![0].rim, 1);
    });

    test("fromJson handles null cbrbDataList and shareOfWalletList", () {
      final Map<String, dynamic> json = {};

      final riskBureau = RiskBureau.fromJson(json);

      expect(riskBureau, isNotNull);
      expect(riskBureau.cbrbDataList, isNull);
      expect(riskBureau.shareOfWalletList, isNull);
    });

    test("toJson converts RiskBureau object to JSON", () {
      final riskBureau = RiskBureau(
        cbrbDataList: [
          CBRB(rimNo: 1, customerName: "CBRB 1"),
        ],
        shareOfWalletList: [
          ShareOfWalletData(rim: 1, customerName: "SOW 1"),
        ],
      );

      final json = riskBureau.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json["cbrbDataList"], isA<List<dynamic>>());
      expect(json["cbrbDataList"][0]["rimNo"], 1);
      expect(json["shareOfWalletList"], isA<List<dynamic>>());
      expect(json["shareOfWalletList"][0]["rim"], 1);
    });

    test("toJson handles null cbrbDataList and shareOfWalletList", () {
      final riskBureau = RiskBureau();

      final json = riskBureau.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json["cbrbDataList"], isNull);
      expect(json["shareOfWalletList"], isNull);
    });
  });
}
