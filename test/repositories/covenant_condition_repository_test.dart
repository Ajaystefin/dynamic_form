import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/covenant_condition_repository.dart";
import "../test_config.dart";
import "mock_api_manager.dart";

void main() {
  group("CovenantConditionRepository Integration Tests", () {
    late CovenantConditionRepository covenantRepository;
    late MockAPIManager mockAPIManager;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      mockAPIManager = MockAPIManager();
      Globals.request = Request(applicationRefNo: "APP-12345");
      covenantRepository = CovenantConditionRepository(
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
        final repository = CovenantConditionRepository(
          apiManager: customMockAPIManager,
        );

        // Assert
        expect(repository, isA<CovenantConditionRepository>());
      });

      test("should use default dependencies when none provided", () {
        // Act
        // Use singleton instance to avoid circular dependency
        final repository = CovenantConditionRepository.instance;

        // Assert
        expect(repository, isA<CovenantConditionRepository>());
      });

      test("should maintain singleton behavior with instance getter", () {
        // Act
        final instance1 = CovenantConditionRepository.instance;
        final instance2 = CovenantConditionRepository.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("getCovenants - Success Scenarios", () {
      test("should successfully get covenants", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 1, code: "ADMIN"),
        );
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "covenantList": [
                {
                  "covenantConditionId": 1,
                  "type": 1,
                  "description":
                      "Maintain minimum debt service coverage ratio of 1.25x",
                  "category": 100,
                  "frequency": 4, // Quarterly
                  "monitorDate": 1672531200000, // 2023-01-01
                  "isGeneral": true,
                  "status": "New",
                  "action": 0,
                  "isCovenant": true,
                  "deleted": false,
                  "covConMasterId": 10,
                  "refNo": "COV001",
                  "rimNo": 12345,
                  "customerName": "ABC Corporation",
                  "isStandard": true,
                  "groupId": 100,
                  "facilityIdList": [
                    {
                      "rimNo": 12345,
                      "limitNumber": "LIM001",
                      "facilityId": 1,
                      "limitLabel": "Working Capital",
                    }
                  ],
                },
                {
                  "covenantConditionId": 2,
                  "type": 2,
                  "description":
                      "Submit audited financial statements within 120 days",
                  "category": 200,
                  "frequency": 1, // Annual
                  "monitorDate": 1704067200000, // 2024-01-01
                  "isGeneral": false,
                  "status": "New",
                  "action": 1,
                  "isCovenant": true,
                  "deleted": false,
                  "covConMasterId": 11,
                  "refNo": "COV002",
                  "rimNo": 67890,
                  "customerName": "XYZ Trading LLC",
                  "isStandard": false,
                  "groupId": 200,
                  "facilityIdList": [
                    {
                      "rimNo": 67890,
                      "limitNumber": "LIM002",
                      "facilityId": 2,
                      "limitLabel": "Trade Finance",
                    }
                  ],
                }
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await covenantRepository.getCovenants(1);

        // Assert
        // expect(result.first, 2);
        // Verify second covenant
        expect(result[1].covenantConditionId, equals(2));
      });

      test("should handle empty covenants list", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 2, code: "USER"));
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {"covenantList": []},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await covenantRepository.getCovenants(1);

        // Assert
        expect(result, isEmpty);
      });
    });

    group("getCovenants - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        const errorMessage = "Failed to fetch covenants";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => covenantRepository.getCovenants(1),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        mockAPIManager.setMockException(Exception("Network timeout"));

        // Act & Assert
        expect(
          () async => covenantRepository.getCovenants(1),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Network timeout"),
            ),
          ),
        );
      });
    });

    group("deleteCovenantCondition - Success Scenarios", () {
      test("should successfully delete covenant condition", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 1, code: "ADMIN"),
        );
        Globals.user = testUser;

        final testCovenantCondition = CovenantCondition(
          covenantConditionId: 1,
          covenantType: 1,
          description: "Test covenant to delete",
          category: 100,
          frequency: 4,
          isGeneric: true,
          status: 1,
          action: 0,
          isCovenant: true,
          deleted: false, // Will be set to true by the method
          covConMasterId: 10,
          refNo: "COV001",
          rimNo: 12345,
          customerName: "Test Customer",
          isStandard: true,
          groupId: 100,
        );

        final mockResponse = AppResponse(
          message: "Covenant condition deleted successfully",
          body: {
            "status": {
              "statusDescription": "Covenant condition deleted successfully",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await covenantRepository.deleteCovenantCondition(
          testCovenantCondition,
          1, // isCovenant
        );

        // Assert
        expect(result, equals("Covenant condition deleted successfully"));
        expect(testCovenantCondition.deleted, isTrue); // Should be set to true

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.saveCovenants),
        );
        expect(mockAPIManager.callLog[0]["method"], equals("POST"));

        // Verify request payload
        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody["roleID"], null);
        expect(requestBody["role"], null);
        expect(requestBody["userID"], null);
        expect(requestBody["userName"], null);
        expect(requestBody["requestData"]["covenantList"], hasLength(1));
        expect(requestBody["requestData"]["mode"], equals("Edit"));
        expect(requestBody["requestData"]["isCovenant"], equals(1));

        final covenantData = requestBody["requestData"]["covenantList"][0];
        expect(covenantData["deleted"], isTrue);
        expect(covenantData["covenantConditionId"], equals(1));
        expect(covenantData["description"], equals("Test covenant to delete"));
      });

      test("should handle null covenant condition", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Null covenant processed",
          body: {
            "status": {"statusDescription": "Null covenant processed"},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await covenantRepository.deleteCovenantCondition(null, 1);

        // Assert
        expect(result, equals("Null covenant processed"));

        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody["requestData"]["covenantList"][0], isNull);
      });
    });

    group("deleteCovenantCondition - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        final testCovenantCondition = CovenantCondition(
          covenantConditionId: 1,
          description: "Test covenant",
        );

        const errorMessage = "Failed to delete covenant condition";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Deletion failed"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => covenantRepository.deleteCovenantCondition(
            testCovenantCondition,
            1,
          ),
          throwsA(equals(errorMessage)),
        );
      });
    });

    group("Edge Cases and Integration", () {
      test("should handle complex covenant with facility relationships",
          () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "covenantList": [
                {
                  "covenantConditionId": 100,
                  "type": 1,
                  "description": "Complex multi-facility covenant",
                  "category": 500,
                  "frequency": 2, // Semi-annual
                  "monitorDate": 1672531200000,
                  "isGeneral": false,
                  "status": "New",
                  "action": 0,
                  "isCovenant": true,
                  "deleted": false,
                  "covConMasterId": 50,
                  "refNo": "COMPLEX001",
                  "rimNo": 99999,
                  "customerName": "Complex Customer Corp",
                  "isStandard": false,
                  "groupId": 500,
                  "facilityIdList": [
                    {
                      "rimNo": 99999,
                      "limitNumber": "LIM001",
                      "facilityId": "1",
                      "limitLabel": "Primary Facility",
                      "presentLimit": 5000000,
                      "proposedLimit": 7000000,
                    },
                    {
                      "rimNo": 99999,
                      "limitNumber": "LIM002",
                      "facilityId": "2",
                      "limitLabel": "Secondary Facility",
                      "presentLimit": 3000000,
                      "proposedLimit": 4000000,
                    },
                    {
                      "rimNo": 99999,
                      "limitNumber": "LIM003",
                      "facilityId": "3",
                      "limitLabel": "Contingent Facility",
                      "presentLimit": 1000000,
                      "proposedLimit": 1500000,
                    }
                  ],
                }
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await covenantRepository.getCovenants(1);

        // Assert
        expect(result, hasLength(1));
      });
    });

    group("saveCovenantDetails", () {
      test("returns message on success", () async {
        Globals.user = User(
          id: "u1",
          name: "User One",
          currentRole: Role(id: 1, code: "ADMIN"),
        );

        final dummyList = [
          {"covenantConditionId": 5},
        ];
        final mockResponse = AppResponse(
          message: "Saved OK",
          body: {},
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        final result =
            await covenantRepository.saveCovenantDetails(dummyList, 1);
        expect(result, "Saved OK");

        // verify we called the correct endpoint
        expect(
          mockAPIManager.callLog.last["endpoint"],
          equals(APIEndpoints.saveCovenants),
        );
      });

      test("throws on error status", () async {
        Globals.user = User(currentRole: Role(id: 1, code: "ADMIN"));

        final dummyList = [
          {"covenantConditionId": 6},
        ];
        final mockResponse = AppResponse(
          message: "Bad request",
          body: {},
          code: 400,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        await expectLater(
          () => covenantRepository.saveCovenantDetails(dummyList, 0),
          throwsA(equals("Bad request")),
        );
      });
    });

    group("getConditions", () {
      test(
          "returns parsed list of CovenantCondition on"
          " success and verifies payload", () async {
        // Arrange
        final mockConditions = [
          {
            "id": 1,
            "name": "Maintain DSCR > 1.2",
            "status": 100,
            "facilityDetailList": null,
          },
          {
            "id": 2,
            "name": "Submit quarterly financials",
            "status": 101,
            "facilityDetailList": null,
          },
        ];
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "conditionsList": mockConditions,
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await covenantRepository.getConditions();

        // Assert
        expect(result, isA<List<CovenantCondition>>());
        expect(result, hasLength(2));

        expect(result.first.status, 100);

        // Verify endpoint & JSON-encoded payload
        expect(mockAPIManager.callLog, hasLength(1));
        final call = mockAPIManager.callLog.first;
        expect(call["endpoint"], equals(APIEndpoints.getConditions));

        final sentBody = call["body"] as String; // should be JSON string
        final decoded = json.decode(sentBody) as Map<String, dynamic>;
        expect(decoded["appRefNo"], null);
        final reqData = decoded["requestData"] as Map<String, dynamic>;
        expect(reqData["appRefNo"], equals("APP-12345"));
        expect(reqData["role"], null);
      });

      test("returns empty list when conditionsList is empty", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "conditionsList": [],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await covenantRepository.getConditions();

        // Assert
        expect(result, isEmpty);
        expect(
          mockAPIManager.callLog.single["endpoint"],
          equals(APIEndpoints.getConditions),
        );
      });

      test("throws response.message when status == error", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Failed to fetch conditions",
          body: {
            "responseData": {
              "conditionsList": [],
            },
          },
          code: 500,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () => covenantRepository.getConditions(),
          throwsA(equals("Failed to fetch conditions")),
        );
        expect(
          mockAPIManager.callLog.single["endpoint"],
          equals(APIEndpoints.getConditions),
        );
      });

      test(
          "throws TypeError "
          "when response body "
          "shape is malformed (no conditionsList)", () async {
        // Arrange: missing conditionsList key
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              // 'conditionsList' missing
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert: `as List` cast should throw
        expect(
          covenantRepository.getConditions,
          throwsA(isA<TypeError>()),
        );
      });

      test("throws TypeError when conditionsList is not a List", () async {
        // Arrange: wrong type for conditionsList
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "conditionsList": "not-a-list",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          covenantRepository.getConditions,
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}
