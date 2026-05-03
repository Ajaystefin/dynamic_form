// test/models/clean_exposure_model_test.dart

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/approval/clean_exposure.dart";

void main() {
  group("Exposure Model Tests", () {
    test("Exposure default constructor assigns values correctly", () {
      final exposure = Exposure(
        id: 1,
        rimNo: 100,
        appRefNo: "APP001",
        updatedProposedExposure: 10.5,
        updatedPresentExposure: 20.5,
        updatedGuarantorExposure: 30.5,
        updatedSharedLimitPresent: 40.5,
        updatedSharedLimitProposed: 50.5,
        calculatedProposedExposure: 60.5,
        calculatedPresentExposure: 70.5,
        calculatedGuarantorExposure: 80.5,
        calculatedSharedLimitPresent: 90.5,
        calculatedSharedLimitProposed: 100.5,
        createdBy: "user1",
        updatedBy: "user2",
        createdDate: DateTime.parse("2024-01-01T00:00:00Z"),
        updatedDate: DateTime.parse("2024-02-01T00:00:00Z"),
      );

      expect(exposure.id, 1);
      expect(exposure.rimNo, 100);
      expect(exposure.appRefNo, "APP001");
      expect(exposure.updatedProposedExposure, 10.5);
      expect(exposure.updatedPresentExposure, 20.5);
      expect(exposure.updatedGuarantorExposure, 30.5);
      expect(exposure.updatedSharedLimitPresent, 40.5);
      expect(exposure.updatedSharedLimitProposed, 50.5);
      expect(exposure.calculatedProposedExposure, 60.5);
      expect(exposure.calculatedPresentExposure, 70.5);
      expect(exposure.calculatedGuarantorExposure, 80.5);
      expect(exposure.calculatedSharedLimitPresent, 90.5);
      expect(exposure.calculatedSharedLimitProposed, 100.5);
      expect(exposure.createdBy, "user1");
      expect(exposure.updatedBy, "user2");
      expect(exposure.createdDate, isNotNull);
      expect(exposure.updatedDate, isNotNull);
    });

    test("Exposure.fromJson parses full JSON correctly", () {
      final json = {
        "cleanExposureId": 1,
        "rimNo": 200,
        "appRefNo": "APP002",
        "updatedProposedExposure": 1.0,
        "updatedPresentExposure": 2.0,
        "updatedGuarantorExposure": 3.0,
        "updatedSharedLimitPresent": 4.0,
        "updatedSharedLimitProposed": 5.0,
        "calculatedProposedExposure": 6.0,
        "calculatedPresentExposure": 7.0,
        "calculatedGuarantorExposure": 8.0,
        "calculatedSharedLimitPresent": 9.0,
        "calculatedSharedLimitProposed": 10.0,
        "createdBy": "creator",
        "updatedBy": "updater",
        "createdDate": "2024-01-01T00:00:00Z",
        "updatedDate": "2024-01-02T00:00:00Z",
      };

      final exposure = Exposure.fromJson(json);

      expect(exposure.id, 1);
      expect(exposure.rimNo, 200);
      expect(exposure.appRefNo, "APP002");
      expect(exposure.updatedProposedExposure, 1.0);
      expect(exposure.updatedPresentExposure, 2.0);
      expect(exposure.updatedGuarantorExposure, 3.0);
      expect(exposure.updatedSharedLimitPresent, 4.0);
      expect(exposure.updatedSharedLimitProposed, null);
      expect(exposure.calculatedProposedExposure, 6.0);
      expect(exposure.calculatedPresentExposure, 7.0);
      expect(exposure.calculatedGuarantorExposure, 8.0);
      expect(exposure.calculatedSharedLimitPresent, 9.0);
      expect(exposure.calculatedSharedLimitProposed, 10.0);
      expect(exposure.createdBy, "creator");
      expect(exposure.updatedBy, "updater");
      expect(exposure.createdDate, isA<DateTime>());
      expect(exposure.updatedDate, isA<DateTime>());
    });

    test("Exposure.fromJson applies default values when JSON is null", () {
      final exposure = Exposure.fromJson({});

      expect(exposure.id, 0);
      expect(exposure.rimNo, 0);
      expect(exposure.appRefNo, "");
      expect(exposure.updatedProposedExposure, 0.0);
      expect(exposure.updatedPresentExposure, 0.0);
      expect(exposure.updatedGuarantorExposure, 0.0);
      expect(exposure.updatedSharedLimitPresent, 0.0);
      expect(exposure.calculatedProposedExposure, 0.0);
      expect(exposure.calculatedPresentExposure, 0.0);
      expect(exposure.calculatedGuarantorExposure, 0.0);
      expect(exposure.calculatedSharedLimitPresent, 0.0);
      expect(exposure.calculatedSharedLimitProposed, 0.0);
      expect(exposure.createdBy, "");
      expect(exposure.updatedBy, "");
      expect(exposure.createdDate, isNull);
      expect(exposure.updatedDate, isNull);
    });

    test("Exposure.toJson returns correct map including dates", () {
      final date = DateTime.parse("2024-01-01T00:00:00Z");

      final exposure = Exposure(
        id: 1,
        rimNo: 10,
        appRefNo: "APP",
        calculatedProposedExposure: 1,
        calculatedPresentExposure: 2,
        calculatedGuarantorExposure: 3,
        calculatedSharedLimitPresent: 4,
        calculatedSharedLimitProposed: 5,
        updatedProposedExposure: 6,
        updatedPresentExposure: 7,
        updatedGuarantorExposure: 8,
        updatedSharedLimitPresent: 9,
        updatedSharedLimitProposed: 10,
        createdBy: "a",
        updatedBy: "b",
        createdDate: date,
        updatedDate: date,
      );

      final json = exposure.toJson();

      expect(json["cleanExposureId"], 1);
      expect(json["rimNo"], 10);
      expect(json["appRefNo"], "APP");
      expect(json["createdDate"], date.toUtc().toIso8601String());
      expect(json["updatedDate"], date.toUtc().toIso8601String());
    });

    test("Exposure.toInsertJson provides defaults for nulls", () {
      final exposure = Exposure(
        rimNo: 1,
        appRefNo: "APP",
      );

      final json = exposure.toInsertJson();

      expect(json["rimNo"], 1);
      expect(json["appRefNo"], "APP");
      expect(json["updatedProposedExposure"], 0);
      expect(json["calculatedSharedLimitProposed"], 0);
    });
  });

  group("CleanExposure Model Tests", () {
    test("CleanExposure.fromJson parses exposures list", () {
      final json = {
        "exposures": [
          {"cleanExposureId": 1},
        ],
        "totalProposedExposure": 100.0,
        "totalPresentExposure": 200.0,
        "totalGuarantorExposure": 300.0,
        "totalSharedLimitProposed": 400.0,
        "totalSharedLimitPresent": 500.0,
        "isGroup": true,
      };

      final cleanExposure = CleanExposure.fromJson(json);

      expect(cleanExposure.exposures, isNotNull);
      expect(cleanExposure.exposures!.length, 1);
      expect(cleanExposure.exposures!.first.id, 1);
      expect(cleanExposure.totalProposedExposure, 100.0);
      expect(cleanExposure.totalPresentExposure, 200.0);
      expect(cleanExposure.totalGuarantorExposure, 300.0);
      expect(cleanExposure.totalSharedLimitProposed, 400.0);
      expect(cleanExposure.totalSharedLimitPresent, 500.0);
      expect(cleanExposure.isGroup, true);
    });

    test("CleanExposure.fromJson handles empty json safely", () {
      final cleanExposure = CleanExposure.fromJson({});

      expect(cleanExposure.exposures, isEmpty);
      expect(cleanExposure.totalProposedExposure, 0.0);
      expect(cleanExposure.totalPresentExposure, 0.0);
      expect(cleanExposure.totalGuarantorExposure, 0.0);
      expect(cleanExposure.totalSharedLimitProposed, 0.0);
      expect(cleanExposure.totalSharedLimitPresent, 0.0);
      expect(cleanExposure.isGroup, false);
    });

    test("CleanExposure.toJson serializes correctly", () {
      final exposure = Exposure(id: 1);
      final cleanExposure = CleanExposure(
        exposures: [exposure],
        totalProposedExposure: 10,
        totalPresentExposure: 20,
        totalGuarantorExposure: 30,
        totalSharedLimitProposed: 40,
        totalSharedLimitPresent: 50,
        isGroup: true,
      );

      final json = cleanExposure.toJson();

      expect(json["totalProposedExposure"], 10);
      expect(json["isGroup"], true);
      expect(json["exposured"], isA<List>());
      expect(json["exposured"].length, 1);
    });
  });
}
