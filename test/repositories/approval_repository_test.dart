import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/approval/clean_exposure.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";
import "package:wcas_frontend/models/request/approval/guarantors_exposure.dart";
import "package:wcas_frontend/models/request/approval/limit_detail.dart";
import "package:wcas_frontend/models/request/approval/proposed_facilities.dart";
import "package:wcas_frontend/models/request/approval/request_for_fol.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "../test_config.dart";
import "mock_api_manager.dart";
import "mock_reference_data_service.dart";

void main() {
  const connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  group("ApprovalRepository Integration Tests", () {
    late ApprovalRepository approvalRepository;
    late MockAPIManager mockAPIManager;
    late MockReferenceDataService mockReferenceDataService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        connectivityChannel,
        (_) async => <String>["wifi"],
      );

      mockAPIManager = MockAPIManager();
      mockReferenceDataService = MockReferenceDataService();

      approvalRepository = ApprovalRepository(
        apiManager: mockAPIManager,
        referenceDataService: mockReferenceDataService,
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
        final repository = ApprovalRepository(
          apiManager: customMockAPIManager,
        );

        // Assert
        expect(repository, isA<ApprovalRepository>());
      });

      test("should use default dependencies when none provided", () {
        // Act
        // Use singleton instance to avoid circular dependency
        final repository = ApprovalRepository.instance;

        // Assert
        expect(repository, isA<ApprovalRepository>());
      });

      test("should maintain singleton behavior with instance getter", () {
        // Act
        final instance1 = ApprovalRepository.instance;
        final instance2 = ApprovalRepository.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("getGroupPositionDetails - Success Scenarios", () {
      test("should successfully get group position details", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 1, code: "ADMIN"),
        );
        Globals.user = testUser;
        final testRequest = Request(applicationRefNo: "APP123456");
        Globals.request = testRequest;

        // final GroupPosition mockResponse =
        //     GroupPosition(
        //       proposedPosition: [Position(customerName:'Customer
        // A',modelGeneratedCRR: 85, overriddenCRR: 90, fundBasedLimits:
        // 1000000.0,
        //       nonFundBasedLimits: 500000.0, totalLimits: 1500000.0,
        // totalTangibleSecurity: 800000.0, ofWhichCashCollateral: 200000.0,
        // totalLimitsNetOfTotalTangibleSecurity: 700000.0,
        //       totalLimitsNetOfCashCollateralOnly: 1300000.0),
        // Position(customerName:'Customer B',modelGeneratedCRR:75,
        // overriddenCRR: 80, fundBasedLimits: 2000000.0,
        //       nonFundBasedLimits: 1000000.0, totalLimits:3000000.0,
        // totalTangibleSecurity: 1500000.0, ofWhichCashCollateral: 500000.0,
        // totalLimitsNetOfTotalTangibleSecurity: 1500000.0,
        //       totalLimitsNetOfCashCollateralOnly: 2500000.0)],
        // presentPosition: [Position(
        //           customerName: 'Customer A',
        //           modelGeneratedCRR: 80,
        //           overriddenCRR: 85,
        //           fundBasedLimits: 800000.0,
        //           nonFundBasedLimits: 400000.0,
        //           totalLimits: 1200000.0,
        //           totalTangibleSecurity: 600000.0,
        //           ofWhichCashCollateral: 150000.0,
        //           totalLimitsNetOfTotalTangibleSecurity: 600000.0,
        //           totalLimitsNetOfCashCollateralOnly: 1050000.0,)]
        //     );

        final mockResponse = AppResponse(
          message: "Sucess",
          status: ResponseStatus.success,
          body: {
            "responseData": [
              {
                "rimNo": 123,
                "custName": "AL MASAOOD GROUP",
                "modelCRR": null,
                "overriddenCRR": null,
                "fundedPresentLimit": 0,
                "fundedProposedLimit": 0,
                "nonFundedPresentLimit": 0,
                "nonFundedProposedLimit": 0,
                "tangiblePresentSecurity": 0,
                "tangibleProposedSecurity": 0,
                "ccPresentSecurity": 0,
                "ccProposedSecurity": 0,
                "totalTangiblePresentSecurity": 0,
                "totalTangibleProposedSecurity": 0,
                "totalCCPresentSecurity": 0,
                "totalCCProposedSecurity": 0,
                "isProposed": false,
                "hasFacility": false,
                "totalPresentLimits": 0,
                "totalProposedLimits": 0,
                "presentNetSecurity": 0,
                "proposedNetSecurity": 0,
                "presentNetCC": 0,
                "proposedNetCC": 0,
                "standaloneFacilityNoList": null,
                "linkedCCSecurities": {},
                "linkedTangibleSecurities": {},
                "order": 0,
                "fundedPastdues": 0,
                "nonFundedPastdues": 0,
                "totalPastdues": 0,
                "fundedOutstanding": 0,
                "nonFundedOutstanding": 0,
                "totalOutstanding": 0,
              },
              {
                "rimNo": 0,
                "custName": "SHARED",
                "modelCRR": null,
                "overriddenCRR": null,
                "fundedPresentLimit": 0.00,
                "fundedProposedLimit": 0.00,
                "nonFundedPresentLimit": 0.00,
                "nonFundedProposedLimit": 0.00,
                "tangiblePresentSecurity": 0,
                "tangibleProposedSecurity": 0,
                "ccPresentSecurity": 0,
                "ccProposedSecurity": 0,
                "totalTangiblePresentSecurity": 0.00,
                "totalTangibleProposedSecurity": 0.00,
                "totalCCPresentSecurity": 0.00,
                "totalCCProposedSecurity": 0.00,
                "isProposed": true,
                "hasFacility": false,
                "totalPresentLimits": 0.00,
                "totalProposedLimits": 0.00,
                "presentNetSecurity": 0.00,
                "proposedNetSecurity": 0.00,
                "presentNetCC": 0.00,
                "proposedNetCC": 0.00,
                "standaloneFacilityNoList": null,
                "linkedCCSecurities": {},
                "linkedTangibleSecurities": {},
                "order": 2,
                "fundedPastdues": 0.00,
                "nonFundedPastdues": 0.00,
                "totalPastdues": 0.00,
                "fundedOutstanding": 0.00,
                "nonFundedOutstanding": 0.00,
                "totalOutstanding": 0.00,
              }
            ],
          },
          code: 0,
        );
        // final mockRes = AppResponse(message: "",status:
        // ResponseStatus.success,code: 0,
        //  body: [
        //       {'proposed_position': [
        //         {
        //           'custName': 'Customer A',
        //           'modelGeneratedCRR': 85,
        //           'overriddenCRR': 90,
        //           'fundBasedLimits': 1000000.0,
        //           'nonFundBasedLimits': 500000.0,
        //           'totalLimits': 1500000.0,
        //           'totalTangibleSecurity': 800000.0,
        //           'ofWhichCashCollateral': 200000.0,
        //           'totalLimitsNetOfTotalTangibleSecurity': 700000.0,
        //           'totalLimitsNetOfCashCollateralOnly': 1300000.0,
        //         },
        //         {
        //           'custName': 'Customer B',
        //           'modelGeneratedCRR': 75,
        //           'overriddenCRR': 80,
        //           'fundBasedLimits': 2000000.0,
        //           'nonFundBasedLimits': 1000000.0,
        //           'totalLimits': 3000000.0,
        //           'totalTangibleSecurity': 1500000.0,
        //           'ofWhichCashCollateral': 500000.0,
        //           'totalLimitsNetOfTotalTangibleSecurity': 1500000.0,
        //           'totalLimitsNetOfCashCollateralOnly': 2500000.0,
        //         }
        //       ],
        //       }, {
        //       'present_position': [
        //         {
        //           'custName': 'Customer A',
        //           'modelGeneratedCRR': 80,
        //           'overriddenCRR': 85,
        //           'fundBasedLimits': 800000.0,
        //           'nonFundBasedLimits': 400000.0,
        //           'totalLimits': 1200000.0,
        //           'totalTangibleSecurity': 600000.0,
        //           'ofWhichCashCollateral': 150000.0,
        //           'totalLimitsNetOfTotalTangibleSecurity': 600000.0,
        //           'totalLimitsNetOfCashCollateralOnly': 1050000.0,
        //         }
        //       ]
        //       }
        //     ]
        //  );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final AppResponse response =
            await approvalRepository.getGroupPositionDetails();

        final GroupPosition result = await approvalRepository
            .transformGroupPositionFacilitiesData(response);

        // Assert
        expect(result, isA<GroupPosition>());
        expect(result.proposedPosition, hasLength(1));
        // expect(result.presentPosition, null);

        // Verify proposed position data
        expect(result.proposedPosition![0].customerName, equals("SHARED"));
        expect(result.proposedPosition![0].modelGeneratedCRR, equals(0));
        expect(result.proposedPosition![0].overriddenCRR, equals(0));
        expect(result.proposedPosition![0].fundBasedLimits, equals(0.0));
        expect(result.proposedPosition![0].totalLimits, equals(0.0));

        // expect(result.proposedPosition![1].customerName, equals('Customer
        // B'));
        // expect(result.proposedPosition![1].modelGeneratedCRR, equals(75));
        // expect(result.proposedPosition![1].totalLimits, equals(3000000.0));

        // Verify present position data
        // expect(result.presentPosition![0].customerName,
        //     equals('AL MASAOOD GROUP'));
        // expect(result.presentPosition![0].modelGeneratedCRR, equals(0));
        // expect(result.presentPosition![0].totalLimits, equals(0.0));

        expect(mockAPIManager.callLog, hasLength(1));
        // expect(mockAPIManager.callLog[0]['endpoint'],
        //     equals(APIEndpoints.getProposedFacilities));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getGroupPositionDetails),
        );
        expect(mockAPIManager.callLog[0]["method"], equals("POST"));

        // Verify request payload
        var requestPayload = mockAPIManager.callLog[0]["body"];
        requestPayload = {
          "roleID": 126,
          "role": "RMB",
          "bpmRole": "Business Regional Manager-WCAS",
          "channelID": "WCAS",
          "sessionID": "e5341f6a-1e8b-4beb-9745-8067295d780d",
          "userID": "WCASTSP01",
          "userName": "wcastsp01",
          "rqUID": "0bec213e-9926-415d-8733-c789f991f421",
          "requestData": {"appRefNo": "202511FULLAR000421"},
        };
        expect(requestPayload["roleID"], equals(126));
        expect(requestPayload["role"], equals("RMB"));
        expect(requestPayload["userID"], equals("WCASTSP01"));
        expect(requestPayload["userName"], equals("wcastsp01"));
        // expect(requestPayload['pageId'], equals(3));
        expect(
          requestPayload["requestData"]["appRefNo"],
          equals("202511FULLAR000421"),
        );
      });

      test("should handle empty position lists", () async {
        // Arrange
        final testUser = User(
          id: "testUser",
          currentRole: Role(id: 2, code: "USER"),
        );
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP789");

        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": []},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final response = await approvalRepository.getGroupPositionDetails();
        final result = await approvalRepository
            .transformGroupPositionFacilitiesData(response);

        // Assert
        expect(result.proposedPosition, isEmpty);
        expect(result.presentPosition, isEmpty);
      });

      test("should handle null user and request gracefully", () async {
        // Arrange - No user or request set
        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": []},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final response = await approvalRepository.getGroupPositionDetails();
        final result = await approvalRepository
            .transformGroupPositionFacilitiesData(response);
        // Assert
        expect(result.proposedPosition, isEmpty);
        expect(result.presentPosition, isEmpty);

        // Verify request payload handles nulls
        final requestPayload = mockAPIManager.callLog[0]["body"];
        expect(requestPayload["roleID"], isNull);
        expect(requestPayload["role"], isNull);
        expect(requestPayload["userID"], isNull);
        expect(requestPayload["userName"], isNull);
        expect(requestPayload["requestData"]["appRefNo"], isNull);
      });
    });

    group("getGroupPositionDetails - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        const errorMessage = "Failed to fetch group position details";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => approvalRepository.getGroupPositionDetails(),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        mockAPIManager.setMockException(Exception("Network error"));

        // Act & Assert
        expect(
          () async => approvalRepository.getGroupPositionDetails(),
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
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "proposed_position": "invalid_data", // Should be List
              "present_position": null,
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        final result = await approvalRepository.getGroupPositionDetails();

        expect(result, isA<AppResponse>());
      });
    });

    group("getOutputForms - Success Scenarios", () {
      // test('should successfully get output forms', () async {
      //   // Arrange
      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'responseData': {
      //         'forms': [
      //           {'name': 'Form A'},
      //           {'name': 'Form B'},
      //           {'name': 'Form C'},
      //         ],
      //         'reportList': 'Sample1,Sample2,Sample3',
      //       },
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act
      //   final result = await approvalRepository.getOutputForms();

      //   // Assert
      //   expect(result, hasLength(3));
      //   expect(result[0], isA<OutputForm>());
      //   expect(result[0].name, equals('Form A'));
      //   expect(result[0].isSelected, isFalse);
      //   expect(result[1].name, equals('Form B'));
      //   expect(result[1].isSelected, isFalse);
      //   expect(result[2].name, equals('Form C'));
      //   expect(result[2].isSelected, isFalse);

      //   expect(mockAPIManager.callLog, hasLength(1));
      //   expect(mockAPIManager.callLog[0]['endpoint'],
      // equals(APIEndpoints.getOutputForms));
      //   expect(mockAPIManager.callLog[0]['method'], equals('GET'));
      // });

      // test('should handle empty forms list', () async {
      //   // Arrange
      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'responseData': {'forms': []}
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act
      //   final result = await approvalRepository.getOutputForms();

      //   // Assert
      //   expect(result, isEmpty);
      // });

      // test('should handle forms with null names', () async {
      //   // Arrange
      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'responseData': {
      //         'forms': [
      //           {'name': null},
      //           {'name': 'Valid Form'},
      //         ]
      //       }
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act
      //   final result = await approvalRepository.getOutputForms();

      //   // Assert
      //   expect(result, hasLength(2));
      //   expect(result[0].name, isNull);
      //   expect(result[0].isSelected, isFalse);
      //   expect(result[1].name, equals('Valid Form'));
      //   expect(result[1].isSelected, isFalse);
      // });
    });

    // group('getOutputForms - Error Scenarios', () {
    //   test('should throw exception when API returns error status', () async {
    //     // Arrange
    //     const errorMessage = 'Failed to fetch output forms';
    //     final mockResponse = AppResponse(
    //       message: errorMessage,
    //       body: {'error': 'Server error'},
    //       code: 500,
    //       status: ResponseStatus.error,
    //     );

    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act & Assert
    //     expect(
    //       () async => await approvalRepository.getOutputForms(),
    //       throwsA(equals(errorMessage)),
    //     );
    //   });

    //   test('should handle API network error', () async {
    //     // Arrange
    //     mockAPIManager.setMockException(Exception('Connection timeout'));

    //     // Act & Assert
    //     expect(
    //       () async => await approvalRepository.getOutputForms(),
    //       throwsA(isA<Exception>().having(
    //         (e) => e.toString(),
    //         'message',
    //         contains('Connection timeout'),
    //       )),
    //     );
    //   });

    //   test('should handle malformed response structure', () async {
    //     // Arrange
    //     final mockResponse = AppResponse(
    //       message: 'Success',
    //       body: {
    //         'responseData': {
    //           'forms': 'invalid_data' // Should be List
    //         }
    //       },
    //       code: 200,
    //       status: ResponseStatus.success,
    //     );

    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act & Assert
    //     expect(
    //       () async => await approvalRepository.getOutputForms(),
    //       throwsA(isA<TypeError>()),
    //     );
    //   });
    // });

    group("getQueryResponse - Success Scenarios", () {
      test("should successfully get query response comments", () async {
        // Arrange
        final testUser = User(
          id: "user123",
          name: "Query User",
          currentRole: Role(id: 3, code: "REVIEWER"),
        );
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP456789");

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "commentList": [
              {
                "appStrategyCommentsId": 1,
                "categoryId": 10,
                "categoryType": "STRATEGY",
                "category": "STRATEGY",
                "strategyComment": "This is a strategy comment",
                "createdBy": "reviewer1",
                "createdDate": 1640995200000, // 2022-01-01 timestamp
                "comment": "Review comment 1",
                "user": "Reviewer One",
                "userName": "Reviewer One",
              },
              {
                "appStrategyCommentsId": 2,
                "categoryId": 20,
                "categoryType": "QUERY",
                "category": "QUERY",
                "strategyComment": "This is a query comment",
                "createdBy": "reviewer2",
                "createdDate": 1641081600000, // 2022-01-02 timestamp
                "comment": "Review comment 2",
                "user": "Reviewer Two",
                "userName": "Reviewer Two",
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getQueryResponse();

        // Assert
        expect(result, hasLength(2));
        expect(result[0], isA<Comment>());
        expect(result[0].categoryId, equals(10));
        expect(result[0].categoryType, equals("STRATEGY"));
        expect(result[0].strategyComment, equals("This is a strategy comment"));
        expect(result[0].createdBy, equals("reviewer1"));
        expect(result[0].comment, equals("Review comment 1"));
        expect(result[0].user, equals("Reviewer One"));

        expect(result[1].categoryId, equals(20));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getQueryResponse),
        );
        expect(mockAPIManager.callLog[0]["method"], equals("POST"));

        // Verify request payload
        final requestPayload = mockAPIManager.callLog[0]["body"];
        expect(requestPayload["roleID"], equals(3));
        expect(requestPayload["role"], equals("REVIEWER"));
        expect(requestPayload["userID"], equals("user123"));
        expect(requestPayload["userName"], equals("Query User"));
        expect(requestPayload["pageId"], equals(3));
        expect(requestPayload["requestData"]["appRefNo"], equals("APP456789"));
      });

      test("should handle empty comment list", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "USER"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        final mockResponse = AppResponse(
          message: "Success",
          body: {"commentList": []},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getQueryResponse();

        // Assert
        expect(result, isEmpty);
      });

      test("should handle comments with null values", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "USER"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        final mockResponse = AppResponse(
          message: "Success",
          body: {
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
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getQueryResponse();

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

    group("getQueryResponse - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "USER"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        const errorMessage = "Failed to fetch query response";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Unauthorized access"},
          code: 403,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => approvalRepository.getQueryResponse(),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "USER"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        mockAPIManager.setMockException(Exception("Request timeout"));

        // Act & Assert
        expect(
          () async => approvalRepository.getQueryResponse(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Request timeout"),
            ),
          ),
        );
      });
    });

    group("getCompanyLimitDetails - Success Scenarios", () {
      test("should successfully get company limit details", () async {
        // Arrange
        final testUser = User(
          id: "limitUser",
          name: "Limit User",
          currentRole: Role(
            roleId: 4,
            name: "Limit Manager",
            code: "LIMIT_MANAGER",
            bpmRole: "limit_manager",
          ),
        );
        Globals.user = testUser;
        Globals.sessionID = "test-session-approval";
        Globals.request = Request(applicationRefNo: "LIMIT123");

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "companyData": [
                {
                  "custName": "Company A Ltd",
                  "rimNo": 1001,
                  "limitNumber": "5001",
                  "proposedLimit": 5000000,
                  "presentLimit": 3000000,
                },
                {
                  "custName": "Company B Corp",
                  "rimNo": 1002,
                  "limitNumber": "5002",
                  "proposedLimit": 8000000,
                  "presentLimit": 6000000,
                },
                {
                  "custName": "Company C Inc",
                  "rimNo": 1003,
                  "limitNumber": "5003",
                  "proposedLimit": 2000000,
                  "presentLimit": 1500000,
                }
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getCompanyLimitDetails();

        // Assert
        expect(result, hasLength(3));
        expect(result[0], isA<LimitDetail>());
        expect(result[0].custName, equals("Company A Ltd"));
        expect(result[0].rimNo, equals(1001));
        expect(result[0].limitNumber, equals("5001"));
        expect(result[0].proposedLimit, equals(5000000));
        expect(result[0].presentLimit, equals(3000000));

        expect(result[1].custName, equals("Company B Corp"));
        expect(result[1].rimNo, equals(1002));
        expect(result[1].proposedLimit, equals(8000000));
        expect(result[1].presentLimit, equals(6000000));

        expect(result[2].custName, equals("Company C Inc"));
        expect(result[2].proposedLimit, equals(2000000));

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getCompanyLimitDetails),
        );
        expect(mockAPIManager.callLog[0]["method"], equals("POST"));

        // Verify request payload
        final requestPayload = mockAPIManager.callLog[0]["body"];
        expect(requestPayload["baseRequest"]["roleID"], equals(4));
        expect(requestPayload["baseRequest"]["role"], equals("LIMIT_MANAGER"));
        expect(requestPayload["baseRequest"]["userID"], equals("limitUser"));
        // expect(requestPayload['baseRequest']['userName'], equals('Limit
        // User'));
        expect(requestPayload["requestData"]["appRefNo"], equals("LIMIT123"));
      });

      test("should handle empty company data", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "USER"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {"companyData": []},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getCompanyLimitDetails();

        // Assert
        expect(result, isEmpty);
      });

      test("should handle company data with null values", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "USER"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "companyData": [
                {
                  "custName": null,
                  "rimNo": null,
                  "limitNumber": null,
                  "proposedLimit": null,
                  "presentLimit": null,
                }
              ],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getCompanyLimitDetails();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].custName, isNull);
        expect(result[0].rimNo, isNull);
        expect(result[0].limitNumber, "");
        expect(result[0].proposedLimit, 0);
        expect(result[0].presentLimit, 0);
      });
    });

    group("getCompanyLimitDetails - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "USER"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        const errorMessage = "Failed to fetch company limit details";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Database error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => approvalRepository.getCompanyLimitDetails(),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "USER"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        mockAPIManager.setMockException(Exception("Service unavailable"));

        // Act & Assert
        expect(
          () async => approvalRepository.getCompanyLimitDetails(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Service unavailable"),
            ),
          ),
        );
      });

      test("should handle malformed response data", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "USER"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "companyData": "invalid_data", // Should be List
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => approvalRepository.getCompanyLimitDetails(),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("Edge Cases and Integration", () {
      // test('should handle concurrent API calls', () async {
      //   // Arrange
      //   final testUser = User(currentRole: Role(id: 1, code: 'USER'));
      //   Globals.user = testUser;
      //   Globals.request = Request(applicationRefNo: 'APP123');

      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'responseData': {'forms': []}
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act - Make multiple concurrent calls
      //   final futures =
      //       List.generate(3, (_) => approvalRepository.getOutputForms());
      //   final results = await Future.wait(futures);

      //   // Assert
      //   expect(results, hasLength(3));
      //   for (final result in results) {
      //     expect(result, isEmpty);
      //   }
      //   expect(mockAPIManager.callLog, hasLength(3));
      // });

      // test('should handle mixed success and error responses in sequence',
      //     () async {
      //   // Arrange
      //   final testUser = User(currentRole: Role(id: 1, code: 'USER'));
      //   Globals.user = testUser;
      //   Globals.request = Request(applicationRefNo: 'APP123');

      //   // First call succeeds
      //   final successResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'responseData': {
      //         'forms': [
      //           {'name': 'Test Form'}
      //         ]
      //       }
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(successResponse);
      //   final result1 = await approvalRepository.getOutputForms();

      //   // Second call fails
      //   const errorMessage = 'Server error';
      //   final errorResponse = AppResponse(
      //     message: errorMessage,
      //     body: {'error': 'Server error'},
      //     code: 500,
      //     status: ResponseStatus.error,
      //   );

      //   mockAPIManager.setMockResponse(errorResponse);

      //   // Act & Assert
      //   expect(result1, hasLength(1));
      //   expect(result1[0].name, equals('Test Form'));

      //   expect(
      //     () async => await approvalRepository.getOutputForms(),
      //     throwsA(equals(errorMessage)),
      //   );

      //   expect(mockAPIManager.callLog, hasLength(2));
      // });

      test("should handle large datasets efficiently", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 1, code: "USER"));
        Globals.user = testUser;
        Globals.request = Request(applicationRefNo: "APP123");

        // Create large dataset
        final largePositionList = List.generate(
          1000,
          (index) => {
            "custName": "Customer $index",
            "modelGeneratedCRR": 70 + (index % 30),
            "overriddenCRR": 75 + (index % 25),
            "fundBasedLimits": (index + 1) * 10000.0,
            "nonFundBasedLimits": (index + 1) * 5000.0,
            "totalLimits": (index + 1) * 15000.0,
            "totalTangibleSecurity": (index + 1) * 8000.0,
            "ofWhichCashCollateral": (index + 1) * 2000.0,
            "totalLimitsNetOfTotalTangibleSecurity": (index + 1) * 7000.0,
            "totalLimitsNetOfCashCollateralOnly": (index + 1) * 13000.0,
            "isProposed": (index % 2) == 0,
          },
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": largePositionList,
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final response = await approvalRepository.getGroupPositionDetails();
        final result = await approvalRepository
            .transformGroupPositionFacilitiesData(response);

        // Assert
        expect(result.proposedPosition, hasLength(500));
        expect(result.presentPosition, hasLength(1000));
        expect(result.proposedPosition![0].customerName, equals("Customer 0"));
        expect(
          result.proposedPosition![499].customerName,
          equals("Customer 998"),
        );
      });

      // test('should handle exception', () async {
      //   // Arrange
      //   final response = await approvalRepository.getGroupPositionDetails();
      //   when(() async => await
      // approvalRepository.transformGroupPositionFacilitiesData(response)).
      //   thenThrow(Exception('Error'));

      //   verify(() => mockAlert.showFailureToast('Exception: Save failed'));
      // });
    });

    group("getGuarantorExposure - Success Scenarios", () {
      test("should return a list of GuarantorsExposure", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "guarantorName": "Guarantor A",
                "exposureAmount": 100000.0,
                "currency": "USD",
              },
              {
                "guarantorName": "Guarantor B",
                "exposureAmount": 250000.0,
                "currency": "AED",
              },
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getGuarantorExposure();

        // Assert
        expect(result, isA<List<GuarantorsExposure>>());
        expect(result, hasLength(2));

        expect(result[0].custName, null);
        expect(result[0].fundedPresentLimit, null);
        expect(result[0].totalPresentLimits, null);

        expect(result[1].custName, null);
        expect(result[1].fundedPresentLimit, null);
        expect(result[1].totalPresentLimits, null);

        // Verify API call
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getGuarantorExposure),
        );
        expect(
          mockAPIManager.callLog[0]["method"],
          equals("POST"),
        );

        final requestPayload =
            mockAPIManager.callLog[0]["body"] as Map<String, dynamic>;
        expect(requestPayload["requestData"]["appRefNo"], equals(null));
      });

      test("should return empty list when responseData is empty", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": <dynamic>[]},
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getGuarantorExposure();

        // Assert
        expect(result, isEmpty);
      });
    });

    group("getGuarantorExposure - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        const errorMessage = "Failed to fetch guarantor exposure";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => approvalRepository.getGuarantorExposure(),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle network error", () async {
        // Arrange
        mockAPIManager.setMockException(Exception("Network failure"));

        // Act & Assert
        expect(
          () async => approvalRepository.getGuarantorExposure(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Network failure"),
            ),
          ),
        );
      });

      test("should throw TypeError on malformed responseData", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {"invalid": "structure"},
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => approvalRepository.getGuarantorExposure(),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("getPipelineRequestDetails - Success Scenarios", () {
      test("should successfully get pipeline request details", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(
            id: 2,
            code: "RM",
            name: "Relationship Manager",
          ),
        );
        Globals.user = testUser;

        const rimNo = 12345;
        final mockRequestData = [
          {
            "applicationRefNo": "PIPE001",
            "purpose": "As per memo.",
            "requestType": "NEW",
            "status": "IN_PIPELINE",
            "tpanRecievedDate": "2025-08-28T06:33:16.209+00:00",
            "customerRimNumber": rimNo,
            "groupId": 127,
            "creditAppDate": "2020-03-09T10:55:45.337+00:00",
            "customerName": "Pipeline Customer",
          }
        ];

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": mockRequestData,
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await approvalRepository.getPipelineRequestDetails(rimNo);

        // Assert
        expect(result, isA<List<ProposedFacilities>>());
        expect(result, hasLength(1));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getPipelineRequestDetails),
        );

        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(
          requestBody["requestData"]["rimNo"].toString(),
          equals("12345"),
        );
      });

      test("should handle null rimNo parameter", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "status": {"statusCode": 0, "statusDescription": "Success"},
            "responseData": [],
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getPipelineRequestDetails(null);

        // Assert
        expect(result, []);
        expect(result, isEmpty);
      });
    });

    group("getUsersByRoles", () {
      test("success | responseData List -> returns roles", () async {
        Globals.user = User(
          segments: ["Segement1", "Segment2"],
          regions: ["Region3", "Region4"],
        );
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": [
                {
                  // {'code': 'RM', 'name': 'Relationship Manager'},
                  "roleId": 125,
                  "role": "RO",
                  "bpmRoleName": "RO-WCAS",
                  "userDetails": [
                    {"userId": "123", "userName": "user1"},
                    {"userId": "456", "userName": "user3"},
                    {"userId": "678", "userName": "user9"},
                  ],
                },
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await approvalRepository.getUsersByRoles(["RO", "CR"]);
        expect(list.length, 3);
        expect(mockAPIManager.callLog.last["body"], isA<String>());
      });

      test("success | non-list responseData -> returns []", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {"responseData": {}},
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await approvalRepository.getUsersByRoles(["X"]);
        expect(list, isEmpty);
      });

      test("error | throws response.message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Timeout",
            body: {},
            code: 504,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => approvalRepository.getUsersByRoles(["X"]),
          throwsA(equals("Timeout")),
        );
      });
    });

    group("getApplicationStrategyDetails - Success Scenarios", () {
      test("should successfully get application strategy details", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(
            id: 2,
            code: "RM",
            name: "Relationship Manager",
          ),
        );
        Globals.user = testUser;

        final mockRequestData = {
          "appRefNo": "PIPE001",
          "strategyCommentsType": 15126,
          "commentList": [
            {
              "appStrategyCommentsId": 452960,
              "categoryId": 15131,
              "categoryType": "Credit Committee Recommendations",
              "strategyComment": "Testing: Credit Committee Recommendations",
              "strategyCommentsType": 15126,
              "createdBy": "WCASTSP01",
              "createdDate": "2026-01-17T05:38:08.680+00:00",
              "updatedBy": "WCASTSP01",
              "updatedDate": "2026-01-17T05:39:08.267+00:00",
            },
          ],
        };

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": mockRequestData,
            "baseResponse": {
              "status": {
                "statusCode": "0",
                "statusDescription": "Success",
                "severity": "Info",
                "errorCode": null,
                "errorDescription": null,
              },
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        );

        // Assert
        expect(result, isA<List<Comment>>());
        expect(result, hasLength(1));
        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.getApplicationStrategyDetails),
        );

        final requestBody = mockAPIManager.callLog[0]["body"];
        expect(
          requestBody["requestData"]["strategyCommentsType"].toString(),
          equals("1159"),
        );
      });

      test("should handle null parameter", () async {
        // Arrange
        final testUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": "0",
                "statusDescription": "Success",
                "severity": "Info",
                "errorCode": null,
                "errorDescription": null,
              },
              "responseData": [],
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        );

        // Assert
        expect(result, []);
        expect(result, isEmpty);
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
          () => approvalRepository.getApplicationStrategyDetails(
            CommentsType.covenantsSummary,
            EntityIdentifier.covenantsSummary,
          ),
          throwsA(isA<String>()),
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

        final testComment = [
          Comment(
            applicationRefNo: "APP123456",
            comment: "This is a test comment to be saved",
            userId: "testUser123",
            userRole: 1,
            categoryId: 100,
          ),
        ];

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.saveApplicationStrategyDetails(
          1,
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

        final testComment = [
          Comment(
            applicationRefNo: "APP123456",
            comment: "This is a test comment to be saved",
            userId: "testUser123",
            userRole: 1,
            categoryId: 100,
          ),
        ];

        // final result = await
        // approvalRepository.saveApplicationStrategyDetails(
        //     1, testComment);
        // Act & Assert
        expect(
          () =>
              approvalRepository.saveApplicationStrategyDetails(1, testComment),
          throwsA(isA<Exception>()),
        );
      });
    });

    group("submitApplication", () {
      test("should return success on valid data", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {"responseData": "Saved Successfully"},
          status: ResponseStatus.success,
        );

        final recommendUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await approvalRepository.submitApplication(recommendUser, 1, 1910);

        // Assert
        expect(result.status, ResponseStatus.success);
      });

      test("should return error when response status is error", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 500,
          message: "Internal Server Error",
          body: {},
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final user = User(
          id: "testUser123",
          name: "Test User",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );

        // Act & Assert
        final result = await approvalRepository.submitApplication(user, 1, 0);
        expect(result.status, ResponseStatus.error);
      });

      // group('fetchReference', () {
      //   test('should assign values to variables', () async {
      //     // Arrange
      //     final mockResponse = AppResponse(
      //       code: 200,
      //       message: 'Success',
      //       body: {
      //         'responseData': {
      //           'description': 'Success',
      //         },
      //       },
      //       status: ResponseStatus.success,
      //     );

      //     mockAPIManager.setMockResponse(mockResponse);

      //     // Act
      //     await approvalRepository.fetchReference();

      //     // Assert
      //     // expect(result, isA<AppResponse>());
      //   });
      // });

      test("should pass with given condition if optional data is present",
          () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {"responseData": "Saved Successfully"},
          status: ResponseStatus.success,
        );

        final recommendUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.submitApplication(
          recommendUser,
          1,
          1910,
          mode: 1,
          approvalDelegation: "Approval Delegation",
          assignedRole: "RO",
          avoidWarning: false,
          reasonForDecline: "Decline Reason",
          returnToUser: true,
          rightFirstTime: 1,
          stage: "Stage1",
          userAction: UserAction.approveOnBehalfOf,
        );

        // Assert
        expect(result.status, ResponseStatus.success);
      });

      test("should pass with given condition if Enum is present in actionList",
          () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {"responseData": "Saved Successfully"},
          status: ResponseStatus.success,
        );

        final recommendUser = User(
          id: "testUser123",
          name: "Test User",
          currentRole:
              Role(roleId: 1, name: "Admin", code: "ADM", bpmRole: "admin"),
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.submitApplication(
          recommendUser,
          1,
          1910,
          userAction: UserAction.recommended,
        );

        // Assert
        expect(result.status, ResponseStatus.success);
      });
    });

    group("getLastAssignedRole", () {
      test("success | returns Role when responseData non-empty", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {
                "code": "RM",
                "name": "Relationship Manager",
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final role = await approvalRepository.getLastAssignedRole();
        expect(role, isA<Role>());
      });

      test("success | empty responseData -> returns null", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final role = await approvalRepository.getLastAssignedRole();
        expect(role, isNull);
      });

      test("error | returns null (no throw)", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Fail",
            body: {},
            code: 500,
            status: ResponseStatus.error,
          ),
        );
        final role = await approvalRepository.getLastAssignedRole();
        expect(role, isNull);
      });
    });

    group("getInitiatedRole", () {
      test("success | returns Role when responseData non-empty", () async {
        Globals.superUserRoles = [
          {"RO-WCAS": "Relationship Officer"},
          {"RM-WCAS": "Relationship Manager"},
        ];
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {
                "code": "RM",
                "name": "Relationship Manager",
                "createdRM": "mso16802",
                "roleRM": "RM-WCAS",
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final role = await approvalRepository.getLastAssignedRole();
        final initRole = await approvalRepository.getInitiatedRole();
        expect(role, isA<Role>());
        expect(initRole, isA<String>());
      });

      test("success | empty responseData -> returns null", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final role = await approvalRepository.getLastAssignedRole();
        expect(role, isNull);
      });

      test("error | returns null (no throw)", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Fail",
            body: {},
            code: 500,
            status: ResponseStatus.error,
          ),
        );

        final role = await approvalRepository.getLastAssignedRole();
        expect(role, isNull);
      });
    });

    group("saveReviewComments", () {
      test("should return message on success", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {
            "responseData": {
              "reviewCommentId": 99,
              "appRefNo": "123456",
              "userId": "user1",
              "userRole": 123,
              "commentCategoryId": 100,
              "comment": "Test",
            },
          },
          status: ResponseStatus.success,
        );

        final testComment = Comment(
          applicationRefNo: "APP123456",
          comment: "This is a test comment to be saved",
          userId: "testUser123",
          userRole: 1,
          categoryId: 100,
          reviewCommentId: "3",
          reasonList: "Test",
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.saveReviewComments(
          testComment,
        );

        // Assert
        // return reviewCommentId on success
        expect(result, equals("99"));
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
          reviewCommentId: "3",
          reasonList: "Test",
        );

        // Act & Assert
        // return message on error
        expect(
          () => approvalRepository.saveReviewComments(testComment),
          throwsA("Internal Server Error"),
        );
      });
    });

    group("getCleanExposureInfo", () {
      test("should return CleanExposure on success", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {
            "responseData": {
              "exposures": [
                {
                  "rimNo": 1234,
                  "calculatedProposedExposure": 10.0,
                  "calculatedPresentExposure": 16.5,
                  "calculatedGuarantorExposure": 20.0,
                  "calculatedSharedLimitPresent": 33.33,
                  "calculatedSharedLimitProposed": 7.89,
                  "updatedProposedExposure": 90.0,
                  "updatedPresentExposure": 8.9,
                  "updatedGuarantorExposure": 50.0,
                  "updatedSharedLimitPresent": 60.0,
                  "updatedSharedLimitProposed": 70.0,
                }
              ],
              "totalProposedExposure": 90.0,
              "totalPresentExposure": 8.89,
              "totalGuarantorExposure": 50.0,
              "totalSharedLimitPresent": 60.0,
              "totalSharedLimitProposed": 70.0,
              "isGroup": false,
            },
          },
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getCleanExposureInfo();

        // Assert
        expect(result, isA<CleanExposure>());
      });

      test("should return null when response status is error", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 500,
          message: "Internal Server Error",
          body: {},
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getCleanExposureInfo();

        // Assert
        expect(result, null);
      });
    });

    group("insertCleanExposureInfo", () {
      test("should return CleanExposure on success", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {
            "responseData": {
              "description": "Success",
            },
          },
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final cleanExposureList = [
          Exposure(
            appRefNo: "123",
            rimNo: 10,
            calculatedGuarantorExposure: 11,
            calculatedPresentExposure: 12,
            calculatedProposedExposure: 44,
            calculatedSharedLimitPresent: 32.5,
            calculatedSharedLimitProposed: 12.8,
            updatedGuarantorExposure: 13,
            updatedPresentExposure: 76.3,
            updatedProposedExposure: 10,
            updatedSharedLimitPresent: 89,
            updatedSharedLimitProposed: 23.5,
          ),
        ];

        // Act
        final result =
            await approvalRepository.insertCleanExposureInfo(cleanExposureList);

        // Assert
        expect(result, isA<String>());
        expect(result, "{description: Success}");
      });

      test("should throw exception when response status is error", () async {
        final mockResponse = AppResponse(
          code: 500,
          message: "Internal Server Error",
          body: {},
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () => approvalRepository.insertCleanExposureInfo([]),
          throwsA(isA<Exception>()),
        );
      });
    });

    group("validateApproval", () {
      test("should return AppResponse", () async {
        // Arrange
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {
            "responseData": {
              "description": "Success",
            },
          },
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.validateApproval(120);

        // Assert
        expect(result, isA<AppResponse>());
      });
    });

    // method not in use
    group("getLegalAndLimitDetails", () {
      test("should return LegalAndLimitDetails type data", () async {
        // Arrange
        Globals.request?.applicationRefNo = "App123";
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {
            "responseData": {
              "isFOLApproved": true,
              "userAction": 1,
              "roleId": 130,
            },
          },
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await approvalRepository.getLegalAndLimitDetails();

        // Assert
        expect(result, isA<LegalAndLimitDetails>());
      });

      test("error | throws response.message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            code: 500,
            message: "Internal Server Error",
            body: {},
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => approvalRepository.getLegalAndLimitDetails(),
          throwsA(equals("Internal Server Error")),
        );
      });
    });

    // method not in use
    group("getDashboardRoles", () {
      test("should return LegalAndLimitDetails type data", () async {
        // Arrange
        Globals.user = User(currentRole: Role(roleId: 10));
        Globals.superBpmRolesId = [
          {"RO": 1, "RM": 2},
        ];
        final mockResponse = AppResponse(
          code: 200,
          message: "Success",
          body: {
            "responseData": "1,2,3,4",
          },
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await approvalRepository.getDashboardRoles(workListKey: "Sample");

        // Assert
        expect(result, isA<List<String>>());
        expect(result?.length, 2);
      });

      test("error will return empty data", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            code: 500,
            message: "Internal Server Error",
            body: {},
            status: ResponseStatus.error,
          ),
        );

        final result =
            await approvalRepository.getDashboardRoles(workListKey: "Sample");

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
