import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

import "../test_config.dart";
import "mock_api_manager.dart";

// Mock EncryptionHelper to avoid encryption key issues in tests
class MockEncryptionHelper {
  static String encrypt(String plainText) {
    return "encrypted_$plainText";
  }
}

// Mock LocalStorageService
class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, dynamic value) async {
    _storage[box] ??= {};
    _storage[box]![key] = value;
  }

  @override
  Future<dynamic> get(String box, String key) async {
    return _storage[box]?[key];
  }

  @override
  Future<void> delete(String box, String key) async {
    _storage[box]?.remove(key);
  }

  @override
  Future<void> clearBox(String box) async {
    _storage[box]?.clear();
  }

  void clearAll() {
    _storage.clear();
  }
}

// Mock SessionCubit
class MockSessionCubit {
  static final _singleton = MockSessionCubit();
  static MockSessionCubit get instance => _singleton;

  bool _sessionStopped = false;

  void stopSession() {
    _sessionStopped = true;
  }

  bool get sessionStopped => _sessionStopped;

  void reset() {
    _sessionStopped = false;
  }
}

void main() {
  group("AuthRepository Integration Tests", () {
    late AuthRepository authRepository;
    late MockAPIManager mockAPIManager;
    late MockLocalStorageService mockLocalStorageService;
    late MockSessionCubit mockSessionCubit;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      mockAPIManager = MockAPIManager();
      mockLocalStorageService = MockLocalStorageService();
      mockSessionCubit = MockSessionCubit();

      // Set up LocalStorageService mock
      LocalStorageService().setStorage(mockLocalStorageService);

      authRepository = AuthRepository(
        apiManager: mockAPIManager,
        localStorageService: LocalStorageService(),
        encryptFunction: MockEncryptionHelper.encrypt,
        getSuccessMessage: () => "Login successful",
      );

      // Reset globals
      Globals.user = null;
      Globals.sessionID = "";
      mockSessionCubit.reset();
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
      mockLocalStorageService.clearAll();
      Globals.user = null;
      Globals.sessionID = "";
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group("Dependency Injection", () {
      test("should use injected APIManager and LocalStorageService", () {
        // Arrange
        final customMockAPIManager = MockAPIManager();
        final customMockLocalStorage = LocalStorageService();

        // Act
        final repository = AuthRepository(
          apiManager: customMockAPIManager,
          localStorageService: customMockLocalStorage,
          encryptFunction: MockEncryptionHelper.encrypt,
          getSuccessMessage: () => "Login successful",
        );

        // Assert
        expect(repository, isA<AuthRepository>());
      });

      test("should use default dependencies when none provided", () {
        // Act
        // Use singleton instance to avoid circular dependency
        final repository = AuthRepository.instance;

        // Assert
        expect(repository, isA<AuthRepository>());
      });

      test("should maintain singleton behavior with instance getter", () {
        // Act
        final instance1 = AuthRepository.instance;
        final instance2 = AuthRepository.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("login - Success Scenarios", () {
      test("should successfully login with valid credentials", () async {
        // Arrange
        const username = "testuser";
        const password = "testpass123";

        final mockResponseBody = {
          "responseData": {
            "userResponse": {
              "userId": "testuser",
              "userName": "Test User",
              "userDetailId": 1,
              "email": "test@example.com",
              "designation": "Manager",
              "isActive": 1,
              "authenticated": true,
              "roleList": [
                {
                  "roleId": 1,
                  "roleName": "Admin",
                  "roleCode": "ADM",
                  "bpmRole": "admin",
                  "roleGroup": "ADMIN",
                }
              ],
            },
            "tokenResponse": {
              "jwtToken": "mock-jwt-token",
              "refreshToken": "mock-refresh-token",
              "expiresIn": 3600,
            },
          },
        };

        final mockResponse = AppResponse(
          message: "Login successful",
          body: mockResponseBody,
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await authRepository.login(
          username: username,
          password: password,
        );

        // Assert
        expect(result, isNotNull);
        expect(Globals.user, isNotNull);
        expect(Globals.user!.id, equals("testuser"));
        expect(Globals.user!.name, equals("Test User"));
        expect(Globals.user!.availableRoles, hasLength(1));
        expect(Globals.user!.currentRole?.name, equals("Admin"));
        expect(Globals.sessionID, isNotEmpty);

        // Verify API call
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.login),
        );
        expect(mockAPIManager.callLog[0]["method"], equals("POST"));

        // Verify request structure
        final requestBody = mockAPIManager.callLog[0]["body"];
        final requestData = json.decode(
          requestBody is String ? requestBody : json.encode(requestBody),
        );
        expect(requestData["channelID"], equals("WCAS"));
        expect(requestData["requestData"]["userID"], equals(username));
        expect(requestData["requestData"]["authType"], equals("password"));

        // Verify local storage
        final storedToken = await mockLocalStorageService.get(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        );
        expect(storedToken, equals("mock-jwt-token"));

        final storedRefreshToken = await mockLocalStorageService.get(
          LocalStorageBoxes.user,
          LocalStorageKeys.refreshToken,
        );
        expect(storedRefreshToken, equals("mock-refresh-token"));
      });

      test("should handle login with multiple roles", () async {
        // Arrange
        const username = "multiuser";
        const password = "password123";

        final mockResponseBody = {
          "responseData": {
            "userResponse": {
              "userId": "multiuser",
              "userName": "Multi Role User",
              "userDetailId": 2,
              "authenticated": true,
              "roleList": [
                {
                  "roleId": 1,
                  "roleName": "Admin",
                  "roleCode": "ADM",
                  "bpmRole": "admin",
                },
                {
                  "roleId": 2,
                  "roleName": "Manager",
                  "roleCode": "MGR",
                  "bpmRole": "manager",
                }
              ],
            },
            "tokenResponse": {
              "jwtToken": "multi-jwt-token",
              "refreshToken": "multi-refresh-token",
              "expiresIn": 7200,
            },
          },
        };

        final mockResponse = AppResponse(
          message: "Login successful",
          body: mockResponseBody,
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await authRepository.login(
          username: username,
          password: password,
        );

        // Assert
        expect(result, isNotNull);
        expect(Globals.user!.availableRoles, hasLength(2));
        expect(
          Globals.user!.currentRole?.name,
          equals("Admin"),
        ); // First role is set as current
        expect(Globals.user!.availableRoles![1].name, equals("Manager"));
      });

      test("should clear existing user data before login", () async {
        // Arrange
        // Set up existing user data
        await mockLocalStorageService.put(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
          "old-token",
        );

        const username = "newuser";
        const password = "newpass";

        final mockResponseBody = {
          "responseData": {
            "userResponse": {
              "userId": "newuser",
              "userName": "New User",
              "authenticated": true,
              "roleList": [
                {
                  "roleId": 3,
                  "roleName": "User",
                  "roleCode": "USR",
                  "bpmRole": "user",
                }
              ],
            },
            "tokenResponse": {
              "jwtToken": "new-jwt-token",
              "refreshToken": "new-refresh-token",
              "expiresIn": 3600,
            },
          },
        };

        final mockResponse = AppResponse(
          message: "Login successful",
          body: mockResponseBody,
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        await authRepository.login(username: username, password: password);

        // Assert - User box should be cleared first, then new data stored
        final storedToken = await mockLocalStorageService.get(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        );
        expect(storedToken, equals("new-jwt-token"));
        expect(Globals.user!.id, equals("newuser"));
      });

      test("should successfully login with no segment", () async {
        // Arrange
        const username = "testuser";
        const password = "testpass123";

        final mockResponseBody = {
          "responseData": {
            "tokenResponse": {
              "jwtToken":
                  "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ3Y2FzdHNwMDEiLC"
                  "JpYXQiOjE3NjgyMTgzMDMsImV4cCI6MTc2ODIxOTIwM30."
                      "UmNXytZjaMfVia_Y1wuHUJPjG1g4NNYpWvZLGgsIfZE",
              "expiresIn": 900000,
              "refreshToken":
                  "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ3Y2FzdHNwMDEiLCJ"
                  "1dWlkIjoiZWU4MDZjNjAtZTNmZS00ZTcwLThkOTgtODBkNWM"
                  "0YjM5ZTAxIn0."
                      "J-xxXp-Dh9pv4aDI0tAS2EleKJPiRtuQzCv5mWKh4kc",
              "tokenType": "Bearer",
            },
            "userResponse": {
              "userId": "testuser",
              "userName": "Test User",
              "userDetailId": 1,
              "email": "test@example.com",
              "designation": "Manager",
              "regionList": [
                "Deira",
                "Abu Dhabi",
                "Al Twar",
                "Dubai",
                "Jumeirah",
                "Northern Emirates",
                "Zabeel",
                "New Dubai",
              ],
              "segmentList": [],
              "approveOnBehalfOf": 1,
              "approvalAccess": 1,
              "tranApprovalAccess": 1,
              "accessToVipCust": 0,
              "createdBy": "WCASTSP01",
              "createdDate": "2024-12-16T14:57:05.000+00:00",
              "isIslamic": 0,
              "isActive": 0,
              "roleList": [
                {
                  "roleId": 125,
                  "roleName": "Relationship Officer ",
                  "roleCode": "RO",
                  "bpmRole": "RO-WCAS",
                },
                {
                  "roleId": 128,
                  "roleName": "Commercial Area Manager - Business",
                  "roleCode": "CAM",
                  "bpmRole": "Business CAM-WCAS",
                },
                {
                  "roleId": 134,
                  "roleName": "Credit Coordinator",
                  "roleCode": "CCOOD",
                  "bpmRole": "Credit Coordinator-WCAS",
                },
                {
                  "roleId": 141,
                  "roleName": "Board of Directors - Proxy ",
                  "roleCode": "BDP",
                  "bpmRole": "Board of Directors Proxy",
                },
                {
                  "roleId": 2024,
                  "roleName": "Admin",
                  "roleCode": "ADM",
                  "bpmRole": "Admin-WCAS",
                }
              ],
            },
          },
        };

        final mockResponse = AppResponse(
          message: "Login successful",
          body: mockResponseBody,
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await authRepository.login(
          username: username,
          password: password,
        );

        // Assert
        expect(result, isNotNull);
        expect(Globals.sessionID, isNotEmpty);
      });
    });
    group("login - Error Scenarios", () {
      test("should throw exception when login fails with non-200 status",
          () async {
        // Arrange
        const username = "invaliduser";
        const password = "wrongpass";

        final mockResponse = AppResponse(
          message: "Invalid credentials",
          body: {"error": "Authentication failed"},
          code: 401,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => authRepository.login(
            username: username,
            password: password,
          ),
          throwsA(equals("Invalid credentials")),
        );

        // Verify user box was cleared but no user data was set
        expect(Globals.user, isNull);
      });

      test("should handle API network error during login", () async {
        // Arrange
        const username = "testuser";
        const password = "testpass";

        mockAPIManager.setMockException(Exception("Network error"));

        // Act & Assert
        expect(
          () async => authRepository.login(
            username: username,
            password: password,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Network error"),
            ),
          ),
        );
      });

      test("should handle malformed response data", () async {
        // Arrange
        const username = "testuser";
        const password = "testpass";

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "userResponse": {
                "userId": "testuser",
                // Missing required fields like roleList
                "roleList": null,
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => authRepository.login(
            username: username,
            password: password,
          ),
          throwsA(isA<Error>()),
        );
      });
    });

    group("refreshToken - Success Scenarios", () {
      test("should successfully refresh token with valid refresh token",
          () async {
        // Arrange
        // Set up user for BaseRequest
        final testUser = User(
          id: "test123",
          name: "Test User",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session";

        const refreshTokenValue = "valid-refresh-token";
        await mockLocalStorageService.put(
          LocalStorageBoxes.user,
          LocalStorageKeys.refreshToken,
          refreshTokenValue,
        );

        final mockResponseBody = {
          "responseData": {"jwtToken": "new-access-token", "expiresIn": 3600},
        };

        final mockResponse = AppResponse(
          message: "Token refreshed",
          body: mockResponseBody,
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await authRepository.refreshToken();

        // Assert
        expect(result, equals("new-access-token"));

        // Verify API call
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.refreshToken),
        );

        // Verify request contains refresh token
        final requestBody = mockAPIManager.callLog[0]["body"];
        final requestData = json.decode(
          requestBody is String ? requestBody : json.encode(requestBody),
        );
        expect(
          requestData["requestData"]["refreshToken"],
          equals(refreshTokenValue),
        );

        // Verify new token is stored
        final storedToken = await mockLocalStorageService.get(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        );
        expect(storedToken, equals("new-access-token"));
      });

      test("should handle refresh token with null stored refresh token",
          () async {
        // Arrange
        // Set up user for BaseRequest
        final testUser = User(
          id: "test456",
          name: "Test User 2",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-2";

        // No refresh token stored
        final mockResponseBody = {
          "responseData": {"jwtToken": "new-token", "expiresIn": 1800},
        };

        final mockResponse = AppResponse(
          message: "Token refreshed",
          body: mockResponseBody,
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await authRepository.refreshToken();

        // Assert
        expect(result, equals("new-token"));

        // Verify request was made with null refresh token
        final requestBody = mockAPIManager.callLog[0]["body"];
        final requestData = json.decode(
          requestBody is String ? requestBody : json.encode(requestBody),
        );
        expect(requestData["requestData"]["refreshToken"], isNull);
      });
    });

    group("refreshToken - Error Scenarios", () {
      test("should throw exception when refresh token API fails", () async {
        // Arrange
        // Set up user for BaseRequest
        final testUser = User(
          id: "test789",
          name: "Test User 3",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-3";
        await mockLocalStorageService.put(
          LocalStorageBoxes.user,
          LocalStorageKeys.refreshToken,
          "expired-token",
        );

        final mockResponse = AppResponse(
          message: "Refresh token expired",
          body: {"error": "Token expired"},
          code: 401,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => authRepository.refreshToken(),
          throwsA(equals("Refresh token expired")),
        );
      });

      test("should handle network error during token refresh", () async {
        // Arrange
        // Set up user for BaseRequest
        final testUser = User(
          id: "test999",
          name: "Test User 4",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-4";
        mockAPIManager.setMockException(Exception("Connection timeout"));

        // Act & Assert
        expect(
          () async => authRepository.refreshToken(),
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

    group("logout - Success Scenarios", () {
      test("should successfully logout user", () async {
        // Arrange
        // Set up user for BaseRequest
        final testUser = User(
          id: "logout123",
          name: "Logout User",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;
        Globals.sessionID = "logout-session";

        // Set up user data
        await mockLocalStorageService.put(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
          "test-token",
        );
        await mockLocalStorageService.put(
          LocalStorageBoxes.user,
          LocalStorageKeys.userInfo,
          {"userId": "test"},
        );

        final mockResponse = AppResponse(
          message: "Logout successful",
          body: {},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        await authRepository.logout();

        // Assert
        // Verify API call
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.logout),
        );

        // Verify local storage is cleared
        final storedToken = await mockLocalStorageService.get(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        );
        expect(storedToken, isNull);

        final storedUserInfo = await mockLocalStorageService.get(
          LocalStorageBoxes.user,
          LocalStorageKeys.userInfo,
        );
        expect(storedUserInfo, isNull);
      });

      test("should handle logout when API returns success status", () async {
        // Arrange
        // Set up user for BaseRequest
        final testUser = User(
          id: "logout456",
          name: "Logout User 2",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;
        Globals.sessionID = "logout-session-2";
        final mockResponse = AppResponse(
          message: "Logged out",
          body: {},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert - Should not throw
        await authRepository.logout();
        expect(mockAPIManager.callLog, hasLength(1));
      });
    });

    group("logout - Error Scenarios", () {
      test("should throw exception when logout API returns error status",
          () async {
        // Arrange
        // Set up user for BaseRequest
        final testUser = User(
          id: "logout789",
          name: "Logout User 3",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;
        Globals.sessionID = "logout-session-3";
        final mockResponse = AppResponse(
          message: "Logout failed",
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => authRepository.logout(),
          throwsA(equals("Logout failed")),
        );
      });

      test("should rethrow exception when API call fails", () async {
        // Arrange
        // Set up user for BaseRequest
        final testUser = User(
          id: "logout999",
          name: "Logout User 4",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;
        Globals.sessionID = "logout-session-4";
        mockAPIManager.setMockException(Exception("Network failure"));

        // Act & Assert
        expect(
          () async => authRepository.logout(),
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

    group("updateUserInCache", () {
      test("should store user data in local storage", () async {
        // Arrange
        final testUser = User(
          id: "test123",
          name: "Test User",
          email: "test@example.com",
        );
        Globals.user = testUser;

        // Act
        await authRepository.updateUserInCache();

        // Assert
        final storedUserInfo = await mockLocalStorageService.get(
          LocalStorageBoxes.user,
          LocalStorageKeys.userInfo,
        );
        expect(storedUserInfo, isNotNull);
        expect(storedUserInfo, equals(testUser.toJson()));
      });

      test("should handle null user", () async {
        // Arrange
        Globals.user = null;

        // Act
        await authRepository.updateUserInCache();

        // Assert
        final storedUserInfo = await mockLocalStorageService.get(
          LocalStorageBoxes.user,
          LocalStorageKeys.userInfo,
        );
        expect(storedUserInfo, isNull);
      });
    });

    group("isLoggedIn", () {
      test("should return true when valid user data exists in storage",
          () async {
        // Arrange
        final userData = {
          "userId": "test123",
          "userName": "Test User",
          "authenticated": true,
          "currentRole": {"roleId": 1, "roleName": "Admin", "roleCode": "ADM"},
        };

        await mockLocalStorageService.put(
          LocalStorageBoxes.user,
          LocalStorageKeys.userInfo,
          userData,
        );
        await mockLocalStorageService.put(
          LocalStorageBoxes.user,
          LocalStorageKeys.sessionID,
          "test-session",
        );

        // Act
        final result = await authRepository.isLoggedIn();

        // Assert
        expect(result, isTrue);
        expect(Globals.user, isNotNull);
        expect(Globals.user!.id, equals("test123"));
        expect(Globals.sessionID, equals("test-session"));
      });

      test("should return false when no user data exists in storage", () async {
        // Arrange - No user data stored

        // Act
        final result = await authRepository.isLoggedIn();

        // Assert
        expect(result, isFalse);
        expect(Globals.user, isNull);
      });

      test("should handle null session ID", () async {
        // Arrange
        final userData = {
          "userId": "test123",
          "userName": "Test User",
        };

        await mockLocalStorageService.put(
          LocalStorageBoxes.user,
          LocalStorageKeys.userInfo,
          userData,
        );
        // No session ID stored

        // Act
        final result = await authRepository.isLoggedIn();

        // Assert
        expect(result, isTrue);
        expect(Globals.user, isNotNull);
        expect(Globals.sessionID, equals(""));
      });
    });

    group("changeRole", () {
      test("should successfully change user role", () async {
        // Arrange
        final testRole = Role(
          roleId: 2,
          name: "Manager",
          code: "MGR",
          bpmRole: "manager",
        );

        final testUser = User(
          id: "test123",
          name: "Test User",
          currentRole: Role(
            roleId: 1,
            name: "Current Role",
            code: "CUR",
            bpmRole: "current",
          ),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session";

        // Mock role rights API response (for getRoleRights)
        final roleRightsResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {"pageList": []},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        // Set up mock response - both calls will return this
        mockAPIManager.setMockResponse(roleRightsResponse);

        // Act
        await authRepository.changeRole(testRole);

        // Assert - changeRole calls both sendUpdateToServer and updateRole
        // (getRoleRights)
        expect(mockAPIManager.callLog, hasLength(2));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.updateUserRole),
        );
        expect(
          mockAPIManager.callLog[1]["endpoint"],
          equals(APIEndpoints.getAuthRoleRightMap),
        );
      });
    });

    group("updateRole", () {
      test("should update role with access rights", () async {
        // Arrange
        final testRole = Role(
          roleId: 3,
          name: "Analyst",
          code: "ANA",
        );

        final testUser = User(
          id: "test123",
          name: "Test User",
          currentRole: Role(
            roleId: 1,
            name: "Current Role",
            code: "CUR",
            bpmRole: "current",
          ),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-auth";

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "pageIds": [
                {
                  "pageId": 1,
                  "pageName": "Dashboard",
                  "componentName": "dashboard",
                  "accessType": "E", // edit
                  "navigationOrder": 1,
                },
                {
                  "pageId": 2,
                  "pageName": "Reports",
                  "componentName": "reports",
                  "accessType": "V", // view
                  "navigationOrder": 2,
                }
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        await authRepository.updateRole(testRole);

        // Assert
        expect(Globals.user!.currentRole, isNotNull);
        expect(Globals.user!.currentRole!.rights, isNotNull);
        expect(
          Globals.user!.currentRole!.rights!["dashboard"],
          equals(AccessType.edit),
        );
        expect(
          Globals.user!.currentRole!.rights!["reports"],
          equals(AccessType.view),
        );
        expect(Globals.user!.currentRole!.routesAccessibility, isNotNull);
      });

      test("should handle updateRole with request parameter", () async {
        // Arrange
        final testRole = Role(roleId: 4, name: "Reviewer");
        final testRequest =
            Request(requestSubType: Reference(reference1: "TEST_TYPE"));

        final testUser = User(
          id: "test123",
          currentRole: Role(
            roleId: 1,
            name: "Current Role",
            code: "CUR",
            bpmRole: "current",
          ),
        );
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {"pageList": []},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        await authRepository.updateRole(testRole, request: testRequest);

        // Assert
        expect(mockAPIManager.callLog, hasLength(1));

        // Verify request data contains request info
        final requestBody = mockAPIManager.callLog[0]["body"];
        final requestData = json.decode(
          requestBody is String ? requestBody : json.encode(requestBody),
        );
        // expect(requestData['requestData']['appRequestType'], equals('APN'));
        expect(requestData["requestData"]["subType"], equals("TEST_TYPE"));
      });
    });

    group("getRoleRights - Success Scenarios", () {
      test("should successfully get role rights and update role", () async {
        // Arrange
        // Set up user for BaseRequest
        final testRole = Role(
          roleId: 5,
          name: "Admin",
          code: "ADM",
        );

        final testUser = User(
          id: "admin123",
          name: "Admin User",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );
        Globals.user = testUser;
        Globals.sessionID = "admin-session";

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "pageIds": [
                {
                  "pageId": 1,
                  "pageName": "User Management",
                  "componentName": "user_management",
                  "accessType": "E", // edit
                  "navigationOrder": 1,
                },
                {
                  "pageId": 2,
                  "pageName": "System Config",
                  "componentName": "system_config",
                  "accessType": "V", // view
                  "navigationOrder": 2,
                },
                {
                  "pageId": 3,
                  "pageName": "Hidden Page",
                  "componentName": "hidden_page",
                  "accessType": "N", // none
                  "navigationOrder": 3,
                }
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await authRepository.getRoleRights(testRole);

        // Assert
        expect(result, isNotNull);
        expect(result!.rights, isNotNull);
        expect(result.rights!["user_management"], equals(AccessType.edit));
        expect(result.rights!["system_config"], equals(AccessType.view));
        expect(result.rights!["hidden_page"], equals(AccessType.none));
        expect(result.routesAccessibility, isNotNull);
        expect(
          result.routesAccessibility!["user_management"],
          equals(MenuMode.disabled),
        );
        expect(Globals.user!.currentRole, equals(result));
      });

      test("should handle empty pages list", () async {
        // Arrange
        final testRole = Role(roleId: 6, name: "Limited User");
        final testUser = User(
          id: "limited123",
          currentRole:
              Role(roleId: 1, name: "Limited", code: "LIM", bpmRole: "limited"),
        );
        Globals.user = testUser;
        Globals.sessionID = "limited-session";

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {"pageList": []},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await authRepository.getRoleRights(testRole);

        // Assert
        expect(result, isNotNull);
        expect(result!.rights, isEmpty);
        expect(result.routesAccessibility, isEmpty);
      });

      test("should handle pages without componentName", () async {
        // Arrange
        final testRole = Role(roleId: 7, name: "Special User");
        final testUser = User(
          id: "special123",
          currentRole:
              Role(roleId: 1, name: "Special", code: "SPE", bpmRole: "special"),
        );
        Globals.user = testUser;
        Globals.sessionID = "special-session";

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "pageIds": [
                {
                  "pageId": 1,
                  "pageName": "Page Without Component",
                  "accessType": "V",
                  "navigationOrder": 1,
                  // No componentName
                },
                {
                  "pageId": 2,
                  "pageName": "Page With Component",
                  "componentName": "with_component",
                  "accessType": "E",
                  "navigationOrder": 2,
                }
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await authRepository.getRoleRights(testRole);

        // Assert
        expect(result, isNotNull);
        expect(result!.rights, hasLength(1)); // Only page with componentName
        expect(result.rights!["with_component"], equals(AccessType.edit));
        expect(
          result.routesAccessibility,
          hasLength(2),
        ); // Both pages in routes
      });
    });

    group("getRoleRights - Error Scenarios", () {
      test("should throw exception when API returns error", () async {
        // Arrange
        final testRole = Role(roleId: 8, name: "Failed Role");
        final testUser = User(
          id: "user123",
          currentRole:
              Role(roleId: 1, name: "User", code: "USR", bpmRole: "user"),
        );
        Globals.user = testUser;
        Globals.sessionID = "user-session";

        final mockResponse = AppResponse(
          message: "Access denied",
          body: {"error": "Insufficient permissions"},
          code: 403,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => authRepository.getRoleRights(testRole),
          throwsA(equals("Access denied")),
        );
      });
    });

    group("sendUpdateToServer - Success Scenarios", () {
      test("should successfully send role update to server", () async {
        // Arrange
        final testRole = Role(
          roleId: 9,
          name: "Updated Role",
          code: "UPD",
          bpmRole: "updated",
        );

        final testUser = User(
          id: "user123",
          name: "Test User",
        );
        Globals.user = testUser;
        Globals.sessionID = "session123";

        final mockResponse = AppResponse(
          message: "Role updated successfully",
          body: {},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await authRepository.sendUpdateToServer(testRole);

        // Assert
        expect(result, equals("Role updated successfully"));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(mockAPIManager.callLog[0]["method"], equals("PUT"));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.updateUserRole),
        );

        // Verify request data
        final requestBody = mockAPIManager.callLog[0]["body"];
        final requestData = json.decode(
          requestBody is String ? requestBody : json.encode(requestBody),
        );
        expect(requestData["baseRequest"]["roleID"], equals(9));
        expect(requestData["baseRequest"]["role"], equals("UPD"));
        expect(requestData["baseRequest"]["bpmRole"], equals("updated"));
        expect(requestData["baseRequest"]["userID"], equals("user123"));
        expect(requestData["baseRequest"]["userName"], equals("Test User"));
        expect(requestData["baseRequest"]["sessionID"], equals("session123"));
        expect(requestData["baseRequest"]["channelID"], equals("WCAS"));
      });
    });

    group("sendUpdateToServer - Error Scenarios", () {
      test("should throw exception when server returns error", () async {
        // Arrange
        final testRole = Role(roleId: 10, name: "Error Role");
        final testUser = User(
          id: "user123",
          currentRole:
              Role(roleId: 1, name: "User", code: "USR", bpmRole: "user"),
        );
        Globals.user = testUser;
        Globals.sessionID = "update-session";

        final mockResponse = AppResponse(
          message: "Update failed",
          body: {"error": "Role not found"},
          code: 404,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => authRepository.sendUpdateToServer(testRole),
          throwsA(equals("Update failed")),
        );
      });
    });

    group("getRoutesAccessibility", () {
      test(
          "should generate routes accessibility map sorted by navigation order",
          () {
        // Arrange
        final pages = [
          Page(
            id: 3,
            name: "Third Page",
            componentName: "third_page",
            navigationOrder: 3,
            accessType: AccessType.view,
          ),
          Page(
            id: 1,
            name: "First Page",
            componentName: "first_page",
            navigationOrder: 1,
            accessType: AccessType.view,
          ),
          Page(
            id: 2,
            name: "Second Page",
            componentName: "second_page",
            navigationOrder: 2,
            accessType: AccessType.view,
          ),
        ];

        // Act
        final result = authRepository.getRoutesAccessibility(pages);

        // Assert
        expect(result, hasLength(3));

        // Verify order (LinkedHashMap maintains insertion order)
        final keys = result.keys.toList();
        expect(keys[0], equals("first_page"));
        expect(keys[1], equals("second_page"));
        expect(keys[2], equals("third_page"));

        // Verify all are disabled by default
        expect(result["first_page"], equals(MenuMode.disabled));
        expect(result["second_page"], equals(MenuMode.disabled));
        expect(result["third_page"], equals(MenuMode.disabled));
      });

      test("should handle pages without componentName using name", () {
        // Arrange
        final pages = [
          Page(
            id: 1,
            name: "Page Name",
            navigationOrder: 1,
            accessType: AccessType.view,
            // No componentName
          ),
          Page(
            id: 2,
            name: "Another Page",
            componentName: "another_page",
            navigationOrder: 2,
            accessType: AccessType.view,
          ),
        ];

        // Act
        final result = authRepository.getRoutesAccessibility(pages);

        // Assert
        expect(result, hasLength(2));
        expect(result["Page Name"], equals(MenuMode.disabled));
        expect(result["another_page"], equals(MenuMode.disabled));
      });

      test("should handle pages with null name and componentName", () {
        // Arrange
        final pages = [
          Page(
            id: 1,
            navigationOrder: 1,
            accessType: AccessType.view,
            // Both name and componentName are null
          ),
        ];

        // Act
        final result = authRepository.getRoutesAccessibility(pages);

        // Assert
        expect(result, hasLength(1));
        expect(result[""], equals(MenuMode.disabled));
      });
    });

    group("Static Methods", () {
      test("hasRight should return true for view access", () {
        // Arrange
        final testRole = Role(
          rights: {
            "test_component": AccessType.view,
            "edit_component": AccessType.edit,
            "no_access_component": AccessType.none,
          },
        );

        final testUser = User(currentRole: testRole);
        Globals.user = testUser;

        // Act & Assert
        expect(AuthRepository.hasRight("test_component"), isTrue);
        expect(AuthRepository.hasRight("edit_component"), isTrue);
        expect(AuthRepository.hasRight("no_access_component"), isFalse);
        expect(AuthRepository.hasRight("nonexistent_component"), isFalse);
      });

      test("hasRight should return false when user is null", () {
        // Arrange
        Globals.user = null;

        // Act & Assert
        expect(AuthRepository.hasRight("any_component"), isFalse);
      });

      test("hasRight should return false when currentRole is null", () {
        // Arrange
        final testUser = User(currentRole: null);
        Globals.user = testUser;

        // Act & Assert
        expect(AuthRepository.hasRight("any_component"), isFalse);
      });

      test("getPageMode should return correct page modes", () {
        // Arrange
        final testRole = Role(
          rights: {
            "view_component": AccessType.view,
            "edit_component": AccessType.edit,
            "no_access_component": AccessType.none,
          },
        );

        final testUser = User(currentRole: testRole);
        Globals.user = testUser;

        // Act & Assert
        expect(
          AuthRepository.getPageMode("view_component"),
          equals(PageMode.view),
        );
        expect(
          AuthRepository.getPageMode("edit_component"),
          equals(PageMode.edit),
        );
        expect(
          AuthRepository.getPageMode("no_access_component"),
          equals(PageMode.na),
        );
        expect(
          AuthRepository.getPageMode("nonexistent_component"),
          equals(PageMode.na),
        );
      });

      test("getPageMode should return na when user is null", () {
        // Arrange
        Globals.user = null;

        // Act & Assert
        expect(
          AuthRepository.getPageMode("any_component"),
          equals(PageMode.na),
        );
      });
    });

    group("Edge Cases and Error Handling", () {
      test("should handle concurrent login attempts", () async {
        // Arrange
        const username = "concurrent_user";
        const password = "password123";

        final mockResponse = AppResponse(
          message: "Login successful",
          body: {
            "responseData": {
              "userResponse": {
                "userId": username,
                "userName": "Concurrent User",
                "authenticated": true,
                "roleList": [
                  {
                    "roleId": 1,
                    "roleName": "User",
                    "roleCode": "USR",
                    "bpmRole": "user",
                  }
                ],
              },
              "tokenResponse": {
                "jwtToken": "concurrent-token",
                "refreshToken": "concurrent-refresh",
                "expiresIn": 3600,
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act - Make multiple concurrent login attempts
        final futures = List.generate(
          3,
          (_) => authRepository.login(username: username, password: password),
        );
        final results = await Future.wait(futures);

        // Assert
        expect(results, hasLength(3));
        for (final result in results) {
          expect(result, isNotNull);
        }
        expect(mockAPIManager.callLog, hasLength(3));
      });
    });
  });
}
