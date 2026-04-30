import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/models/request/risk_rating/risk_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/updated_rating.dart";
import "package:wcas_frontend/repositories/risk_rating_repository.dart";
import "mock_api_manager.dart";

void main() {
  group("RiskRatingRepository Integration Tests", () {
    late RiskRatingRepository riskRatingRepository;
    late MockAPIManager mockAPIManager;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await EnvConfig.setEnvironment();
      mockAPIManager = MockAPIManager();
      riskRatingRepository = RiskRatingRepository(apiManager: mockAPIManager);
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
      Globals.user = null;
      Globals.request = null;
    });

    group("Constructor and Initialization", () {
      test("should create instance with default APIManager when none provided",
          () {
        // Use singleton instance to avoid circular dependency
        final repo = RiskRatingRepository.instance;
        expect(repo, isNotNull);
      });

      test("should create instance with provided APIManager", () {
        final repo = RiskRatingRepository(apiManager: mockAPIManager);
        expect(repo, isNotNull);
      });

      test("should provide singleton instance", () {
        // Use singleton instance to avoid circular dependency
        final instance1 = RiskRatingRepository.instance;
        final instance2 = RiskRatingRepository.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("getRatingDetails - Success Scenarios", () {
      test("should successfully fetch rating details", () async {
        // Arrange
        final testRequest = Request(
          applicationRefNo: "APP12345",
          requestRefNo: "REQ12345",
        );
        Globals.request = testRequest;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": 0,
                "statusDescription": "Rating details fetched successfully",
              },
            },
            "responseData": {
              "externalRatingList": [],
              "internalRatingList": [
                {"id": 1, "internalRating": "A", "riskScore": 90.0},
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await riskRatingRepository.getRatingDetails();

        // Assert
        expect(result, isA<RiskRating>());
        expect(result.internalRatings, isNotNull);
      });

      test("should handle empty rating lists", () async {
        // Arrange
        final testRequest = Request(
          applicationRefNo: "APP12345",
          requestRefNo: "REQ12345",
        );
        Globals.request = testRequest;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": 0,
                "statusDescription": "No ratings found",
              },
            },
            "responseData": {
              "externalRatingList": [],
              "internalRatingList": [],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await riskRatingRepository.getRatingDetails();

        // Assert
        expect(result, isA<RiskRating>());
      });
    });

    group("getRatingDetails - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Rating details not found",
          body: {
            "status": {
              "statusCode": 1,
              "statusDescription": "No rating data available",
            },
          },
          code: 404,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => riskRatingRepository.getRatingDetails(),
          throwsA(equals("Rating details not found")),
        );
      });

      test("should handle network exceptions", () async {
        // Arrange
        mockAPIManager.setMockException(Exception("Network timeout"));

        // Act & Assert
        expect(
          () async => riskRatingRepository.getRatingDetails(),
          throwsA(isA<Exception>()),
        );
      });
    });
    group("getUpdatedRatingDetails - Success Scenarios", () {
      test("should successfully fetch updated rating details with valid data",
          () async {
        // Arrange
        const rimNo = 12345;
        const entityId = 67890;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": 0,
                "statusDescription": "Updated rating fetched successfully",
              },
            },
            "responseData": [
              {
                "entityId": entityId,
                "rimNo": rimNo,
                "existingFinalGrade": "A",
                "proposedFinalGrade": "A+",
                "isLatestVersion": true,
              },
              {
                "entityId": 67891,
                "rimNo": rimNo,
                "existingFinalGrade": "B",
                "proposedFinalGrade": "B+",
                "isLatestVersion": false,
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await riskRatingRepository.getUpdatedRatingDetails(
          rimNo: rimNo,
          entityId: entityId,
        );

        // Assert
        expect(result, isA<List<UpdatedRating?>>());
        expect(result.length, 2);
        expect(result[0]?.entityId, entityId);
        expect(result[0]?.rimNo, rimNo);
        expect(result[0]?.existingFinalGrade, "A");
        expect(result[0]?.proposedFinalGrade, "A+");
      });

      test("should handle null data in response list", () async {
        // Arrange
        const rimNo = 12345;
        const entityId = 67890;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": 0,
                "statusDescription": "Rating fetched with null entries",
              },
            },
            "responseData": [
              {"entityId": entityId, "rimNo": rimNo},
              null,
              {"entityId": 67891, "rimNo": rimNo},
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await riskRatingRepository.getUpdatedRatingDetails(
          rimNo: rimNo,
          entityId: entityId,
        );

        // Assert
        expect(result, isA<List<UpdatedRating?>>());
        expect(result.length, 2);
      });

      test("should handle empty response data list", () async {
        // Arrange
        const rimNo = 12345;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": 0,
                "statusDescription": "No ratings found",
              },
            },
            "responseData": [],
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await riskRatingRepository.getUpdatedRatingDetails(rimNo: rimNo);

        // Assert
        expect(result, isA<List<UpdatedRating?>>());
        expect(result.length, 0);
      });
    });

    group("getUpdatedRatingDetails - Error Scenarios", () {
      test("should handle network exceptions", () async {
        // Arrange
        mockAPIManager.setMockException(Exception("Connection timeout"));

        // Act & Assert
        expect(
          () async => riskRatingRepository.getUpdatedRatingDetails(rimNo: 123),
          throwsA(isA<Exception>()),
        );
      });
    });

    group("getRatingDetailsByEntity - Success Scenarios", () {
      test("should successfully fetch rating details by entity", () async {
        // Arrange
        const rimNo = "12345";

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": 0,
                "statusDescription": "Rating details fetched successfully",
              },
            },
            "responseData": [
              {
                "entityId": 100,
                "rimNo": 12345,
                "existingFinalGrade": "A",
                "proposedFinalGrade": "A+",
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await riskRatingRepository.getRatingDetailsByEntity(rimNo: rimNo);

        // Assert
        expect(result, isA<List<UpdatedRating?>>());
        expect(result.length, 1);
        expect(result[0]?.entityId, 100);
      });

      test("should handle null entries in response", () async {
        // Arrange
        const rimNo = "12345";

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": 0,
                "statusDescription": "Rating details with null entries",
              },
            },
            "responseData": [
              {"entityId": 100, "rimNo": 12345},
              null,
              {"entityId": 101, "rimNo": 12345},
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await riskRatingRepository.getRatingDetailsByEntity(rimNo: rimNo);

        // Assert
        expect(result, isA<List<UpdatedRating?>>());
        expect(result.length, 2);
      });
    });

    group("getRatingDetailsByEntity - Error Scenarios", () {
      test("should throw exception when entity rating not found", () async {
        // Arrange
        const rimNo = "INVALID_RIM";
        final mockResponse = AppResponse(
          message: "Entity rating not found",
          body: {
            "status": {
              "statusCode": 1,
              "statusDescription": "No rating found for entity",
            },
          },
          code: 404,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => riskRatingRepository.getRatingDetailsByEntity(
            rimNo: rimNo,
          ),
          throwsA(equals("Entity rating not found")),
        );
      });

      test("should handle server errors gracefully", () async {
        // Arrange
        const rimNo = "RIM001";
        final mockResponse = AppResponse(
          message: "Internal server error",
          body: {
            "status": {
              "statusCode": 500,
              "statusDescription": "Database connection failed",
            },
          },
          code: 500,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => riskRatingRepository.getRatingDetailsByEntity(
            rimNo: rimNo,
          ),
          throwsA(equals("Internal server error")),
        );
      });
    });

    group("saveRatings - Error Scenarios", () {
      test("should throw exception when save fails", () async {
        // Arrange
        final testRequest = Request(
          applicationRefNo: "APP12345",
          requestRefNo: "REQ12345",
        );
        Globals.request = testRequest;

        final mockResponse = AppResponse(
          message: "Invalid rating data",
          body: {
            "status": {
              "statusCode": 1,
              "statusDescription": "Rating validation failed",
            },
          },
          code: 400,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => riskRatingRepository.saveRatings(customerRating: {}),
          throwsA(equals("Invalid rating data")),
        );
      });

      test("should handle network exceptions during save", () async {
        // Arrange
        final testRequest = Request(
          applicationRefNo: "APP12345",
          requestRefNo: "REQ12345",
        );
        Globals.request = testRequest;

        mockAPIManager.setMockException(Exception("Connection timeout"));

        // Act & Assert
        expect(
          () async => riskRatingRepository.saveRatings(customerRating: {}),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
