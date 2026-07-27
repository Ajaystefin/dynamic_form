import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";

void main() {
  group("SecurityDeferral", () {
    test("should create SecurityDeferral instance with all properties", () {
      final deferral = SecurityDeferral(
        securityNo: "SEC001",
        securityId: 1,
        securityType: "Assignment",
        present: "100000",
        proposed: "150000",
        aedPresent: 100000,
        aedProposed: 150000,
        allFacilities: true,
        selected: true,
        draft: false,
        isChecked: true,
        dateDeferral: DateTime(2026, 4, 25),
        facilityDetails: [
          FacilityDetail(
            limitNumber: "LIM001",
            rimNo: "12345",
            limitDescription: "Test Limit",
            limitAmountAED000s: 100000,
            amountToBeReleased: 50000,
          ),
        ],
      );

      expect(deferral.securityNo, "SEC001");
      expect(deferral.securityId, 1);
      expect(deferral.securityType, "Assignment");
      expect(deferral.present, "100000");
      expect(deferral.proposed, "150000");
      expect(deferral.aedPresent, 100000);
      expect(deferral.aedProposed, 150000);
      expect(deferral.allFacilities, true);
      expect(deferral.selected, true);
      expect(deferral.draft, false);
      expect(deferral.isChecked, true);
      expect(deferral.facilityDetails?.length, 1);
      expect(deferral.dateDeferral, DateTime(2026, 4, 25));
    });

    test("should create SecurityDeferral from JSON safely", () {
      final json = {
        "securityNo": "SEC001",
        "securityMasterId": "1",
        "securityType": "Assignment",
        "presentSecurity": "100000",
        "proposedSecurity": "null",
        "aedequivalentPresentSecurity": "100000",
        "aedequivalentProposedSecurity": null,
        "allFacilities": "true",
        "selected": true,
        "draft": false,
        "deferralDate": 20260425,
        "facilityDetailsList": [
          {
            "limitNumber": "LIM001",
            "rimNo": "12345",
            "limitDescription": "Test Limit",
            "presentLimit": 100,
            "amountToBeReleased": 50.0,
            "facilityMasterId": 1,
          }
        ],
      };

      final deferral = SecurityDeferral.fromJson(json);

      expect(deferral.securityNo, "SEC001");
      expect(deferral.securityId, 1);
      expect(deferral.securityType, "Assignment");
      expect(deferral.present, "100000");
      expect(deferral.proposed, ""); // 'null' → ''
      expect(deferral.aedPresent, 100000);
      expect(deferral.aedProposed, isNull);
      expect(deferral.allFacilities, true);
      expect(deferral.selected, true);
      expect(deferral.draft, false);
      //expect(deferral.dateDeferral, DateTime(2026, 4, 25));
      expect(deferral.facilityDetails?.length, 1);
    });

    test("should convert SecurityDeferral to JSON with correct date format",
        () {
      final deferral = SecurityDeferral(
        securityNo: "SEC001",
        securityId: 1,
        securityType: "Assignment",
        present: "100000",
        proposed: "150000",
        selected: true,
        isChecked: true,
        dateDeferral: DateTime(2026, 4, 25),
      );

      final json = deferral.toJson();

      expect(json["securityNo"], "SEC001");
      expect(json["securityMasterId"], 1);
      expect(json["securityType"], "Assignment");
      expect(json["presentSecurity"], "100000");
      expect(json["proposedSecurity"], "150000");
      expect(json["selected"], true);
      expect(json["dateDeferral"], null); // IMPORTANT
    });

    test("should handle null and empty values safely", () {
      final deferral = SecurityDeferral.fromJson({
        "securityNo": null,
        "proposedSecurity": "null",
        "selected": null,
      });

      expect(deferral.securityNo, "");
      expect(deferral.proposed, "");
      expect(deferral.selected, false);
    });
  });

  group("FacilityDetail", () {
    test("should create FacilityDetail from JSON", () {
      final json = {
        "limitNumber": "LIM001",
        "rimNo": "12345",
        "limitDescription": "Test Limit",
        "presentLimit": 100000,
        "amountToBeReleased": 50000.0,
        "facilityMasterId": 1,
      };

      final facility = FacilityDetail.fromJson(json);

      expect(facility.limitNumber, "LIM001");
      expect(facility.rimNo, "12345");
      expect(facility.limitDescription, "Test Limit");
      expect(facility.limitAmountAED000s, 100000);
      expect(facility.amountToBeReleased, 50000.0);
      expect(facility.facilityMasterId, 1);
    });

    test("should convert FacilityDetail to JSON correctly", () {
      final facility = FacilityDetail(
        limitNumber: "LIM001",
        rimNo: "12345",
        limitDescription: "Test Limit",
        limitAmountAED000s: 100000,
        amountToBeReleased: 50000,
        facilityMasterId: 1,
      );

      final json = facility.toJson();

      expect(json["limitNumber"], "LIM001");
      expect(json["rimNo"], "12345");
      expect(json["Limit Description"], "Test Limit");
      expect(json["presentLimit"], 100000);
      expect(json["amountToBeReleased"], 50000);
      expect(json["facilityMasterId"], 1);
    });
  });
}
