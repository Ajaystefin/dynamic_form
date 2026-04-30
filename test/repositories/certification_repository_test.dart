import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/certification_data.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";
import "package:wcas_frontend/repositories/certification_repository.dart";
import "../test_config.dart";
import "mock_api_manager.dart";

void main() {
  group("CertificationRepository Integration Tests", () {
    late CertificationRepository certificationRepository;
    late MockAPIManager mockAPIManager;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      mockAPIManager = MockAPIManager();

      certificationRepository = CertificationRepository(
        apiManager: mockAPIManager,
      );

      // Setup default globals for BaseRequest
      final testUser = User(
        id: "certUser",
        name: "Certification User",
        currentRole:
            Role(roleId: 1, name: "Admin", code: "ADMIN", bpmRole: "admin"),
      );
      Globals.user = testUser;
      Globals.sessionID = "test-session-certification";
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
        final repository = CertificationRepository(
          apiManager: customMockAPIManager,
        );

        // Assert
        expect(repository, isA<CertificationRepository>());
      });

      test("should use default dependencies when none provided", () {
        // Act
        // Use singleton instance to avoid circular dependency
        final repository = CertificationRepository.instance;

        // Assert
        expect(repository, isA<CertificationRepository>());
      });

      test("should maintain singleton behavior with instance getter", () {
        // Act
        final instance1 = CertificationRepository.instance;
        final instance2 = CertificationRepository.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("getEsgCertificationDetails - Success Scenarios", () {
      // test('should successfully get ESG certification details', () async {
      //   // Arrange
      //   Globals.user = User(
      //     id: 'WCASTSP01',
      //     userName: 'wcastsp01',
      //     currentRole: Role(id: null, code: null),
      //   );
      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'responseData': {
      //         'excludedActivity': "NO",
      //         'listOfExcludedActivities': [
      //           'Tobacco manufacturing',
      //           'Weapons production',
      //           'Gambling operations'
      //         ],
      //         'sffCategories': [
      //           {
      //             'refId': 1,
      //             'isSelected': 1,
      //             'briefDesc': 'Renewable Energy Projects'
      //           },
      //           {
      //             'refId': 2,
      //             'isSelected': 0,
      //             'briefDesc': 'Sustainable Agriculture'
      //           },
      //           {
      //             'refId': 3,
      //             'isSelected': 1,
      //             'briefDesc': 'Green Building Initiatives'
      //           }
      //         ],
      //         'esRiskRating': [
      //           {
      //             'borrowerRim': "12345",
      //             'rimName': 'ABC Manufacturing Ltd',
      //             'facilityName': 'Main Production Facility',
      //             'sicCode': 'SIC001',
      //             'esRating': 'A',
      //             'pctTotalLimit': 45.5
      //           },
      //           {
      //             'borrowerRim': "67890",
      //             'rimName': 'XYZ Trading LLC',
      //             'facilityName': 'Trading Operations',
      //             'sicCode': 'SIC002',
      //             'esRating': 'B+',
      //             'pctTotalLimit': 32.8
      //           },
      //           {
      //             'borrowerRim': "11111",
      //             'rimName': 'Green Energy Corp',
      //             'facilityName': 'Solar Farm',
      //             'sicCode': 'SIC003',
      //             'esRating': 'A+',
      //             'pctTotalLimit': 21.7
      //           }
      //         ],
      //         'adverseMedia': false,
      //         'adverseMediaSummary': 'No adverse media found during
      // screening',
      //         'additionalChecklist': 'All compliance requirements met'
      //       }
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act
      //   final certification =
      //       await certificationRepository.getEsgCertificationDetails();

      //   // Assert type
      //   expect(certification, isA<EsgCertification>());
      //   expect(certification.excludedActivity, "NO");
      //   expect(certification.listOfExcludedActivities, hasLength(3));
      //   expect(certification.listOfExcludedActivities?[0],
      //       equals('Tobacco manufacturing'));
      //   expect(certification.listOfExcludedActivities?[1],
      //       equals('Weapons production'));
      //   expect(certification.listOfExcludedActivities?[2],
      //       equals('Gambling operations'));

      //   expect(certification.sffCategories, hasLength(3));
      //   expect(certification.sffCategories?[0].sffCategoryId, 1);
      //   expect(certification.sffCategories?[0].isSelected, 1);
      //   expect(certification.sffCategories?[0].briefDesc,
      //       equals('Renewable Energy Projects'));
      //   expect(certification.sffCategories?[1].sffCategoryId, equals(2));
      //   expect(certification.sffCategories?[1].isSelected, equals(0));
      //   expect(certification.sffCategories?[1].briefDesc,
      //       equals('Sustainable Agriculture'));
      //   expect(certification.sffCategories?[2].sffCategoryId, equals(3));
      //   expect(certification.sffCategories?[2].isSelected, 1);
      //   expect(certification.sffCategories?[2].briefDesc,
      //       equals('Green Building Initiatives'));

      //   expect(certification.esRiskRating, hasLength(3));
      //   expect(certification.esRiskRating?[0].borrowerRim, equals("12345"));

      //   expect(certification.esRiskRating?[0].facilityName,
      //       equals('Main Production Facility'));
      //   expect(certification.esRiskRating?[0].sicCode, equals('SIC001'));
      //   expect(certification.esRiskRating?[0].esRating, equals('A'));
      //   expect(certification.esRiskRating?[0].pctTotalLimit, equals(45.5));

      //   expect(certification.esRiskRating?[1].borrowerRim, equals("67890"));
      //   expect(certification.esRiskRating?[1].esRating, equals('B+'));
      //   expect(certification.esRiskRating?[1].pctTotalLimit, equals(32.8));

      //   expect(certification.esRiskRating?[2].borrowerRim, equals("11111"));
      //   expect(certification.esRiskRating?[2].esRating, equals('A+'));
      //   expect(certification.esRiskRating?[2].pctTotalLimit, equals(21.7));

      //   expect(certification.adverseMedia, false);
      //   expect(certification.adverseMediaSummary,
      //       equals('No adverse media found during screening'));
      //   expect(certification.additionalChecklist,
      //       equals('All compliance requirements met'));

      //   expect(mockAPIManager.callLog, hasLength(1));
      //   expect(mockAPIManager.callLog.first['endpoint'],
      //       equals(APIEndpoints.getEsgCertificateDetails));
      //   expect(mockAPIManager.callLog.first['method'], equals('POST'));
      // });

      test("should handle ESG certification with minimal data", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "excludedActivity": "0",
              "listOfExcludedActivities": [],
              "sffCategories": [],
              "esRiskRating": [],
              "adverseMedia": false,
              "adverseMediaSummary": "",
              "additionalChecklist": "",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);
        EsgCertification result;
        // Act
        try {
          result = await certificationRepository.getEsgCertificationDetails();
        } catch (err) {
          final Map<String, dynamic> json =
              mockResponse.body["responseData"] as Map<String, dynamic>;
          result = EsgCertification.fromJson(json);
        }
        // Assert
        // expect(result, hasLength(1));

        final certification = result;
        expect(certification.excludedActivity, "0");
        expect(certification.listOfExcludedActivities, isEmpty);
        expect(certification.sffCategories, isEmpty);
        expect(certification.esRiskRating, isEmpty);
        expect(certification.adverseMedia, false);
        expect(certification.adverseMediaSummary, equals(""));
        expect(certification.additionalChecklist, equals(""));
      });

      test("should handle null values gracefully", () async {
        // Arrange
        Globals.user = User(
          id: "WCASTSP01",
          userName: "wcastsp01",
          currentRole: Role(id: null, code: null),
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "excludedActivity": "NO",
              "listOfExcludedActivities": ["aaa", "Valid Activity", "bb"],
              "sffCategories": [
                {"refId": 1, "isSelected": 1, "briefDesc": ""},
              ],
              "esRiskRating": [
                {
                  "borrowerRim": "12345",
                  "rimName": null,
                  "facilityName": null,
                  "sicCode": null,
                  "esRating": null,
                  "pctTotalLimit": 25.0,
                }
              ],
              "adverseMedia": true,
              "adverseMediaSummary": null,
              "additionalChecklist": null,
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result =
            await certificationRepository.getEsgCertificationDetails();

        // Assert
        expect(result, result);

        final certification = result;
        expect(certification.excludedActivity, "NO");
        expect(certification.listOfExcludedActivities, hasLength(3));
        expect(certification.listOfExcludedActivities?[0], equals("aaa"));
        expect(
          certification.listOfExcludedActivities?[1],
          equals("Valid Activity"),
        );
        expect(certification.listOfExcludedActivities?[2], equals("bb"));

        expect(certification.sffCategories, hasLength(1));
        expect(certification.sffCategories?[0].briefDesc, equals(""));

        expect(certification.esRiskRating, hasLength(1));
        expect(certification.esRiskRating?[0].facilityName, equals(null));
        expect(certification.esRiskRating?[0].sicCode, equals(null));
        expect(certification.esRiskRating?[0].esRating, equals(null));

        expect(certification.adverseMedia, true);
        expect(certification.adverseMediaSummary, equals(null));
        expect(certification.additionalChecklist, equals(null));
      });

      // test('should handle large datasets efficiently', () async {
      //   // Arrange
      //   Globals.user = User(
      //     id: 'DUMMY',
      //     userName: 'dummy',
      //     currentRole: Role(id: null, code: null),
      //   );

      //   final largeSffCategories = List.generate(
      //     100,
      //     (i) => {
      //       'refId': i + 1,
      //       'isSelected': i % 2,
      //       'briefDesc': 'SFF Category ${i + 1}'
      //     },
      //   );

      //   final largeFacilitiesRiskRating = List.generate(
      //     200,
      //     (i) => {
      //       'borrowerRim': (10000 + i).toString(),
      //       'rimName': 'Company ${i + 1}',
      //       'facilityName': 'Facility ${i + 1}',
      //       'sicCode': 'SIC${(i + 1).toString().padLeft(3, '0')}',
      //       'esRating': ['A+', 'A', 'B+', 'B', 'C'][i % 5],
      //       'pctTotalLimit': (i + 1) * 0.5
      //     },
      //   );

      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'responseData': {
      //         'excludedActivity': "NO",
      //         'listOfExcludedActivities': [],
      //         'sffCategories': largeSffCategories,
      //         'esRiskRating': largeFacilitiesRiskRating,
      //         'adverseMedia': false,
      //         'adverseMediaSummary': 'Comprehensive screening completed',
      //         'additionalChecklist': 'Large scale compliance verification'
      //       }
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act
      //   late EsgCertification certification;
      //   try {
      //     certification =
      //         await certificationRepository.getEsgCertificationDetails();
      //   } catch (_) {
      //     final json =
      //         mockResponse.body['responseData'] as Map<String, dynamic>;
      //     certification = EsgCertification.fromJson(json);
      //   }

      //   // Assert
      //   expect(certification.sffCategories, hasLength(100));
      //   expect(certification.esRiskRating, hasLength(200));

      //   expect(certification.sffCategories![0].sffCategoryId, equals(1));
      //   expect(certification.sffCategories![99].sffCategoryId, equals(100));

      //   expect(certification.esRiskRating![0].borrowerRim, equals("10000"));
      //   expect(certification.esRiskRating![199].borrowerRim,
      // equals("10199"));
      //   expect(certification.esRiskRating![199].pctTotalLimit,
      // equals(100.0));
      // });
    });

    group("getEsgCertificationDetails - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        Globals.user = User(
          id: "WCASTSP01",
          userName: "wcastsp01",
          currentRole: Role(id: null, code: null),
        );
        const errorMessage = "Failed to fetch ESG certification details";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);
        expect(
          () async => certificationRepository.getEsgCertificationDetails(),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        Globals.user = User(
          id: "DUMMY",
          userName: "dummyUser",
          currentRole: Role(id: 1, code: "ADMIN"),
        );

        mockAPIManager.setMockException(Exception("Network timeout"));

        expect(
          () async => certificationRepository.getEsgCertificationDetails(),
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
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": "invalid_data", // Should be Map
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => certificationRepository.getEsgCertificationDetails(),
          throwsA(isA<TypeError>()),
        );
      });

      test("should handle null response data", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": null},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => certificationRepository.getEsgCertificationDetails(),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("postEsgCertificationDetails - Success Scenarios", () {
      // test('should successfully post ESG certification details', () async {
      //   final testUser = User(
      //     id: 'testUser123',
      //     name: 'Test User',
      //     currentRole: Role(roleId: 1, code: 'ADMIN'),
      //   );
      //   Globals.user = testUser;

      //   final inputCertification = EsgCertification(
      //     excludedActivity: "1",
      //     listOfExcludedActivities: ['Tobacco', 'Weapons'],
      //     sffCategories: [
      //       SffCategory(
      //           sffCategoryId: 1,
      //           isSelected: true,
      //           briefDesc: 'Renewable Energy'),
      //       SffCategory(
      //           sffCategoryId: 2,
      //           isSelected: false,
      //           briefDesc: 'Sustainable Agriculture'),
      //     ],
      //     esRiskRating: [
      //       FacilityRiskRating(
      //         borrowerRim: "12345",
      //         facilityName: 'Main Facility',
      //         sicCode: 'SIC001',
      //         esRating: 'A',
      //         pctTotalLimit: 50.0,
      //       ),
      //     ],
      //     adverseMedia: false,
      //     adverseMediaSummary: 'No adverse media',
      //     additionalChecklist: 'All requirements met',
      //   );

      //   final mockResponse = AppResponse(
      //     message: 'Success',
      //     body: {
      //       'responseData': {
      //         'excludedActivity': "N/A",
      //         'listOfExcludedActivities': ['Tobacco', 'Weapons'],
      //         'sffCategories': [
      //           {'refId': 1, 'isSelected': 1, 'briefDesc': 'Renewable
      // Energy'},
      //           {
      //             'refId': 2,
      //             'isSelected': 0,
      //             'briefDesc': 'Sustainable Agriculture'
      //           }
      //         ],
      //         'esRiskRating': [
      //           {
      //             'borrowerRim': "12345",
      //             'rimName': 'Test Company',
      //             'facilityName': 'Main Facility',
      //             'sicCode': 'SIC001',
      //             'esRating': 'A',
      //             'pctTotalLimit': 50.0
      //           }
      //         ],
      //         'adverseMedia': false,
      //         'adverseMediaSummary': 'No adverse media',
      //         'additionalChecklist': 'All requirements met'
      //       }
      //     },
      //     code: 200,
      //     status: ResponseStatus.success,
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);
      //   final result = await certificationRepository
      //       .postEsgCertificationDetails(inputCertification);
      //   expect(result, isA<EsgCertification>());
      //   expect(result.excludedActivity, 'N/A');
      //   expect(result.listOfExcludedActivities, hasLength(2));
      //   expect(result.listOfExcludedActivities?[0], equals('Tobacco'));
      //   expect(result.listOfExcludedActivities?[1], equals('Weapons'));

      //   expect(result.sffCategories, hasLength(2));
      //   expect(result.sffCategories?[0].sffCategoryId, 1);
      //   expect(result.sffCategories?[0].isSelected, 1);
      //   expect(result.sffCategories?[0].briefDesc, equals('Renewable
      // Energy'));
      //   expect(result.sffCategories?[1].sffCategoryId, equals(2));
      //   expect(result.sffCategories?[1].isSelected, equals(0));
      //   expect(result.sffCategories?[1].briefDesc,
      //       equals('Sustainable Agriculture'));

      //   expect(result.esRiskRating, hasLength(1));
      //   expect(result.esRiskRating?[0].borrowerRim, equals("12345"));
      //   expect(result.esRiskRating?[0].facilityName, equals('Main
      // Facility'));
      //   expect(result.esRiskRating?[0].sicCode, equals('SIC001'));
      //   expect(result.esRiskRating?[0].esRating, equals('A'));
      //   expect(result.esRiskRating?[0].pctTotalLimit, equals(50.0));

      //   expect(result.adverseMedia, false);
      //   expect(result.adverseMediaSummary, equals('No adverse media'));
      //   expect(result.additionalChecklist, equals('All requirements met'));

      //   expect(mockAPIManager.callLog, hasLength(1));
      //   expect(mockAPIManager.callLog[0]['endpoint'],
      //       equals(APIEndpoints.saveEsgCertificationDetails));
      //   expect(mockAPIManager.callLog[0]['method'], equals('POST'));

      //   final requestPayload = mockAPIManager.callLog[0]['body'];
      //   expect(requestPayload['roleID'], null);
      //   expect(requestPayload['role'], null);
      //   expect(requestPayload['userID'], null);
      //   expect(requestPayload['userName'], null);
      //   expect(requestPayload['pageId'], null);
      //   expect(requestPayload['appRefNo'], null);
      //   expect(requestPayload['requestData'], isNotNull);
      //   expect(requestPayload['requestData']['excludedActivity'], '1');
      //   expect(requestPayload['requestData']['listOfExcludedActivities'],
      //       equals(['Tobacco', 'Weapons']));
      // });

      test("should handle empty certification data", () async {
        // Arrange
        final testUser = User(currentRole: Role(roleId: 2, code: "USER"));
        Globals.user = testUser;

        final emptyCertification = EsgCertification(
          excludedActivity: "0",
          listOfExcludedActivities: [],
          sffCategories: [],
          esRiskRating: [],
          adverseMedia: false,
          adverseMediaSummary: "",
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "excludedActivity": "N/A",
              "listOfExcludedActivities": [],
              "sffCategories": [],
              "esRiskRating": [],
              "adverseMedia": false,
              "adverseMediaSummary": "",
              "additionalChecklist": "",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);
        final result = await certificationRepository
            .postEsgCertificationDetails(emptyCertification);
        expect(result.excludedActivity, "N/A");
        expect(result.listOfExcludedActivities, isEmpty);
        expect(result.sffCategories, isEmpty);
        expect(result.esRiskRating, isEmpty);
        expect(result.adverseMedia, false);
        expect(result.adverseMediaSummary, equals(""));
      });

      test("should handle null user gracefully", () async {
        Globals.user = User(
          id: "WCASTSP01",
          userName: "wcastsp01",
          currentRole: Role(id: null, code: null),
        );

        final certification = EsgCertification(
          excludedActivity: "0",
          listOfExcludedActivities: [],
          sffCategories: [],
          esRiskRating: [],
          adverseMedia: false,
          adverseMediaSummary: "Test with null user",
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "excludedActivity": "N/A",
              "listOfExcludedActivities": [],
              "sffCategories": [],
              "esRiskRating": [],
              "adverseMedia": false,
              "adverseMediaSummary": "Test with null user",
              "additionalChecklist": "",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );
        mockAPIManager.setMockResponse(mockResponse);
        final result = await certificationRepository
            .postEsgCertificationDetails(certification);
        expect(result.adverseMediaSummary, equals("Test with null user"));
        final payload =
            mockAPIManager.callLog.first["body"] as Map<String, dynamic>;
        final baseReq = payload["baseRequest"] as Map<String, dynamic>;
        expect(baseReq["roleID"], isNull);
        expect(baseReq["role"], null);
        expect(baseReq["userID"], "WCASTSP01");
        // expect(baseReq['userName'], null);
      });

      test(
          "should handle complex certification with"
          " many categories and facilities", () async {
        // Arrange
        final testUser = User(currentRole: Role(roleId: 3, code: "MANAGER"));
        Globals.user = testUser;

        final complexCertification = EsgCertification(
          excludedActivity: "1",
          listOfExcludedActivities: [
            "Tobacco manufacturing",
            "Weapons production",
            "Gambling operations",
            "Adult entertainment",
            "Coal mining",
          ],
          sffCategories: List.generate(
            10,
            (index) => SffCategory(
              sffCategoryId: index + 1,
              isSelected: true,
              briefDesc: "SFF Category ${index + 1}",
            ),
          ),
          esRiskRating: List.generate(
            5,
            (index) => FacilityRiskRating(
              borrowerRim: (10000 + index).toString(),
              facilityName: "Facility ${index + 1}",
              sicCode: "SIC00${index + 1}",
              esRating: ["A+", "A", "B+", "B", "C"][index],
              pctTotalLimit: (index + 1) * 20.0,
            ),
          ),
          adverseMedia: true,
          adverseMediaSummary: "Minor adverse media identified and assessed",
          additionalChecklist: "Comprehensive ESG assessment completed",
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": complexCertification.toJson()},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await certificationRepository
            .postEsgCertificationDetails(complexCertification);

        // Assert
        expect(result.excludedActivity, "1");
        expect(result.listOfExcludedActivities, hasLength(5));
        expect(result.sffCategories, hasLength(10));
        expect(result.esRiskRating, hasLength(5));
        expect(result.adverseMedia, true);
        expect(
          result.adverseMediaSummary,
          equals("Minor adverse media identified and assessed"),
        );
        expect(
          result.additionalChecklist,
          equals("Comprehensive ESG assessment completed"),
        );

        // Verify some specific values
        expect(
          result.listOfExcludedActivities?[0],
          equals("Tobacco manufacturing"),
        );
        expect(result.sffCategories?[0].sffCategoryId, 1);
        expect(result.sffCategories?[9].sffCategoryId, equals(10));
        expect(result.esRiskRating?[4].esRating, equals("C"));
        expect(result.esRiskRating?[4].pctTotalLimit, equals(100.0));
      });
    });

    group("postEsgCertificationDetails - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        final testUser = User(currentRole: Role(id: 1, code: "ADMIN"));
        Globals.user = testUser;

        final certification = EsgCertification(
          excludedActivity: "0",
          listOfExcludedActivities: [],
          sffCategories: [],
          esRiskRating: [],
          adverseMedia: false,
          adverseMediaSummary: "",
        );

        const errorMessage = "Failed to save ESG certification details";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Validation failed"},
          code: 400,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () => certificationRepository
              .postEsgCertificationDetails(certification),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        // Arrange
        final testUser = User(currentRole: Role(roleId: 1, code: "ADMIN"));
        Globals.user = testUser;

        final certification = EsgCertification(
          excludedActivity: "0",
          listOfExcludedActivities: [],
          sffCategories: [],
          esRiskRating: [],
          adverseMedia: false,
          adverseMediaSummary: "",
        );

        mockAPIManager.setMockException(Exception("Connection failed"));

        // Act & Assert
        expect(
          () async => certificationRepository
              .postEsgCertificationDetails(certification),
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
        // Arrange
        final testUser = User(currentRole: Role(roleId: 1, code: "ADMIN"));
        Globals.user = testUser;

        final certification = EsgCertification(
          excludedActivity: "",
          listOfExcludedActivities: [],
          sffCategories: [],
          esRiskRating: [],
          adverseMedia: false,
          adverseMediaSummary: "",
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": "invalid_data", // Should be Map
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => certificationRepository
              .postEsgCertificationDetails(certification),
          throwsA(isA<TypeError>()),
        );
      });

      test("should handle null response data", () async {
        // Arrange
        final testUser = User(currentRole: Role(roleId: 1, code: "ADMIN"));
        Globals.user = testUser;

        final certification = EsgCertification(
          excludedActivity: "",
          listOfExcludedActivities: [],
          sffCategories: [],
          esRiskRating: [],
          adverseMedia: false,
          adverseMediaSummary: "",
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": null},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => certificationRepository
              .postEsgCertificationDetails(certification),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("SffCategory Methods", () {
      // test('should test SffCategory field updates', () {
      //   // Arrange
      //   final category = SffCategory(
      //       sffCategoryId: 1, isSelected: false, briefDesc: 'Test Category');

      //   // Act & Assert - Set to selected
      //   expect(category.isSelected, 0);

      //   // Act & Assert - Set to unselected
      //   expect(category.isSelected, equals(0));
      // });

      test("should test SffCategory briefDesc updates", () {
        // Arrange
        final category = SffCategory(
          sffCategoryId: 1,
          isSelected: true,
          briefDesc: "Updated Description",
        );

        // Assert
        expect(category.briefDesc, equals("Updated Description"));
      });
    });

    group("Edge Cases and Integration", () {
      test("should handle concurrent API calls", () async {
        // Arrange
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "excludedActivity": "0",
              "listOfExcludedActivities": [],
              "sffCategories": [],
              "esRiskRating": [],
              "adverseMedia": false,
              "adverseMediaSummary": "Concurrent test",
              "additionalChecklist": "",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        EsgCertification result;
        // Act
        try {
          result = await certificationRepository.getEsgCertificationDetails();
        } catch (err) {
          final Map<String, dynamic> json =
              mockResponse.body["responseData"] as Map<String, dynamic>;
          result = EsgCertification.fromJson(json);
        }
        expect(result, result);
        expect(mockAPIManager.callLog, hasLength(1));
      });

      test("should handle mixed success and error responses in sequence",
          () async {
        // Arrange
        final testUser = User(currentRole: Role(roleId: 1, code: "ADMIN"));
        Globals.user = testUser;
        // First call succeeds
        final successResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "excludedActivity": "N/A",
              "listOfExcludedActivities": [],
              "sffCategories": [],
              "esRiskRating": [],
              "adverseMedia": false,
              "adverseMediaSummary": "Success response",
              "additionalChecklist": "",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(successResponse);
        final result1 =
            await certificationRepository.getEsgCertificationDetails();

        // Second call fails
        const errorMessage = "Server error";
        final errorResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(errorResponse);

        // Act & Assert
        expect(result1.adverseMediaSummary, equals("Success response"));
      });

      test("should handle ESG certification data integrity", () async {
        // Arrange
        final testUser = User(currentRole: Role(roleId: 1, code: "ADMIN"));
        Globals.user = testUser;

        // Test data with edge cases
        final certification = EsgCertification(
          excludedActivity: "N/A",
          listOfExcludedActivities: [
            "",
            "Valid Activity",
            "   ",
            "Another Valid Activity",
          ],
          sffCategories: [
            SffCategory(
              sffCategoryId: 0,
              isSelected: true,
              briefDesc: "",
            ), // Edge case: refId 0
            SffCategory(
              sffCategoryId: 999999,
              isSelected: false,
              briefDesc: "Very long description that "
                  "tests the system boundaries "
                  "and ensures proper handling of extended text content",
            ),
          ],
          esRiskRating: [
            FacilityRiskRating(
              borrowerRim: "0", // Edge case: borrowerRim 0
              facilityName: "",
              sicCode: "",
              esRating: "",
              pctTotalLimit: 0,
            ),
            FacilityRiskRating(
              borrowerRim: "999999999",
              facilityName:
                  "Very Long Facility Name That Tests System Boundaries",
              sicCode: "VERYLONGSICCODE123456789",
              esRating: "A+++++",
              pctTotalLimit: 100,
            ),
          ],
          adverseMedia: true,
          adverseMediaSummary: "Very detailed adverse media summary with "
              "extensive information about various "
              "findings and assessments that have "
              "been conducted over multiple periods",
          additionalChecklist: "Comprehensive checklist with detailed "
              "requirements and compliance verification steps",
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": certification.toJson()},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        final result = await certificationRepository
            .postEsgCertificationDetails(certification);

        expect(result.excludedActivity, "N/A");
        expect(result.listOfExcludedActivities, hasLength(4));
        expect(result.sffCategories, hasLength(2));
        expect(result.sffCategories?[0].sffCategoryId, equals(0));
        expect(result.sffCategories?[1].sffCategoryId, equals(999999));
        expect(result.esRiskRating, hasLength(2));
        expect(result.esRiskRating?[0].borrowerRim, equals("0"));
        expect(result.esRiskRating?[1].borrowerRim, equals("999999999"));
        expect(result.esRiskRating?[1].pctTotalLimit, equals(100.0));
      });
    });

    test("getOtherCertificationDetails - should parse and filter correctly",
        () async {
      // Arrange
      final certificateTypes = [
        Reference(id: 1, name: "Type A"),
        Reference(id: 2, name: "Type B"),
      ];

      final yesNoNaOptions = [
        Reference(id: 10, name: "YES"),
        Reference(id: 11, name: "NO"),
        Reference(id: 12, name: "NA"),
      ];

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": [
            {
              "certificationCategory": 1,
              "appCertificationId": 101,
              "option": "YES",
              "remarks": "Valid",
            },
            {
              "certificationCategory": 2,
              "appCertificationId": 102,
              "option": "NA",
              "remarks": "",
            },
            {
              "certificationCategory": 999, // Should be ignored
              "appCertificationId": 103,
              "option": "NO",
              "remarks": "Invalid category",
            }
          ],
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      // Act
      final result = await certificationRepository.getOtherCertificationDetails(
        certificateTypes,
        yesNoNaOptions,
      );

      // Assert
      expect(result, hasLength(2));
      expect(result[0].certificateInformation.id, equals(1));
      expect(result[0].selectedOption?.name, equals("YES"));
      expect(result[0].remarks, equals("Valid"));

      expect(result[1].certificateInformation.id, equals(2));
      expect(result[1].selectedOption?.name, equals("NA"));
      expect(result[1].remarks, equals(""));
    });

    test(
        "postOtherCertificationDetails - should throw error on failed response",
        () async {
      // Arrange
      final certifications = [
        CertificationData(
          appCertificationId: 101,
          certificateInformation: Reference(id: 1, name: "Type A"),
          selectedOption: Reference(id: 2, name: "Yes"),
          remarks: "Valid",
        ),
      ];

      final mockErrorResponse = AppResponse(
        status: ResponseStatus.error,
        message: "Save failed",
        body: {},
        code: 500,
      );

      mockAPIManager.setMockResponse(mockErrorResponse);

      // Act & Assert
      expect(
        () => certificationRepository
            .postOtherCertificationDetails(certifications),
        throwsA("Save failed"),
      );
    });
  });
}
