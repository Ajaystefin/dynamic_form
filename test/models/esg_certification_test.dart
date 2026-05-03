import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";

void main() {
  group("EsgCertification", () {
    test("constructor: creates instance with all properties", () {
      final esgCertification = EsgCertification(
        esgCertificationsId: 1,
        appRefNo: "APP123",
        applicationType: "New",
        role: "Borrower",
        excludedActivity: "Mining",
        isRequestInfoEsgExcluded: true,
        listOfExcludedActivities: ["Mining", "Oil"],
        sffRequired: true,
        sffCategories: [
          SffCategory(
            sffCategoryId: 10,
            isSelected: true,
            sffCategory: "Green",
            briefDesc: "Category 1",
          ),
        ],
        sllRequired: true,
        esRiskRating: [
          FacilityRiskRating(
            esgFaciliyId: 100,
            borrowerRim: "12345",
            facilityName: "Test Facility",
            sicCode: "1234",
            pctTotalLimit: 50,
            esRating: "A",
          ),
        ],
        isRequestInfoEsgRestricted: false,
        adverseMedia: true,
        adverseMediaSummary: "Test Summary",
        requestInfoEsgMediaScan: true,
        additionalChecklist: "Additional items",
        section1Guidance: 1,
        section2Guidance: 2,
        section3Guidance: 3,
        section4AGuidance: 4,
        section4BGuidance: 5,
        createdBy: "User",
        createdDate: DateTime(2024, 1, 1),
        updatedBy: "User2",
        updatedDate: DateTime(2024, 1, 2),
      );

      expect(esgCertification.esgCertificationsId, 1);
      expect(esgCertification.appRefNo, "APP123");
      expect(esgCertification.applicationType, "New");
      expect(esgCertification.role, "Borrower");
      expect(esgCertification.excludedActivity, "Mining");
      expect(esgCertification.isRequestInfoEsgExcluded, true);
      expect(esgCertification.listOfExcludedActivities, ["Mining", "Oil"]);
      expect(esgCertification.sffRequired, true);
      expect(esgCertification.sffCategories?.length, 1);
      expect(esgCertification.sllRequired, true);
      expect(esgCertification.esRiskRating?.length, 1);
      expect(esgCertification.isRequestInfoEsgRestricted, false);
      expect(esgCertification.adverseMedia, true);
      expect(esgCertification.adverseMediaSummary, "Test Summary");
      expect(esgCertification.requestInfoEsgMediaScan, true);
      expect(esgCertification.additionalChecklist, "Additional items");
      expect(esgCertification.section1Guidance, 1);
      expect(esgCertification.section2Guidance, 2);
      expect(esgCertification.section3Guidance, 3);
      expect(esgCertification.section4AGuidance, 4);
      expect(esgCertification.section4BGuidance, 5);
      expect(esgCertification.createdBy, "User");
      expect(esgCertification.createdDate, DateTime(2024, 1, 1));
      expect(esgCertification.updatedBy, "User2");
      expect(esgCertification.updatedDate, DateTime(2024, 1, 2));
    });

    test("constructor: creates instance with minimal properties (all null)",
        () {
      final esgCertification = EsgCertification();
      expect(esgCertification.esgCertificationsId, isNull);
      expect(esgCertification.appRefNo, isNull);
      expect(esgCertification.applicationType, isNull);
      expect(esgCertification.role, isNull);
      expect(esgCertification.excludedActivity, isNull);
      expect(esgCertification.isRequestInfoEsgExcluded, isNull);
      expect(esgCertification.listOfExcludedActivities, isNull);
      expect(esgCertification.sffRequired, isNull);
      expect(esgCertification.sffCategories, isNull);
      expect(esgCertification.sllRequired, isNull);
      expect(esgCertification.esRiskRating, isNull);
      expect(esgCertification.isRequestInfoEsgRestricted, isNull);
      expect(esgCertification.adverseMedia, isNull);
      expect(esgCertification.adverseMediaSummary, isNull);
      expect(esgCertification.requestInfoEsgMediaScan, isNull);
      expect(esgCertification.additionalChecklist, isNull);
      expect(esgCertification.section1Guidance, isNull);
      expect(esgCertification.section2Guidance, isNull);
      expect(esgCertification.section3Guidance, isNull);
      expect(esgCertification.section4AGuidance, isNull);
      expect(esgCertification.section4BGuidance, isNull);
      expect(esgCertification.createdBy, isNull);
      expect(esgCertification.createdDate, isNull);
      expect(esgCertification.updatedBy, isNull);
      expect(esgCertification.updatedDate, isNull);
    });

    test("fromJson: parses all properties including nested lists and dates",
        () {
      final json = {
        "esgCertificationsId": 1,
        "appRefNo": "APP123",
        "applicationType": "New",
        "role": "Borrower",
        "excludedActivity": "Mining",
        "isRequestInfoEsgExcluded": true,
        "listOfExcludedActivities": ["Mining", 99], // numeric -> string
        "sffRequired": 1, // int branch => true
        "sffCategories": [
          {
            "sffCategoryId": 10,
            "selected": true,
            "sffCategory": "Green",
            "briefDescription": "Category 1",
          }
        ],
        "sllRequired": true,
        "esRiskRating": [
          {
            "borrowerRim": 12345, // numeric -> string
            "facilityName": "Test Facility",
            "sicCode": "1234",
            "pctTotalLimit": 50, // int -> double
            "esRating": "A",
          }
        ],
        "isRequestInfoEsgRestricted": false,
        "adverseMedia": 1, // int branch => true
        "adverseMediaSummary": "Test Summary",
        "requestInfoEsgMediaScan": true,
        "additionalChecklist": "Additional items",
        "section1Guidance": 1,
        "section2Guidance": 2,
        "section3Guidance": 3,
        "section4AGuidance": 4,
        "section4BGuidance": 5,
        "createdBy": "User",
        "createdDate": "2024-01-01T00:00:00.000",
        "updatedBy": "User",
        "updatedDate": "2024-01-02T00:00:00.000",
      };

      final esgCertification = EsgCertification.fromJson(json);

      expect(esgCertification.esgCertificationsId, 1);
      expect(esgCertification.appRefNo, "APP123");
      expect(esgCertification.applicationType, "New");
      expect(esgCertification.role, "Borrower");
      expect(esgCertification.excludedActivity, "Mining");
      expect(esgCertification.isRequestInfoEsgExcluded, true);
      expect(esgCertification.listOfExcludedActivities, ["Mining", "99"]);
      expect(esgCertification.sffRequired, true);
      expect(esgCertification.sffCategories?.single.sffCategoryId, 10);
      expect(esgCertification.sffCategories?.single.isSelected, true);
      expect(esgCertification.sffCategories?.single.sffCategory, "Green");
      expect(esgCertification.sffCategories?.single.briefDesc, "Category 1");
      expect(esgCertification.sllRequired, true);
      expect(esgCertification.esRiskRating?.single.borrowerRim, "12345");
      expect(esgCertification.esRiskRating?.single.pctTotalLimit, 50.0);
      expect(esgCertification.esRiskRating?.single.esRating, "A");
      expect(esgCertification.isRequestInfoEsgRestricted, false);
      expect(esgCertification.adverseMedia, true);
      expect(esgCertification.adverseMediaSummary, "Test Summary");
      expect(esgCertification.requestInfoEsgMediaScan, true);
      expect(esgCertification.additionalChecklist, "Additional items");
      expect(esgCertification.section1Guidance, 1);
      expect(esgCertification.section2Guidance, 2);
      expect(esgCertification.section3Guidance, 3);
      expect(esgCertification.section4AGuidance, 4);
      expect(esgCertification.section4BGuidance, 5);
      expect(esgCertification.createdBy, "User");
      expect(esgCertification.createdDate, DateTime(2024, 1, 1));
      expect(esgCertification.updatedBy, "User");
      expect(esgCertification.updatedDate, DateTime(2024, 1, 2));
    });

    test("fromJson: supports boolean branches for sffRequired/adverseMedia",
        () {
      final json = {
        "sffRequired": true, // bool branch
        "adverseMedia": false, // bool branch
      };
      final esgCertification = EsgCertification.fromJson(json);
      expect(esgCertification.sffRequired, true);
      expect(esgCertification.adverseMedia, false);
    });

    test("fromJson: all-null JSON yields null properties", () {
      final json = {
        "esgCertificationsId": null,
        "appRefNo": null,
        "applicationType": null,
        "role": null,
        "excludedActivity": null,
        "isRequestInfoEsgExcluded": null,
        "listOfExcludedActivities": null,
        "sffRequired": null,
        "sffCategories": null,
        "sllRequired": null,
        "esRiskRating": null,
        "isRequestInfoEsgRestricted": null,
        "adverseMedia": null,
        "adverseMediaSummary": null,
        "requestInfoEsgMediaScan": null,
        "additionalChecklist": null,
        "section1Guidance": null,
        "section2Guidance": null,
        "section3Guidance": null,
        "section4AGuidance": null,
        "section4BGuidance": null,
        "createdBy": null,
        "createdDate": null,
        "updatedBy": null,
        "updatedDate": null,
      };
      final esgCertification = EsgCertification.fromJson(json);
      expect(esgCertification.esgCertificationsId, isNull);
      expect(esgCertification.appRefNo, isNull);
      expect(esgCertification.applicationType, isNull);
      expect(esgCertification.role, isNull);
      expect(esgCertification.excludedActivity, isNull);
      expect(esgCertification.isRequestInfoEsgExcluded, isNull);
      expect(esgCertification.listOfExcludedActivities, isNull);
      expect(esgCertification.sffRequired, isNull);
      expect(esgCertification.sffCategories, isNull);
      expect(esgCertification.sllRequired, isNull);
      expect(esgCertification.esRiskRating, isNull);
      expect(esgCertification.isRequestInfoEsgRestricted, isNull);
      expect(esgCertification.adverseMedia, isNull);
      expect(esgCertification.adverseMediaSummary, isNull);
      expect(esgCertification.requestInfoEsgMediaScan, isNull);
      expect(esgCertification.additionalChecklist, isNull);
      expect(esgCertification.section1Guidance, isNull);
      expect(esgCertification.section2Guidance, isNull);
      expect(esgCertification.section3Guidance, isNull);
      expect(esgCertification.section4AGuidance, isNull);
      expect(esgCertification.section4BGuidance, isNull);
      expect(esgCertification.createdBy, isNull);
      expect(esgCertification.createdDate, isNull);
      expect(esgCertification.updatedBy, isNull);
      expect(esgCertification.updatedDate, isNull);
    });

    test("toJson: serializes all non-null properties and nested lists", () {
      final esgCertification = EsgCertification(
        appRefNo: "APP123",
        applicationType: "New",
        role: "Borrower",
        excludedActivity: "Mining",
        isRequestInfoEsgExcluded: true,
        listOfExcludedActivities: ["Mining", "Oil"],
        sffRequired: true,
        sffCategories: [
          SffCategory(
            sffCategoryId: 10,
            isSelected: true,
            sffCategory: "Green",
            briefDesc: "Category 1",
          ),
        ],
        sllRequired: true,
        esRiskRating: [
          FacilityRiskRating(
            borrowerRim: "12345",
            facilityName: "Test Facility",
            sicCode: "1234",
            pctTotalLimit: 50,
            esRating: "A",
          ),
        ],
        isRequestInfoEsgRestricted: false,
        adverseMedia: true,
        adverseMediaSummary: "Test Summary",
        requestInfoEsgMediaScan: true,
        additionalChecklist: "Additional items",
        createdBy: "User",
        createdDate: DateTime(2024, 1, 1),
        updatedBy: "User",
        updatedDate: DateTime(2024, 1, 2),
      );

      final json = esgCertification.toJson();

      // Fields present in toJson
      expect(json["appRefNo"], "APP123");
      expect(json["applicationType"], "New");
      expect(json["role"], "Borrower");
      expect(json["excludedActivity"], "Mining");
      expect(json["isRequestInfoEsgExcluded"], true);
      expect(json["listOfExcludedActivities"], ["Mining", "Oil"]);
      expect(json["sffRequired"], true);
      expect((json["sffCategories"] as List).single["sffCategoryId"], 10);
      expect((json["sffCategories"] as List).single["selected"], true);
      expect((json["sffCategories"] as List).single["sffCategory"], "Green");
      expect(
        (json["sffCategories"] as List).single["briefDescription"],
        "Category 1",
      );
      expect(json["sllRequired"], true);
      expect((json["esRiskRating"] as List).single["borrowerRim"], "12345");
      expect(
        (json["esRiskRating"] as List).single["facilityName"],
        "Test Facility",
      );
      expect((json["esRiskRating"] as List).single["sicCode"], "1234");
      expect((json["esRiskRating"] as List).single["pctTotalLimit"], 50.0);
      expect((json["esRiskRating"] as List).single["esRating"], "A");
      expect(json["isRequestInfoEsgRestricted"], false);
      expect(json["adverseMedia"], true);
      expect(json["adverseMediaSummary"], "Test Summary");
      expect(json["requestInfoEsgMediaScan"], true);
      expect(json["additionalChecklist"], "Additional items");
      expect(json["createdBy"], "User");
      expect(json["createdDate"], DateTime(2024, 1, 1).toIso8601String());
      expect(json["updatedBy"], "User");
      expect(json["updatedDate"], DateTime(2024, 1, 2).toIso8601String());

      // Fields intentionally not serialized (should be null on Map lookup)
      expect(json["esgCertificationsId"], isNull);
      expect(json["section1Guidance"], isNull);
      expect(json["section2Guidance"], isNull);
      expect(json["section3Guidance"], isNull);
      expect(json["section4AGuidance"], isNull);
      expect(json["section4BGuidance"], isNull);
    });

    test("toJson: serializes null properties as null (or missing)", () {
      final json = EsgCertification().toJson();
      expect(json["esgCertificationsId"], isNull);
      expect(json["appRefNo"], isNull);
      expect(json["applicationType"], isNull);
      expect(json["role"], isNull);
      expect(json["excludedActivity"], isNull);
      expect(json["isRequestInfoEsgExcluded"], isNull);
      expect(json["listOfExcludedActivities"], isNull);
      expect(json["sffRequired"], isNull);
      expect(json["sffCategories"], isNull);
      expect(json["sllRequired"], isNull);
      expect(json["esRiskRating"], isNull);
      expect(json["isRequestInfoEsgRestricted"], isNull);
      expect(json["adverseMedia"], isNull);
      expect(json["adverseMediaSummary"], isNull);
      expect(json["requestInfoEsgMediaScan"], isNull);
      expect(json["additionalChecklist"], isNull);
      expect(json["createdBy"], isNull);
      expect(json["createdDate"], isNull);
      expect(json["updatedBy"], isNull);
      expect(json["updatedDate"], isNull);
    });

    test("copyWith: updates selected fields and preserves others", () {
      final original = EsgCertification(
        appRefNo: "APP123",
        applicationType: "OrigType",
        role: "Borrower",
        sffRequired: true,
        isRequestInfoEsgExcluded: false,
        section1Guidance: 11,
        section2Guidance: 22,
        section3Guidance: 33,
        section4AGuidance: 44,
        section4BGuidance: 55,
        createdBy: "Creator",
        createdDate: DateTime(2024, 1, 1),
        updatedBy: "Updater",
        updatedDate: DateTime(2024, 1, 2),
      );

      final updated = original.copyWith(
        // Explicitly carry appRefNo because copyWith does not fallback it
        appRefNo: original.appRefNo,
        role: "Guarantor",
        sffRequired: false,
        isRequestInfoEsgExcluded: true,
        section1Guidance: 101,
        section2Guidance: 202,
        section3Guidance: 303,
        section4AGuidance: 404,
        section4BGuidance: 505,
        applicationType: "NewType",
        updatedBy: "NewUpdater",
        updatedDate: DateTime(2024, 1, 3),
      );

      expect(updated.appRefNo, "APP123"); // carried through
      expect(updated.applicationType, "NewType"); // replaced
      expect(updated.role, "Guarantor"); // replaced
      expect(updated.sffRequired, false); // replaced
      expect(updated.isRequestInfoEsgExcluded, true); // replaced

      // guidance values replaced
      expect(updated.section1Guidance, 101);
      expect(updated.section2Guidance, 202);
      expect(updated.section3Guidance, 303);
      expect(updated.section4AGuidance, 404);
      expect(updated.section4BGuidance, 505);

      // createdBy/Date preserved (not changed here)
      expect(updated.createdBy, "Creator");
      expect(updated.createdDate, DateTime(2024, 1, 1));

      // updatedBy/Date changed
      expect(updated.updatedBy, "NewUpdater");
      expect(updated.updatedDate, DateTime(2024, 1, 3));
    });

    test(
        "copyWith: leaving createdBy/createdDate unset makes them null (current behavior)",
        () {
      final original = EsgCertification(
        appRefNo: "APP123",
        role: "Borrower",
        createdBy: "Creator",
        createdDate: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        appRefNo: original.appRefNo,
        role: "Borrower",
        // createdBy and createdDate omitted => copyWith sets them to null
      );

      expect(updated.appRefNo, "APP123");
      expect(updated.role, "Borrower");
      expect(updated.createdBy, "Creator");
      expect(updated.createdDate, DateTime(2024, 1, 1));
    });
  });

  group("SffCategory", () {
    test("fromJson: parses all properties with correct keys", () {
      final json = {
        "sffCategoryId": 10,
        "selected": true,
        "sffCategory": "Green",
        "briefDescription": "Category 1",
      };
      final sffCategory = SffCategory.fromJson(json);
      expect(sffCategory.sffCategoryId, 10);
      expect(sffCategory.isSelected, true);
      expect(sffCategory.sffCategory, "Green");
      expect(sffCategory.briefDesc, "Category 1");
    });

    test("fromJson: null values produce defaults/Nulls", () {
      final json = {
        "sffCategoryId": null,
        "selected": null,
        "sffCategory": null,
        "briefDescription": null,
      };
      final sffCategory = SffCategory.fromJson(json);
      expect(sffCategory.sffCategoryId, isNull);
      expect(sffCategory.isSelected, isNull);
      expect(sffCategory.sffCategory, ""); // default in model
      expect(sffCategory.briefDesc, ""); // default in model
    });

    test("toJson: serializes all properties", () {
      final sffCategory = SffCategory(
        sffCategoryId: 10,
        isSelected: true,
        sffCategory: "Green",
        briefDesc: "Category 1",
      );
      final json = sffCategory.toJson();
      expect(json["sffCategoryId"], 10);
      expect(json["selected"], true);
      expect(json["sffCategory"], "Green");
      expect(json["briefDescription"], "Category 1");
    });

    test("toJson: null properties as null (or missing)", () {
      final json = SffCategory().toJson();
      expect(json["sffCategoryId"], isNull);
      expect(json["selected"], isNull);
      expect(json["sffCategory"], isNull);
      expect(json["briefDescription"], isNull);
    });
  });

  group("FacilityRiskRating", () {
    test("fromJson: parses all properties (double/int + numeric->string rim)",
        () {
      final json = {
        "borrowerRim": 12345, // numeric -> string
        "facilityName": "Test Facility",
        "sicCode": "1234",
        "pctTotalLimit": 50.0,
        "esRating": "A",
      };
      final facilityRiskRating = FacilityRiskRating.fromJson(json);
      expect(
        facilityRiskRating.esgFaciliyId,
        null,
      ); // not deserialized in model
      expect(facilityRiskRating.borrowerRim, "12345");
      expect(facilityRiskRating.facilityName, "Test Facility");
      expect(facilityRiskRating.sicCode, "1234");
      expect(facilityRiskRating.pctTotalLimit, 50.0);
      expect(facilityRiskRating.esRating, "A");
    });

    test("fromJson: integer pctTotalLimit coerced to double", () {
      final json = {"pctTotalLimit": 50};
      final facilityRiskRating = FacilityRiskRating.fromJson(json);
      expect(facilityRiskRating.pctTotalLimit, 50.0);
    });

    test("fromJson: all-null JSON yields null properties", () {
      final json = {
        "esgFaciliyId": null,
        "borrowerRim": null,
        "facilityName": null,
        "sicCode": null,
        "pctTotalLimit": null,
        "esRating": null,
      };
      final facilityRiskRating = FacilityRiskRating.fromJson(json);
      expect(facilityRiskRating.esgFaciliyId, isNull);
      expect(facilityRiskRating.borrowerRim, isNull);
      expect(facilityRiskRating.facilityName, isNull);
      expect(facilityRiskRating.sicCode, isNull);
      expect(facilityRiskRating.pctTotalLimit, isNull);
      expect(facilityRiskRating.esRating, isNull);
    });

    test("toJson: serializes all properties", () {
      final fr = FacilityRiskRating(
        esgFaciliyId: 1,
        borrowerRim: "12345",
        facilityName: "Test Facility",
        sicCode: "1234",
        pctTotalLimit: 50,
        esRating: "A",
      );
      final json = fr.toJson();
      expect(json["esgFaciliyId"], null); // not serialized by model
      expect(json["borrowerRim"], "12345");
      expect(json["facilityName"], "Test Facility");
      expect(json["sicCode"], "1234");
      expect(json["pctTotalLimit"], 50.0);
      expect(json["esRating"], "A");
    });

    test("toJson: null properties", () {
      final json = FacilityRiskRating().toJson();
      expect(json["esgFaciliyId"], isNull);
      expect(json["borrowerRim"], isNull);
      expect(json["facilityName"], isNull);
      expect(json["sicCode"], isNull);
      expect(json["pctTotalLimit"], isNull);
      expect(json["esRating"], isNull);
    });
  });

  group("EskRiskRatingFacilityDto.fromJson", () {
    test("parses numeric pctTotalLimit and strings correctly", () {
      final dtoNum = EskRiskRatingFacilityDto.fromJson({
        "facilityName": "main",
        "sicCode": "51200",
        "pctTotalLimit": 100, // num -> double
        "esRating": "High",
      });

      expect(dtoNum.facilityName, "main");
      expect(dtoNum.sicCode, "51200");
      expect(dtoNum.pctTotalLimit, 100.0);
      expect(dtoNum.esRating, "High");
      expect(dtoNum.borrowerRim, isNull, reason: "Not set in fromJson");

      final dtoStr = EskRiskRatingFacilityDto.fromJson({
        "facilityName": "secondary",
        "sicCode": "3711",
        "pctTotalLimit": "42.5", // string -> double
        "esRating": "Medium",
      });

      expect(dtoStr.facilityName, "secondary");
      expect(dtoStr.sicCode, "3711");
      expect(dtoStr.pctTotalLimit, 42.5);
      expect(dtoStr.esRating, "Medium");
    });

    test("handles null and invalid pctTotalLimit gracefully", () {
      final dtoNull = EskRiskRatingFacilityDto.fromJson({
        "facilityName": "null_case",
        "sicCode": "0000",
        "pctTotalLimit": null, // null -> null
        "esRating": "Low",
      });
      expect(dtoNull.pctTotalLimit, isNull);

      final dtoInvalid = EskRiskRatingFacilityDto.fromJson({
        "facilityName": "invalid_case",
        "sicCode": "9999",
        "pctTotalLimit": {"unexpected": "map"}, // invalid type -> null branch
        "esRating": "Low",
      });
      expect(dtoInvalid.pctTotalLimit, isNull);
    });

    test("toJson emits expected fields", () {
      final dto = EskRiskRatingFacilityDto(
        facilityName: "test_facility",
        sicCode: "51200",
        pctTotalLimit: 88.8,
        esRating: "High",
      );

      final json = dto.toJson();
      expect(json, {
        "facilityName": "test_facility",
        "sicCode": "51200",
        "pctTotalLimit": 88.8,
        "esRating": "High",
      });
      expect(
        json.containsKey("borrowerRim"),
        isFalse,
        reason: "borrowerRim is intentionally not serialized",
      );
    });
  });

  group("FacilityRiskRating.fromJson (parent)", () {
    test("parses with nested eSRiskRatingFacilityDto present", () {
      final rating = FacilityRiskRating.fromJson({
        "borrowerRim": 2213, // int -> string via asString
        "facilityName": "top_level_name",
        "sicCode": "1111",
        "pctTotalLimit": "12.34", // string -> double via asDouble
        "esRating": "A",
        "eSRiskRatingFacilityDto": [
          {
            "facilityName": "test_facility",
            "sicCode": "51200",
            "esRating": "High",
            "pctTotalLimit": 100.00,
          }
        ],
      });

      expect(rating.borrowerRim, "2213");
      expect(rating.facilityName, "top_level_name");
      expect(rating.sicCode, "1111");
      expect(rating.pctTotalLimit, 12.34);
      expect(rating.esRating, "A");

      final facilities = rating.eSRiskRatingFacilityDto;
      expect(facilities, isNotNull);
      expect(facilities, isA<List<EskRiskRatingFacilityDto>>());
      expect(facilities!.length, 1);
      expect(facilities.first.facilityName, "test_facility");
      expect(facilities.first.sicCode, "51200");
      expect(facilities.first.esRating, "High");
      expect(facilities.first.pctTotalLimit, 100.0);
    });

    test("handles null eSRiskRatingFacilityDto by returning an empty list", () {
      final rating = FacilityRiskRating.fromJson({
        "borrowerRim": "9999",
        "facilityName": "parent",
        "sicCode": "2222",
        "pctTotalLimit": 55, // num -> double
        "esRating": "B",
        "eSRiskRatingFacilityDto": null,
      });

      expect(rating.borrowerRim, "9999");
      expect(rating.pctTotalLimit, 55.0);
      expect(
        rating.eSRiskRatingFacilityDto,
        isNotNull,
        reason: "Factory returns [] (non-null) when"
            " eSRiskRatingFacilityDto is null",
      );
      expect(rating.eSRiskRatingFacilityDto!.isEmpty, isTrue);
    });

    test("handles missing eSRiskRatingFacilityDto by returning an empty list",
        () {
      final rating = FacilityRiskRating.fromJson({
        "borrowerRim": "no_list",
        "facilityName": "parent_missing_list",
        "sicCode": "3333",
        "pctTotalLimit": "not-a-number", // invalid string -> null
        "esRating": "C",
        // eSRiskRatingFacilityDto key missing
      });

      expect(rating.borrowerRim, "no_list");
      expect(
        rating.pctTotalLimit,
        isNull,
        reason: "Invalid numeric string should result in null via asDouble",
      );
      expect(rating.eSRiskRatingFacilityDto, isNotNull);
      expect(rating.eSRiskRatingFacilityDto!.isEmpty, isTrue);
    });

    test("toJson emits top-level fields (intentionally excludes nested list)",
        () {
      final rating = FacilityRiskRating(
        borrowerRim: "1234",
        facilityName: "main",
        sicCode: "4444",
        pctTotalLimit: 77.77,
        esRating: "A+",
        eSRiskRatingFacilityDto: [
          EskRiskRatingFacilityDto(
            facilityName: "nested",
            sicCode: "5555",
            pctTotalLimit: 10,
            esRating: "Low",
          ),
        ],
      );

      final json = rating.toJson();
      expect(
        json,
        {
          "borrowerRim": "1234",
          "facilityName": "main",
          "sicCode": "4444",
          "pctTotalLimit": 77.77,
          "esRating": "A+",
        },
        reason:
            "Nested eSRiskRatingFacilityDto is intentionally not serialized",
      );
      expect(json.containsKey("eSRiskRatingFacilityDto"), isFalse);
    });
  });
}
