import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

void main() {
  group("Facility Class Tests", () {
    test("Default constructor values", () {
      final facility = Facility();
      expect(facility.limitNumber, null);
      expect(facility.controllingLimitNumber, null);
      expect(facility.isPolicyDeviation, false);
      expect(facility.isConditionsStandard, false);
      expect(facility.isCrossBoarderExposure, false);
    });

    test("toJson returns correct keys and values", () {
      final facility = Facility(
        rimNo: 123,
        limitNumber: "LIMIT123",
        proposedLimit: 5000,
        remarks: "Test remarks",
        additionalDetails: "Additional info",
        facilityTypeName: "Type A",
        projectName: Reference(name: "Project X"),
        selectedProductTypeValue: Reference(id: 10, name: "ProductType"),
        selectedpromissoryNoteValue: Reference(id: 1),
      );

      final json = facility.toJson();
      expect(json["rimNo"], 123);
      expect(json["limitNumber"], null);
      expect(json["proposedLimit"], 5000);
      expect(json["remarks"], "Test remarks");
      expect(json["additionalDetails"], "Additional info");
      expect(json["facilityTypeName"], "Type A");
      expect(json["projectName"], "Project X");
      expect(json["productType"], 10);
      // expect(json['promissoryNoteTaken'], true);
    });

    test("fromJson parses values correctly", () {
      final json = {
        "rimNo": "123",
        "limitNumber": "LIMIT999",
        "appRefNo": "APP123",
        "controllingLimitNumber": "CTRL123",
        "limitLabel": "Label",
        "limitDescription": "Description",
        "presentLimit": 1000,
        "proposedLimit": 2000,
        "facilityID": 1,
        "remarks": "Some remarks",
        "additionalDetails": "Extra details",
        "S_No": 1,
        "Facility_Details": "Details",
        "Sub_Facility_Details": "SubDetails",
        "Sustainability_Classification": ["Green", "Eco"],
        "Existing_Limits": 3000,
        "Proposed_Limits": 4000,
        "Outstanding": 500,
        "Tenor_Days": 30,
        "Applicable_Pricing": "Pricing",
        "Margin": "MarginValue",
        "projectName": "Project Y",
        "facilityTypeName": "Type B",
      };

      final facility = Facility.fromJson(json);
      expect(facility.rimNo, 123);
      expect(facility.limitNumber, "LIMIT999");
      expect(facility.appRefNo, "APP123");
      expect(facility.controllingLimitNumber, null);
      expect(facility.limitLabel, "Label");
      expect(facility.limitDescription, "Description");
      expect(facility.presentLimit, 1000);
      expect(facility.proposedLimit, 2000);
      expect(facility.facilityId, 1);
      expect(facility.remarks, "Some remarks");
      expect(facility.additionalDetails, "Extra details");
      expect(facility.sNo, 1);
      expect(facility.facilityDetails, "Details");
      expect(facility.subFacilityDetails, "SubDetails");
      expect(facility.sustainabilityClassification?.length, 2);
      expect(facility.existingLimits, 3000);
      expect(facility.proposedLimits, 4000);
      expect(facility.outstanding, 500);
      expect(facility.tenorDays, 30);
      expect(facility.applicablePricing, "Pricing");
      // expect(facility.margin, 'MarginValue');
      expect(facility.projectName?.name, "Project Y");
      expect(facility.facilityTypeName, "Type B");
    });

    test("fromJson handles missing and null values gracefully", () {
      final json = {"rimNo": null};
      final facility = Facility.fromJson(json);
      expect(facility.rimNo, 0);
      expect(facility.limitNumber, isNull);
    });
  });

  group("FacilitySubTypes Class Tests", () {
    test("Constructor assigns values correctly", () {
      final subType = FacilitySubTypes(
        subTypeSelected: true,
        subType: "Loan",
        commitmentAccountNumber: "ACC123",
        currentOutstanding: 1000,
        pastDues: 200,
        existingAmounts: 5000,
        proposedLimit: 7000,
        tenor: 12,
        commission: 50,
      );

      expect(subType.subTypeSelected, true);
      expect(subType.subType, "Loan");
      expect(subType.commitmentAccountNumber, "ACC123");
      expect(subType.currentOutstanding, 1000);
      expect(subType.pastDues, 200);
      expect(subType.existingAmounts, 5000);
      expect(subType.proposedLimit, 7000);
      expect(subType.tenor, 12);
      expect(subType.commission, 50);
    });

    test("toJson returns correct map", () {
      final subType = FacilitySubTypes(
        subTypeSelected: false,
        subType: "Credit",
        commitmentAccountNumber: "ACC999",
        currentOutstanding: 1500,
        pastDues: 300,
        existingAmounts: 6000,
        proposedLimit: 8000,
        tenor: 24,
        commission: 75,
      );

      final json = subType.toJson();
      expect(json["subTypeSelected"], false);
      expect(json["subType"], "Credit");
      expect(json["commitmentAccountNumber"], "ACC999");
      expect(json["currentOutstanding"], 1500);
      expect(json["pastDues"], 300);
      expect(json["existingAmounts"], 6000);
      expect(json["proposedLimit"], 8000);
      expect(json["tenor"], 24);
      expect(json["commission"], 75);
    });

    test("fromJson handles missing and null values gracefully", () {
      final json = {"subType": null};
      final subType = FacilitySubTypes.fromJson(json);
      expect(subType.subTypeSelected, isNull);
      expect(subType.subType, isNull);
      expect(subType.commitmentAccountNumber, isNull);
      expect(subType.currentOutstanding, isNull);
      expect(subType.pastDues, isNull);
      expect(subType.existingAmounts, isNull);
      expect(subType.proposedLimit, isNull);
      expect(subType.tenor, isNull);
      expect(subType.commission, isNull);
    });
  });

  group("Facility.fromJsonLinkage", () {
    test("parses rimNo from int", () {
      final f = Facility.fromJsonLinkage({"rimNo": 123});
      expect(f.rimNo, 123);
    });

    test("parses rimNo from double (toInt)", () {
      final f = Facility.fromJsonLinkage({"rimNo": 123.9});
      expect(f.rimNo, 123); // double.toInt() truncates
    });

    test("parses rimNo from numeric string", () {
      final f = Facility.fromJsonLinkage({"rimNo": "456"});
      expect(f.rimNo, 456);
    });

    test("rimNo defaults to 0 for non-numeric string and other types", () {
      final f1 = Facility.fromJsonLinkage({"rimNo": "abc"});
      expect(f1.rimNo, 0);

      final f2 = Facility.fromJsonLinkage({
        "rimNo": {"unexpected": true},
      });
      expect(f2.rimNo, 0);

      final f3 = Facility.fromJsonLinkage({"rimNo": null});
      expect(f3.rimNo, 0);
    });

    test("limitNumber prefers limitNumber over limitNo when both exist", () {
      final f = Facility.fromJsonLinkage(
        {"rimNo": 0, "limitNumber": "LN-1", "limitNo": "LN-2"},
      );
      expect(f.limitNumber, "LN-1");
    });

    test("limitNumber falls back to limitNo when limitNumber is absent", () {
      final f = Facility.fromJsonLinkage({"rimNo": 0, "limitNo": "LN-2"});
      expect(f.limitNumber, "LN-2");
    });

    test("limitNumber null when neither key present", () {
      final f = Facility.fromJsonLinkage({"rimNo": 0});
      expect(f.limitNumber, isNull);
    });

    test("appRefNo casts to String? correctly", () {
      final f1 = Facility.fromJsonLinkage({"rimNo": 0, "appRefNo": "APP-007"});
      expect(f1.appRefNo, "APP-007");

      final f2 = Facility.fromJsonLinkage({"rimNo": 0, "appRefNo": null});
      expect(f2.appRefNo, isNull);
    });

    test("controllingLimitNumber preserved as dynamic", () {
      final f1 = Facility.fromJsonLinkage(
        {"rimNo": 0, "controllingLimitNumber": "CL-01"},
      );
      expect(f1.controllingLimitNumber, "CL-01");

      final f2 = Facility.fromJsonLinkage(
        {"rimNo": 0, "controllingLimitNumber": "999"},
      );
      expect(f2.controllingLimitNumber, "999");

      final f3 = Facility.fromJsonLinkage({"rimNo": 0});
      expect(f3.controllingLimitNumber, isNull);
    });

    test(
        "limitDescription parseString: trims, handles int/double, defaults to empty",
        () {
      final f1 = Facility.fromJsonLinkage(
        {"rimNo": 0, "limitDescription": "  Hello  "},
      );
      expect(f1.limitDescription, "Hello");

      final f2 = Facility.fromJsonLinkage({"rimNo": 0, "limitDescription": 42});
      expect(f2.limitDescription, "42");

      final f3 =
          Facility.fromJsonLinkage({"rimNo": 0, "limitDescription": 3.14});
      expect(f3.limitDescription, "3.14");

      final f4 =
          Facility.fromJsonLinkage({"rimNo": 0, "limitDescription": null});
      expect(f4.limitDescription, "");

      final f5 = Facility.fromJsonLinkage({
        "rimNo": 0,
        "limitDescription": {"unexpected": true},
      });
      expect(f5.limitDescription, "");
    });

    test("proposedLimit preserved as dynamic", () {
      final f1 =
          Facility.fromJsonLinkage({"rimNo": 0, "proposedLimit": 100000});
      expect(f1.proposedLimit, 100000);

      final f2 =
          Facility.fromJsonLinkage({"rimNo": 0, "proposedLimit": 100000});
      expect(f2.proposedLimit, 100000);

      final f3 = Facility.fromJsonLinkage({"rimNo": 0});
      expect(f3.proposedLimit, isNull);
    });

    test("projectName creates Reference when not null; null otherwise", () {
      final f1 =
          Facility.fromJsonLinkage({"rimNo": 0, "projectName": "Project X"});
      expect(f1.projectName, isNotNull);
      expect(f1.projectName!.name, "Project X");

      final f2 = Facility.fromJsonLinkage({"rimNo": 0, "projectName": null});
      expect(f2.projectName, isNull);

      final f3 = Facility.fromJsonLinkage({"rimNo": 0});
      expect(f3.projectName, isNull);
    });

    test("full object mapping sanity check", () {
      final f = Facility.fromJsonLinkage({
        "rimNo": "789",
        "limitNumber": "LN-789",
        "appRefNo": "APP-789",
        "controllingLimitNumber": "CL-789",
        "limitDescription": "  Desc  ",
        "proposedLimit": 50000,
        "projectName": "Mega Project",
      });

      expect(f.rimNo, 789);
      expect(f.limitNumber, "LN-789");
      expect(f.appRefNo, "APP-789");
      expect(f.controllingLimitNumber, "CL-789");
      expect(f.limitDescription, "Desc");
      expect(f.proposedLimit, 50000);
      expect(f.projectName!.name, "Mega Project");
    });
  });
}
