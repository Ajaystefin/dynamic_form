import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";

void main() {
  group("GroupPosition", () {
    test("fromJson creates a valid GroupPosition object", () {
      final Map<String, dynamic> json = {
        "present_position": [
          {
            "customerName": "Customer A",
            "modelGeneratedCRR": 10,
            "overriddenCRR": 12,
            "fundBasedLimits": 100.0,
            "nonFundBasedLimits": 50.0,
            "totalLimits": 150.0,
            "totalTangibleSecurity": 20.0,
            "ofWhichCashCollateral": 10.0,
            "totalLimitsNetOfTotalTangibleSecurity": 130.0,
            "totalLimitsNetOfCashCollateralOnly": 140.0,
          }
        ],
        "proposed_position": [
          {
            "customerName": "Customer B",
            "modelGeneratedCRR": 15,
            "overriddenCRR": 18,
            "fundBasedLimits": 200.0,
            "nonFundBasedLimits": 75.0,
            "totalLimits": 275.0,
            "totalTangibleSecurity": 30.0,
            "ofWhichCashCollateral": 15.0,
            "totalLimitsNetOfTotalTangibleSecurity": 245.0,
            "totalLimitsNetOfCashCollateralOnly": 260.0,
          }
        ],
      };

      final groupPosition = GroupPosition.fromJson(json);

      expect(groupPosition.presentPosition, isNotNull);
      expect(groupPosition.presentPosition!.length, 1);
      expect(groupPosition.presentPosition![0].customerName, "Customer A");

      expect(groupPosition.proposedPosition, isNotNull);
      expect(groupPosition.proposedPosition!.length, 1);
      expect(groupPosition.proposedPosition![0].customerName, "Customer B");
    });

    test("toJson converts GroupPosition object to JSON", () {
      final groupPosition = GroupPosition(
        presentPosition: [
          Position(
            customerName: "Customer A",
            modelGeneratedCRR: 10,
            overriddenCRR: 12,
            fundBasedLimits: 100,
            nonFundBasedLimits: 50,
            totalLimits: 150,
            totalTangibleSecurity: 20,
            ofWhichCashCollateral: 10,
            totalLimitsNetOfTotalTangibleSecurity: 130,
            totalLimitsNetOfCashCollateralOnly: 140,
          ),
        ],
        proposedPosition: [
          Position(
            customerName: "Customer B",
            modelGeneratedCRR: 15,
            overriddenCRR: 18,
            fundBasedLimits: 200,
            nonFundBasedLimits: 75,
            totalLimits: 275,
            totalTangibleSecurity: 30,
            ofWhichCashCollateral: 15,
            totalLimitsNetOfTotalTangibleSecurity: 245,
            totalLimitsNetOfCashCollateralOnly: 260,
          ),
        ],
      );

      final json = groupPosition.toJson();

      expect(json["present_position"], isNotNull);
      expect(json["present_position"][0]["customerName"], "Customer A");

      expect(json["proposed_position"], isNotNull);
      expect(json["proposed_position"][0]["customerName"], "Customer B");
    });

    test("fromJson handles null or empty lists", () {
      final Map<String, dynamic> json = {
        "present_position": null,
        "proposed_position": [],
      };

      final groupPosition = GroupPosition.fromJson(json);

      expect(groupPosition.presentPosition, isNull);
      expect(groupPosition.proposedPosition, isNotNull);
      expect(groupPosition.proposedPosition, isEmpty);
    });

    test("toJson handles null or empty lists", () {
      final groupPosition = GroupPosition(
        proposedPosition: [],
      );

      final json = groupPosition.toJson();

      expect(json["present_position"], isNull);
      expect(json["proposed_position"], isNotNull);
      expect(json["proposed_position"], isEmpty);
    });
  });

  group("Position", () {
    test("fromJson creates a valid Position object", () {
      final Map<String, dynamic> json = {
        "custName": "Test Customer",
        "modelCRR": 10,
        "overriddenCRR": 12,
        "fundedProposedLimit": 100.0,
        "nonFundedProposedLimit": 50.0,
        "totalProposedLimits": 150.0,
        "totalTangibleProposedSecurity": 20.0,
        "totalCCProposedSecurity": 10.0,
        // 'totalLimitsNetOfTotalTangibleSecurity': 130.0,
        // 'totalLimitsNetOfCashCollateralOnly': 140.0,
      };

      final position = Position.fromJsonProposed(json);

      expect(position.customerName, "Test Customer");
      expect(position.modelGeneratedCRR, 10);
      expect(position.overriddenCRR, 12);
      expect(position.fundBasedLimits, 100.0);
      expect(position.nonFundBasedLimits, 50.0);
      expect(position.totalLimits, 150.0);
      expect(position.totalTangibleSecurity, 20.0);
      expect(position.ofWhichCashCollateral, 10.0);
      // expect(position.totalLimitsNetOfTotalTangibleSecurity, 130.0);
      // expect(position.totalLimitsNetOfCashCollateralOnly, 140.0);
    });

    test("toJson converts Position object to JSON", () {
      final position = Position(
        customerName: "Test Customer",
        modelGeneratedCRR: 10,
        overriddenCRR: 12,
        fundBasedLimits: 100,
        nonFundBasedLimits: 50,
        totalLimits: 150,
        totalTangibleSecurity: 20,
        ofWhichCashCollateral: 10,
        totalLimitsNetOfTotalTangibleSecurity: 130,
        totalLimitsNetOfCashCollateralOnly: 140,
      );

      final json = position.toJson();

      expect(json["customerName"], "Test Customer");
      expect(json["modelGeneratedCRR"], 10);
      expect(json["overriddenCRR"], 12);
      expect(json["fundBasedLimits"], 100.0);
      expect(json["nonFundBasedLimits"], 50.0);
      expect(json["totalLimits"], 150.0);
      expect(json["totalTangibleSecurity"], 20.0);
      expect(json["ofWhichCashCollateral"], 10.0);
      expect(json["totalLimitsNetOfTotalTangibleSecurity"], 130.0);
      expect(json["totalLimitsNetOfCashCollateralOnly"], 140.0);
    });
  });

  group("CustomerPosition", () {
    test("CustomerPosition object is created correctly", () {
      final customerPosition = CustomerPosition(
        rimNo: "123",
        order: 3,
        customerName: "Test Customer",
        presentRowValues: ["10", "20"],
        proposedRowValues: ["30", "40"],
      );

      expect(customerPosition.customerName, "Test Customer");
      expect(customerPosition.presentRowValues, ["10", "20"]);
      expect(customerPosition.proposedRowValues, ["30", "40"]);
    });
  });
}
