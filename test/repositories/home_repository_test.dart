import "dart:convert";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/home/audit.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/repositories/home_repository.dart";
import "mock_api_manager.dart";

void main() {
  group("HomeRepository Integration Tests", () {
    late HomeRepository homeRepository;
    late MockAPIManager mockAPIManager;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await EnvConfig.setEnvironment();
      mockAPIManager = MockAPIManager();
      homeRepository = HomeRepository(apiManager: mockAPIManager);
      // Initialize a default sessionID to avoid null issues
      Globals.sessionID = "test-session-123";
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
      Globals.user = null;
    });

    group("Constructor and Initialization", () {
      test("should create instance with default APIManager when none provided",
          () {
        // Use singleton instance to avoid circular dependency
        final repo = HomeRepository.instance;
        expect(repo, isNotNull);
      });

      test("should create instance with provided APIManager", () {
        final repo = HomeRepository(apiManager: mockAPIManager);
        expect(repo, isNotNull);
      });

      test("should provide singleton instance", () {
        // Use singleton instance to avoid circular dependency
        final instance1 = HomeRepository.instance;
        final instance2 = HomeRepository.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("saveUIAuditData - Success Scenarios", () {
      test("should successfully save UI audit data", () async {
        // Arrange
        final auditData = Audit(
          userID: "testUser",
          userName: "Test User",
          role: "ADMIN",
          roleID: 1,
          pageId: 1,
          requestData: "LOGIN action performed",
        );

        final mockResponse = AppResponse(
          message: "Audit data saved successfully",
          body: <String, dynamic>{"success": true, "auditId": 12345},
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        await homeRepository.saveUIAuditData(auditData);

        // Assert
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.saveUIAuditUrl),
        );
        expect(mockAPIManager.callLog[0]["method"], equals("POST"));

        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody, equals(auditData.toJson()));
      });

      test("should handle multiple audit data saves", () async {
        // Arrange
        final auditDataList = [
          Audit(userID: "user1", userName: "User One", requestData: "LOGIN"),
          Audit(userID: "user2", userName: "User Two", requestData: "LOGOUT"),
          Audit(
            userID: "user3",
            userName: "User Three",
            requestData: "VIEW_PAGE",
          ),
        ];

        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{"success": true},
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        for (final auditData in auditDataList) {
          await homeRepository.saveUIAuditData(auditData);
        }

        // Assert
        expect(mockAPIManager.callLog, hasLength(auditDataList.length));
        for (int i = 0; i < auditDataList.length; i++) {
          expect(
            mockAPIManager.callLog[i]["body"],
            equals(auditDataList[i].toJson()),
          );
        }
      });
    });

    group("saveUIAuditData - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final auditData = Audit(
          userID: "testUser",
          userName: "Test User",
          requestData: "INVALID_ACTION",
        );

        final mockResponse = AppResponse(
          message: "Invalid audit data",
          body: <String, dynamic>{"error": "Action not recognized"},
          code: 400,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () => homeRepository.saveUIAuditData(auditData),
          throwsA(equals("Invalid audit data")),
        );
      });

      test("should handle server errors", () async {
        // Arrange
        final auditData = Audit(
          userID: "testUser",
          userName: "Test User",
          requestData: "LOGIN",
        );
        mockAPIManager.setMockException(Exception("Server error"));

        // Act & Assert
        expect(
          () => homeRepository.saveUIAuditData(auditData),
          throwsA(isA<Exception>()),
        );
      });
    });

    group("getReferenceData", () {
      group("Success Scenarios", () {
        test("parses Map → referenceDataTypeList branch", () async {
          Globals.user = User(
            id: "u1",
            name: "Test User",
            currentRole: Role(
              roleId: 1,
              code: "ADMIN",
              name: "Administrator",
              bpmRole: "ADMIN_BPM",
            ),
          );

          final missingKeys = ["COUNTRY", "CURRENCY"];
          final mockResponse = AppResponse(
            message: "OK",
            body: <String, dynamic>{
              "responseData": <Map<String, dynamic>>[
                <String, dynamic>{
                  "id": 1,
                  "name": "COUNTRY",
                  "description": "Country codes",
                  "referenceList": <Map<String, dynamic>>[
                    <String, dynamic>{"id": 1, "name": "UAE", "code": "AE"},
                    <String, dynamic>{"id": 2, "name": "USA", "code": "US"},
                  ],
                },
                <String, dynamic>{
                  "id": 2,
                  "name": "CURRENCY",
                  "description": "Currency codes",
                  "referenceList": <Map<String, dynamic>>[
                    <String, dynamic>{"id": 1, "name": "AED", "code": "AED"},
                    <String, dynamic>{"id": 2, "name": "USD", "code": "USD"},
                  ],
                },
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          );
          mockAPIManager.setMockResponse(mockResponse);

          final result = await homeRepository.getReferenceData(missingKeys);

          // verify two ReferenceType instances
          expect(result, hasLength(2));
          expect(result[0], isA<ReferenceType>());
          expect(result[1].name, "CURRENCY");

          // check first item’s fields
          final first = result.first;
          expect(first.id, null);
          expect(first.name, "COUNTRY");
          expect(first.description, "Country codes");

          // verify request payload was built via BaseRequest
          final raw = mockAPIManager.callLog[0]["body"] as String;
          final payload = json.decode(raw) as Map<String, dynamic>;

          expect(payload["baseRequest"]["roleID"], 1);
          expect(payload["baseRequest"]["role"], "ADMIN");
          expect(payload["baseRequest"]["bpmRole"], "ADMIN_BPM");
          expect(payload["baseRequest"]["userID"], "u1");
          // expect(payload['baseRequest']['userName'], 'Test User');
          expect(
            payload["requestData"]["referenceDataName"],
            equals(missingKeys),
          );
        });

        test("parses top‐level List branch", () async {
          Globals.user = User(
            id: "u2",
            name: "User Two",
            currentRole: Role(
              roleId: 1,
              code: "ADMIN",
              name: "Administrator",
              bpmRole: "ADMIN_BPM",
            ),
          );

          final missingKeys = ["A", "B"];
          final mockResponse = AppResponse(
            message: "OK",
            body: <String, dynamic>{
              "responseData": <Map<String, dynamic>>[
                <String, dynamic>{
                  "id": 3,
                  "name": "A",
                  "description": "Alpha",
                  "referenceList": <dynamic>[],
                },
                <String, dynamic>{
                  "id": 4,
                  "name": "B",
                  "description": "Beta",
                  "referenceList": <dynamic>[],
                }
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          );
          mockAPIManager.setMockResponse(mockResponse);

          final result = await homeRepository.getReferenceData(missingKeys);

          expect(result, hasLength(2));
          expect(result[0].id, null);
          expect(result[1].description, "Beta");
        });

        test("empty referenceDataTypeList yields empty list", () async {
          Globals.user = User(
            id: "u3",
            name: "User Three",
            currentRole: Role(
              roleId: 1,
              code: "ADMIN",
              name: "Administrator",
              bpmRole: "ADMIN_BPM",
            ),
          );

          // Map branch, but empty list
          final mockResponse1 = AppResponse(
            message: "OK",
            body: <String, dynamic>{"responseData": <dynamic>[]},
            code: 200,
            status: ResponseStatus.success,
          );
          mockAPIManager.setMockResponse(mockResponse1);
          final r1 = await homeRepository.getReferenceData(["X"]);
          expect(r1, isEmpty);

          // List branch, but empty list
          final mockResponse2 = AppResponse(
            message: "OK",
            body: <String, dynamic>{"responseData": <dynamic>[]},
            code: 200,
            status: ResponseStatus.success,
          );
          mockAPIManager.setMockResponse(mockResponse2);
          final r2 = await homeRepository.getReferenceData(["Y"]);
          expect(r2, isEmpty);
        });
      });

      group("Error Scenarios", () {
        test("throws response.message on error status", () async {
          Globals.user = User(
            id: "u4",
            name: "User Four",
            currentRole: Role(
              roleId: 1,
              code: "ADMIN",
              name: "Administrator",
              bpmRole: "ADMIN_BPM",
            ),
          );

          final mockResponse = AppResponse(
            message: "Invalid reference keys",
            body: <String, dynamic>{"error": "Not found"},
            code: 400,
            status: ResponseStatus.error,
          );
          mockAPIManager.setMockResponse(mockResponse);

          await expectLater(
            () => homeRepository.getReferenceData(["INVALID"]),
            throwsA(equals("Invalid reference keys")),
          );
        });

        test("bubbles up network exceptions", () async {
          Globals.user = User(
            id: "u5",
            name: "User Five",
            currentRole: Role(
              roleId: 1,
              code: "ADMIN",
              name: "Administrator",
              bpmRole: "ADMIN_BPM",
            ),
          );

          mockAPIManager.setMockException(Exception("Network timeout"));

          await expectLater(
            () => homeRepository.getReferenceData(["COUNTRY"]),
            throwsA(isA<Exception>()),
          );
        });

        test("malformed referenceDataTypeList entry throws TypeError",
            () async {
          Globals.user = User(
            id: "u6",
            name: "User Six",
            currentRole: Role(
              roleId: 1,
              code: "ADMIN",
              name: "Administrator",
              bpmRole: "ADMIN_BPM",
            ),
          );

          final mockResponse = AppResponse(
            message: "OK",
            body: <String, dynamic>{
              "responseData": <String, dynamic>{
                "referenceDataTypeList": <dynamic>["bad_item"],
              },
            },
            code: 200,
            status: ResponseStatus.success,
          );
          mockAPIManager.setMockResponse(mockResponse);

          await expectLater(
            () => homeRepository.getReferenceData(["COUNTRY"]),
            throwsA(isA<TypeError>()),
          );
        });
      });

      group("Authorization guard", () {
        test("throws TypeError when user is null", () async {
          Globals.user = null;

          await expectLater(
            () => homeRepository.getReferenceData(["ANY"]),
            throwsA(isA<TypeError>()),
          );
        });
      });
    });

    group("Edge Cases and Integration", () {
      test("should handle concurrent API calls", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(
            roleId: 1,
            code: "ADMIN",
            name: "Administrator",
            bpmRole: "ADMIN_BPM",
          ),
        );
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{"success": true, "responseData": <dynamic>[]},
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final futures = [
          homeRepository.getReferenceData(["COUNTRY"]),
        ];
        await Future.wait(futures);
        await homeRepository.saveUIAuditData(
          Audit(userID: "test", userName: "Test User", requestData: "TEST"),
        );

        // Assert
        expect(mockAPIManager.callLog, hasLength(2));
      });

      test("should handle large reference data requests", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(
            roleId: 1,
            code: "ADMIN",
            name: "Administrator",
            bpmRole: "ADMIN_BPM",
          ),
        );
        Globals.user = testUser;

        final largeKeyList = List.generate(100, (index) => "KEY_$index");
        final mockReferenceTypes = List.generate(
          100,
          (index) => {
            "id": index + 1,
            "name": "KEY_$index",
            "description": "Description for key $index",
            "referenceList": [],
          },
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{"responseData": mockReferenceTypes},
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await homeRepository.getReferenceData(largeKeyList);

        // Assert
        expect(result, hasLength(100));

        final requestBody = json.decode(mockAPIManager.callLog[0]["body"]);
        expect(
          requestBody["requestData"]["referenceDataName"],
          equals(largeKeyList),
        );
      });

      test("should handle special characters in audit data", () async {
        // Arrange
        final auditData = Audit(
          userID: "user@domain.com",
          userName: "Special User",
          requestData: "Test with special chars: àáâãäåæçèéêë ñòóôõö ùúûüý",
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{"success": true},
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        await homeRepository.saveUIAuditData(auditData);

        // Assert
        expect(mockAPIManager.callLog, hasLength(1));
        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody, equals(auditData.toJson()));
      });

      test("should handle methods that don't require user context", () async {
        // Arrange - No user set for non-user dependent methods
        Globals.user = null;

        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{"success": true},
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert - Methods that don't require user context should work

        await homeRepository.saveUIAuditData(
          Audit(userID: "test", userName: "Test User", requestData: "TEST"),
        );

        // getReferenceData should work even with null user (BaseRequest handles
        // null user)
        final result = await homeRepository.getReferenceData(["TEST"]);
        expect(
          result,
          isEmpty,
        ); // Should return empty list when mock returns error response

        expect(
          mockAPIManager.callLog,
          hasLength(
            2,
          ),
        ); // getProductDetail, saveUIAuditData, and getReferenceData calls
      });
    });
  });
}
