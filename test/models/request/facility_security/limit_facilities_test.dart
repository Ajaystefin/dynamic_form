import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/facility_security/limit_facilities.dart";

void main() {
  group("LimitsResponse", () {
    test("should parse from JSON with numeric values", () {
      // Arrange
      final json = {
        "limitsFacilityId": 101,
        "rimNo": 12345,
        "commitmentAccountNumber": "ACC123",
        "controllingLimitNo": "CLN001",
        "limitType": "Working Capital",
        "limitAmount": 500000,
        "limitCurrency": "AED",
        "pastDues": 1000,
        "outstandingAmount": 250000,
        "createdOn": "2025-11-26",
        "limitDescription": "Main Limit",
        "createdBy": "Admin",
        "createdDate": "2025-11-01",
        "updatedBy": "Admin",
        "updatedDate": "2025-11-20",
      };

      // Act
      final response = LimitsResponse.fromJson(json);

      // Assert
      expect(response.limitsFacilityId, equals(101));
      expect(response.rimNo, equals(12345));
      expect(response.limitAmount, equals(500000));
      expect(response.limitCurrency, equals("AED"));
      expect(response.limitDescription, equals("Main Limit"));
    });

    test("should parse from JSON with string values", () {
      // Arrange
      final json = {
        "limitsFacilityId": "101",
        "rimNo": "12345",
        "limitAmount": "500000",
        "pastDues": "1000",
        "outstandingAmount": "250000",
      };

      // Act
      final response = LimitsResponse.fromJson(json);

      // Assert
      expect(response.limitsFacilityId, equals(101));
      expect(response.rimNo, equals(12345));
      expect(response.limitAmount, equals(500000));
      expect(response.pastDues, equals(1000));
      expect(response.outstandingAmount, equals(250000));
    });

    test("should handle null and invalid values gracefully", () {
      // Arrange
      final json = {
        "limitsFacilityId": null,
        "rimNo": "invalid",
        "limitAmount": "invalid",
      };

      // Act
      final response = LimitsResponse.fromJson(json);

      // Assert
      expect(response.limitsFacilityId, isNull);
      expect(response.rimNo, isNull);
      expect(response.limitAmount, isNull);
    });

    test("should convert to JSON correctly", () {
      // Arrange
      const response = LimitsResponse(
        limitsFacilityId: 101,
        rimNo: 12345,
        commitmentAccountNumber: "ACC123",
        controllingLimitNo: "CLN001",
        limitType: "Working Capital",
        limitAmount: 500000,
        limitCurrency: "AED",
        pastDues: 1000,
        outstandingAmount: 250000,
        createdOn: "2025-11-26",
        limitDescription: "Main Limit",
        createdBy: "Admin",
        createdDate: "2025-11-01",
        updatedBy: "Admin",
        updatedDate: "2025-11-20",
      );

      // Act
      final json = response.toJson();

      // Assert
      expect(json["limitsFacilityId"], equals(101));
      expect(json["rimNo"], equals(12345));
      expect(json["limitAmount"], equals(500000));
      expect(json["limitCurrency"], equals("AED"));
      expect(json["limitDescription"], equals("Main Limit"));
    });
  });
}
