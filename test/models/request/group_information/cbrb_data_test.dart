import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/group_information/cbrb_data.dart";

void main() {
  group("CBRB", () {
    test("CBRB.fromJson should correctly parse JSON", () {
      final Map<String, dynamic> json = {
        "rimNo": 123,
        "customerName": "Test Customer",
        "fundedLimitAllBanks": 1000,
        "nonFundedLimitAllBanks": 500,
        "fundedOutstandingAllBanks": 800,
        "nonFundedOutstandingAllBanks": 400,
        "fundedLimitCBD": 700,
        "nonFundedLimitCBD": 300,
        "fundedOutstandingCBD": 600,
        "nonFundedOutstandingCBD": 200,
        "noOfBanks": 5,
        "cbrbClassifications": "A",
        "new": true,
        "deleted": false,
      };

      final cbrb = CBRB.fromJson(json);

      expect(cbrb.rimNo, 123);
      expect(cbrb.customerName, "Test Customer");
      expect(cbrb.fundedLimitAllBanks, 1000);
      expect(cbrb.nonFundedLimitAllBanks, 500);
      expect(cbrb.fundedOutstandingAllBanks, 800);
      expect(cbrb.nonFundedOutstandingAllBanks, 400);
      expect(cbrb.fundedLimitCBD, 700);
      expect(cbrb.nonFundedLimitCBD, 300);
      expect(cbrb.fundedOutstandingCBD, 600);
      expect(cbrb.nonFundedOutstandingCBD, 200);

      expect(cbrb.noOfBanks, 5);
      expect(cbrb.cbrbClassifications, "A");
      expect(cbrb.news, true);
      expect(cbrb.deleted, false);
    });

    test("CBRB.toJson should correctly convert to JSON", () {
      final cbrb = CBRB(
        rimNo: 123,
        customerName: "Test Customer",
        fundedLimitAllBanks: 1000,
        nonFundedLimitAllBanks: 500,
        fundedOutstandingAllBanks: 800,
        nonFundedOutstandingAllBanks: 400,
        fundedLimitCBD: 700,
        nonFundedLimitCBD: 300,
        fundedOutstandingCBD: 600,
        nonFundedOutstandingCBD: 200,
        noOfBanks: 5,
        cbrbClassifications: "A",
        news: true,
        deleted: false,
      );

      final json = cbrb.toJson();

      expect(json["rimNo"], 123);
      expect(json["customerName"], "Test Customer");
      expect(json["fundedLimitAllBanks"], 1000);
      expect(json["nonFundedLimitAllBanks"], 500);
      expect(json["fundedOutstandingAllBanks"], 800);
      expect(json["nonFundedOutstandingAllBanks"], 400);
      expect(json["fundedLimitCBD"], 700);
      expect(json["nonFundedLimitCBD"], 300);
      expect(json["fundedOutstandingCBD"], 600);
      expect(json["nonFundedOutstandingCBD"], 200);

      expect(json["noOfBanks"], "5");
      expect(json["cbrbClassifications"], "A");
      expect(json["new"], true);
      expect(json["deleted"], false);
    });

    test("CBRB constructor should correctly assign values", () {
      final cbrb = CBRB(
        rimNo: 123,
        customerName: "Test Customer",
        fundedLimitAllBanks: 1000,
        nonFundedLimitAllBanks: 500,
        fundedOutstandingAllBanks: 800,
        nonFundedOutstandingAllBanks: 400,
        fundedLimitCBD: 700,
        nonFundedLimitCBD: 300,
        fundedOutstandingCBD: 600,
        nonFundedOutstandingCBD: 200,
        noOfBanks: 5,
        cbrbClassifications: "A",
        news: true,
        deleted: false,
      );

      expect(cbrb.rimNo, 123);
      expect(cbrb.customerName, "Test Customer");
      expect(cbrb.fundedLimitAllBanks, 1000);
      expect(cbrb.nonFundedLimitAllBanks, 500);
      expect(cbrb.fundedOutstandingAllBanks, 800);
      expect(cbrb.nonFundedOutstandingAllBanks, 400);
      expect(cbrb.fundedLimitCBD, 700);
      expect(cbrb.nonFundedLimitCBD, 300);
      expect(cbrb.fundedOutstandingCBD, 600);
      expect(cbrb.nonFundedOutstandingCBD, 200);

      expect(cbrb.noOfBanks, 5);
      expect(cbrb.cbrbClassifications, "A");
      expect(cbrb.news, true);
      expect(cbrb.deleted, false);
    });
  });
}
