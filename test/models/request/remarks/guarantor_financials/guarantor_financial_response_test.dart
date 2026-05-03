import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor_financial_response.dart";

void main() {
  group("GuarantorFinancialDetailsResponse", () {
    test("fromJson should parse valid JSON correctly", () {
      final json = {
        "guarantorFinancialsId": 123,
        "appRefNo": "APP001",
        "rimNo": 456,
        "customerName": "Test Guarantor",
        "guarantorFinancialsComment": "Test Comment",
        "entityDetails": [
          {
            "guarantorFinancialsId": 123,
            "entityId": 1,
            "entityLongName": "Entity One",
            "financialsCategory": [],
          }
        ],
        "createdBy": "admin",
        "createdDate": "2024-01-01T10:00:00.000Z",
        "updatedBy": "editor",
        "updatedDate": "2024-01-02T15:30:00.000Z",
      };

      final response = GuarantorFinancialDetailsResponse.fromJson(json);

      expect(response.guarantorFinancialsId, 123);
      expect(response.appRefNo, "APP001");
      expect(response.rimNo, 456);
      expect(response.customerName, "Test Guarantor");
      // expect(response.guarantorFinancialsComment, 'Test Comment');
      expect(response.entityDetails.length, 1);
      expect(response.createdBy, "admin");
      expect(response.createdDate, isNotNull);
      expect(response.updatedBy, "editor");
      expect(response.updatedDate, isNotNull);
    });

    test("fromJson should handle null optional fields", () {
      final json = {
        "guarantorFinancialsId": null,
        "appRefNo": "APP002",
        "rimNo": 789,
        "customerName": "Another Guarantor",
        "guarantorFinancialsComment": null,
        "entityDetails": [],
        "createdBy": null,
        "createdDate": null,
        "updatedBy": null,
        "updatedDate": null,
      };

      final response = GuarantorFinancialDetailsResponse.fromJson(json);

      expect(response.guarantorFinancialsId, isNull);
      expect(response.appRefNo, "APP002");
      // expect(response.guarantorFinancialsComment, isNull);
      expect(response.entityDetails, isEmpty);
      expect(response.createdBy, isNull);
      expect(response.createdDate, isNull);
      expect(response.updatedBy, isNull);
      expect(response.updatedDate, isNull);
    });
    test("_parseDate should handle invalid date strings", () {
      final json = {
        "guarantorFinancialsId": 1,
        "appRefNo": "APP004",
        "rimNo": 222,
        "customerName": "Test",
        "guarantorFinancialsComment": null,
        "entityDetails": [],
        "createdBy": null,
        "createdDate": "invalid-date",
        "updatedBy": null,
        "updatedDate": null,
      };

      final response = GuarantorFinancialDetailsResponse.fromJson(json);
      expect(response.createdDate, isNull);
    });
  });

  group("GuarantorEntityDetail", () {
    test("fromJson should parse correctly", () {
      final json = {
        "guarantorFinancialsId": 100,
        "entityId": 5,
        "entityLongName": "Test Entity",
        "financialsCategory": [
          {
            "financialsCategory": 1,
            "financialsValues": [],
            "guarantorHealth": 3,
            "remarks": "Good",
          }
        ],
      };

      final entity = GuarantorEntityDetail.fromJson(json);

      expect(entity.guarantorFinancialsId, 100);
      expect(entity.entityId, 5);
      expect(entity.entityLongName, "Test Entity");
      expect(entity.financialsCategory.length, 1);
    });

    test("toJson should serialize correctly", () {
      final entity = GuarantorEntityDetail(
        guarantorFinancialsId: 200,
        entityId: 10,
        entityLongName: "Serialized Entity",
        financialsCategory: [],
      );

      final json = entity.toJson();

      expect(json["guarantorFinancialsId"], 200);
      expect(json["entityId"], 10);
      expect(json["entityLongName"], "Serialized Entity");
      expect(json["financialsCategory"], isEmpty);
    });
  });

  group("GuarantorCategoryDetail", () {
    test("fromJson should parse correctly", () {
      final json = {
        "financialsCategory": 2,
        "financialsValues": [
          {
            "financialsCategory": 2,
            "financialRatioType": "351",
            "userAddedRatioType": null,
            "financialYear": 2024,
            "period": "12M",
            "auditMethod": "Audited",
            "auditor": "KPMG",
            "value": 1500.50,
          }
        ],
        "guarantorHealth": 4,
        "remarks": "Excellent",
      };

      final category = GuarantorCategoryDetail.fromJson(json);

      expect(category.financialsCategory, 2);
      expect(category.financialsValues.length, 1);
      expect(category.guarantorHealth, 4);
      expect(category.remarks, "Excellent");
    });

    test("fromJson should handle null optional fields", () {
      final json = {
        "financialsCategory": 3,
        "financialsValues": [],
        "guarantorHealth": null,
        "remarks": null,
      };

      final category = GuarantorCategoryDetail.fromJson(json);

      expect(category.guarantorHealth, isNull);
      expect(category.remarks, isNull);
      expect(category.financialsValues, isEmpty);
    });

    test("toJson should serialize correctly", () {
      final category = GuarantorCategoryDetail(
        financialsCategory: 5,
        financialsValues: [],
        guarantorHealth: 2,
        remarks: "Fair",
      );

      final json = category.toJson();

      expect(json["financialsCategory"], 5);
      expect(json["financialsValues"], isEmpty);
      expect(json["guarantorHealth"], 2);
      expect(json["remarks"], "Fair");
    });
  });

  group("GuarantorFinancialValue", () {
    test("fromJson should parse with valid financialRatioType", () {
      final json = {
        "financialsCategory": 1,
        "financialRatioType": "100",
        "userAddedRatioType": null,
        "financialYear": 2023,
        "period": "6M",
        "auditMethod": "Co.Prep'd",
        "auditor": null,
        "value": 1000,
      };

      final value = GuarantorFinancialValue.fromJson(json);

      expect(value.financialsCategory, 1);
      expect(value.financialRatioType, "100");
      expect(value.userAddedRatioType, isNull);
      expect(value.financialYear, 2023);
      expect(value.period, "6M");
      expect(value.auditMethod, "Co.Prep'd");
      expect(value.auditor, isNull);
      expect(value.value, 1000.0);
      expect(value.value, isA<double>());
    });

    test('fromJson should normalize "null" string to null', () {
      final json = {
        "financialsCategory": 2,
        "financialRatioType": "null",
        "userAddedRatioType": "Custom Ratio",
        "financialYear": 2024,
        "period": "12M",
        "auditMethod": "Audited",
        "auditor": "PWC",
        "value": 2500.75,
      };

      final value = GuarantorFinancialValue.fromJson(json);

      expect(value.financialRatioType, isNull);
      expect(value.userAddedRatioType, "Custom Ratio");
      expect(value.auditor, "PWC");
      expect(value.value, 2500.75);
    });

    test("fromJson should handle null financialRatioType", () {
      final json = {
        "financialsCategory": 3,
        "financialRatioType": null,
        "userAddedRatioType": null,
        "financialYear": 2022,
        "period": "3M",
        "auditMethod": "Unaudited",
        "auditor": null,
        "value": null,
      };

      final value = GuarantorFinancialValue.fromJson(json);

      expect(value.financialRatioType, isNull);
      expect(value.value, isNull);
    });

    test("fromJson should handle integer value", () {
      final json = {
        "financialsCategory": 4,
        "financialRatioType": "9065",
        "userAddedRatioType": null,
        "financialYear": 2025,
        "period": "9M",
        "auditMethod": "Reviewed",
        "auditor": "EY",
        "value": 3000,
      };

      final value = GuarantorFinancialValue.fromJson(json);

      expect(value.value, 3000.0);
      expect(value.value, isA<double>());
    });

    test("fromJson should handle double value", () {
      final json = {
        "financialsCategory": 5,
        "financialRatioType": "351",
        "userAddedRatioType": "Test",
        "financialYear": 2026,
        "period": "12M",
        "auditMethod": "Audited",
        "auditor": "Deloitte",
        "value": 4500.25,
      };

      final value = GuarantorFinancialValue.fromJson(json);

      expect(value.value, 4500.25);
    });

    test("toJson should serialize correctly", () {
      final value = GuarantorFinancialValue(
        financialsCategory: 6,
        financialRatioType: "400",
        statementDate: "400",
        userAddedRatioType: "Test Ratio",
        financialYear: 2025,
        period: "9M",
        auditMethod: "Reviewed",
        auditor: "EY",
        value: 3000.25,
      );

      final json = value.toJson();

      expect(json["financialsCategory"], 6);
      expect(json["financialRatioType"], "400");
      expect(json["userAddedRatioType"], "Test Ratio");
      expect(json["financialYear"], 2025);
      expect(json["period"], "9M");
      expect(json["auditMethod"], "Reviewed");
      expect(json["auditor"], "EY");
      expect(json["value"], 3000.25);
    });

    test("toJson should serialize null financialRatioType", () {
      final value = GuarantorFinancialValue(
        financialsCategory: 7,
        financialRatioType: null,
        userAddedRatioType: null,
        financialYear: 2024,
        statementDate: "400",
        period: "6M",
        auditMethod: "Unaudited",
        auditor: null,
        value: null,
      );

      final json = value.toJson();

      expect(json["financialRatioType"], isNull);
      expect(json["value"], isNull);
    });
  });

  group("Round-trip serialization", () {
    test("Full object should round-trip correctly", () {
      final original = GuarantorFinancialDetailsResponse(
        guarantorFinancialsId: 500,
        appRefNo: "APP999",
        rimNo: 888,
        customerName: "Round Trip Guarantor",
        // guarantorFinancialsComment: 'Round Trip Comment',
        entityDetails: [
          GuarantorEntityDetail(
            guarantorFinancialsId: 500,
            entityId: 20,
            entityLongName: "Round Trip Entity",
            financialsCategory: [
              GuarantorCategoryDetail(
                financialsCategory: 10,
                financialsValues: [
                  GuarantorFinancialValue(
                    financialsCategory: 10,
                    financialRatioType: "500",
                    userAddedRatioType: "Custom",
                    financialYear: 2024,
                    period: "12M",
                    statementDate: "400",
                    auditMethod: "Audited",
                    auditor: "Deloitte",
                    value: 5000,
                  ),
                ],
                guarantorHealth: 5,
                remarks: "Perfect",
              ),
            ],
          ),
        ],
        createdBy: "system",
        createdDate: DateTime.parse("2024-06-01T00:00:00.000Z"),
        updatedBy: "admin",
        updatedDate: DateTime.parse("2024-06-02T00:00:00.000Z"),
      );

      final json = original.toJson();
      final restored = GuarantorFinancialDetailsResponse.fromJson(json);

      expect(restored.guarantorFinancialsId, original.guarantorFinancialsId);
      expect(restored.appRefNo, original.appRefNo);
      expect(restored.rimNo, original.rimNo);
      expect(restored.customerName, original.customerName);
      // expect(restored.guarantorFinancialsComment,
      //     original.guarantorFinancialsComment);
      expect(restored.entityDetails.length, original.entityDetails.length);
      expect(restored.createdBy, original.createdBy);
      expect(restored.updatedBy, original.updatedBy);
    });
  });
}
