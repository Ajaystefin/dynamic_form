import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";
import "package:wcas_frontend/models/request/group_information/risk_bureau.dart";
import "package:wcas_frontend/repositories/group_information_repository.dart";
import "../test_config.dart";
import "mock_api_manager.dart";

void main() {
  group("GroupInformationRepository Integration Tests", () {
    late GroupInformationRepository groupInfoRepository;
    late MockAPIManager mockAPIManager;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      mockAPIManager = MockAPIManager();

      groupInfoRepository = GroupInformationRepository(
        apiManager: mockAPIManager,
      );

      // Reset globals
      Globals.user = null;
      // If your repo needs appRefNo on BaseRequest, you can set:
      // Globals.request = Request(applicationRefNo: 'APP-UT-001');
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
        final repository = GroupInformationRepository(
          apiManager: customMockAPIManager,
        );

        // Assert
        expect(repository, isA<GroupInformationRepository>());
      });

      test("should use default dependencies when none provided", () {
        // Act
        // Use singleton instance to avoid circular dependency
        final repository = GroupInformationRepository.instance;

        // Assert
        expect(repository, isA<GroupInformationRepository>());
      });

      test("should maintain singleton behavior with instance getter", () {
        // Act
        final instance1 = GroupInformationRepository.instance;
        final instance2 = GroupInformationRepository.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("getGroupInformation - Success Scenarios", () {
      test("should handle empty group information list", () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 2, code: "USER", name: "User"));
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": <dynamic>[]},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await groupInfoRepository.getGroupInformation();

        // Assert
        expect(result, isEmpty);
        expect(mockAPIManager.callLog, hasLength(1));
        // expect(
        //   mockAPIManager.callLog.first.endpoint,
        //   APIEndpoints.getGroupInformation,
        // );
      });

      test("should handle facilities with null values gracefully", () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 1, code: "ADMIN", name: "Admin"));
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "customerName": null,
                "customerRim": null,
                "cbrbClassification": null,
                "crr": null,
                "fundedCurrentLimit": null,
                "nonFundedCurrentLimit": null,
                "fundedProposedLimit": null,
                "nonFundedProposedLimit": null,
                "fundedOutstanding": null,
                "fundedPastDues": null,
                "nonFundedOutstanding": null,
                "nonFundedPastDues": null,
                "category": null,
                "previousApprovedCrr": null,
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await groupInfoRepository.getGroupInformation();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].customerName, isNull);
        expect(result[0].customerRim, isNull);
        expect(result[0].cbrbClassification, isNull);
        expect(result[0].crr, isNull);
        expect(result[0].fundedCurrentLimit, isNull);
        expect(result[0].category, isNull);
      });
    });

    group("getGroupInformation - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 1, code: "ADMIN", name: "Admin"));
        Globals.user = testUser;

        const errorMessage = "Failed to fetch group information";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => groupInfoRepository.getGroupInformation(),
          throwsA(equals(errorMessage)),
        );
      });

      test("should handle API network error", () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 1, code: "ADMIN", name: "Admin"));
        Globals.user = testUser;

        mockAPIManager.setMockException(Exception("Network timeout"));

        // Act & Assert
        expect(
          () async => groupInfoRepository.getGroupInformation(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Network timeout"),
            ),
          ),
        );
      });
    });

    group("getFacilitiesOtherBanks - Success Scenarios", () {
      test("should handle empty facilities list", () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 1, code: "ADMIN", name: "Admin"));
        Globals.user = testUser;

        // NOTE: latest repo expects responseData to be a List (not wrapped in
        // {"facilitiesList": []})
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": <dynamic>[],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await groupInfoRepository.getFacilitiesOtherBanks();

        // Assert
        expect(result, isEmpty);
        expect(mockAPIManager.callLog, hasLength(1));
        // expect(
        //   mockAPIManager.callLog.first.endpoint,
        //   APIEndpoints.getFacilityWithOtherBank,
        // );
      });

      test("should map facilities list to Facility models", () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 1, code: "ADMIN", name: "Admin"));
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "customerName": "Alpha Ltd",
                "customerRimNo": 11111,
                "bankName": 100,
                "fundedLimit": 1000,
                "nonFundedLimit": 500,
                "total": 1500,
                "securityCode": "SEC-A",
                "facilityType": "OD",
                "comments": "ok",
                "facilityOtherbanksId": 77,
              },
              {
                "customerName": "Beta LLC",
                "customerRimNo": 22222,
                "bankName": 101,
                "fundedLimit": 2000,
                "nonFundedLimit": 0,
                "total": 2000,
                "securityCode": "SEC-B",
                "facilityType": "TL",
                "comments": "ok",
                "facilityOtherbanksId": 88,
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await groupInfoRepository.getFacilitiesOtherBanks();

        // Assert
        expect(result, hasLength(2));
        expect(result.first.customerName, "Alpha Ltd");
        expect(result.last.bankNameId, 101);
      });
    });

    group("getFacilitiesOtherBanks - Error Scenarios", () {
      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 1, code: "ADMIN", name: "Admin"));
        Globals.user = testUser;

        const errorMessage = "Failed to fetch facilities with other banks";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => groupInfoRepository.getFacilitiesOtherBanks(),
          throwsA(equals(errorMessage)),
        );
      });
    });

    group("getFacilitiesCentralRiskBureau", () {
      test("should return RiskBureau on success", () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 1, code: "ADMIN", name: "Admin"));
        Globals.user = testUser;

        // ⚠️ Adjust keys to what RiskBureau.fromJson expects in your project.
        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {
              "rimNo": 12345,
              "direct_limits": "1000",
              "indirect_limits": "250",
              "direct_os": "500",
              "indirect_os": "100",
              "no_of_bank": "3",
              "cbrb_classifications": "A",
              "comments": "ok",
            },
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final rb = await groupInfoRepository.getFacilitiesCentralRiskBureau();

        // Assert
        expect(rb, isA<RiskBureau>());
        expect(mockAPIManager.callLog, hasLength(1));
        // expect(
        //   mockAPIManager.callLog.first.endpoint,
        //   APIEndpoints.getShareofWalletDetails,
        // );
      });

      test("should throw exception when API returns error status", () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 1, code: "ADMIN", name: "Admin"));
        Globals.user = testUser;

        const errorMessage = "Failed to fetch central risk bureau data";
        final mockResponse = AppResponse(
          message: errorMessage,
          body: {"error": "Server error"},
          code: 500,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => groupInfoRepository.getFacilitiesCentralRiskBureau(),
          throwsA(equals(errorMessage)),
        );
      });
    });

    group("saveCBRBData", () {
      test("should throw message on error", () async {
        // Arrange
        final facilitiesListJson = <Map<String, dynamic>>[
          {
            "customerName": "ACME",
            "rimNo": 99999,
            "directLimit": 1000,
            "indirectLimit": "null",
            "directOutstanding": 250,
            "indirectOutstanding": "null",
            "noOfBanks": 4,
            "cbrbClassifications": "A",
          },
        ];

        const error = "CBRB not saved";
        final mockResponse = AppResponse(
          message: error,
          body: {"error": "bad"},
          code: 400,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => groupInfoRepository.saveCBRBData(facilitiesListJson),
          throwsA(error),
        );
      });
    });

    group("saveOtherBankData", () {
      test("should throw message on error", () async {
        // Arrange
        final facilitiesListJson = Facility(
          customerName: "ACME",
          customerRimNo: 55555,
          comments: "OK",
        );

        const error = "OB not saved";
        final mockResponse = AppResponse(
          message: error,
          body: {"error": "bad"},
          code: 400,
          status: ResponseStatus.error,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => groupInfoRepository.saveOtherBankData(facilitiesListJson),
          throwsA(error),
        );
      });
    });

    group("deleteOtherBankFacility", () {
      test("should throw message on API error", () async {
        // Arrange
        const err = "Delete OB failed";
        final mockResponse = AppResponse(
          message: err,
          body: {"error": true},
          code: 500,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => groupInfoRepository.deleteOtherBankFacility(null),
          throwsA(err),
        );
      });
    });

    group("deleteCBRBData", () {
      test("should throw message on API error", () async {
        // Arrange
        const err = "Delete CBRB failed";
        final mockResponse = AppResponse(
          message: err,
          body: {"error": true},
          code: 400,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () async => groupInfoRepository.deleteCBRBData(null),
          throwsA(err),
        );
      });
    });

    group("Edge Cases and Integration", () {
      test("should handle concurrent API calls", () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 1, code: "ADMIN", name: "Admin"));
        Globals.user = testUser;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": [
              {
                "customerName": "Concurrent Customer",
                "customerRim": 99999,
                "cbrbClassification": "Grade A",
                "crr": 95.0,
                "category": "Concurrent Test",
              }
            ],
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act - Make multiple concurrent calls
        final futures =
            List.generate(3, (_) => groupInfoRepository.getGroupInformation());
        final results = await Future.wait(futures);

        // Assert
        expect(results, hasLength(3));
        for (final result in results) {
          expect(result, hasLength(1));
          expect(result[0].customerName, equals("Concurrent Customer"));
        }
        expect(mockAPIManager.callLog, hasLength(3));
      });

      test("should handle large group information datasets efficiently",
          () async {
        // Arrange
        final testUser =
            User(currentRole: Role(id: 1, code: "ADMIN", name: "Admin"));
        Globals.user = testUser;

        final largeGroupInfoList = List.generate(
          100,
          (index) => {
            "customerName": "Customer ${index + 1}",
            "customerRim": 10000 + index,
            "cbrbClassification": [
              "Grade A",
              "Grade B+",
              "Grade A-",
              "Grade B",
            ][index % 4],
            "crr": 70.0 + (index % 30),
            "fundedCurrentLimit": (index + 1.0) * 100000,
            "nonFundedCurrentLimit": (index + 1.0) * 50000,
            "fundedProposedLimit": (index + 1.0) * 120000,
            "nonFundedProposedLimit": (index + 1.0) * 60000,
            "fundedOutstanding": (index + 1.0) * 80000,
            "fundedPastDues": index % 10 == 0 ? (index + 1.0) * 5000 : 0.0,
            "nonFundedOutstanding": (index + 1.0) * 40000,
            "nonFundedPastDues": 0.0,
            "category": ["Corporate", "SME", "Large Corporate"][index % 3],
            "previousApprovedCrr": 65.0 + (index % 35),
          },
        );

        final mockResponse = AppResponse(
          message: "Success",
          body: {"responseData": largeGroupInfoList},
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await groupInfoRepository.getGroupInformation();

        // Assert
        expect(result, hasLength(100));
        expect(result[0].customerName, equals("Customer 1"));
        expect(result[0].customerRim, equals(10000));
        expect(result[99].customerName, equals("Customer 100"));
        expect(result[99].customerRim, equals(10099));
        expect(
          result[99].fundedCurrentLimit,
          equals(10000000),
        ); // (99 + 1) * 100000
      });
    });
  });
}
