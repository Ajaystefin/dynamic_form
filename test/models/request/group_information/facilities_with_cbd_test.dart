import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/group_information/facilities_with_cbd.dart";

void main() {
  group("FacilitiesWithCbd", () {
    test("fromJson creates a valid object from JSON", () {
      final Map<String, dynamic> json = {
        "customerName": "Test Customer",
        "customerRim": 12345,
        "cbrbClassification": "A",
        "crr": 100.0,
        "fundedCurrentLimit": 1000.0,
        "nonFundedCurrentLimit": 500.0,
        "fundedProposedLimit": 1200.0,
        "nonFundedProposedLimit": 600.0,
        "fundedOutstanding": 800.0,
        "fundedPastDues": 50.0,
        "nonFundedOutstanding": 300.0,
        "nonFundedPastDues": 20.0,
        "category": "Category A",
        "previousApprovedCrr": 90.0,
      };

      final facilitiesWithCbd = FacilitiesWithCbd.fromJson(json);

      expect(facilitiesWithCbd, isA<FacilitiesWithCbd>());
      expect(facilitiesWithCbd.customerName, "Test Customer");
      expect(facilitiesWithCbd.customerRim, 12345);
      expect(facilitiesWithCbd.cbrbClassification, "A");
      expect(facilitiesWithCbd.crr, 100);
      expect(facilitiesWithCbd.fundedCurrentLimit, 1000);
      expect(facilitiesWithCbd.nonFundedCurrentLimit, 500);
      expect(facilitiesWithCbd.fundedProposedLimit, 1200);
      expect(facilitiesWithCbd.nonFundedProposedLimit, 600);
      expect(facilitiesWithCbd.fundedOutstanding, 800);
      expect(facilitiesWithCbd.fundedPastDues, 50);
      expect(facilitiesWithCbd.nonFundedOutstanding, 300);
      expect(facilitiesWithCbd.nonFundedPastDues, 20);
      expect(facilitiesWithCbd.category, "Category A");
      expect(facilitiesWithCbd.previousApprovedCrr, 90);
    });

    test("toJson converts a valid object to JSON", () {
      final facilitiesWithCbd = FacilitiesWithCbd(
        customerName: "Test Customer",
        customerRim: 12345,
        cbrbClassification: "A",
        crr: 100,
        fundedCurrentLimit: 1000,
        nonFundedCurrentLimit: 500,
        fundedProposedLimit: 1200,
        nonFundedProposedLimit: 600,
        fundedOutstanding: 800,
        fundedPastDues: 50,
        nonFundedOutstanding: 300,
        nonFundedPastDues: 20,
        category: "Category A",
        previousApprovedCrr: 90,
      );

      final json = facilitiesWithCbd.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json["customerName"], "Test Customer");
      expect(json["customerRim"], 12345);
      expect(json["cbrbClassification"], "A");
      expect(json["crr"], 100);
      expect(json["fundedCurrentLimit"], 1000);
      expect(json["nonFundedCurrentLimit"], 500);
      expect(json["fundedProposedLimit"], 1200);
      expect(json["nonFundedProposedLimit"], 600);
      expect(json["fundedOutstanding"], 800);
      expect(json["fundedPastDues"], 50);
      expect(json["nonFundedOutstanding"], 300);
      expect(json["nonFundedPastDues"], 20);
      expect(json["category"], "Category A");
      expect(json["previousApprovedCrr"], 90);
    });

    test("fromJson handles null values", () {
      final Map<String, dynamic> json = {};
      final facilitiesWithCbd = FacilitiesWithCbd.fromJson(json);

      expect(facilitiesWithCbd.customerName, isNull);
      expect(facilitiesWithCbd.customerRim, isNull);
      expect(facilitiesWithCbd.cbrbClassification, isNull);
      expect(facilitiesWithCbd.crr, isNull);
      expect(facilitiesWithCbd.fundedCurrentLimit, isNull);
      expect(facilitiesWithCbd.nonFundedCurrentLimit, isNull);
      expect(facilitiesWithCbd.fundedProposedLimit, isNull);
      expect(facilitiesWithCbd.nonFundedProposedLimit, isNull);
      expect(facilitiesWithCbd.fundedOutstanding, isNull);
      expect(facilitiesWithCbd.fundedPastDues, isNull);
      expect(facilitiesWithCbd.nonFundedOutstanding, isNull);
      expect(facilitiesWithCbd.nonFundedPastDues, isNull);
      expect(facilitiesWithCbd.category, isNull);
      expect(facilitiesWithCbd.previousApprovedCrr, isNull);
    });

    test("toJson handles null values", () {
      final facilitiesWithCbd = FacilitiesWithCbd();
      final json = facilitiesWithCbd.toJson();

      expect(json["customerName"], isNull);
      expect(json["customerRim"], isNull);
      expect(json["cbrbClassification"], isNull);
      expect(json["crr"], isNull);
      expect(json["fundedCurrentLimit"], isNull);
      expect(json["nonFundedCurrentLimit"], isNull);
      expect(json["fundedProposedLimit"], isNull);
      expect(json["nonFundedProposedLimit"], isNull);
      expect(json["fundedOutstanding"], isNull);
      expect(json["fundedPastDues"], isNull);
      expect(json["nonFundedOutstanding"], isNull);
      expect(json["nonFundedPastDues"], isNull);
      expect(json["category"], isNull);
      expect(json["previousApprovedCrr"], isNull);
    });
  });
}
