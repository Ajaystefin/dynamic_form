import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_ratio_response.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor_financial_response.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/remarks_repository.dart";
import "mock_api_manager.dart";

void main() {
  late MockAPIManager mockAPIManager;
  late RemarksRepository repository;

  group("RemarksRepository Integration Tests", () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await EnvConfig.setEnvironment();

      mockAPIManager = MockAPIManager();
      repository = RemarksRepository(apiManager: mockAPIManager);

      // Prepare Globals
      Globals.request = Request(applicationRefNo: "APP123");
      Globals.user = User(
        id: "user1",
        name: "Tester",
        currentRole: Role(id: 1, code: "ADMIN", name: "Admin"),
      );
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
    });

    group("Constructor and Initialization", () {
      test("should create instance with default APIManager when none provided",
          () {
        final repo = RemarksRepository.instance;
        expect(repo, isNotNull);
      });

      test("should create instance with provided APIManager", () {
        final repo = RemarksRepository(apiManager: mockAPIManager);
        expect(repo, isNotNull);
      });

      test("should provide singleton instance", () {
        final i1 = RemarksRepository.instance;
        final i2 = RemarksRepository.instance;
        expect(identical(i1, i2), isTrue);
      });
    });

    group("getFinancialDetailsFromCreditLens", () {
      test("returns FinancialDetailsResponse on success", () async {
        // Arrange: stub successful response
        final innerJson = {
          "EntityId": 456,
          "LongName": "Test Corp",
          "ShortName": "TC",
          "statements": <dynamic>[],
          "macros": <String, dynamic>{},
        };
        final fullBody = {"responseData": innerJson};
        final mockResponse = AppResponse(
          message: "OK",
          code: 200,
          status: ResponseStatus.success,
          body: fullBody,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await repository.getFinancialDetailsFromCreditLens(456);

        // Assert
        expect(result, isA<FinancialDetailsResponse>());
        expect(result.longName, equals("Test Corp"));
        expect(result.shortName, equals("TC"));
        expect(result.statements, isEmpty);
        expect(result.macros, isEmpty);

        // verify API call
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getFinancialDataFromCreditLens),
        );
        expect(
          mockAPIManager.callLog[0]["body"],
          containsPair("requestData", 456),
        );
      });

      test("throws when API returns error status", () async {
        // Arrange: stub error response
        final mockError = AppResponse(
          message: "Something went wrong",
          code: 500,
          status: ResponseStatus.error,
          body: <String, dynamic>{},
        );
        mockAPIManager.setMockResponse(mockError);

        // Act & Assert
        expect(
          () => repository.getFinancialDetailsFromCreditLens(789),
          throwsA("Something went wrong"),
        );

        // verify API call was made
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getFinancialDataFromCreditLens),
        );
      });
    });

    group("getFinancialRatioAnalysisDetails", () {
      test("returns FinancialRatioAnalysisResponse on success", () async {
        final innerJson = {
          "customerFinancialsId": 1,
          "appRefNo": "APP123",
          "rimNo": 123,
          "customerName": "Test Customer",
          "descOfAccounts": "Test Desc",
          "entityDetails": [],
          "createdBy": "Admin",
          "createdDate": "2023-01-01T00:00:00.000",
          "updatedBy": "Admin",
          "updatedDate": "2023-01-01T00:00:00.000",
        };
        final fullBody = {"responseData": innerJson};
        final mockResponse = AppResponse(
          message: "OK",
          code: 200,
          status: ResponseStatus.success,
          body: fullBody,
        );
        mockAPIManager.setMockResponse(mockResponse);

        final result =
            await repository.getFinancialRatioAnalysisDetails(rimNo: 123);

        expect(result, isA<FinancialRatioAnalysisResponse>());
        expect(result.customerFinancialsId, equals(1));
        expect(result.rimNo, equals(123));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getFinancialRatioAnalysisDetails),
        );
        expect(
          mockAPIManager.callLog[0]["body"],
          containsPair("requestData", {"appRefNo": "APP123", "rimNo": 123}),
        );
      });

      test("throws when API returns error status", () async {
        final mockError = AppResponse(
          message: "Error fetching details",
          code: 500,
          status: ResponseStatus.error,
          body: <String, dynamic>{},
        );
        mockAPIManager.setMockResponse(mockError);

        expect(
          () => repository.getFinancialRatioAnalysisDetails(rimNo: 123),
          throwsA("Error fetching details"),
        );
      });
    });

    group("saveFinancialRatioAnalysisDetails", () {
      test("returns List<FinancialRatioAnalysisResponse> on success", () async {
        final requestItem = FinancialRatioAnalysisResponse(
          customerFinancialsId: 1,
          appRefNo: "APP123",
          rimNo: 123,
          customerName: "Test Customer",
          descOfAccounts: "Test Desc",
          entityDetails: [],
          createdBy: "Admin",
          createdDate: DateTime(2023),
          updatedBy: "Admin",
          updatedDate: DateTime(2023),
        );
        final responseItemJson = requestItem.toJson();
        final fullBody = {
          "responseData": [responseItemJson],
        };
        final mockResponse = AppResponse(
          message: "OK",
          code: 200,
          status: ResponseStatus.success,
          body: fullBody,
        );
        mockAPIManager.setMockResponse(mockResponse);

        final result = await repository.saveFinancialRatioAnalysisDetails(
          items: [requestItem],
        );

        expect(result, isA<List<FinancialRatioAnalysisResponse>>());
        expect(result, hasLength(1));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.saveFinancialRatioAnalysisDetails),
        );
      });

      test("throws when API returns error status", () async {
        final mockError = AppResponse(
          message: "Error saving details",
          code: 500,
          status: ResponseStatus.error,
          body: <String, dynamic>{},
        );
        mockAPIManager.setMockResponse(mockError);

        expect(
          () => repository.saveFinancialRatioAnalysisDetails(items: []),
          throwsA("Error saving details"),
        );
      });
    });

    group("deleteFinancialRatioAnalysisDetails", () {
      test("returns DeleteFinancialRatioAnalysisResult on success", () async {
        final innerJson = {"status": "Success"};
        final fullBody = {"responseData": innerJson};
        final mockResponse = AppResponse(
          message: "OK",
          code: 200,
          status: ResponseStatus.success,
          body: fullBody,
        );
        mockAPIManager.setMockResponse(mockResponse);

        final result = await repository.deleteFinancialRatioAnalysisDetails(
          rimNo: 123,
          entityId: 456,
          financialsCategory: 1,
          userAddedRatioType: "TypeA",
        );

        expect(result, isA<DeleteFinancialRatioAnalysisResult>());
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.deleteFinancialRatioAnalysisDetails),
        );

        final payload = mockAPIManager.callLog[0]["body"]["requestData"];
        expect(payload["rimNo"], equals("123"));
        expect(payload["entityId"], equals("456"));
        expect(payload["financialsCategory"], equals(1));
        expect(payload["userAddedRatioType"], equals("TypeA"));
      });

      test("throws when API returns error status", () async {
        final mockError = AppResponse(
          message: "Error deleting details",
          code: 500,
          status: ResponseStatus.error,
          body: <String, dynamic>{},
        );
        mockAPIManager.setMockResponse(mockError);

        expect(
          () => repository.deleteFinancialRatioAnalysisDetails(
            rimNo: 123,
            entityId: 456,
            financialsCategory: 1,
          ),
          throwsA("Error deleting details"),
        );
      });
    });

    group("getGuarantorFinancialDetails", () {
      test("returns GuarantorFinancialDetailsResponse on success", () async {
        final innerJson = {
          "guarantorFinancialsId": 101,
          "appRefNo": "APP123",
          "rimNo": 123,
          "customerName": "Guarantor Name",
          "guarantorFinancialsComment": "Comment",
          "entityDetails": [],
          "createdBy": "Admin",
          "createdDate": "2023-01-01T00:00:00.000",
          "updatedBy": "Admin",
          "updatedDate": "2023-01-01T00:00:00.000",
        };
        final fullBody = {"responseData": innerJson};
        final mockResponse = AppResponse(
          message: "OK",
          code: 200,
          status: ResponseStatus.success,
          body: fullBody,
        );
        mockAPIManager.setMockResponse(mockResponse);

        final result =
            await repository.getGuarantorFinancialDetails(rimNo: 123);

        expect(result, isA<GuarantorFinancialDetailsResponse>());
        expect(result.guarantorFinancialsId, equals(101));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getGuarantorFinancialDetails),
        );
        expect(
          mockAPIManager.callLog[0]["body"],
          containsPair("requestData", {"appRefNo": "APP123", "rimNo": 123}),
        );
      });

      test("throws when API returns error status", () async {
        final mockError = AppResponse(
          message: "Error fetching guarantor details",
          code: 500,
          status: ResponseStatus.error,
          body: <String, dynamic>{},
        );
        mockAPIManager.setMockResponse(mockError);

        expect(
          () => repository.getGuarantorFinancialDetails(rimNo: 123),
          throwsA("Error fetching guarantor details"),
        );
      });
    });

    group("saveGuarantorFinancialDetails", () {
      test("returns List<GuarantorFinancialDetailsResponse> on success",
          () async {
        final requestItem = GuarantorFinancialDetailsResponse(
          guarantorFinancialsId: 101,
          appRefNo: "APP123",
          rimNo: 123,
          customerName: "Guarantor Name",
          // guarantorFinancialsComment: 'Comment',
          entityDetails: [],
          createdBy: "Admin",
          createdDate: DateTime(2023),
          updatedBy: "Admin",
          updatedDate: DateTime(2023),
        );
        final responseItemJson = requestItem.toJson();
        final fullBody = {
          "responseData": [responseItemJson],
        };
        final mockResponse = AppResponse(
          message: "OK",
          code: 200,
          status: ResponseStatus.success,
          body: fullBody,
        );
        mockAPIManager.setMockResponse(mockResponse);

        final result = await repository.saveGuarantorFinancialDetails(
          items: [requestItem],
        );

        expect(result, isA<List<GuarantorFinancialDetailsResponse>>());
        expect(result, hasLength(1));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.saveGuarantorFinancialDetails),
        );
      });

      test("throws when API returns error status", () async {
        final mockError = AppResponse(
          message: "Error saving guarantor details",
          code: 500,
          status: ResponseStatus.error,
          body: <String, dynamic>{},
        );
        mockAPIManager.setMockResponse(mockError);

        expect(
          () => repository.saveGuarantorFinancialDetails(items: []),
          throwsA("Error saving guarantor details"),
        );
      });
    });

    group("deleteGuarantorDetails", () {
      test("returns DeleteFinancialRatioAnalysisResult on success", () async {
        final innerJson = {"status": "Success"};
        final fullBody = {"responseData": innerJson};
        final mockResponse = AppResponse(
          message: "OK",
          code: 200,
          status: ResponseStatus.success,
          body: fullBody,
        );
        mockAPIManager.setMockResponse(mockResponse);

        final result = await repository.deleteGuarantorDetails(
          rimNo: 123,
          entityId: 456,
          financialsCategory: 2,
          userAddedRatioType: "TypeB",
        );

        expect(result, isA<DeleteFinancialRatioAnalysisResult>());
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.deleteGuarantorDetails),
        );

        final payload = mockAPIManager.callLog[0]["body"]["requestData"];
        expect(payload["rimNo"], equals("123"));
        expect(payload["entityId"], equals("456"));
        expect(payload["financialsCategory"], equals(2));
        expect(payload["userAddedRatioType"], equals("TypeB"));
      });

      test("throws when API returns error status", () async {
        final mockError = AppResponse(
          message: "Error deleting guarantor details",
          code: 500,
          status: ResponseStatus.error,
          body: <String, dynamic>{},
        );
        mockAPIManager.setMockResponse(mockError);

        expect(
          () => repository.deleteGuarantorDetails(
            rimNo: 123,
            entityId: 456,
            financialsCategory: 2,
          ),
          throwsA("Error deleting guarantor details"),
        );
      });
    });
  });
}
