import 'package:flutter_test/flutter_test.dart';
import 'package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_ratio_response.dart';

void main() {
  group('FinancialRatioAnalysisResponse', () {
    test('fromJson should parse valid JSON correctly', () {
      final json = {
        'customerFinancialsId': 123,
        'appRefNo': 'APP001',
        'rimNo': 456,
        'customerName': 'Test Customer',
        'descOfAccounts': 'Test Description',
        'entityDetails': [
          {
            'customerFinancialsId': 123,
            'entityId': 1,
            'entityLongName': 'Entity One',
            'financialsCategory': []
          }
        ],
        'createdBy': 'admin',
        'createdDate': '2024-01-01T10:00:00.000Z',
        'updatedBy': 'editor',
        'updatedDate': '2024-01-02T15:30:00.000Z',
      };

      final response = FinancialRatioAnalysisResponse.fromJson(json);

      expect(response.customerFinancialsId, 123);
      expect(response.appRefNo, 'APP001');
      expect(response.rimNo, 456);
      expect(response.customerName, 'Test Customer');
      expect(response.descOfAccounts, 'Test Description');
      expect(response.entityDetails.length, 1);
      expect(response.createdBy, 'admin');
      expect(response.createdDate, isNotNull);
      expect(response.updatedBy, 'editor');
      expect(response.updatedDate, isNotNull);
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        'customerFinancialsId': null,
        'appRefNo': 'APP002',
        'rimNo': 789,
        'customerName': 'Another Customer',
        'descOfAccounts': null,
        'entityDetails': [],
        'createdBy': null,
        'createdDate': null,
        'updatedBy': null,
        'updatedDate': null,
      };

      final response = FinancialRatioAnalysisResponse.fromJson(json);

      expect(response.customerFinancialsId, isNull);
      expect(response.appRefNo, 'APP002');
      expect(response.descOfAccounts, isNull);
      expect(response.entityDetails, isEmpty);
      expect(response.createdBy, isNull);
      expect(response.createdDate, isNull);
      expect(response.updatedBy, isNull);
      expect(response.updatedDate, isNull);
    });

    test('toJson should serialize correctly', () {
      final response = FinancialRatioAnalysisResponse(
        customerFinancialsId: 999,
        appRefNo: 'APP003',
        rimNo: 111,
        customerName: 'Serialized Customer',
        descOfAccounts: 'Serialized Description',
        entityDetails: [],
        createdBy: 'creator',
        createdDate: DateTime.parse('2024-03-01T12:00:00.000Z'),
        updatedBy: 'updater',
        updatedDate: DateTime.parse('2024-03-02T14:00:00.000Z'),
      );

      final json = response.toJson();

      expect(json['customerFinancialsId'], 999);
      expect(json['appRefNo'], 'APP003');
      expect(json['rimNo'], 111);
      expect(json['customerName'], 'Serialized Customer');
      expect(json['descOfAccounts'], 'Serialized Description');
      expect(json['entityDetails'], isEmpty);
      expect(json['createdBy'], 'creator');
      expect(json['createdDate'], '2024-03-01T12:00:00.000Z');
      expect(json['updatedBy'], 'updater');
      expect(json['updatedDate'], '2024-03-02T14:00:00.000Z');
    });

    test('_parseDate should handle invalid date strings', () {
      final json = {
        'customerFinancialsId': 1,
        'appRefNo': 'APP004',
        'rimNo': 222,
        'customerName': 'Test',
        'descOfAccounts': null,
        'entityDetails': [],
        'createdBy': null,
        'createdDate': 'invalid-date',
        'updatedBy': null,
        'updatedDate': null,
      };

      final response = FinancialRatioAnalysisResponse.fromJson(json);
      expect(response.createdDate, isNull);
    });
  });

  group('EntityDetail', () {
    test('fromJson should parse correctly', () {
      final json = {
        'customerFinancialsId': 100,
        'entityId': 5,
        'entityLongName': 'Test Entity',
        'financialsCategory': [
          {
            'financialsCategory': 1,
            'financialsValues': [],
            'financialHealth': 3,
            'remarks': 'Good'
          }
        ]
      };

      final entity = EntityDetail.fromJson(json);

      expect(entity.customerFinancialsId, 100);
      expect(entity.entityId, 5);
      expect(entity.entityLongName, 'Test Entity');
      expect(entity.financialsCategory.length, 1);
    });

    test('toJson should serialize correctly', () {
      final entity = EntityDetail(
        customerFinancialsId: 200,
        entityId: 10,
        entityLongName: 'Serialized Entity',
        financialsCategory: [],
      );

      final json = entity.toJson();

      expect(json['customerFinancialsId'], 200);
      expect(json['entityId'], 10);
      expect(json['entityLongName'], 'Serialized Entity');
      expect(json['financialsCategory'], isEmpty);
    });
  });

  group('FinancialCategoryDetail', () {
    test('fromJson should parse correctly', () {
      final json = {
        'financialsCategory': 2,
        'financialsValues': [
          {
            'financialsCategory': 2,
            'financialRatioType': '97',
            'userAddedRatioType': null,
            'financialYear': 2024,
            'period': '12M',
            'auditMethod': 'Audited',
            'auditor': 'KPMG',
            'value': 1500.50
          }
        ],
        'financialHealth': 4,
        'remarks': 'Excellent'
      };

      final category = FinancialCategoryDetail.fromJson(json);

      expect(category.financialsCategory, 2);
      expect(category.financialsValues.length, 1);
      expect(category.financialHealth, 4);
      expect(category.remarks, 'Excellent');
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        'financialsCategory': 3,
        'financialsValues': [],
        'financialHealth': null,
        'remarks': null
      };

      final category = FinancialCategoryDetail.fromJson(json);

      expect(category.financialHealth, isNull);
      expect(category.remarks, isNull);
      expect(category.financialsValues, isEmpty);
    });

    test('toJson should serialize correctly', () {
      final category = FinancialCategoryDetail(
        financialsCategory: 5,
        financialsValues: [],
        financialHealth: 2,
        remarks: 'Fair',
      );

      final json = category.toJson();

      expect(json['financialsCategory'], 5);
      expect(json['financialsValues'], isEmpty);
      expect(json['financialHealth'], 2);
      expect(json['remarks'], 'Fair');
    });
  });

  group('FinancialValue', () {
    test('fromJson should parse with integer value', () {
      final json = {
        'financialsCategory': 1,
        'financialRatioType': '100',
        'userAddedRatioType': null,
        'financialYear': 2023,
        'period': '6M',
        'auditMethod': 'Co.Prep\'d',
        'auditor': null,
        'value': 1000
      };

      final value = FinancialValue.fromJson(json);

      expect(value.financialsCategory, 1);
      expect(value.financialRatioType, '100');
      expect(value.userAddedRatioType, isNull);
      expect(value.financialYear, 2023);
      expect(value.period, '6M');
      expect(value.auditMethod, 'Co.Prep\'d');
      expect(value.auditor, isNull);
      expect(value.value, 1000.0);
      expect(value.value, isA<double>());
    });

    test('fromJson should parse with double value', () {
      final json = {
        'financialsCategory': 2,
        'financialRatioType': '200',
        'userAddedRatioType': 'Custom Ratio',
        'financialYear': 2024,
        'period': '12M',
        'auditMethod': 'Audited',
        'auditor': 'PWC',
        'value': 2500.75
      };

      final value = FinancialValue.fromJson(json);

      expect(value.value, 2500.75);
      expect(value.userAddedRatioType, 'Custom Ratio');
      expect(value.auditor, 'PWC');
    });

    test('fromJson should handle null value', () {
      final json = {
        'financialsCategory': 3,
        'financialRatioType': '300',
        'userAddedRatioType': null,
        'financialYear': 2022,
        'period': '3M',
        'auditMethod': 'Unaudited',
        'auditor': null,
        'value': null
      };

      final value = FinancialValue.fromJson(json);

      expect(value.value, isNull);
    });

    test('toJson should serialize correctly', () {
      final value = FinancialValue(
        financialsCategory: 4,
        financialRatioType: '400',
        userAddedRatioType: 'Test Ratio',
        financialYear: 2025,
        period: '9M',
        auditMethod: 'Reviewed',
        auditor: 'EY',
        value: 3000.25,
      );

      final json = value.toJson();

      expect(json['financialsCategory'], 4);
      expect(json['financialRatioType'], '400');
      expect(json['userAddedRatioType'], 'Test Ratio');
      expect(json['financialYear'], 2025);
      expect(json['period'], '9M');
      expect(json['auditMethod'], 'Reviewed');
      expect(json['auditor'], 'EY');
      expect(json['value'], 3000.25);
    });
  });

  group('DeleteFinancialRatioAnalysisResult', () {
    test('fromJson should parse string input', () {
      final result = DeleteFinancialRatioAnalysisResult.fromJson('success');

      expect(result.message, 'success');
      expect(result.isSuccess, true);
    });

    test('fromJson should parse map input', () {
      final json = {'message': 'Success'};
      final result = DeleteFinancialRatioAnalysisResult.fromJson(json);

      expect(result.message, 'Success');
      expect(result.isSuccess, true);
    });

    test('fromJson should handle other types', () {
      final result = DeleteFinancialRatioAnalysisResult.fromJson(12345);

      expect(result.message, '12345');
      expect(result.isSuccess, false);
    });

    test('isSuccess should be case-insensitive', () {
      final result1 = DeleteFinancialRatioAnalysisResult(message: 'SUCCESS');
      final result2 = DeleteFinancialRatioAnalysisResult(message: 'Success');
      final result3 = DeleteFinancialRatioAnalysisResult(message: 'success');
      final result4 = DeleteFinancialRatioAnalysisResult(message: 'failed');

      expect(result1.isSuccess, true);
      expect(result2.isSuccess, true);
      expect(result3.isSuccess, true);
      expect(result4.isSuccess, false);
    });

    test('toJson should serialize correctly', () {
      final result = DeleteFinancialRatioAnalysisResult(message: 'Deleted');
      final json = result.toJson();

      expect(json['message'], 'Deleted');
    });
  });

  group('Round-trip serialization', () {
    test('Full object should round-trip correctly', () {
      final original = FinancialRatioAnalysisResponse(
        customerFinancialsId: 500,
        appRefNo: 'APP999',
        rimNo: 888,
        customerName: 'Round Trip Customer',
        descOfAccounts: 'Round Trip Description',
        entityDetails: [
          EntityDetail(
            customerFinancialsId: 500,
            entityId: 20,
            entityLongName: 'Round Trip Entity',
            financialsCategory: [
              FinancialCategoryDetail(
                financialsCategory: 10,
                financialsValues: [
                  FinancialValue(
                    financialsCategory: 10,
                    financialRatioType: '500',
                    userAddedRatioType: 'Custom',
                    financialYear: 2024,
                    period: '12M',
                    auditMethod: 'Audited',
                    auditor: 'Deloitte',
                    value: 5000.0,
                  )
                ],
                financialHealth: 5,
                remarks: 'Perfect',
              )
            ],
          )
        ],
        createdBy: 'system',
        createdDate: DateTime.parse('2024-06-01T00:00:00.000Z'),
        updatedBy: 'admin',
        updatedDate: DateTime.parse('2024-06-02T00:00:00.000Z'),
      );

      final json = original.toJson();
      final restored = FinancialRatioAnalysisResponse.fromJson(json);

      expect(restored.customerFinancialsId, original.customerFinancialsId);
      expect(restored.appRefNo, original.appRefNo);
      expect(restored.rimNo, original.rimNo);
      expect(restored.customerName, original.customerName);
      expect(restored.descOfAccounts, original.descOfAccounts);
      expect(restored.entityDetails.length, original.entityDetails.length);
      expect(restored.createdBy, original.createdBy);
      expect(restored.updatedBy, original.updatedBy);
    });
  });
}
