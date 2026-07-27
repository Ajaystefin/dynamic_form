import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/group_borrower_search.dart";
import "package:wcas_frontend/repositories/borrower_repository.dart";

import "../test_config.dart";
import "mock_api_manager.dart";

Matcher throwsExceptionWithMessage(String message) {
  return throwsA(
    isA<Exception>().having(
      (e) => e.toString(),
      "message",
      contains(message),
    ),
  );
}

//
// ignore: type_annotate_public_apis
Map<String, dynamic> decodeRequestBody(body) {
  if (body == null) {
    return <String, dynamic>{};
  }

  if (body is String) {
    return json.decode(body) as Map<String, dynamic>;
  }

  if (body is Map<String, dynamic>) {
    return body;
  }

  if (body is Map) {
    return Map<String, dynamic>.from(body);
  }

  throw UnsupportedError("Unsupported request body type: ${body.runtimeType}");
}

void main() {
  group("BorrowerRepository Tests", () {
    late BorrowerRepository borrowerRepository;
    late MockAPIManager mockAPIManager;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      mockAPIManager = MockAPIManager();
      borrowerRepository = BorrowerRepository(apiManager: mockAPIManager);

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
        final customMockAPIManager = MockAPIManager();

        final repository = BorrowerRepository(
          apiManager: customMockAPIManager,
        );

        expect(repository, isA<BorrowerRepository>());
      });

      test("should use default singleton instance", () {
        final repository = BorrowerRepository.instance;

        expect(repository, isA<BorrowerRepository>());
      });

      test("should maintain singleton behavior with instance getter", () {
        final instance1 = BorrowerRepository.instance;
        final instance2 = BorrowerRepository.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("getCustomerByRim - Success Scenarios", () {
      test("should get customer by rim and parse response", () async {
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

        final result = await borrowerRepository.getCustomerByRim(testRim);

        expect(result, isA<GroupBorrowerSearchResponse>());
        expect(result.responseData?.partyId, equals("MIN123"));
        expect(result.responseData?.partyInfo, isNull);

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getCustomerByRim),
        );
        expect(mockAPIManager.callLog[0]["method"], equals("POST"));

        final requestBody =
            decodeRequestBody(mockAPIManager.callLog[0]["body"]);
        expect(requestBody["requestData"]["PartyId"], equals(testRim));
      });

      test("should handle null user gracefully", () async {
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

        final result = await borrowerRepository.getCustomerByRim(testRim);

        expect(result.responseData?.partyId, equals("NULL_USER"));

        final requestBody =
            decodeRequestBody(mockAPIManager.callLog[0]["body"]);
        expect(requestBody["roleID"], isNull);
        expect(requestBody["role"], isNull);
        expect(requestBody["userID"], isNull);
        expect(requestBody["userName"], isNull);
        expect(requestBody["requestData"]["PartyId"], equals(testRim));
      });

      test("should handle customer with alternative name field", () async {
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        const testRim = 77777;
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "PartyId": "ALT123",
              "rimNo": 77777,
              "name": "Alternative Name Customer",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await borrowerRepository.getCustomerByRim(testRim);

        expect(result.responseData?.partyId, equals("ALT123"));
        expect(result.responseData?.partyInfo, isNull);
      });

      test("should handle empty response body map", () async {
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: <String, dynamic>{},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await borrowerRepository.getCustomerByRim(123);

        expect(result, isA<GroupBorrowerSearchResponse>());
        expect(result.responseData, isNull);
      });
    });

    group("getCustomerByRim - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
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

        expect(
          () async => borrowerRepository.getCustomerByRim(testRim),
          throwsExceptionWithMessage(errorMessage),
        );
      });

      test("should handle API network error", () async {
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        mockAPIManager.setMockException(Exception("Connection failed"));

        expect(
          () async => borrowerRepository.getCustomerByRim(12345),
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
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: "invalid_body",
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => borrowerRepository.getCustomerByRim(12345),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("getCustomerByPotentialRim - Success Scenarios", () {
      test("should return customer when valid profile response is received",
          () async {
        const testRim = 24680;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "PartyId": "POTENTIAL001",
              "rimNo": testRim,
              "customerName": "Potential Customer",
              "PartyInfo": <String, dynamic>{},
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result =
            await borrowerRepository.getCustomerByPotentialRim(testRim);

        expect(result, isA<Customer>());
        expect(result?.id, equals("POTENTIAL001"));
        expect(result?.customerRimNo, equals(testRim));
        expect(result?.customerName, equals("Potential Customer"));

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getCustomerProfile),
        );
        expect(mockAPIManager.callLog[0]["method"], equals("POST"));

        final requestBody =
            decodeRequestBody(mockAPIManager.callLog[0]["body"]);
        expect(requestBody["requestData"]["PartyId"], equals(testRim));
      });
    });

    group("getCustomerByPotentialRim - Error Scenarios", () {
      test("should throw no user found when responseData is null", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": null,
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => borrowerRepository.getCustomerByPotentialRim(10001),
          throwsA(isA<Exception>()),
        );
      });

      test("should throw no user found when responseData is empty", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": <String, dynamic>{},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => borrowerRepository.getCustomerByPotentialRim(10002),
          throwsA(isA<Exception>()),
        );
      });

      test("should throw no user found when PartyInfo is missing", () async {
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "PartyId": "NO_PARTY_INFO",
              "rimNo": 10003,
              "customerName": "No Party Info",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => borrowerRepository.getCustomerByPotentialRim(10003),
          throwsA(isA<Exception>()),
        );
      });

      test("should throw no user found when API returns error status",
          () async {
        final mockResponse = AppResponse(
          message: "Failed",
          body: {
            "error": "Not found",
          },
          code: 404,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () async => borrowerRepository.getCustomerByPotentialRim(10004),
          throwsA(isA<Exception>()),
        );
      });

      test("should wrap API network exception as ApiException", () async {
        mockAPIManager.setMockException(Exception("Profile API timeout"));

        expect(
          () async => borrowerRepository.getCustomerByPotentialRim(10005),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Profile API timeout"),
            ),
          ),
        );
      });
    });

    group("Edge Cases and Integration", () {
      test("should handle mixed success and error responses in sequence",
          () async {
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

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

        const errorMessage = "Customer not found";
        final errorResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Not found"},
          code: 404,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(errorResponse);

        expect(result1.responseData?.partyId, equals("SUCCESS1"));
        expect(result1.responseData?.partyInfo, isNull);

        expect(
          () async => borrowerRepository.getCustomerByRim(22222),
          throwsExceptionWithMessage(errorMessage),
        );

        expect(mockAPIManager.callLog, hasLength(2));
      });
    });
  });
}
