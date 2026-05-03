import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/facility_security/limits_facilities_response.dart";

void main() {
  group("LimitsFacilityResponse", () {
    test("should parse from JSON correctly", () {
      // Arrange
      final json = {
        "facilityDetails": {
          "facilityTitle": "Main Facility",
          "appRefNo": "APP123",
          "facilityId": 101,
          "limitNo": "LIM001",
          "currency": "AED",
          "presentLimit": 500000,
          "isMainLimit": true,
        },
        "facilityBorrowerMap": {
          "borrowerList": ["Borrower1", "Borrower2"],
          "companyBorrowerList": ["Company1"],
        },
        "conditions": ["Condition1"],
        "defacultFeeRates": ["FeeRate1"],
        "additionalDetails": {"extra": "details"},
        "facilitySubLimits": ["SubLimit1"],
      };

      // Act
      final response = LimitsFacilityResponse.fromJson(json);

      // Assert
      expect(response.facilityDetails?.facilityTitle, equals("Main Facility"));
      expect(response.facilityDetails?.currency, equals("AED"));
      expect(response.facilityBorrowerMap?.borrowerList?.length, equals(2));
      expect(response.conditions?.contains("Condition1"), isTrue);
    });

    test("should convert to JSON correctly", () {
      // Arrange
      final details = FacilityDetails(
        facilityTitle: "Main Facility",
        appRefNo: "APP123",
        facilityId: 101,
        limitNo: "LIM001",
        currency: "AED",
        presentLimit: 500000,
        isMainLimit: true,
      );

      const borrowerMap = FacilityBorrowerMap(
        borrowerList: ["Borrower1"],
        companyBorrowerList: ["Company1"],
      );

      final response = LimitsFacilityResponse(
        facilityDetails: details,
        facilityBorrowerMap: borrowerMap,
        conditions: const ["Condition1"],
        defacultFeeRates: const ["FeeRate1"],
        additionalDetails: const {"extra": "details"},
        facilitySubLimits: const ["SubLimit1"],
      );

      // Act
      final json = response.toJson();

      // Assert
      expect(json["facilityDetails"]["facilityTitle"], equals("Main Facility"));
      expect(
        json["facilityBorrowerMap"]["borrowerList"][0],
        equals("Borrower1"),
      );
      expect(json["conditions"][0], equals("Condition1"));
    });
  });

  group("FacilityDetails", () {
    test("should parse from JSON correctly", () {
      // Arrange
      final json = {
        "facilityTitle": "Main Facility",
        "appRefNo": "APP123",
        "facilityId": 101,
        "limitNo": "LIM001",
        "currency": "AED",
        "presentLimit": 500000,
        "isMainLimit": true,
      };

      // Act
      final details = FacilityDetails.fromJson(json);

      // Assert
      expect(details.facilityTitle, equals("Main Facility"));
      expect(details.appRefNo, equals("APP123"));
      expect(details.presentLimit, equals(500000));
      expect(details.isMainLimit, isTrue);
    });

    test("should convert to JSON correctly", () {
      // Arrange
      final details = FacilityDetails(
        facilityTitle: "Main Facility",
        appRefNo: "APP123",
        facilityId: 101,
        limitNo: "LIM001",
        currency: "AED",
        presentLimit: 500000,
        isMainLimit: true,
      );

      // Act
      final json = details.toJson();

      // Assert
      expect(json["facilityTitle"], equals("Main Facility"));
      expect(json["appRefNo"], equals("APP123"));
      expect(json["presentLimit"], equals(500000));
    });
  });

  group("FacilityBorrowerMap", () {
    test("should parse from JSON correctly", () {
      // Arrange
      final json = {
        "borrowerList": ["Borrower1", "Borrower2"],
        "companyBorrowerList": ["Company1"],
      };

      // Act
      final borrowerMap = FacilityBorrowerMap.fromJson(json);

      // Assert
      expect(borrowerMap.borrowerList?.length, equals(2));
      expect(borrowerMap.companyBorrowerList?.first, equals("Company1"));
    });

    test("should convert to JSON correctly", () {
      // Arrange
      const borrowerMap = FacilityBorrowerMap(
        borrowerList: ["Borrower1"],
        companyBorrowerList: ["Company1"],
      );

      // Act
      final json = borrowerMap.toJson();

      // Assert
      expect(json["borrowerList"][0], equals("Borrower1"));
      // expect(json['companyBorrowerList'][0], equals('Company1'));
    });
  });
}
