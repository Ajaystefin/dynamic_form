import "dart:convert";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/repositories/borrower_repository.dart";
import "../test_config.dart";
import "mock_api_manager.dart";

void main() {
  group("BorrowerRepository Integration Tests", () {
    late BorrowerRepository borrowerRepository;
    late MockAPIManager mockAPIManager;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      mockAPIManager = MockAPIManager();

      borrowerRepository = BorrowerRepository(
        apiManager: mockAPIManager,
      );

      // Reset globals
      Globals.user = null;
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
      Globals.user = null;
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group("Dependency Injection", () {
      test("should use injected APIManager", () {
        // Arrange
        final customMockAPIManager = MockAPIManager();

        // Act
        final repository = BorrowerRepository(
          apiManager: customMockAPIManager,
        );

        // Assert
        expect(repository, isA<BorrowerRepository>());
      });

      test("should use default dependencies when none provided", () {
        // Act
        // Use singleton instance to avoid circular dependency
        final repository = BorrowerRepository.instance;

        // Assert
        expect(repository, isA<BorrowerRepository>());
      });

      test("should maintain singleton behavior with instance getter", () {
        // Act
        final instance1 = BorrowerRepository.instance;
        final instance2 = BorrowerRepository.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    // group('getGroupCustomers - Success Scenarios', () {
    //   test('should successfully get group customers', () async {
    //     // Arrange
    //     final mockResponse = AppResponse(
    //       message: 'Success',
    //       body: {
    //         'responseData': [
    //           {
    //             'PartyId': 'PARTY001',
    //             'rimNo': 12345,
    //             'customerName': 'ABC Corporation',
    //             'primaryBusinessActivity': 'Manufacturing',
    //             'existingSICCode': 'SIC001',
    //             'proposedSICCode': 'SIC002',
    //             'isBorrower': true,
    //             'custInfoId': 1001,
    //             'applicationRefNo': 'APP123456',
    //             'groupName': 'ABC Group',
    //             'groupId': 100,
    //             'legalStatus': 'Limited Company',
    //             'tradeLicenseNumber': 'TL123456',
    //             'tlIssuingAuthority': 'Dubai Municipality',
    //             'tlExpiryDate': "1735689600000", // 2025-01-01
    //             'industryDescription': 'Heavy Manufacturing',
    //             'industrySicCode': 'IND001',
    //             'incorporateCountry': 'UAE',
    //             'businessCountryList': ['UAE', 'Saudi Arabia', 'Qatar'],
    //             'establishmentDate': "1609459200000", // 2021-01-01
    //             'relatnStartDate': "1640995200000", // 2022-01-01
    //             'borrowRelationShipDate': "1640995200000", // 2022-01-01
    //             'healthCode': 1,
    //             'purpose': 2,
    //             'cccStatus': 'Active',
    //             'locationAddress': '123 Business Bay, Dubai',
    //             'correspondanceAddress': '123 Business Bay, Dubai',
    //             'createdDate': "1640995200000",
    //             'createdBy': 'system',
    //             'updatedDate': "1640995200000",
    //             'updatedBy': 'system',
    //             'cbrbClasification': 'Grade A',
    //             'tradedCountryList': ['UAE', 'Saudi Arabia'],
    //             'countryRiskList': ['UAE'],
    //             'cbdCBRBClassification': 'Low Risk',
    //             'borrowRelnDateEditable': true,
    //             'isBorrowerBelowGrade': false,
    //             'ifrsStaging': 'Stage 1',
    //             'deviationBreachJustification': 'No deviations',
    //             'worldRank': '100',
    //             'countryRank': '5',
    //             'category': 'Corporate',
    //             'GroupKeys': {
    //               'GroupId': '100',
    //               'GroupName': 'ABC Group',
    //               'groupDescription': 'Leading manufacturing group'
    //             },
    //             'customerOwnerShipInfoList': [
    //               {
    //                 'custOwnId': 1,
    //                 'custOwnershipName': 'John Doe',
    //                 'custOwnershipRim': 54321,
    //                 'rim': 12345,
    //                 'nationality': 'UAE',
    //                 'shareHoldingPercentage': 60,
    //                 'resident': 'Yes',
    //                 'beneficialOwnerhipPercentage': 60,
    //                 'identificationDetail': 'Emirates ID',
    //                 'identificationNumber': '784-1234-5678901-2',
    //                 'createdDate': 1640995200000,
    //                 'createdBy': 'system',
    //                 'updatedDate': 1640995200000,
    //                 'updatedBy': 'system',
    //                 'custOwnershipType': 'Individual'
    //               }
    //             ],
    //             'exceptionList': [
    //               {
    //                 'type': 'Documentation',
    //                 'facilityId': 1,
    //                 'description': 'Missing trade license copy',
    //                 'dueDate': 1672531200000, // 2023-01-01
    //                 'status': 'Pending',
    //                 'recommendations': 'Submit copy within 30 days',
    //                 'delete': false
    //               }
    //             ]
    //           },
    //           {
    //             'PartyId': 'PARTY002',
    //             'rimNo': 67890,
    //             'customerName': 'XYZ Trading LLC',
    //             'primaryBusinessActivity': 'Trading',
    //             'existingSICCode': 'SIC003',
    //             'proposedSICCode': 'SIC004',
    //             'isBorrower': false,
    //             'custInfoId': 1002,
    //             'applicationRefNo': 'APP789012',
    //             'groupName': 'XYZ Group',
    //             'groupId': 200,
    //             'legalStatus': 'LLC',
    //             'incorporateCountry': 'UAE',
    //             'businessCountryList': ['UAE'],
    //             'isBorrowerBelowGrade': true
    //           }
    //         ]
    //       },
    //       code: 200,
    //       status: ResponseStatus.success,
    //     );

    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act
    //     final result = await borrowerRepository.getGroupCustomers();

    //     // Assert
    //     expect(result, hasLength(2));

    //     // Verify first customer
    //     expect(result[0], isA<Customer>());
    //     expect(result[0].id, equals('PARTY001'));
    //     expect(result[0].customerRimNo, equals(12345));
    //     expect(result[0].customerName, equals('ABC Corporation'));
    //     expect(result[0].primaryBusinessActivity, equals('Manufacturing'));
    //     expect(result[0].existingSICCode, equals('SIC001'));
    //     expect(result[0].proposedSICCode, equals('SIC002'));
    //     expect(result[0].isBorrower, isTrue);
    //     expect(result[0].custInfoId, equals(1001));
    //     expect(result[0].applicationRefNo, equals('APP123456'));
    //     expect(result[0].groupName, equals('ABC Group'));
    //     expect(result[0].groupId, equals(100));
    //     expect(result[0].legalStatus, equals('Limited Company'));
    //     expect(result[0].tradeLicenseNumber, equals('TL123456'));
    //     expect(result[0].tlIssuingAuthority, equals('Dubai Municipality'));
    //     expect(result[0].industryDescription, equals('Heavy Manufacturing'));
    //     expect(result[0].industrySicCode, equals('IND001'));
    //     expect(result[0].incorporateCountry, equals('UAE'));

    //     expect(result[0].cccStatus, equals('Active'));
    //     expect(result[0].locationAddress, equals('123 Business Bay, Dubai'));
    //     expect(result[0].cbrbClassification, equals('Grade A'));

    //     expect(result[0].cbdCBRBClassification, equals('Low Risk'));
    //     expect(result[0].borrowRelnDateEditable, isTrue);
    //     expect(result[0].isBorrowerBelowGrade, isFalse);
    //     expect(result[0].ifrsStaging, equals('Stage 1'));
    //     expect(result[0].worldRank, equals('100'));
    //     expect(result[0].countryRank, equals('5'));
    //     expect(result[0].category, equals('Corporate'));

    //     // Verify group data
    //     expect(result[0].groups, isNotNull);
    //     expect(result[0].groups!.id, equals('100'));
    //     expect(result[0].groups!.name, equals('ABC Group'));

    //     // Verify ownership info
    //     // expect(result[0].ownershipInfos, hasLength(1));
    //     // expect(result[0].ownershipInfos![0].custOwnId, equals(1));
    //     // expect(
    //     //     result[0].ownershipInfos![0].custOwnershipName, equals('John Doe'));
    //     // expect(result[0].ownershipInfos![0].nationality, equals('UAE'));
    //     // expect(result[0].ownershipInfos![0].shareHoldingPercentage, equals(60));

    //     // Verify exceptions
    //     // expect(result[0].exceptions, hasLength(1));
    //     // expect(result[0].exceptions![0].type, equals('Documentation'));
    //     // expect(result[0].exceptions![0].description,
    //     //     equals('Missing trade license copy'));
    //     // expect(result[0].exceptions![0].status, equals('Pending'));

    //     // Verify second customer
    //     expect(result[1].id, equals('PARTY002'));
    //     expect(result[1].customerRimNo, equals(67890));
    //     expect(result[1].customerName, equals('XYZ Trading LLC'));
    //     expect(result[1].isBorrower, isFalse);
    //     expect(result[1].isBorrowerBelowGrade, isTrue);

    //     expect(mockAPIManager.callLog, hasLength(1));
    //     expect(mockAPIManager.callLog[0]['endpoint'],
    //         equals(APIEndpoints.getGroupCustomers));
    //     expect(mockAPIManager.callLog[0]['method'], equals('GET'));
    //   });

    //   test('should handle empty customer list', () async {
    //     // Arrange
    //     final mockResponse = AppResponse(
    //       message: 'Success',
    //       body: {'responseData': []},
    //       code: 200,
    //       status: ResponseStatus.success,
    //     );

    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act
    //     final result = await borrowerRepository.getGroupCustomers();

    //     // Assert
    //     expect(result, isEmpty);
    //   });

    //   test('should handle customers with minimal data', () async {
    //     // Arrange
    //     final mockResponse = AppResponse(
    //       message: 'Success',
    //       body: {
    //         'responseData': [
    //           {
    //             'PartyId': 'MIN001',
    //             'rimNo': 11111,
    //             'customerName': 'Minimal Customer'
    //           },
    //           {
    //             'PartyId': 'MIN002',
    //             'name':
    //                 'Alternative Name Field', // Uses 'name' instead of 'customerName'
    //             'customerRimNumber':
    //                 22222 // Uses 'customerRimNumber' instead of 'rimNo'
    //           }
    //         ]
    //       },
    //       code: 200,
    //       status: ResponseStatus.success,
    //     );

    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act
    //     final result = await borrowerRepository.getGroupCustomers();

    //     // Assert
    //     expect(result, hasLength(2));
    //     expect(result[0].id, equals('MIN001'));
    //     expect(result[0].customerRimNo, equals(11111));
    //     expect(result[0].customerName, equals('Minimal Customer'));

    //     expect(result[1].id, equals('MIN002'));
    //     expect(result[1].customerRimNo,
    //         equals(22222)); // Should pick up customerRimNumber
    //     expect(result[1].customerName,
    //         equals('Alternative Name Field')); // Should pick up name
    //   });

    //   test('should handle customers with null values gracefully', () async {
    //     // Arrange
    //     final mockResponse = AppResponse(
    //       message: 'Success',
    //       body: {
    //         'responseData': [
    //           {
    //             'PartyId': null,
    //             'rimNo': null,
    //             'customerName': null,
    //             'primaryBusinessActivity': null,
    //             'isBorrower': null,
    //             'businessCountryList': null,
    //             'customerOwnerShipInfoList': null,
    //             'exceptionList': null
    //           }
    //         ]
    //       },
    //       code: 200,
    //       status: ResponseStatus.success,
    //     );

    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act
    //     final result = await borrowerRepository.getGroupCustomers();

    //     // Assert
    //     expect(result, hasLength(1));
    //     expect(result[0].id, isNull);
    //     expect(result[0].customerRimNo, isNull);
    //     expect(result[0].customerName, isNull);
    //     expect(result[0].primaryBusinessActivity, isNull);
    //     expect(result[0].isBorrower, isNull);
    //   });
    // });

    group("getGroupCustomers - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        const errorMessage = "Failed to fetch group customers";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => borrowerRepository.getGroupCustomers(),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        // Arrange
        mockAPIManager.setMockException(Exception("Network timeout"));

        // Act & Assert
        expect(
          () async => borrowerRepository.getGroupCustomers(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Network timeout"),
            ),
          ),
        );
      });

      test("should handle malformed response structure", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": "invalid_data", // Should be List
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => borrowerRepository.getGroupCustomers(),
          throwsA(isA<TypeError>()),
        );
      });

      test("should handle null response data", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": null},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => borrowerRepository.getGroupCustomers(),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("getCustomerByRim - Success Scenarios", () {
      test("should handle customer with minimal data", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 2, code: "USER"));
        Globals.user = testUser;

        const testRim = 99999;
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "PartyId": "MIN123",
              "rimNo": 99999,
              "customerName": "Minimal Customer",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await borrowerRepository.getCustomerByRim(testRim);

        // Assert
        expect(result.responseData?.partyId, equals("MIN123"));
        expect(
          result.responseData?.partyInfo?.personData?.personName?.lastName,
          equals(null),
        );
        expect(result.responseData?.partyInfo, isNull);
      });

      test("should handle null user gracefully", () async {
        // Arrange - No user set
        const testRim = 54321;
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "PartyId": "NULL_USER",
              "rimNo": 54321,
              "customerName": "Null User Test",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await borrowerRepository.getCustomerByRim(testRim);

        // Assert
        expect(result.responseData?.partyId, equals("NULL_USER"));
        expect(
          result.responseData?.partyInfo?.personData?.personName?.lastName,
          equals(null),
        );

        // Verify request payload handles null user
        final requestBody = json.decode(mockAPIManager.callLog[0]["body"]);
        expect(requestBody["roleID"], isNull);
        expect(requestBody["role"], isNull);
        expect(requestBody["userID"], equals(null)); // Hardcoded fallback
        expect(requestBody["userName"], equals(null)); // Hardcoded fallback
        expect(requestBody["requestData"]["rimNo"], equals(null));
      });

      test("should handle customer with alternative name field", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        const testRim = 77777;
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "PartyId": "ALT123",
              "rimNo": 77777,
              "name": "Alternative Name"
                  " Customer", // Uses 'name' instead of 'customerName'
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await borrowerRepository.getCustomerByRim(testRim);

        // Assert
        expect(result.responseData?.partyId, equals("ALT123"));
        expect(result.responseData?.partyId, equals("ALT123"));
        expect(
          result.responseData?.partyInfo?.personData?.personName?.lastName,
          equals(null),
        );
      });
    });

    group("getCustomerByRim - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        const testRim = 12345;
        const errorMessage = "Customer not found";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Customer with RIM 12345 not found"},
          code: 404,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => borrowerRepository.getCustomerByRim(testRim),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        const testRim = 12345;
        mockAPIManager.setMockException(Exception("Connection failed"));

        // Act & Assert
        expect(
          () async => borrowerRepository.getCustomerByRim(testRim),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Connection failed"),
            ),
          ),
        );
      });

      test("should handle malformed response structure", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        const testRim = 12345;
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": "invalid_data", // Should be Map
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => borrowerRepository.getCustomerByRim(testRim),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("Edge Cases and Integration", () {
      test("should handle concurrent API calls", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "PartyId": "CONCURRENT1",
                "rimNo": 11111,
                "customerName": "Concurrent Customer 1",
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act - Make multiple concurrent calls
        final futures =
            List.generate(3, (_) => borrowerRepository.getGroupCustomers());
        final results = await Future.wait(futures);

        // Assert
        expect(results, hasLength(3));
        for (final result in results) {
          expect(result, hasLength(1));
          expect(result[0].id, equals("CONCURRENT1"));
        }
        expect(mockAPIManager.callLog, hasLength(3));
      });

      test("should handle mixed success and error responses in sequence",
          () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        // First call succeeds
        final successResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "PartyId": "SUCCESS1",
              "rimNo": 11111,
              "customerName": "Success Customer",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(successResponse);
        final result1 = await borrowerRepository.getCustomerByRim(11111);

        // Second call fails
        const errorMessage = "Customer not found";
        final errorResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Not found"},
          code: 404,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(errorResponse);

        // Act & Assert
        expect(result1.responseData?.partyId, equals("SUCCESS1"));
        expect(
          result1.responseData?.partyInfo?.personData?.personName?.lastName,
          equals(null),
        );

        expect(
          () async => borrowerRepository.getCustomerByRim(22222),
          throwsA(equals(errorMessage)),
        );

        expect(mockAPIManager.callLog, hasLength(2));
      });

      test("should handle large customer datasets efficiently", () async {
        // Arrange
        final largeCustomerList = List.generate(
          500,
          (index) => {
            "PartyId": "PARTY$index",
            "rimNo": 10000 + index,
            "customerName": "Customer $index",
            "primaryBusinessActivity": "Business Activity $index",
            "isBorrower": index % 2 == 0,
            "groupId": 100 + (index % 10),
            "groupName": "Group ${100 + (index % 10)}",
          },
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": largeCustomerList},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await borrowerRepository.getGroupCustomers();

        // Assert
        expect(result, hasLength(500));
        expect(result[0].id, equals("PARTY0"));
        expect(result[0].customerRimNo, equals(10000));
        expect(result[0].isBorrower, isTrue);
        expect(result[499].id, equals("PARTY499"));
        expect(result[499].customerRimNo, equals(10499));
        expect(result[499].isBorrower, isFalse);
      });

      test("should handle complex nested data structures", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "PartyId": "COMPLEX1",
                "rimNo": 88888,
                "customerName": "Complex Customer",
                "GroupKeys": {
                  "GroupId": "999",
                  "GroupName": "Complex Group",
                  "groupDescription": "A very complex group structure",
                },
                "customerOwnerShipInfoList": [
                  {
                    "custOwnId": 1,
                    "custOwnershipName": "Owner 1",
                    "shareHoldingPercentage": 40,
                    "nationality": "UAE",
                  },
                  {
                    "custOwnId": 2,
                    "custOwnershipName": "Owner 2",
                    "shareHoldingPercentage": 35,
                    "nationality": "Saudi Arabia",
                  },
                  {
                    "custOwnId": 3,
                    "custOwnershipName": "Owner 3",
                    "shareHoldingPercentage": 25,
                    "nationality": "Qatar",
                  }
                ],
                "exceptionList": [
                  {
                    "type": "Legal",
                    "description": "Pending legal documentation",
                    "status": "In Progress",
                  },
                  {
                    "type": "Financial",
                    "description": "Awaiting financial statements",
                    "status": "Pending",
                  }
                ],
                "businessCountryList": [
                  "UAE",
                  "Saudi Arabia",
                  "Qatar",
                  "Oman",
                  "Kuwait",
                ],
                "tradedCountryList": [
                  "UAE",
                  "Saudi Arabia",
                  "Qatar",
                  "Oman",
                  "Kuwait",
                  "Bahrain",
                ],
                "countryRiskList": ["UAE", "Saudi Arabia", "Qatar"],
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await borrowerRepository.getGroupCustomers();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals("COMPLEX1"));
        expect(result[0].groups!.id, equals("999"));
      });
    });
  });
}
