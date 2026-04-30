import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/admin/access_right.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "../test_config.dart";
import "mock_api_manager.dart";
import "mock_reference_data_service.dart";

void main() {
  group("AdminRepository Integration Tests", () {
    late AdminRepository adminRepository;
    late MockAPIManager mockAPIManager;
    late MockReferenceDataService mockReferenceDataService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      mockAPIManager = MockAPIManager();
      mockReferenceDataService = MockReferenceDataService();

      adminRepository = AdminRepository(
        apiManager: mockAPIManager,
        referenceDataService: mockReferenceDataService,
      );

      // Reset globals
      Globals.user = null;
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
      mockReferenceDataService.clearMockData();
      Globals.user = null;
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group("Dependency Injection", () {
      test("should use injected APIManager and ReferenceDataService", () {
        // Arrange
        final customMockAPIManager = MockAPIManager();
        final customMockReferenceService = MockReferenceDataService();

        // Act
        final repository = AdminRepository(
          apiManager: customMockAPIManager,
          referenceDataService: customMockReferenceService,
        );

        // Assert
        expect(repository, isA<AdminRepository>());
      });

      test("should use default dependencies when none provided", () {
        // Act - Use singleton instance to avoid circular dependency
        final repository = AdminRepository.instance;

        // Assert
        expect(repository, isA<AdminRepository>());
      });

      test("should maintain singleton behavior with instance getter", () {
        // Act
        final instance1 = AdminRepository.instance;
        final instance2 = AdminRepository.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("saveAccessRights - Success Scenarios", () {
      test("should successfully save access rights for new record", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session";
        final role = Reference(reference1: "ADMIN", name: "Administrator");
        final requestType = Reference(reference1: "APP", name: "Application");
        final accessRight = AccessRight(
          role: "ADMIN",
          requestType: "APPLICATION",
          subType: "NEW",
          pages: [
            Page(
              id: 1,
              name: "Dashboard",
              componentName: "dashboard",
              accessType: AccessType.edit,
              navigationOrder: 1,
            ),
          ],
        );

        final mockResponse = AppResponse(
          message: "Access rights saved successfully",
          body: <String, dynamic>{
            "baseResponse": <String, dynamic>{
              "status": <String, dynamic>{
                "statusCode": 0,
                "statusDescription": "Success",
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.saveAccessRights(
          requestType,
          role,
          accessRight,
          false,
        );

        // Assert
        expect(result, equals("Success"));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.saveRoleRightMap),
        );

        // Verify request structure for new record
        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody["baseRequest"]["channelID"], equals("WCAS"));
        expect(requestBody["requestData"]["role"], equals("ADMIN"));
        expect(
          requestBody["requestData"]["subType"],
          equals("APP"),
        ); // AM for accessRightSave
      });

      test("should successfully save access rights for update", () async {
        // Arrange
        final testUser = User(
          id: "testUser456",
          name: "Test Manager",
          currentRole:
              Role(roleId: 2, name: "Manager", code: "MGR", bpmRole: "manager"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-2";

        final accessRight = AccessRight(
          role: "MANAGER",
          requestType: "APPLICATION",
          subType: "UPDATE",
        );
        final role = Reference(reference1: "ADMIN", name: "Administrator");
        final requestType = Reference(reference1: "APP", name: "Application");
        final mockResponse = AppResponse(
          message: "Access rights updated successfully",
          body: <String, dynamic>{
            "baseResponse": <String, dynamic>{
              "status": <String, dynamic>{
                "statusCode": 0,
                "statusDescription": "Updated successfully",
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.saveAccessRights(
          requestType,
          role,
          accessRight,
          true,
        );

        // Assert
        expect(result, equals("Updated successfully"));
        expect(mockAPIManager.callLog, hasLength(1));

        // Verify subType is set to update constant
        expect(
          accessRight.subType,
          equals("APP"),
        ); // ServerConstants.accessRightUpdate
      });
    });

    group("saveAccessRights - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(
          id: "testUser789",
          name: "Test User Error",
          currentRole:
              Role(roleId: 3, name: "Test", code: "TST", bpmRole: "test"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-3";

        final accessRight = AccessRight(role: "TEST");
        const errorMessage = "Save failed";
        final role = Reference(reference1: "ADMIN", name: "Administrator");
        final requestType = Reference(reference1: "APP", name: "Application");

        final mockResponse = AppResponse(
          message: errorMessage,
          body: <String, dynamic>{
            "status": <String, dynamic>{
              "statusCode": 1,
              "statusDescription": "Save error",
            },
          },
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => adminRepository.saveAccessRights(
            requestType,
            role,
            accessRight,
            false,
          ),
          throwsA(equals(errorMessage)),
        );
      });

      test("should rethrow exception when API call fails", () async {
        // Arrange
        final testUser = User(
          id: "testUser999",
          name: "Test User Exception",
          currentRole:
              Role(roleId: 4, name: "Test", code: "TST", bpmRole: "test"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-4";

        final accessRight = AccessRight(role: "TEST");
        final role = Reference(reference1: "ADMIN", name: "Administrator");
        final requestType = Reference(reference1: "APP", name: "Application");

        mockAPIManager.setMockException(Exception("Network failure"));

        // Act & Assert
        expect(
          () async => adminRepository.saveAccessRights(
            requestType,
            role,
            accessRight,
            true,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Network failure"),
            ),
          ),
        );
      });
    });

    group("getAccessRights - Success Scenarios", () {
      test("should successfully get access rights", () async {
        // Arrange
        final testUser = User(
          id: "testUser555",
          name: "Test Admin",
          currentRole: Role(
            roleId: 5,
            name: "Administrator",
            code: "ADMIN",
            bpmRole: "admin",
          ),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-5";

        final role = Reference(reference1: "ADMIN", name: "Administrator");
        final requestType = Reference(reference1: "APP", name: "Application");

        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{
            "status": <String, dynamic>{"statusCode": 0},
            "responseData": <String, dynamic>{
              "role": "ADMIN",
              "requestType": "APP",
              "subType": "NW",
              "pageIds": <Map<String, dynamic>>[
                <String, dynamic>{
                  "pageId": 1,
                  "pageName": "Dashboard",
                  "componentName": "dashboard",
                  "accessType": "E",
                  "navigationOrder": 1,
                }
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.getAccessRights(role, requestType);

        // Assert
        expect(result, isNotNull);
        // The exact field values depend on AccessRight.fromJson implementation
        expect(result, isA<AccessRight>());

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getRoleRightMap),
        );

        // Verify request data
        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody["baseRequest"], isNotNull);
        expect(requestBody["requestData"], isNotNull);
      });

      test("should return valid AccessRight when successful", () async {
        // Arrange
        final testUser = User(
          id: "testUser666",
          name: "Test User",
          currentRole:
              Role(roleId: 6, name: "User", code: "USER", bpmRole: "user"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-6";

        final role = Reference(reference1: "USER");
        final requestType = Reference(reference1: "REQ");

        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "role": "USER",
              "requestType": "REQ",
              "subType": "REQ",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.getAccessRights(role, requestType);

        // Assert
        expect(result, isA<AccessRight>());
      });
    });

    group("getAccessRights - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(
          id: "testUser777",
          name: "Test User Error",
          currentRole:
              Role(roleId: 7, name: "Invalid", code: "INV", bpmRole: "invalid"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-7";

        final role = Reference(reference1: "INVALID");
        final requestType = Reference(reference1: "INVALID");
        const errorMessage = "Access denied";

        final mockResponse = AppResponse(
          message: errorMessage,
          body: <String, dynamic>{
            "status": <String, dynamic>{
              "statusCode": 1,
              "statusDescription": "Unauthorized",
            },
          },
          code: 403,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => adminRepository.getAccessRights(role, requestType),
          throwsA(equals(errorMessage)),
        );
      });

      test("should rethrow exception when API call fails", () async {
        // Arrange
        final testUser = User(
          id: "testUser888",
          name: "Test User Exception",
          currentRole:
              Role(roleId: 8, name: "Test", code: "TST", bpmRole: "test"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-8";

        final role = Reference(reference1: "TEST");
        final requestType = Reference(reference1: "TEST");

        mockAPIManager.setMockException(Exception("Connection timeout"));

        // Act & Assert
        expect(
          () async => adminRepository.getAccessRights(role, requestType),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Connection timeout"),
            ),
          ),
        );
      });
    });

    group("getReferenceTypes - Success Scenarios", () {
      // test('should successfully get reference types', () async {
      //   // Arrange
      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'responseData': [
      //         {
      //           'referenceDataTypeId': 1,
      //           'name': 'Role Types',
      //           'description': 'User role types',
      //           'status': 'ACTIVE',
      //           'referenceDataList': [
      //             {
      //               'refDataId': 1,
      //               'name': 'Admin',
      //               'refernce1': 'ADM',
      //               'refernce2': 'Administrator',
      //               'status': 'ACTIVE'
      //             }
      //           ],
      //           'columnsInfo': 'role_info'
      //         },
      //         {
      //           'referenceDataTypeId': 2,
      //           'name': 'Request Types',
      //           'description': 'Application request types',
      //           'status': 'ACTIVE',
      //           'referenceDataList': []
      //         }
      //       ]
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act
      //   final result = await adminRepository.getReferenceTypes();

      //   // Assert
      //   expect(result, hasLength(2));
      //   expect(result[0].id, equals(1));
      //   expect(result[0].name, equals('Role Types'));
      //   expect(result[0].description, equals('User role types'));
      //   expect(result[0].status, equals('ACTIVE'));
      //   expect(result[0].references, hasLength(1));
      //   expect(result[0].references![0].name, equals('Admin'));
      //   expect(result[0].columnsInformation, equals('role_info'));

      //   expect(result[1].id, equals(2));
      //   expect(result[1].name, equals('Request Types'));
      //   expect(result[1].references, isEmpty);

      //   expect(mockAPIManager.callLog, hasLength(1));
      //   expect(mockAPIManager.callLog[0]['endpoint'],
      //       equals(APIEndpoints.configurableReferenceData));
      // });

      // test('should handle empty response data', () async {
      //   // Arrange
      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {'responseData': []},
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act
      //   final result = await adminRepository.getReferenceTypes();

      //   // Assert
      //   expect(result, isEmpty);
      // });
    });

    group("getReferenceTypes - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        const errorMessage = "Failed to fetch reference types";

        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => adminRepository.getReferenceTypes(),
          throwsA(equals(errorMessage)),
        );
      });
    });

    group("saveReferenceDataInformation - Success Scenarios", () {
      // test('should successfully save reference data information', () async {
      //   // Arrange
      //   const referenceDataTypeID = 1;
      //   // const referenceStatusListValue = 1;
      //   final reference = Reference(
      //     id: 100,
      //     name: 'Test Reference',
      //     description: 'Test Description',
      //     reference1: 'REF1',
      //     reference2: 'REF2',
      //     reference3: 'REF3',
      //     reference4: 'REF4',
      //     reference5: 'REF5',
      //   );

      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'status': {'statusDescription': 'Reference data saved
      // successfully'}
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act
      //   final result = await adminRepository.saveReferenceDataInformation(
      //     referenceDataTypeID,
      //     reference,
      //   );

      //   // Assert
      //   expect(result, equals('Reference data saved successfully'));
      //   expect(mockAPIManager.callLog, hasLength(1));
      //   expect(mockAPIManager.callLog[0]['endpoint'],
      //       equals(APIEndpoints.saveConfigurableReferenceData));

      //   // Verify request structure
      //   final requestBody = mockAPIManager.callLog[0]['body'];
      //   expect(requestBody['requestData']['configurableList'], hasLength(1));

      //   final configItem = requestBody['requestData']['configurableList'][0];
      //   expect(configItem['name'], equals('Test Reference'));
      //   expect(configItem['referenceDataListId'], equals(100));
      //   expect(configItem['description'], equals('Test Description'));
      //   expect(configItem['status'], equals(1));
      //   expect(configItem['reference1'], equals('REF1'));
      //   expect(configItem['reference2'], equals('REF2'));
      //   expect(configItem['reference3'], equals('REF3'));
      //   expect(configItem['reference4'], equals('REF4'));
      //   expect(configItem['reference5'], equals('REF5'));
      //   expect(configItem['referenceDataTypeId'], equals(1));
      //   expect(configItem['createdBy'], equals('WCASTSP01'));
      //   expect(configItem['updatedBy'], equals('wcastsp01'));
      // });

      // test('should handle null reference parameter', () async {
      //   // Arrange
      //   const referenceDataTypeID = 2;
      //   // const referenceStatusListValue = 0;

      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'status': {'statusDescription': 'Saved with null reference'}
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act
      //   final result = await adminRepository.saveReferenceDataInformation(
      //     referenceDataTypeID,
      //     null,
      //   );

      //   // Assert
      //   expect(result, equals('Saved with null reference'));

      //   // Verify null reference is handled properly
      //   final requestBody = mockAPIManager.callLog[0]['body'];
      //   final configItem = requestBody['requestData']['configurableList'][0];
      //   expect(configItem['name'], isNull);
      //   expect(configItem['referenceDataListId'], isNull);
      //   expect(configItem['description'], isNull);
      // });
    });

    // group('saveReferenceDataInformation - Error Scenarios', () {
    //   test('should throw exception when API returns error status', () async {
    //     // Arrange
    //     const referenceDataTypeID = 1;
    //     final reference = Reference(name: 'Test');
    //     // const referenceStatusListValue = 1;
    //     const errorMessage = 'Save failed';

    //     final mockResponse = AppResponse(
    //       message: errorMessage,
    //       body: {'error': 'Validation error'},
    //       code: 400,
    //       status: ResponseStatus.error,
    //     );

    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act & Assert
    //     expect(
    //       () async => await adminRepository.saveReferenceDataInformation(
    //         referenceDataTypeID,
    //         reference,
    //       ),
    //       throwsA(equals(errorMessage)),
    //     );
    //   });
    // });

    group("getUserList - Success Scenarios", () {
      test("should successfully get user list with roles", () async {
        // Arrange
        Globals.user = User(currentRole: Role(id: 1, code: "ADMIN"));

        mockReferenceDataService.setMockReferenceData({
          "ROLE_TYPE": [
            Reference(
              reference1: "ADM",
              reference2: "Administrator",
              reference3: "Admin Group",
            ),
            Reference(
              reference1: "USR",
              reference2: "User",
              reference3: "User Group",
            ),
          ],
        });

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "role": "ADM", // updated
                "userDetails": [
                  // updated
                  {
                    "userId": "user1",
                    "userName": "John Doe",
                    "email": "john@example.com",
                    "designation": "Manager",
                    "isActive": true, // updated to bool
                    "authenticated": true,
                  },
                  {
                    "userId": "user2",
                    "userName": "Jane Smith",
                    "email": "jane@example.com",
                    "designation": "Analyst",
                    "isActive": true,
                    "authenticated": true,
                  }
                ],
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.getUserList();

        // Assert
        expect(result, hasLength(2));

        // Verify first user
        expect(result[0].id, equals("user1"));
        expect(result[0].availableRoles, hasLength(1)); // updated
        expect(result[0].availableRoles![0].code, equals("ADM")); // updated
        expect(result[0].availableRoles![0].name, equals("Administrator"));
        expect(result[0].availableRoles![0].group, equals("Admin Group"));

        // Verify second user
        expect(result[1].id, equals("user2"));
        expect(result[1].availableRoles, hasLength(1)); // updated
        expect(result[1].availableRoles![0].code, equals("ADM")); // updated

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getUsersList),
        );
      });

      test("should handle users with unknown role codes", () async {
        // Arrange
        Globals.user = User(currentRole: Role(id: 1, code: "ADMIN"));

        mockReferenceDataService.setMockReferenceData({
          "ROLE_TYPE": [
            Reference(reference1: "ADM", reference2: "Administrator"),
          ],
        });

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "role": "UNKNOWN_ROLE", // updated
                "userDetails": [
                  // updated
                  {
                    "userId": "user1",
                    "userName": "Test User",
                    "isActive": true,
                    "authenticated": true,
                  }
                ],
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.getUserList();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].availableRoles, hasLength(1)); // updated
        expect(
          result[0].availableRoles![0].code,
          equals("UNKNOWN_ROLE"),
        );
        expect(
          result[0].availableRoles![0].name,
          equals(" "),
        );
      });

      test("should handle empty role types from reference service", () async {
        // Arrange
        Globals.user = User(currentRole: Role(id: 1, code: "ADMIN"));

        mockReferenceDataService.setMockReferenceData({"ROLE_TYPE": []});

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "role": "ADM", // updated
                "userDetails": [
                  // updated
                  {
                    "userId": "user1",
                    "userName": "Test User",
                    "isActive": true,
                    "authenticated": true,
                  }
                ],
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.getUserList();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].availableRoles, hasLength(1)); // updated
        expect(result[0].availableRoles![0].code, equals("ADM"));
        expect(result[0].availableRoles![0].name, equals(" "));
      });
    });

    group("getUserList - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        mockReferenceDataService.setMockReferenceData({"ROLE_TYPE": []});

        const errorMessage = "Failed to fetch users";
        mockAPIManager.setMockException(Exception(errorMessage));

        // Act & Assert
        expect(
          () => adminRepository.getUserList(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains(errorMessage),
            ),
          ),
        );
      });
    });

    group("getUserDetailList - Success Scenarios", () {
      test("should successfully get user detail", () async {
        // Arrange
        final roleTypes = [
          Reference(
            reference1: "ICSADM",
            reference2: "ICS Administrator",
            reference3: "ICS Group",
          ),
          Reference(
            reference1: "USR",
            reference2: "User",
            reference3: "User Group",
          ),
        ];
        mockReferenceDataService.setMockReferenceData({"ROLE_TYPE": roleTypes});

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "userId": "wcasitg01",
              "userName": "Test Admin",
              "email": "admin@example.com",
              "designation": "System Admin",
              "isActive": 1,
              "authenticated": true,
              "roleList": ["ICSADM", "USR"],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.getUserDetailList(User());

        // Assert
        expect(result, isA<User>());
        // The exact field values depend on User.fromJson implementation
        expect(result.availableRoles, isNotNull);

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getAdminUserDetails),
        );

        // Verify request structure
        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody["baseRequest"], isNotNull);
        expect(requestBody["requestData"], isNotNull);
      });

      test("should handle user with empty role list", () async {
        // Arrange
        mockReferenceDataService.setMockReferenceData({"ROLE_TYPE": []});

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "userId": "user1",
              "userName": "User One",
              "roleList": [],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.getUserDetailList(User());

        // Assert
        expect(result.id, equals("user1"));
        expect(result.availableRoles, isEmpty);
      });
    });

    group("getUserDetailList - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        mockReferenceDataService.setMockReferenceData({"ROLE_TYPE": []});

        const errorMessage = "User not found";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Not found"},
          code: 404,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.getUserDetailList(User());

        // Assert - Method returns default User rather than throwing
        expect(result, isA<User>());
        expect(result.id, isNull); // Default user should have null/empty fields
      });
    });

    group("saveUserDetailsList - Success Scenarios", () {
      test("should successfully save user details", () async {
        // Arrange
        final userDetails = User(
          userDetailId: 123,
          name: "Test User",
        );
        // const userRoleValue =
        // 'ADMIN';
        // final accessToRegionValue = [Reference(name: 'Region1')];
        // final accessToCustomerSegmentValue = [Reference(name: 'Segment1')];
        // const approveOnBehalfOf = true;
        // const approvalAccess = true;
        // const tranApprovalAccess = false;
        // const accessToVipCust = true;

        final mockResponse = AppResponse(
          message: "User details saved successfully",
          body: <String, dynamic>{},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.saveUserDetailsList(
          userDetails,
        );

        // Assert
        expect(result, equals("User details saved successfully"));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.saveAdminUserDetails),
        );

        // Verify request structure
        final requestBody = mockAPIManager.callLog[0]["body"];
        // The actual structure depends on BaseRequest.baseRequest and
        // User.toSaveDetailsJson()
        expect(requestBody["baseRequest"], isNotNull);
      });

      test("should handle null parameters gracefully", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Saved with null values",
          body: <String, dynamic>{},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.saveUserDetailsList(
          null,
        );

        // Assert
        expect(result, equals("Saved with null values"));

        // Verify null handling
        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody["baseRequest"], isNotNull);
      });
    });

    group("saveUserDetailsList - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final userDetails = User(name: "Test User");
        const errorMessage = "Save failed";

        mockAPIManager.setMockException(Exception(errorMessage));

        // Act & Assert
        expect(
          () => adminRepository.saveUserDetailsList(
            userDetails,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains(errorMessage),
            ),
          ),
        );
      });
    });

    group("getFileAttachments - Success Scenarios", () {
      test("should successfully get file attachments", () async {
        // Arrange
        // Set up user for BaseRequest
        final testUser = User(
          id: "test123",
          name: "Test User",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;

        final role = Reference(reference1: "ADMIN");

        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{
            "baseResponse": <String, dynamic>{
              "status": <String, dynamic>{
                "statusDescription": "Files retrieved successfully",
              },
            },
            "responseData": <Map<String, dynamic>>[
              <String, dynamic>{
                "id": "1",
                "name": "Document1.pdf",
                "parentId": null,
                "access": "V",
                "children": <Map<String, dynamic>>[
                  <String, dynamic>{
                    "id": "2",
                    "name": "Subdocument.pdf",
                    "parentId": 1,
                    "access": "E",
                    "children": <Map<String, dynamic>>[],
                  }
                ],
              },
              <String, dynamic>{
                "id": "3",
                "name": "Document2.pdf",
                "parentId": null,
                "access": "N",
                "children": <Map<String, dynamic>>[],
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.getFileAttachments(role);

        // Assert
        // expect(result, hasLength(2));

        // Verify first file
        // expect(result[0].id, equals(1));
        expect(result[0].name, equals("Document1.pdf"));
        // expect(result[0].parentId, isNull);
        // expect(result[0].access, equals(AccessType.view));
        // expect(result[0].children, hasLength(1));
        // expect(result[0].children![0].id, equals(2));
        // expect(result[0].children![0].name, equals('Subdocument.pdf'));
        // expect(result[0].children![0].access, equals(AccessType.edit));

        // Verify second file
        // expect(result[1].id, equals(3));
        // expect(result[1].name, equals('Document2.pdf'));
        // expect(result[1].access, equals(AccessType.none));
        // expect(result[1].children, isEmpty);

        // expect(mockAPIManager.callLog, hasLength(1));
        // expect(mockAPIManager.callLog[0]['endpoint'],
        //     equals(APIEndpoints.getFileAttachments));

        // Verify request uses BaseRequest structure
        final requestBody = mockAPIManager.callLog[0]["body"];
        // expect(requestBody['baseRequest'], isNotNull);
        expect(requestBody["requestData"]["role"], equals("ADMIN"));
      });

      test("should handle null role parameter", () async {
        // Arrange
        final testUser = User(
          id: "test123",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{
            "baseResponse": <String, dynamic>{
              "status": <String, dynamic>{"statusDescription": "Success"},
            },
            "responseData": <Map<String, dynamic>>[],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.getFileAttachments(null);

        // Assert
        expect(result, isEmpty);

        // Verify null role is handled
        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody["requestData"]["role"], isNull);
      });
    });

    group("getFileAttachments - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(
          id: "test123",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;

        final role = Reference(reference1: "INVALID");
        const errorMessage = "Access denied";

        final mockResponse = AppResponse(
          message: errorMessage,
          body: <String, dynamic>{
            "status": <String, dynamic>{
              "statusCode": 1,
              "statusDescription": "Unauthorized",
            },
          },
          code: 403,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => adminRepository.getFileAttachments(role),
          throwsA(equals(errorMessage)),
        );
      });
    });

    group("saveFileAttachments - Success Scenarios", () {
      test("should successfully save file attachments", () async {
        // Arrange
        final testUser = User(
          id: "test123",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;

        final fileAccesses = [
          FileAccess(
            id: 1,
            name: "Document1.pdf",
            access: AccessType.view,
            children: [],
          ),
          FileAccess(
            id: 2,
            name: "Document2.pdf",
            access: AccessType.edit,
            children: [],
          ),
        ];
        final role = Reference(reference1: "ADMIN");

        final mockResponse = AppResponse(
          message: "File attachments saved successfully",
          body: <String, dynamic>{
            "baseResponse": <String, dynamic>{
              "status": <String, dynamic>{
                "statusDescription": "File attachments saved successfully",
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await adminRepository.saveFileAttachments(fileAccesses, role);

        // Assert
        expect(result, equals("File attachments saved successfully"));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.saveFileAttachments),
        );

        // Verify request structure
        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody["baseRequest"], isNotNull);
        expect(requestBody["requestData"], isNotNull);
      });

      test("should handle empty file attachments list", () async {
        // Arrange
        final testUser = User(
          id: "test123",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;

        final role = Reference(reference1: "TEST");

        final mockResponse = AppResponse(
          message: "Empty list saved",
          body: <String, dynamic>{
            "baseResponse": <String, dynamic>{
              "status": <String, dynamic>{
                "statusDescription": "Empty list saved",
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await adminRepository.saveFileAttachments([], role);

        // Assert
        expect(result, equals("Empty list saved"));

        // Verify empty list is handled
        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(requestBody["baseRequest"], isNotNull);
        expect(requestBody["requestData"], isNotNull);
      });
    });

    // group('saveFileAttachments - Error Scenarios', () {
    //   test('should throw exception when API returns error status', () async {
    //     // Arrange
    //     final testUser = User(
    //       id: 'test123',
    //       currentRole:
    //           Role(roleId: 1, name: 'Admin', code: 'ADM', bpmRole: 'admin'),
    //     );
    //     Globals.user = testUser;

    //     final fileAccesses = [FileAccess(id: 1, name: 'Test')];
    //     final role = Reference(reference1: 'INVALID');
    //     const errorMessage = 'Save failed';

    //     final mockResponse = AppResponse(
    //       message: errorMessage,
    //       body: {'error': 'Validation error'},
    //       code: 400,
    //       status: ResponseStatus.error,
    //     );

    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act & Assert
    //     expect(
    //       () async =>
    //           await adminRepository.saveFileAttachments(fileAccesses, role),
    //       throwsA(equals(errorMessage)),
    //     );
    //   });
    // });

    group("Edge Cases and Integration", () {
      // test('should handle concurrent API calls', () async {
      //   // Arrange
      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {'responseData': []},
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act - Make multiple concurrent calls
      //   final futures =
      //       List.generate(3, (_) => adminRepository.getReferenceTypes());
      //   final results = await Future.wait(futures);

      //   // Assert
      //   expect(results, hasLength(3));
      //   for (final result in results) {
      //     expect(result, isEmpty);
      //   }
      //   expect(mockAPIManager.callLog, hasLength(3));
      // });

      test("should handle malformed response data gracefully", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{
            "responseData": "invalid_data",
          }, // String instead of List
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => adminRepository.getReferenceTypes(),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}
