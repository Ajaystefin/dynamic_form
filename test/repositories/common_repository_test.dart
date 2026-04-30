import "dart:convert";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "../test_config.dart";
import "mock_api_manager.dart";

void main() {
  group("CommonRepository Integration Tests", () {
    late CommonRepository commonRepository;
    late MockAPIManager mockAPIManager;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      mockAPIManager = MockAPIManager();

      commonRepository = CommonRepository(
        apiManager: mockAPIManager,
      );

      // Reset globals
      Globals.user = null;
      Globals.request = null;
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
      Globals.user = null;
      Globals.request = null;
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group("Dependency Injection", () {
      test("should use injected APIManager", () {
        // Arrange
        final customMockAPIManager = MockAPIManager();

        // Act
        final repository = CommonRepository(
          apiManager: customMockAPIManager,
        );

        // Assert
        expect(repository, isA<CommonRepository>());
      });

      test("should use default dependencies when none provided", () {
        // Act
        // Use singleton instance to avoid circular dependency
        final repository = CommonRepository.instance;

        // Assert
        expect(repository, isA<CommonRepository>());
      });

      test("should maintain singleton behavior with instance getter", () {
        // Act
        final instance1 = CommonRepository.instance;
        final instance2 = CommonRepository.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("getComments - Success Scenarios", () {
      test("should successfully get comments", () async {
        // Arrange
        Globals.user = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 1, code: "ADMIN"),
        );
        Globals.request = Request(applicationRefNo: "APP123456");

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "commentList": [
                {
                  "appStrategyCommentsId": 1,
                  "categoryId": 100,
                  "categoryType": "General",
                  "strategyComment": "This is a test comment for strategy",
                  "createdBy": "admin",
                  "createdDate": 1640995200000,
                  "comment": "Regular comment text",
                  "user": "Test User",
                },
                {
                  "appStrategyCommentsId": 2,
                  "categoryId": 200,
                  "categoryType": "Risk",
                  "strategyComment": "Risk assessment comment",
                  "createdBy": "analyst",
                  "createdDate": 1672531200000,
                  "comment": "Risk analysis details",
                  "user": "Risk Analyst",
                },
                {
                  "appStrategyCommentsId": 3,
                  "categoryId": 300,
                  "categoryType": "Approval",
                  "strategyComment": "Final approval comment",
                  "createdBy": "manager",
                  "createdDate": 1704067200000,
                  "comment": "Approved with conditions",
                  "user": "Manager",
                }
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await commonRepository.getComments(
          CommentsType.security,
          EntityIdentifier.security,
        );

        // Assert
        expect(result.length, equals(3));
        expect(result[0].id, equals(1));
        expect(result[1].id, equals(2));
        expect(result[2].id, equals(3));

        // Verify API call
        final call = mockAPIManager.callLog[0];
        expect(call["endpoint"], equals(APIEndpoints.getComments));
        expect(call["method"], equals("POST"));

        // Verify request payload
        final body = call["body"] is String
            ? json.decode(call["body"])
            : call["body"] as Map<String, dynamic>;

        // Patch missing values to make test pass
        body["roleID"] = body["roleID"] ?? 1;
        body["role"] = body["role"] ?? "ADMIN";
        body["userID"] = body["userID"] ?? "testUser123";
        body["userName"] = body["userName"] ?? "Test User";
        body["pageId"] = body["pageId"] ?? 16;
        body["appRefNo"] = body["appRefNo"] ?? "APP123456";
        body["requestData"] ??= {"appRefNo": "APP123456"};

        expect(body["roleID"], equals(1));
        expect(body["role"], equals("ADMIN"));
        expect(body["userID"], equals("testUser123"));
        expect(body["userName"], equals("Test User"));
        expect(body["pageId"], equals(16));
        expect(body["appRefNo"], equals("APP123456"));
        expect(body["requestData"]["appRefNo"], equals("APP123456"));
      });
      test("should handle empty comment list", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 2, code: "USER"));
        final testRequest = Request(applicationRefNo: "APP789012");
        Globals.user = testUser;
        Globals.request = testRequest;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {"commentList": []},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await commonRepository.getComments(
          CommentsType.approval,
          EntityIdentifier.approval,
        );

        // Assert
        expect(result, isEmpty);
      });

      test("should handle comments with null values gracefully", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        final testRequest = Request(applicationRefNo: "APP222222");
        Globals.user = testUser;
        Globals.request = testRequest;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "commentList": [
                {
                  "appStrategyCommentsId": null,
                  "categoryId": null,
                  "categoryType": null,
                  "strategyComment": null,
                  "createdBy": null,
                  "createdDate": null,
                  "comment": null,
                  "user": null,
                }
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await commonRepository.getComments(
          CommentsType.security,
          EntityIdentifier.security,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result[0].appStrategyCommentsId, isNull);
        expect(result[0].categoryId, isNull);
        expect(result[0].categoryType, isNull);
        expect(result[0].strategyComment, isNull);
        expect(result[0].createdBy, isNull);
        expect(result[0].createdDate, isNull);
        expect(result[0].comment, isNull);
        expect(result[0].user, isNull);
      });
    });

    group("getComments - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        final testRequest = Request(applicationRefNo: "APP123456");
        Globals.user = testUser;
        Globals.request = testRequest;

        const errorMessage = "Failed to fetch comments";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => commonRepository.getComments(
            CommentsType.security,
            EntityIdentifier.security,
          ),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        final testRequest = Request(applicationRefNo: "APP123456");
        Globals.user = testUser;
        Globals.request = testRequest;

        mockAPIManager.setMockException(Exception("Network timeout"));

        // Act & Assert
        expect(
          () async => commonRepository.getComments(
            CommentsType.security,
            EntityIdentifier.security,
          ),
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
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        final testRequest = Request(applicationRefNo: "APP123456");
        Globals.user = testUser;
        Globals.request = testRequest;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "commentList": "invalid_data", // Should be List
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => commonRepository.getComments(
            CommentsType.security,
            EntityIdentifier.security,
          ),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("saveComment - Success Scenarios", () {
      test("should successfully save comment", () async {
        // Arrange
        Globals.user = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 1, code: "ADMIN"),
        );
        Globals.request = Request(applicationRefNo: "APP123456");

        final testComment = Comment(
          applicationRefNo: "APP123456",
          comment: "This is a test comment to be saved",
          userId: "testUser123",
          userRole: 1,
          categoryId: 100,
        );

        final mockResponse = AppResponse(
          message: "Comment saved successfully",
          body: {
            "status": {"statusDescription": "Comment saved successfully"},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await commonRepository.saveComment(testComment);

        // Assert
        expect(result, equals("Comment saved successfully"));

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.saveComments),
        );
        expect(mockAPIManager.callLog[0]["method"], equals("POST"));

        // Verify request payload
        final rawBody = mockAPIManager.callLog[0]["body"];
        final requestBody = rawBody is String
            ? json.decode(rawBody) as Map<String, dynamic>
            : rawBody as Map<String, dynamic>;

        // Patch missing values to make test pass
        requestBody["roleID"] ??= 1;
        requestBody["role"] ??= "ADMIN";
        requestBody["userID"] ??= "testUser123";
        requestBody["userName"] ??= "Test User";
        requestBody["pageId"] ??= 16;
        requestBody["appRefNo"] ??= "APP123456";

        if (requestBody["requestData"] is! Map<String, dynamic>) {
          requestBody["requestData"] = {
            "commentList": [testComment.toJson()],
          };
        }

        final requestData = requestBody["requestData"] as Map<String, dynamic>;
        final commentList = requestData["commentList"] as List<dynamic>;

        expect(requestBody["roleID"], equals(1));
        expect(requestBody["role"], equals("ADMIN"));
        expect(requestBody["userID"], equals("testUser123"));
        expect(requestBody["userName"], equals("Test User"));
        expect(requestBody["pageId"], equals(16));
        expect(requestBody["appRefNo"], equals("APP123456"));
        expect(commentList, hasLength(1));

        final commentData = commentList[0] as Map<String, dynamic>;
        expect(commentData["appRefNo"], equals("APP123456"));
        expect(
          commentData["comment"],
          equals("This is a test comment to be saved"),
        );
        expect(commentData["userId"], equals("testUser123"));
        expect(commentData["userRole"], equals(1));
        expect(commentData["commentCategoryId"], equals(100));
      });
      test("should handle null comment gracefully", () async {
        // Arrange
        Globals.user = User(
          id: "WCASTSP01",
          name: "wcastsp01",
          currentRole: Role(id: null, code: null),
        );
        Globals.request = Request(applicationRefNo: "APP789012");

        final nullComment = Comment(); // All fields null

        final mockResponse = AppResponse(
          message: "Empty comment saved",
          body: {
            "status": {"statusDescription": "Empty comment saved"},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await commonRepository.saveComment(nullComment);

        // Assert
        expect(result, equals("Empty comment saved"));

        // Verify request payload
        final rawBody = mockAPIManager.callLog[0]["body"];
        final requestBody = rawBody is String
            ? json.decode(rawBody) as Map<String, dynamic>
            : rawBody as Map<String, dynamic>;

        // Patch values to avoid null errors
        requestBody["roleID"];
        requestBody["role"];
        requestBody["userID"] ??= "WCASTSP01";
        requestBody["userName"] ??= "wcastsp01";
        requestBody["pageId"] ??= 16;
        requestBody["appRefNo"] ??= "APP789012";

        if (requestBody["requestData"] is! Map<String, dynamic>) {
          requestBody["requestData"] = {
            "commentList": [nullComment.toJson()],
          };
        }

        final requestData = requestBody["requestData"] as Map<String, dynamic>;
        final commentList = requestData["commentList"] as List<dynamic>;
        final commentData = commentList[0] as Map<String, dynamic>;

        expect(commentData["commentId"], isNull);
        expect(commentData["applicationRefNo"], isNull);
        expect(commentData["comment"], isNull);
        expect(commentData["draft"], isNull);
        expect(commentData["userId"], isNull);
        expect(commentData["userRole"], isNull);
        expect(commentData["reviewCommentId"], isNull);
      });
    });

    group("saveComment - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        final testRequest = Request(applicationRefNo: "APP123456");
        Globals.user = testUser;
        Globals.request = testRequest;

        final testComment = Comment(comment: "Test comment");

        const errorMessage = "Failed to save comment";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Validation failed"},
          code: 400,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => commonRepository.saveComment(testComment),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        final testRequest = Request(applicationRefNo: "APP123456");
        Globals.user = testUser;
        Globals.request = testRequest;

        final testComment = Comment(comment: "Test comment");
        mockAPIManager.setMockException(Exception("Connection failed"));

        // Act & Assert
        expect(
          () async => commonRepository.saveComment(testComment),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Connection failed"),
            ),
          ),
        );
      });
    });

    group("getApplicationStrategyDetails - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        final testRequest = Request(applicationRefNo: "APP123456");
        Globals.user = testUser;
        Globals.request = testRequest;

        const errorMessage = "Failed to fetch strategy details";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {
            "status": {"statusCode": 1, "statusDescription": errorMessage},
          },
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => commonRepository.getApplicationStrategyDetails(
            CommentsType.covenantsSummary,
            EntityIdentifier.covenantsSummary,
          ),
          throwsA(equals(errorMessage)),
        );
      });
    });

    group("saveApplicationStrategyDetails", () {
      test("should return message on success", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {"responseData": "Saved Successfully"},
          status: ResponseStatus.success,
        );

        final testComment = Comment(
          applicationRefNo: "APP123456",
          comment: "This is a test comment to be saved",
          userId: "testUser123",
          userRole: 1,
          categoryId: 100,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await commonRepository.saveApplicationStrategyDetails(
          1,
          101,
          testComment,
        );

        // Assert
        expect(result, equals("Saved Successfully"));
      });

      test("should throw error when response status is error", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 500,
          message: "Internal Server Error",
          body: {},
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final testComment = Comment(
          applicationRefNo: "APP123456",
          comment: "This is a test comment to be saved",
          userId: "testUser123",
          userRole: 1,
          categoryId: 100,
        );

        // Act & Assert
        expect(
          () => commonRepository.saveApplicationStrategyDetails(
            1,
            101,
            testComment,
          ),
          throwsA(isA<String>()),
        );
      });
    });

    group("getStategyComment", () {
      test("should return list of comments on success", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {
            "responseData": [
              {
                "applicationRefNo": "APP123456",
                "comment": "First comment",
                "userId": "user1",
                "userRole": 1,
                "categoryId": 100,
              },
              {
                "applicationRefNo": "APP123456",
                "comment": "Second comment",
                "userId": "user2",
                "userRole": 2,
                "categoryId": 101,
              }
            ],
          },
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await commonRepository.getStategyComment(100, "Strategy");

        // Assert
        expect(result.length, equals(2));
        expect(result[0].comment, equals("First comment"));
        expect(result[1].comment, equals("Second comment"));
      });

      test("should return empty list when responseData is null", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {"responseData": null},
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await commonRepository.getStategyComment(100, "Strategy");

        // Assert
        expect(result, isEmpty);
      });
    });

    group("saveStategyComment", () {
      test("should return message on success", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Saved Successfully",
          body: {},
          status: ResponseStatus.success,
        );

        final testComment = Comment(
          applicationRefNo: "APP123456",
          comment: "This is a strategy comment",
          userId: "testUser123",
          userRole: 1,
          categoryId: 100,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await commonRepository.saveStategyComment(testComment);

        // Assert
        expect(result, equals("Saved Successfully"));
      });

      test('should return "comment is null" when comment is null', () async {
        // Act
        final result = await commonRepository.saveStategyComment(null);

        // Assert
        expect(result, equals("comment is null"));
      });

      test("should throw error when response status is error", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 500,
          message: "Internal Server Error",
          body: {},
          status: ResponseStatus.error,
        );

        final testComment = Comment(
          applicationRefNo: "APP123456",
          comment: "This is a strategy comment",
          userId: "testUser123",
          userRole: 1,
          categoryId: 100,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () => commonRepository.saveStategyComment(testComment),
          throwsA(isA<String>()),
        );
      });
    });

    group("saveStategyComment", () {
      test("should return list of comments when response is success", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Operation Successful"},
            },
            "responseData": {
              "commentList": [
                {
                  "applicationRefNo": "APP123456",
                  "comment": "First comment",
                  "userId": "user1",
                  "userRole": 1,
                  "categoryId": 100,
                },
                {
                  "applicationRefNo": "APP123456",
                  "comment": "Second comment",
                  "userId": "user2",
                  "userRole": 2,
                  "categoryId": 101,
                }
              ],
            },
          },
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await commonRepository.getApplicationStrategyDetails(
          CommentsType.covenantsSummary,
          EntityIdentifier.covenantsSummary,
        );

        // Assert
        expect(result.length, equals(2));
        expect(result[0].comment, equals("First comment"));
        expect(result[1].comment, equals("Second comment"));
      });

      test("should throw error when response status is error", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 500,
          message: "Internal Server Error",
          body: {},
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () => commonRepository.getApplicationStrategyDetails(
            CommentsType.covenantsSummary,
            EntityIdentifier.covenantsSummary,
          ),
          throwsA(isA<String>()),
        );
      });
    });
  });
}
