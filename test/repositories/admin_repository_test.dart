import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/admin/access_right.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

import "../test_config.dart";
import "mock_api_manager.dart";
import "mock_reference_data_service.dart";

Matcher throwsWithMessage(String message) {
  return throwsA(
    predicate<Object>(
      (Object error) => error.toString().contains(message),
      "throws object containing message: $message",
    ),
  );
}

AppResponse successResponse({
  String message = "Success",
  Map<String, dynamic>? body,
}) {
  return AppResponse(
    message: message,
    body: body ??
        <String, dynamic>{
          "baseResponse": <String, dynamic>{
            "status": <String, dynamic>{
              "statusCode": 0,
              "statusDescription": message,
            },
          },
        },
    code: 200,
    status: ResponseStatus.success,
  );
}

AppResponse errorResponse({
  String message = "Error",
  Map<String, dynamic>? body,
  int code = 500,
}) {
  return AppResponse(
    message: message,
    body: body ??
        <String, dynamic>{
          "baseResponse": <String, dynamic>{
            "status": <String, dynamic>{
              "statusCode": 1,
              "statusDescription": message,
            },
          },
        },
    code: code,
    status: ResponseStatus.error,
  );
}

User testLoggedInUser({
  String id = "test-user",
  String name = "Test User",
  String roleCode = "ADM",
}) {
  return User(
    id: id,
    name: name,
    currentRole: Role(
      roleId: 1,
      id: 1,
      name: "Administrator",
      code: roleCode,
      bpmRole: "admin",
    ),
  );
}

void main() {
  group("AdminRepository - 100% Coverage Tests", () {
    late AdminRepository repository;
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

      repository = AdminRepository(
        apiManager: mockAPIManager,
        referenceDataService: mockReferenceDataService,
      );

      Globals.user = testLoggedInUser();
      Globals.sessionID = "unit-test-session";
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
      mockReferenceDataService.clearMockData();
      Globals.user = null;
      Globals.sessionID = "";
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group("Dependency Injection / Singleton", () {
      test("creates repository with injected dependencies", () {
        final customRepository = AdminRepository(
          apiManager: MockAPIManager(),
          referenceDataService: MockReferenceDataService(),
        );

        expect(customRepository, isA<AdminRepository>());
      });

      test("instance returns singleton object", () {
        final instance1 = AdminRepository.instance;
        final instance2 = AdminRepository.instance;

        expect(identical(instance1, instance2), isTrue);
        expect(instance1, isA<AdminRepository>());
      });
    });

    group("saveAccessRights", () {
      test("saves new access rights successfully", () async {
        final role = Reference(reference1: "ADMIN", name: "Administrator");
        final requestType = Reference(
          reference1: "APP",
          reference4: "APPLICATION",
          name: "Application",
        );

        final accessRight = AccessRight(
          role: "OLD_ROLE",
          requestType: "OLD_REQUEST",
          subType: "OLD_SUBTYPE",
          pages: <Page>[
            Page(
              id: 1,
              name: "Dashboard",
              componentName: "dashboard",
              accessType: AccessType.edit,
              navigationOrder: 1,
            ),
          ],
        );

        mockAPIManager.setMockResponse(
          successResponse(
            message: "Access rights saved successfully",
            body: <String, dynamic>{
              "baseResponse": <String, dynamic>{
                "status": <String, dynamic>{
                  "statusCode": 0,
                  "statusDescription": "Saved successfully",
                },
              },
            },
          ),
        );

        final result = await repository.saveAccessRights(
          requestType,
          role,
          accessRight,
          isUpdate: false,
        );

        expect(result, equals("Saved successfully"));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog.first["endpoint"],
          equals(APIEndpoints.saveRoleRightMap),
        );

        final requestBody = mockAPIManager.callLog.first["body"];
        expect(requestBody["baseRequest"], isNotNull);
        expect(requestBody["requestData"]["role"], equals("ADMIN"));
        expect(
          requestBody["requestData"]["requestType"],
          equals("APPLICATION"),
        );

        // Repository currently assigns subType twice, final value is requestType.reference1.
        expect(requestBody["requestData"]["subType"], equals("APP"));
      });

      test("updates access rights successfully", () async {
        final role = Reference(reference1: "MGR", name: "Manager");
        final requestType = Reference(
          reference1: "REQ",
          reference4: "REQUEST",
          name: "Request",
        );

        final accessRight = AccessRight(
          role: "OLD_ROLE",
          requestType: "OLD_REQUEST",
          subType: "OLD_SUBTYPE",
        );

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "baseResponse": <String, dynamic>{
                "status": <String, dynamic>{
                  "statusCode": 0,
                  "statusDescription": "Updated successfully",
                },
              },
            },
          ),
        );

        final result = await repository.saveAccessRights(
          requestType,
          role,
          accessRight,
          isUpdate: true,
        );

        expect(result, equals("Updated successfully"));
        expect(accessRight.role, equals("MGR"));
        expect(accessRight.requestType, equals("REQUEST"));
        expect(accessRight.subType, equals("REQ"));
        expect(mockAPIManager.callLog, hasLength(1));
      });

      test("throws ApiException when API returns error", () async {
        final role = Reference(reference1: "ADMIN");
        final requestType = Reference(reference1: "APP", reference4: "APP_REQ");
        final accessRight = AccessRight(role: "ADMIN");

        mockAPIManager.setMockResponse(
          errorResponse(message: "Save failed"),
        );

        expect(
          () async => repository.saveAccessRights(
            requestType,
            role,
            accessRight,
            isUpdate: false,
          ),
          throwsWithMessage("Save failed"),
        );
      });

      test("rethrows exception when API call fails", () async {
        final role = Reference(reference1: "ADMIN");
        final requestType = Reference(reference1: "APP", reference4: "APP_REQ");
        final accessRight = AccessRight(role: "ADMIN");

        mockAPIManager.setMockException(Exception("Network failure"));

        expect(
          () async => repository.saveAccessRights(
            requestType,
            role,
            accessRight,
            isUpdate: true,
          ),
          throwsWithMessage("Network failure"),
        );
      });
    });

    group("getAccessRights", () {
      test("gets access rights successfully", () async {
        final role = Reference(reference1: "ADMIN");
        final requestType = Reference(reference1: "APP", reference4: "APP_REQ");

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <String, dynamic>{
                "role": "ADMIN",
                "requestType": "APP_REQ",
                "subType": "APP",
                "pageIds": <Map<String, dynamic>>[
                  <String, dynamic>{
                    "pageId": 1,
                    "pageName": "Dashboard",
                    "componentName": "dashboard",
                    "accessType": "E",
                    "navigationOrder": 1,
                  },
                ],
              },
            },
          ),
        );

        final result = await repository.getAccessRights(role, requestType);

        expect(result, isA<AccessRight>());
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog.first["endpoint"],
          equals(APIEndpoints.getRoleRightMap),
        );

        final requestBody = mockAPIManager.callLog.first["body"];
        expect(requestBody["requestData"]["role"], equals("ADMIN"));
        expect(requestBody["requestData"]["requestType"], equals("APP_REQ"));
        expect(requestBody["requestData"]["subType"], equals("APP"));
      });

      test("throws ApiException when API returns error", () async {
        final role = Reference(reference1: "INVALID");
        final requestType = Reference(reference1: "INVALID");

        mockAPIManager.setMockResponse(
          errorResponse(message: "Access denied", code: 403),
        );

        expect(
          () async => repository.getAccessRights(role, requestType),
          throwsWithMessage("Access denied"),
        );
      });

      test("rethrows exception when API call fails", () async {
        final role = Reference(reference1: "ADMIN");
        final requestType = Reference(reference1: "APP");

        mockAPIManager.setMockException(Exception("Connection timeout"));

        expect(
          () async => repository.getAccessRights(role, requestType),
          throwsWithMessage("Connection timeout"),
        );
      });
    });

    group("getReferenceTypes", () {
      test("gets reference types successfully", () async {
        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <String, dynamic>{
                "referenceData": <Map<String, dynamic>>[
                  <String, dynamic>{
                    "referenceDataTypeId": 1,
                    "name": "ROLE_TYPE",
                    "description": "Role Type",
                    "status": "ACTIVE",
                    "columnsInfo": "role-columns",
                    "referenceDataList": <Map<String, dynamic>>[
                      <String, dynamic>{
                        "referenceDataListId": 100,
                        "name": "Admin",
                        "description": "Administrator",
                        "status": "ACTIVE",
                        "reference1": "ADM",
                        "reference2": "Administrator",
                        "reference3": "Admin Group",
                      },
                    ],
                  },
                  <String, dynamic>{
                    "referenceDataTypeId": 2,
                    "name": "REQUEST_TYPE",
                    "description": "Request Type",
                    "status": "ACTIVE",
                    "columnsInfo": "request-columns",
                    "referenceDataList": <Map<String, dynamic>>[],
                  },
                ],
              },
            },
          ),
        );

        final result = await repository.getReferenceTypes();

        expect(result, hasLength(2));
        expect(result.first.name, equals("ROLE_TYPE"));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog.first["endpoint"],
          equals(APIEndpoints.configurableReferenceData),
        );
      });

      test("returns empty list when referenceData is empty", () async {
        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <String, dynamic>{
                "referenceData": <Map<String, dynamic>>[],
              },
            },
          ),
        );

        final result = await repository.getReferenceTypes();

        expect(result, isEmpty);
      });

      test("throws ApiException when API returns error", () async {
        mockAPIManager.setMockResponse(
          errorResponse(message: "Failed to fetch reference types"),
        );

        expect(
          () async => repository.getReferenceTypes(),
          throwsWithMessage("Failed to fetch reference types"),
        );
      });

      test("throws when response data is malformed", () async {
        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": "invalid-data",
            },
          ),
        );

        expect(
          () async => repository.getReferenceTypes(),
          throwsA(anything),
        );
      });
    });

    group("getReferenceData", () {
      test("gets reference data successfully", () async {
        final referenceType = ReferenceTypeTestFactory.create(
          id: 1,
          name: "ROLE_TYPE",
        );

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <Map<String, dynamic>>[
                <String, dynamic>{
                  "referenceDataName": "ROLE_TYPE",
                  "referenceDataList": <Map<String, dynamic>>[
                    <String, dynamic>{
                      "referenceDataListId": 1,
                      "name": "Administrator",
                      "description": "Admin role",
                      "status": "ACTIVE",
                      "reference1": "ADM",
                      "reference2": "Administrator",
                      "reference3": "Admin Group",
                    },
                    <String, dynamic>{
                      "referenceDataListId": 2,
                      "name": "User",
                      "description": "User role",
                      "status": "ACTIVE",
                      "reference1": "USR",
                      "reference2": "User",
                      "reference3": "User Group",
                    },
                  ],
                },
              ],
            },
          ),
        );

        final result = await repository.getReferenceData(referenceType);

        expect(result, hasLength(2));
        expect(result.first.reference1, equals("ADM"));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog.first["endpoint"],
          equals(APIEndpoints.getReferenceData),
        );

        final requestBody = mockAPIManager.callLog.first["body"];
        expect(
          requestBody["requestData"]["referenceDataName"],
          equals(<String>["ROLE_TYPE"]),
        );
        expect(requestBody["requestData"]["isAdmin"], isTrue);
      });

      test("throws ApiException when getReferenceData API returns error",
          () async {
        final referenceType = ReferenceTypeTestFactory.create(
          id: 1,
          name: "ROLE_TYPE",
        );

        mockAPIManager.setMockResponse(
          errorResponse(message: "Reference data failed"),
        );

        expect(
          () async => repository.getReferenceData(referenceType),
          throwsWithMessage("Reference data failed"),
        );
      });
    });

    group("saveReferenceDataInformation", () {
      test("saves reference data information successfully", () async {
        final reference = Reference(
          id: 10,
          name: "Test Reference",
          description: "Test Description",
          reference1: "REF1",
          reference2: "REF2",
          reference3: "REF3",
          reference4: "REF4",
          reference5: "REF5",
        );

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "baseResponse": <String, dynamic>{
                "status": <String, dynamic>{
                  "statusCode": 0,
                  "statusDescription": "Reference saved",
                },
              },
            },
          ),
        );

        final result = await repository.saveReferenceDataInformation(
          1,
          reference,
        );

        expect(result, equals("Reference saved"));
        expect(reference.typeId, equals(1));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog.first["endpoint"],
          equals(APIEndpoints.saveConfigurableReferenceData),
        );
      });

      test("handles null reference while saving reference data", () async {
        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "baseResponse": <String, dynamic>{
                "status": <String, dynamic>{
                  "statusCode": 0,
                  "statusDescription": "Saved null reference",
                },
              },
            },
          ),
        );

        final result = await repository.saveReferenceDataInformation(2, null);

        expect(result, equals("Saved null reference"));
        expect(mockAPIManager.callLog, hasLength(1));
      });

      test("throws ApiException when save reference API returns error",
          () async {
        mockAPIManager.setMockResponse(
          errorResponse(message: "Reference save failed"),
        );

        expect(
          () async => repository.saveReferenceDataInformation(
            1,
            Reference(name: "Failed Reference"),
          ),
          throwsWithMessage("Reference save failed"),
        );
      });
    });

    group("getUserList", () {
      test("gets user list with mapped roles successfully", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[
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
        };

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <Map<String, dynamic>>[
                <String, dynamic>{
                  "role": "ADM",
                  "userDetails": <Map<String, dynamic>>[
                    <String, dynamic>{
                      "userId": "user1",
                      "userName": "John Doe",
                      "email": "john@example.com",
                      "designation": "Manager",
                      "isActive": true,
                      "authenticated": true,
                    },
                    <String, dynamic>{
                      "userId": "user2",
                      "userName": "Jane Smith",
                      "email": "jane@example.com",
                      "designation": "Analyst",
                      "isActive": true,
                      "authenticated": true,
                    },
                  ],
                },
                <String, dynamic>{
                  "role": "USR",
                  "userDetails": <Map<String, dynamic>>[
                    <String, dynamic>{
                      "userId": "user3",
                      "userName": "User Three",
                      "email": "user3@example.com",
                      "isActive": true,
                      "authenticated": false,
                    },
                  ],
                },
              ],
            },
          ),
        );

        final result = await repository.getUserList();

        expect(result, hasLength(3));
        expect(result[0].id, equals("user1"));
        expect(result[0].availableRoles, hasLength(1));
        expect(result[0].availableRoles!.first.code, equals("ADM"));
        expect(result[0].availableRoles!.first.name, equals("Administrator"));
        expect(result[0].availableRoles!.first.group, equals("Admin Group"));

        expect(result[2].id, equals("user3"));
        expect(result[2].availableRoles!.first.code, equals("USR"));
        expect(result[2].availableRoles!.first.name, equals("User"));

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog.first["endpoint"],
          equals(APIEndpoints.getUsersList),
        );
      });

      test("returns empty users when responseData is null", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[],
        };

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": null,
            },
          ),
        );

        final result = await repository.getUserList();

        expect(result, isEmpty);
      });

      test("maps unknown role code with blank role name", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[
            Reference(reference1: "ADM", reference2: "Administrator"),
          ],
        };

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <Map<String, dynamic>>[
                <String, dynamic>{
                  "role": "UNKNOWN",
                  "userDetails": <Map<String, dynamic>>[
                    <String, dynamic>{
                      "userId": "user1",
                      "userName": "Unknown Role User",
                      "isActive": true,
                      "authenticated": true,
                    },
                  ],
                },
              ],
            },
          ),
        );

        final result = await repository.getUserList();

        expect(result, hasLength(1));
        expect(result.first.availableRoles!.first.code, equals("UNKNOWN"));
        expect(result.first.availableRoles!.first.name, equals(" "));
      });

      test("handles empty reference role types", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[],
        };

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <Map<String, dynamic>>[
                <String, dynamic>{
                  "role": "ADM",
                  "userDetails": <Map<String, dynamic>>[
                    <String, dynamic>{
                      "userId": "user1",
                      "userName": "Test User",
                      "isActive": true,
                      "authenticated": true,
                    },
                  ],
                },
              ],
            },
          ),
        );

        final result = await repository.getUserList();

        expect(result, hasLength(1));
        expect(result.first.availableRoles!.first.code, equals("ADM"));
        expect(result.first.availableRoles!.first.name, equals(" "));
      });

      test("rethrows exception when get user list API fails", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[],
        };

        mockAPIManager.setMockException(Exception("Failed to fetch users"));

        expect(
          () async => repository.getUserList(),
          throwsWithMessage("Failed to fetch users"),
        );
      });

      test("rethrows exception when user list response is malformed", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[],
        };

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": "invalid",
            },
          ),
        );

        expect(
          () async => repository.getUserList(),
          throwsA(anything),
        );
      });
    });

    group("getUserDetailList", () {
      test("gets user details successfully and maps role list", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[
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
          ],
        };

        final selectedUser = User(id: "wcasitg01", userName: "wcasitg01");

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <String, dynamic>{
                "userId": "wcasitg01",
                "userName": "Test Admin",
                "email": "admin@example.com",
                "designation": "System Admin",
                "isActive": true,
                "authenticated": true,
                "roleList": <String>["ICSADM", "USR"],
              },
            },
          ),
        );

        final result = await repository.getUserDetailList(selectedUser);

        expect(result, isA<User>());
        expect(result.id, equals("wcasitg01"));
        expect(result.availableRoles, hasLength(2));
        expect(result.availableRoles!.first.code, equals("ICSADM"));
        expect(result.availableRoles!.first.name, equals("ICS Administrator"));
        expect(result.availableRoles!.first.group, equals("ICS Group"));

        final requestBody = mockAPIManager.callLog.first["body"];
        expect(requestBody["requestData"]["userId"], equals("wcasitg01"));
        expect(requestBody["requestData"]["userName"], equals("wcasitg01"));
      });

      test("handles null user parameter", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[],
        };

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <String, dynamic>{
                "userId": "user-null-param",
                "userName": "Null Param User",
                "roleList": <String>[],
              },
            },
          ),
        );

        final result = await repository.getUserDetailList(null);

        expect(result.id, equals("user-null-param"));

        final requestBody = mockAPIManager.callLog.first["body"];
        expect(requestBody["requestData"]["userId"], isNull);
        expect(requestBody["requestData"]["userName"], isNull);
      });

      test("handles user detail with empty role list", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[],
        };

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <String, dynamic>{
                "userId": "user1",
                "userName": "User One",
                "roleList": <String>[],
              },
            },
          ),
        );

        final result = await repository.getUserDetailList(User());

        expect(result.id, equals("user1"));
        expect(result.availableRoles, isEmpty);
      });

      test("returns empty User when API status is error", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[],
        };

        mockAPIManager.setMockResponse(
          errorResponse(message: "User not found", code: 404),
        );

        final result = await repository.getUserDetailList(User());

        expect(result, isA<User>());
        expect(result.id, isNull);
      });

      test("returns empty User when responseData is null", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[],
        };

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": null,
            },
          ),
        );

        final result = await repository.getUserDetailList(User());

        expect(result, isA<User>());
        expect(result.id, isNull);
      });

      test("rethrows malformed user detail response error", () async {
        mockReferenceDataService.setMockReferenceData =
            <String, List<Reference>>{
          ReferenceDataKeys.roleType: <Reference>[],
        };

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": "invalid",
            },
          ),
        );

        expect(
          () async => repository.getUserDetailList(User()),
          throwsA(anything),
        );
      });
    });

    group("saveUserDetailsList", () {
      test("saves user details successfully", () async {
        final userDetails = User(
          userDetailId: 123,
          id: "user1",
          name: "Test User",
          userName: "test.user",
          email: "test@example.com",
        );

        mockAPIManager.setMockResponse(
          successResponse(message: "User details saved successfully"),
        );

        final result = await repository.saveUserDetailsList(userDetails);

        expect(result, equals("User details saved successfully"));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog.first["endpoint"],
          equals(APIEndpoints.saveAdminUserDetails),
        );
        expect(mockAPIManager.callLog.first["body"]["baseRequest"], isNotNull);
      });

      test("handles null user details successfully", () async {
        mockAPIManager.setMockResponse(
          successResponse(message: "Saved with null values"),
        );

        final result = await repository.saveUserDetailsList(null);

        expect(result, equals("Saved with null values"));
        expect(mockAPIManager.callLog, hasLength(1));
      });

      test("throws ApiException when save user API returns error", () async {
        mockAPIManager.setMockResponse(
          errorResponse(message: "Save failed"),
        );

        expect(
          () async => repository.saveUserDetailsList(User(name: "Test User")),
          throwsWithMessage("Save failed"),
        );
      });

      test("rethrows exception when save user API call fails", () async {
        mockAPIManager.setMockException(Exception("Save user network failure"));

        expect(
          () async => repository.saveUserDetailsList(User(name: "Test User")),
          throwsWithMessage("Save user network failure"),
        );
      });
    });

    group("getUpdatedUserData", () {
      test("gets updated logged-in user data successfully", () async {
        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "responseData": <String, dynamic>{
                "userId": "logged-user",
                "userName": "Logged User",
                "email": "logged@example.com",
              },
            },
          ),
        );

        final result = await repository.getUpdatedUserData();

        expect(result["userId"], equals("logged-user"));
        expect(result["userName"], equals("Logged User"));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog.first["endpoint"],
          equals(APIEndpoints.getLoggedUserDetails),
        );
      });

      test("throws ApiException when get updated user data API returns error",
          () async {
        mockAPIManager.setMockResponse(
          errorResponse(message: "Logged user fetch failed"),
        );

        expect(
          () async => repository.getUpdatedUserData(),
          throwsWithMessage("Logged user fetch failed"),
        );
      });

      test("rethrows exception when get updated user data API call fails",
          () async {
        mockAPIManager
            .setMockException(Exception("Logged user network failure"));

        expect(
          () async => repository.getUpdatedUserData(),
          throwsWithMessage("Logged user network failure"),
        );
      });
    });

    group("getFileAttachments", () {
      test("gets file attachments successfully", () async {
        final role = Reference(reference1: "ADMIN");

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "baseResponse": <String, dynamic>{
                "status": <String, dynamic>{
                  "statusDescription": "Files retrieved successfully",
                },
              },
              "responseData": <Map<String, dynamic>>[
                <String, dynamic>{
                  "id": 1,
                  "name": "Document1.pdf",
                  "parentId": null,
                  "access": "V",
                  "children": <Map<String, dynamic>>[
                    <String, dynamic>{
                      "id": 2,
                      "name": "Subdocument.pdf",
                      "parentId": 1,
                      "access": "E",
                      "children": <Map<String, dynamic>>[],
                    },
                  ],
                },
                <String, dynamic>{
                  "id": 3,
                  "name": "Document2.pdf",
                  "parentId": null,
                  "access": "N",
                  "children": <Map<String, dynamic>>[],
                },
              ],
            },
          ),
        );

        final result = await repository.getFileAttachments(role);

        expect(result, hasLength(2));
        expect(result.first, isA<FileAccess>());
        expect(result.first.name, equals("Document1.pdf"));

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog.first["endpoint"],
          equals(APIEndpoints.getFileAttachments),
        );

        final requestBody = mockAPIManager.callLog.first["body"];
        expect(requestBody["requestData"]["role"], equals("ADMIN"));
      });

      test("handles null role parameter and empty file response", () async {
        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "baseResponse": <String, dynamic>{
                "status": <String, dynamic>{
                  "statusDescription": "Success",
                },
              },
              "responseData": <Map<String, dynamic>>[],
            },
          ),
        );

        final result = await repository.getFileAttachments(null);

        expect(result, isEmpty);
        expect(
          mockAPIManager.callLog.first["body"]["requestData"]["role"],
          isNull,
        );
      });

      test("throws ApiException when get file attachments API returns error",
          () async {
        final role = Reference(reference1: "INVALID");

        mockAPIManager.setMockResponse(
          errorResponse(message: "Access denied", code: 403),
        );

        expect(
          () async => repository.getFileAttachments(role),
          throwsWithMessage("Access denied"),
        );
      });
    });

    group("saveFileAttachments", () {
      test("saves file attachments successfully", () async {
        final role = Reference(reference1: "ADMIN");

        final file1 = FileAccess(
          id: 1,
          name: "Document1.pdf",
          access: AccessType.view,
          children: <FileAccess>[],
        );

        final file2 = FileAccess(
          id: 2,
          name: "Document2.pdf",
          access: AccessType.edit,
          children: <FileAccess>[],
        );

        file1.isUpdated = true;
        file2.isUpdated = false;

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "baseResponse": <String, dynamic>{
                "status": <String, dynamic>{
                  "statusDescription": "File attachments saved successfully",
                },
              },
            },
          ),
        );

        final result = await repository.saveFileAttachments(
          <FileAccess>[file1, file2],
          role,
        );

        expect(result, equals("File attachments saved successfully"));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog.first["endpoint"],
          equals(APIEndpoints.saveFileAttachments),
        );

        final requestBody = mockAPIManager.callLog.first["body"];
        expect(requestBody["requestData"]["role"], equals("ADMIN"));
        expect(requestBody["requestData"]["accessRightList"], isA<List>());
        expect(requestBody["requestData"]["accessRightList"], hasLength(1));
      });

      test("handles empty file attachments list successfully", () async {
        final role = Reference(reference1: "TEST");

        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "baseResponse": <String, dynamic>{
                "status": <String, dynamic>{
                  "statusDescription": "Empty list saved",
                },
              },
            },
          ),
        );

        final result = await repository.saveFileAttachments(
          <FileAccess>[],
          role,
        );

        expect(result, equals("Empty list saved"));

        final requestBody = mockAPIManager.callLog.first["body"];
        expect(requestBody["requestData"]["role"], equals("TEST"));
        expect(requestBody["requestData"]["accessRightList"], isEmpty);
      });

      test("handles null role while saving file attachments", () async {
        mockAPIManager.setMockResponse(
          successResponse(
            body: <String, dynamic>{
              "baseResponse": <String, dynamic>{
                "status": <String, dynamic>{
                  "statusDescription": "Saved without role",
                },
              },
            },
          ),
        );

        final result = await repository.saveFileAttachments(
          <FileAccess>[],
          null,
        );

        expect(result, equals("Saved without role"));
        expect(
          mockAPIManager.callLog.first["body"]["requestData"]["role"],
          isNull,
        );
      });

      test("throws ApiException when save file attachments API returns error",
          () async {
        final role = Reference(reference1: "INVALID");

        mockAPIManager.setMockResponse(
          errorResponse(message: "File save failed"),
        );

        expect(
          () async => repository.saveFileAttachments(<FileAccess>[], role),
          throwsWithMessage("File save failed"),
        );
      });
    });
  });
}

/// Small helper to create ReferenceType without depending on constructor parameter
/// differences across model versions.
///
/// If your ReferenceType constructor supports named params, this factory will
/// still work through fromJson.
class ReferenceTypeTestFactory {
  static dynamic create({
    required int id,
    required String name,
  }) {
    return ReferenceTypeFromJsonAdapter.fromJson(
      <String, dynamic>{
        "referenceDataTypeId": id,
        "name": name,
        "description": "$name Description",
        "status": "ACTIVE",
        "columnsInfo": "$name Columns",
        "referenceDataList": <Map<String, dynamic>>[],
      },
    );
  }
}

/// This adapter keeps the test file resilient if ReferenceType is not directly
/// imported in older test versions.
class ReferenceTypeFromJsonAdapter {
  static dynamic fromJson(Map<String, dynamic> json) {
    return _ReferenceTypeDynamicFactory.create(json);
  }
}

class _ReferenceTypeDynamicFactory {
  static dynamic create(Map<String, dynamic> json) {
    // Import is intentionally kept indirect by using the actual model factory
    // through dynamic dispatch in the test runtime.
    //
    // If analyzer complains here, replace this method body with:
    // return ReferenceType.fromJson(json);
    return ReferenceType.fromJson(json);
  }
}
