import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/information/customer_request_info.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/certification_data.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/models/request/group_information/facilities_other_banks.dart";
// import "package:wcas_frontend/models/request/group_information/risk_bureau.dart";
import "package:wcas_frontend/models/request/remarks/fee_structure.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/models/request/security_perfection.dart";
import "package:wcas_frontend/models/request/sic_code.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RequestRepository requestRepository;
  late MockAPIManager mockAPIManager;

  User buildUser({
    String id = "testUser123",
    String name = "Test User",
    int roleId = 1,
    String roleCode = "ADMIN",
    String roleName = "Administrator",
    List<String>? segments,
    List<String>? regions,
  }) {
    return User(
      id: id,
      name: name,
      currentRole: Role(id: roleId, code: roleCode, name: roleName),
      segments: segments,
      regions: regions,
    );
  }

  Request buildRequest({
    String applicationRefNo = "APP-XYZ-001",
    int? groupId = 42,
    int? customerRimNo = 777,
  }) {
    return Request(
      applicationRefNo: applicationRefNo,
      groupId: groupId,
      customerRimNo: customerRimNo,
    );
  }

  setUp(() async {
    await EnvConfig.setEnvironment();
    mockAPIManager = MockAPIManager();
    requestRepository = RequestRepository(apiManager: mockAPIManager);

    Globals.user = null;
    Globals.request = buildRequest();
    Globals.applicationDetails = null;
  });

  tearDown(() {
    mockAPIManager.clearCallLog();
    Globals.user = null;
    Globals.request = null;
    Globals.applicationDetails = null;
  });

  group("Constructor / Singleton / Override", () {
    test("should create instance with provided APIManager", () {
      final repo = RequestRepository(apiManager: mockAPIManager);
      expect(repo, isNotNull);
    });

    test("should provide singleton instance", () {
      final instance1 = RequestRepository.instance;
      final instance2 = RequestRepository.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test("should override singleton instance", () {
      final customRepo = RequestRepository(apiManager: mockAPIManager);
      RequestRepository.overrideInstance = customRepo;
      expect(identical(RequestRepository.instance, customRepo), isTrue);
    });
  });

  group("getApplicationDetails", () {
    test("should throw exception when API returns error", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Application not found",
        body: {},
        code: 404,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getApplicationDetails(),
        throwsExceptionWithMessage("Application not found"),
      );
    });
  });

  group("getLastApprovedApplication", () {
    test("should return ApplicationDetails when applicationInfoResponse exists",
        () async {
      Globals.request = buildRequest(
        applicationRefNo: "APP123",
        customerRimNo: 1001,
        groupId: 55,
      );

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {
            "applicationInfoResponse": {
              "applicationRefNo": "APP-LAST-001",
              "branch": "Abu Dhabi",
            },
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getLastApprovedApplication();

      expect(result, isA<ApplicationDetails>());
      expect(mockAPIManager.callLog, hasLength(1));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.getLastApprovedApplications),
      );

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["requestData"]["rimNo"], equals(1001));
      expect(requestBody["requestData"]["groupId"], equals(55));
    });

    test(
        "should return empty ApplicationDetails when"
        " applicationInfoResponse is null", () async {
      Globals.request = buildRequest(customerRimNo: 1001, groupId: 55);

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {
            "applicationInfoResponse": null,
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getLastApprovedApplication();

      expect(result, isA<ApplicationDetails>());
    });

    test("should throw exception when API returns error", () async {
      Globals.request = buildRequest();

      final mockResponse = AppResponse(
        message: "Application not found",
        body: {},
        code: 404,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getLastApprovedApplication(),
        throwsExceptionWithMessage("Application not found"),
      );
    });
  });

  group("applicationTypeReconsiderationData", () {
    test("should return list when response has applications", () async {
      Globals.request = buildRequest(customerRimNo: 2222, groupId: 10);

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {
            "applicationInfoListResponse": [
              {
                "applicationRefNo": "APP-1",
                "branch": "Main Branch",
              }
            ],
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result =
          await requestRepository.applicationTypeReconsiderationData();

      expect(result, isA<List<ApplicationDetails>>());
      expect(result.length, 1);
    });

    test("should return empty list when applicationInfoListResponse is null",
        () async {
      Globals.request = buildRequest(customerRimNo: 2222, groupId: 10);

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {
            "applicationInfoListResponse": null,
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result =
          await requestRepository.applicationTypeReconsiderationData();

      expect(result, isA<List<ApplicationDetails>>());
      expect(result, isEmpty);
    });

    test("should throw exception when API returns error", () async {
      final mockResponse = AppResponse(
        message: "API Error",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.applicationTypeReconsiderationData(),
        throwsExceptionWithMessage("API Error"),
      );
    });
  });

  group("getCustomerRequestInfo", () {
    test("should successfully get customer request info", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "status": {
            "statusCode": 0,
            "statusDescription": "Customer request info retrieved",
          },
          "responseData": [
            {
              "id": 1,
              "customerName": "Test Customer",
              "rimNo": 50,
              "groupId": null,
              "requestType": "CREDIT",
              "status": "ACTIVE",
            }
          ],
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getCustomerRequestInfo();

      expect(result, isA<List<Response>?>());
      expect(result, hasLength(1));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.getCustomerRequestInfo),
      );

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["role"], equals("ADMIN"));
      expect(requestBody["requestData"]["rimNo"], equals(50));
      expect(requestBody["requestData"]["groupId"], isNull);
    });

    test("should return empty list when responseData is empty", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "status": {
            "statusCode": 0,
            "statusDescription": "No records",
          },
          "responseData": [],
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getCustomerRequestInfo();

      expect(result, isA<List<Response>?>());
      expect(result, isEmpty);
    });

    test("should throw exception when API returns error", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Request Info Error",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getCustomerRequestInfo(),
        throwsExceptionWithMessage("Request Info Error"),
      );
    });
  });

  group("getPipelineRequestDetails", () {
    test("should return empty list on success with empty responseData",
        () async {
      Globals.request = buildRequest();

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Pipeline retrieved"},
          },
          "responseData": [],
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getPipelineRequestDetails();

      expect(result, isA<List<Response>?>());
      expect(result, isEmpty);
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.getPipelineRequestDetails),
      );

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["requestData"]["groupId"], equals(42));
      expect(requestBody["requestData"]["rimNo"], equals(777));
    });

    test("should throw exception when API fails", () async {
      final mockResponse = AppResponse(
        message: "Error fetching pipeline details",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getPipelineRequestDetails(),
        throwsExceptionWithMessage("Error fetching pipeline details"),
      );
    });
  });

  group("getSecurityDeferralDetails", () {
    test("should successfully get security deferral details", () async {
      Globals.request = buildRequest(
        applicationRefNo: "APP123",
        customerRimNo: 1001,
        groupId: 125,
      );

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {
            "securityDeferralList": [],
            "covenantDeferralList": [],
            "conditionDeferralList": [],
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getSecurityDeferralDetails();

      expect(result, isA<SecurityPerfection>());
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.getSecurityDeferral),
      );

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["requestData"]["rimNo"], equals(1001));
      expect(requestBody["requestData"]["groupId"], equals(125));
      expect(requestBody["requestData"]["appRefNo"], equals("APP123"));
    });

    test("should throw exception when response.code != 200", () async {
      Globals.request = buildRequest(
        applicationRefNo: "APP123",
        customerRimNo: 1001,
      );

      final mockResponse = AppResponse(
        message: "Security Error",
        body: {},
        code: 400,
        status: ResponseStatus.error,
      );

      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getSecurityDeferralDetails(),
        throwsExceptionWithMessage("Security Error"),
      );
    });

    test("should throw TypeError when responseData is null in success response",
        () async {
      Globals.request = buildRequest(
        applicationRefNo: "APP123",
        customerRimNo: 1001,
      );

      final mockResponse = AppResponse(
        message: "Security Error",
        body: {
          "status": {
            "statusCode": 1,
            "statusDescription": "Security data not found",
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getSecurityDeferralDetails(),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group("saveSecurityDeferralDetails", () {
    test("should return message on success", () async {
      final mockResponse = AppResponse(
        message: "Saved Successfully",
        body: {},
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.saveSecurityDeferralDetails(
        securityDeferralList: [
          {"securityNo": "SEC001"},
        ],
        covenantDeferralList: [
          {"covenantConditionNo": "COV001"},
        ],
        conditionDeferralList: [
          {"covenantConditionNo": "CON001"},
        ],
      );

      expect(result, equals("Saved Successfully"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.saveSecurityDeferralDetails),
      );
    });

    test("should throw response.message when save fails", () async {
      final mockResponse = AppResponse(
        message: "Save Failed",
        body: {},
        code: 200,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.saveSecurityDeferralDetails(
          securityDeferralList: [],
          covenantDeferralList: [],
          conditionDeferralList: [],
        ),
        throwsExceptionWithMessage("Save Failed"),
      );
    });
  });

  group("getReviewCommentsResponse", () {
    test("should return null when commentList is null", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {
              "statusCode": "0",
              "statusDescription": "Comments fetched",
            },
          },
          "responseData": {
            "commentList": null,
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getReviewCommentsResponse();
      expect(result, isNull);
    });

    test("should return null when commentList is empty", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {
              "statusCode": "0",
              "statusDescription": "Comments fetched",
            },
          },
          "responseData": {
            "commentList": [],
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getReviewCommentsResponse();
      expect(result, isNull);
    });

    test("should return latest comment when commentList has data", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {
              "statusCode": "0",
              "statusDescription": "Comments fetched",
            },
          },
          "responseData": {
            "commentList": [
              {
                "comment": "Older comment",
                "createdDate": "2024-01-01T10:00:00Z",
                "categoryId": 1,
              },
              {
                "comment": "Latest comment",
                "createdDate": "2024-02-01T10:00:00Z",
                "categoryId": 1,
              },
            ],
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getReviewCommentsResponse();

      expect(result, isA<Comment?>());
      expect(result?.strategyComment, equals("Latest comment"));
    });

    test("should return null when an exception occurs", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Failure",
        body: {
          "baseResponse": {
            "status": {
              "statusCode": "1",
              "statusDescription": "Error",
            },
          },
        },
        code: 500,
        status: ResponseStatus.error,
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getReviewCommentsResponse();
      expect(result, isNull);
    });
  });

  group("updateTerminateStatus", () {
    test("should successfully update terminate status", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Status updated successfully"},
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.updateTerminateStatus(
        "5",
        "Termination due to incomplete documentation",
      );

      expect(result, equals("Status updated successfully"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.updateTerminatedStatus),
      );

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["requestData"]["appRefNo"], equals("APP123"));
      expect(requestBody["requestData"]["reason"], equals(5));
      expect(
        requestBody["requestData"]["remarks"],
        equals("Termination due to incomplete documentation"),
      );
    });

    test("should use 0 when reasonId is null", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Status updated successfully"},
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.updateTerminateStatus(
        null,
        "No reason id",
      );

      expect(result, equals("Status updated successfully"));

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["requestData"]["reason"], equals(0));
    });

    test("should throw exception when API returns error", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Terminate update failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );

      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.updateTerminateStatus("1", "failed"),
        throwsExceptionWithMessage("Terminate update failed"),
      );
    });
  });

  group("getCertificateDetails", () {
    test("should successfully get certificate details", () async {
      Globals.user = buildUser();

      const appRefNo = "APP123";
      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "status": {
            "statusCode": 0,
            "statusDescription": "Certificate details retrieved",
          },
          "responseData": {
            "certificationsList": [
              {
                "certificationDataList": [
                  {
                    "id": 1,
                    "certificationType": "ISO9001",
                    "certificationDate": "2024-01-15",
                    "expiryDate": "2025-01-15",
                    "issuingAuthority": "ISO",
                    "status": "ACTIVE",
                  }
                ],
              },
            ],
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getCertificateDetails(appRefNo);

      expect(result, isA<List<CertificationData>>());
      expect(result, hasLength(1));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.getCertificateDetails),
      );

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["appRefNo"], equals(appRefNo));
      expect(requestBody["requestData"]["appRefNo"], equals(appRefNo));
      expect(requestBody["requestData"]["role"], equals("RM"));
    });

    test("should handle empty certificate details", () async {
      Globals.user = buildUser();

      const appRefNo = "APP123";
      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "status": {
            "statusCode": 0,
            "statusDescription": "No certificate details found",
          },
          "responseData": {"certificationsList": []},
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getCertificateDetails(appRefNo);

      expect(result, isEmpty);
    });

    test("should throw exception when API returns error", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Certificate details error",
        body: {
          "status": {"statusCode": 1},
        },
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getCertificateDetails("APP123"),
        throwsExceptionWithMessage("Certificate details error"),
      );
    });
  });

  group("saveCertificateDetails", () {
    test("should successfully save certificate details", () async {
      Globals.user = buildUser();

      const appRefNo = "APP123";
      final certificationDataList = [
        CertificationData(
          certificateInformation: Reference(),
          appCertificationId: 1,
          certificationCategory: 1,
          remarks: "Active certification",
        ),
        CertificationData(
          certificateInformation: Reference(),
          appCertificationId: 2,
          certificationCategory: 2,
          remarks: "Another certification",
        ),
      ];

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {
            "message": "Certificate details saved successfully",
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.saveCertificateDetails(
        appRefNo,
        certificationDataList,
      );

      expect(result, equals("Certificate details saved successfully"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.saveApplicationStrategyDetails),
      );

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["roleID"], equals(1));
      expect(requestBody["role"], equals("Administrator"));
      expect(requestBody["appRefNo"], equals(appRefNo));
      expect(requestBody["requestData"]["certificationsList"], hasLength(1));
      expect(
        requestBody["requestData"]["certificationsList"][0]["appRefNo"],
        equals(appRefNo),
      );
      expect(
        requestBody["requestData"]["certificationsList"][0]["role"],
        equals("Administrator"),
      );
      expect(
        requestBody["requestData"]["certificationsList"][0]
            ["certificationDataList"],
        hasLength(2),
      );
    });

    test("should handle null certification data list", () async {
      Globals.user = buildUser(roleName: "Admin");

      const appRefNo = "APP123";
      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {"message": "Empty certificate details processed"},
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result =
          await requestRepository.saveCertificateDetails(appRefNo, null);

      expect(result, equals("Empty certificate details processed"));

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(
        requestBody["requestData"]["certificationsList"][0]
            ["certificationDataList"],
        isEmpty,
      );
    });

    test("should throw when save fails", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Save certificate failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.saveCertificateDetails("APP123", []),
        throwsExceptionWithMessage("Save certificate failed"),
      );
    });
  });

  group("saveConditionDetails", () {
    test("should successfully save condition details", () async {
      Globals.user = buildUser();

      final covenantCondition = CovenantCondition(
        covenantConditionId: 1,
        description: "Test condition",
        isCovenant: true,
        mode: "CREATE",
      );

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Condition saved successfully"},
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result =
          await requestRepository.saveConditionDetails(covenantCondition);

      expect(result, equals("Condition saved successfully"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.saveConditions),
      );
      expect(mockAPIManager.callLog.first["method"], equals("POST"));
    });

    test("should save isCovenant as 0 when false", () async {
      final covenantCondition = CovenantCondition(
        covenantConditionId: 2,
        isCovenant: false,
      );

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Condition saved successfully"},
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      await requestRepository.saveConditionDetails(covenantCondition);

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["requestData"]["isCovenant"], equals(0));
    });

    test("should throw exception when API returns error status", () async {
      final covenantCondition = CovenantCondition(covenantConditionId: 1);

      final mockResponse = AppResponse(
        message: "Save failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.saveConditionDetails(covenantCondition),
        throwsExceptionWithMessage("Save failed"),
      );
    });
  });

  group("getSICcodeReviewData", () {
    test("should successfully get SIC code review data", () async {
      Globals.request = buildRequest(
        applicationRefNo: "APP123",
        customerRimNo: 114166,
      );

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": [
            {
              "rimNo": 114166,
              "customerName": "Test Customer",
              "existingSicCode": "99106",
              "proposedSicCode": "99107",
              "remarks": "Updated SIC code",
            }
          ],
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getSICcodeReviewData();

      expect(result, isA<List<SicCodeReview>>());
      expect(result, hasLength(1));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.getSICCodeReview),
      );
    });

    test("should return empty list when responseData is null", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Success",
        body: {"responseData": null},
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getSICcodeReviewData();

      expect(result, isEmpty);
    });

    test("should throw exception when API returns error", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "SIC code data not found",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getSICcodeReviewData(),
        throwsException,
      );
    });
  });

  group("saveSICcodeReview", () {
    test("should successfully save SIC code review", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final sicCodeReview = [
        SicCodeReview(
          rimNo: 114166,
          proposedSicCode: "99107",
        ),
      ];

      final mockResponse = AppResponse(
        message: "SIC code saved successfully",
        body: {"responseData": "Success"},
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.saveSICcodeReview(sicCodeReview);

      expect(result, equals("SIC code saved successfully"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.saveSICcodeReview),
      );
    });

    test("should return null when sicCodeReview is null", () async {
      final result = await requestRepository.saveSICcodeReview(null);

      expect(result, isNull);
      expect(mockAPIManager.callLog, isEmpty);
    });

    test("should return null when sicCodeReview is empty", () async {
      final result = await requestRepository.saveSICcodeReview([]);

      expect(result, isNull);
      expect(mockAPIManager.callLog, isEmpty);
    });

    test("should throw exception when API returns error", () async {
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final sicCodeReview = [
        SicCodeReview(rimNo: 114166, proposedSicCode: "99107"),
      ];

      final mockResponse = AppResponse(
        message: "Save failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.saveSICcodeReview(sicCodeReview),
        throwsExceptionWithMessage("Save failed"),
      );
    });
  });

  group("getSecurityDetails", () {
    test("should throw response.message when API returns error for edit flow",
        () async {
      final mockResponse = AppResponse(
        message: "Bad request",
        body: {
          "status": {"statusCode": 99, "statusDescription": "Err"},
        },
        code: 400,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () => requestRepository.getSecurityDetails(
          selectedSecurity: Security(
            securityId: 10,
            securityNumber: "SEC-1",
            securityProvidedRim: "888",
            securityType: Reference(id: 1),
          ),
          countries: [],
        ),
        throwsExceptionWithMessage("Bad request"),
      );

      expect(
        mockAPIManager.callLog.single["endpoint"],
        equals(APIEndpoints.getSecurityDetails),
      );

      final requestBody = mockAPIManager.callLog.single["body"];
      expect(requestBody["requestData"]["securityId"], equals(10));
      expect(requestBody["requestData"]["groupId"], isNull);
    });

    test(
        "should construct create "
        "flow request with "
        "groupId when selectedSecurity is null", () async {
      Globals.request = buildRequest(
        applicationRefNo: "APP123",
      );

      final mockResponse = AppResponse(
        message: "Create flow failed",
        body: {},
        code: 400,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () => requestRepository.getSecurityDetails(
          countries: <Country>[],
        ),
        throwsExceptionWithMessage("Create flow failed"),
      );

      final requestBody = mockAPIManager.callLog.single["body"];
      expect(requestBody["requestData"]["groupId"], equals(42));
      expect(requestBody["requestData"]["appRefNo"], isNull);
      expect(requestBody["requestData"]["rimNo"], equals(777));
    });
  });

  group("saveGroupFacilitiesWithCbd", () {
    test("should successfully save group facilities with CBD", () async {
      Globals.user = buildUser();

      const appRefNo = "APP123";
      const strategyCommentsType = 1;
      const comments = "Group facilities comments";

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {"message": "Group facilities saved successfully"},
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.saveGroupFacilitiesWithCbd(
        appRefNo,
        strategyCommentsType,
        comments,
      );

      expect(result, equals("Group facilities saved successfully"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.saveApplicationStrategyDetails),
      );

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["appRefNo"], equals(appRefNo));
      expect(requestBody["requestData"]["appRefNo"], equals(appRefNo));
      expect(
        requestBody["requestData"]["strategyCommentsType"],
        equals(strategyCommentsType),
      );
      expect(requestBody["requestData"]["commentList"], hasLength(1));
      expect(
        requestBody["requestData"]["commentList"][0]["strategyComment"],
        equals(comments),
      );
    });

    test("should throw exception when API returns error", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Group facility save failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.saveGroupFacilitiesWithCbd(
          "APP123",
          1,
          "comment",
        ),
        throwsExceptionWithMessage("Group facility save failed"),
      );
    });
  });

  group("getFacilitiesOtherBanks", () {
    test("should successfully get facilities with other banks", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {
            "id": 1,
            "totalFacilities": 5,
            "totalAmount": 25000000.0,
            "banks": ["Bank A", "Bank B"],
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getFacilitiesOtherBanks();

      expect(result, isA<FacilitiesOtherBanks>());
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.getFacilityWithOtherBank),
      );
      expect(mockAPIManager.callLog.first["method"], equals("POST"));

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["roleID"], equals(1));
      expect(requestBody["role"], equals("Administrator"));
      expect(requestBody["pageId"], equals(21));
    });

    test("should throw when API returns error", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Facilities other bank error",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );

      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getFacilitiesOtherBanks(),
        throwsExceptionWithMessage("Facilities other bank error"),
      );
    });
  });

  // Method not in use
  // group("getFacilitiesCentralRiskBureau", () {
  //   test("should successfully get facilities central risk bureau", () async {
  //     Globals.user = buildUser();

  //     final mockResponse = AppResponse(
  //       message: "Success",
  //       body: {
  //         "responseData": {
  //           "id": 1,
  //           "riskRating": "A",
  //           "creditScore": 750,
  //           "lastUpdated": "2024-01-15",
  //         },
  //       },
  //       code: 200,
  //       status: ResponseStatus.success,
  //     );
  //     mockAPIManager.setMockResponse(mockResponse);

  //     final result = await requestRepository.getFacilitiesCentralRiskBureau();

  //     expect(result, isA<RiskBureau>());
  //     expect(
  //       mockAPIManager.callLog.first["endpoint"],
  //       equals(APIEndpoints.getShareofWalletDetails),
  //     );
  //     expect(mockAPIManager.callLog.first["method"], equals("POST"));

  //     final requestBody = mockAPIManager.callLog.first["body"];
  //     expect(requestBody["roleID"], equals(1));
  //     expect(requestBody["role"], equals("Administrator"));
  //     expect(requestBody["pageId"], equals(21));
  //   });

  //   test("should throw when API returns error", () async {
  //     Globals.user = buildUser();

  //     final mockResponse = AppResponse(
  //       message: "Risk bureau error",
  //       body: {},
  //       code: 500,
  //       status: ResponseStatus.error,
  //     );

  //     mockAPIManager.setMockResponse(mockResponse);

  //     expect(
  //       () async => requestRepository.getFacilitiesCentralRiskBureau(),
  //       throwsExceptionWithMessage("Risk bureau error"),
  //     );
  //   });
  // });

  group("saveFacilitiesWithOtherBank", () {
    test("should successfully save facilities with other bank", () async {
      Globals.user = buildUser();

      final facilitiesListJson = [
        {
          "bankName": "Bank A",
          "facilityType": "Term Loan",
          "amount": 5000000.0,
          "currency": "AED",
        },
        {
          "bankName": "Bank B",
          "facilityType": "Working Capital",
          "amount": 3000000.0,
          "currency": "USD",
        }
      ];

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {
            "message": "Facilities with other banks saved successfully",
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository
          .saveFacilitiesWithOtherBank(facilitiesListJson);

      expect(result, equals("Facilities with other banks saved successfully"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.saveFacilityWithOtherBank),
      );
      expect(mockAPIManager.callLog.first["method"], equals("POST"));

      final requestBody = mockAPIManager.callLog.first["body"];
      expect(requestBody["roleID"], equals(1));
      expect(requestBody["role"], equals("Administrator"));
      expect(requestBody["pageId"], equals(21));
      expect(
        requestBody["requestData"]["facilitiesList"],
        equals(facilitiesListJson),
      );
    });

    test("should throw when API returns error", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Save facilities failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.saveFacilitiesWithOtherBank([]),
        throwsExceptionWithMessage("Save facilities failed"),
      );
    });
  });

  group("getApplicationBorrowers", () {
    test("should successfully get application borrowers", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": [
            {
              "id": 1,
              "customerName": "Primary Borrower",
              "rimNo": 1001,
              "isPrimary": true,
              "guaranteeAmount": 5000000.0,
            },
            {
              "id": 2,
              "customerName": "Co-Borrower",
              "rimNo": 1002,
              "isPrimary": false,
              "guaranteeAmount": 2000000.0,
            }
          ],
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getApplicationBorrowers();

      expect(result, isA<List<Customer>>());
      expect(result, hasLength(2));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.getApplicationBorrowers),
      );
      expect(mockAPIManager.callLog.first["method"], equals("GET"));

      final requestParams = mockAPIManager.callLog.first["queryParams"];
      expect(requestParams["roleID"], equals(1));
      expect(requestParams["role"], equals("Administrator"));
      expect(requestParams["pageId"], equals(3));
    });

    test("should throw exception when API returns error", () async {
      Globals.user = buildUser();

      final mockResponse = AppResponse(
        message: "Borrowers fetch failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getApplicationBorrowers(),
        throwsExceptionWithMessage("Borrowers fetch failed"),
      );
    });
  });

  group("getCurrencyCodes", () {
    test("should return mapped currency codes when responseData is list",
        () async {
      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": [
            {"isoCode": "AED", "description": "UAE Dirham"},
            {"isoCode": "USD", "description": "US Dollar"},
            {"isoCode": "  ", "description": "Invalid"},
          ],
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getCurrencyCodes();

      expect(result, isA<List<Reference>>());
      expect(result.length, equals(2));
      expect(result[0].name, equals("AED"));
      expect(result[0].reference4, equals("UAE Dirham"));
      expect(result[1].name, equals("USD"));
      expect(result[1].reference4, equals("US Dollar"));
    });

    test("should return empty list when responseData is not a list", () async {
      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {"isoCode": "AED"},
        },
        code: 200,
        status: ResponseStatus.success,
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getCurrencyCodes();
      expect(result, isEmpty);
    });

    test("should throw exception when API status is error", () async {
      final mockResponse = AppResponse(
        message: "Currency fetch failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );

      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.getCurrencyCodes(),
        throwsExceptionWithMessage("Currency fetch failed"),
      );
    });
  });

  group("saveRemarkStrategyData", () {
    test("should successfully save remark strategy data", () async {
      Globals.user = buildUser();
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final selectedCustomer = Customer(
        customerRimNo: 1001,
        customerName: "Test Customer",
      );

      final comment = Comment(
        strategyComment: "Test strategy comment",
        strategyCommentTypeId: 1,
      );

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Strategy saved successfully"},
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.saveRemarkStrategyData(
        selectedCustomer,
        comment,
      );

      expect(result, equals("Strategy saved successfully"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.saveRelationshipStrategyDetailsByRim),
      );
    });

    test("should throw exception when API returns error", () async {
      Globals.user = buildUser(roleName: "Admin");
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final selectedCustomer = Customer(customerRimNo: 1001);
      final comment = Comment(strategyCommentTypeId: 1);

      final mockResponse = AppResponse(
        message: "Save failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async =>
            requestRepository.saveRemarkStrategyData(selectedCustomer, comment),
        throwsExceptionWithMessage("Save failed"),
      );
    });
  });

  group("getRemarkStrategyData", () {
    test("should successfully get remark strategy data", () async {
      Globals.user = buildUser();
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final selectedCustomer = Customer(
        customerRimNo: 1001,
        customerName: "Test Customer",
      );

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {
            "relationshipStrategyDataForRims": [
              {
                "rimNo": 1001,
                "customerName": "Test Customer",
                "commentList": [
                  {
                    "categoryId": 1,
                    "strategyComment": "Test comment",
                    "strategyCommentTypeId": 1,
                  }
                ],
              }
            ],
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getRemarkStrategyData(
        selectedCustomer,
        1,
        1,
      );

      expect(result, isA<Comment>());
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.getRelationshipStrategyDetailsByRim),
      );
    });

    test("should return empty comment when no matching data found", () async {
      Globals.user = buildUser(roleName: "Admin");
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final selectedCustomer = Customer(customerRimNo: 1001);

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {"relationshipStrategyDataForRims": []},
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getRemarkStrategyData(
        selectedCustomer,
        1,
        1,
      );

      expect(result, isA<Comment>());
    });

    test(
        "should return empty comment when rim "
        "matches but category does not match", () async {
      Globals.user = buildUser();
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final selectedCustomer = Customer(customerRimNo: 1001);

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": {
            "relationshipStrategyDataForRims": [
              {
                "rimNo": 1001,
                "commentList": [
                  {
                    "categoryId": 2,
                    "strategyComment": "Another category",
                  }
                ],
              }
            ],
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result =
          await requestRepository.getRemarkStrategyData(selectedCustomer, 1, 1);

      expect(result, isA<Comment>());
    });
  });

  group("getFeeStructureData", () {
    test("should successfully get fee structure data", () async {
      Globals.user = buildUser();
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "responseData": [
            {
              "id": "1",
              "feeType": "Processing Fee",
              "amountOrPercentage": "1000",
              "feeComment": "Standard processing fee",
              "rimNo": 1001,
              "appRefNo": "APP123",
            },
            {
              "id": "2",
              "feeType": "Administrative Fee",
              "amountOrPercentage": "500",
              "feeComment": "Administrative charges",
              "rimNo": 1001,
              "appRefNo": "APP123",
            }
          ],
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getFeeStructureData(12);

      expect(result, isA<List<FeeStructure>>());
      expect(result, hasLength(2));
      expect(result[0].feeType, equals("Processing Fee"));
      expect(result[1].feeType, equals("Administrative Fee"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.getFeeStructureData),
      );
    });

    test("should return empty list when no fee data available", () async {
      Globals.user = buildUser(roleName: "Admin");
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Success",
        body: {"responseData": []},
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getFeeStructureData(123);

      expect(result, isA<List<FeeStructure>>());
      expect(result, isEmpty);
    });

    test("should return empty list when response status is error", () async {
      Globals.user = buildUser();
      Globals.request = buildRequest(applicationRefNo: "APP123");

      final mockResponse = AppResponse(
        message: "Fee fetch failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.getFeeStructureData(123);

      expect(result, isA<List<FeeStructure>>());
      expect(result, isEmpty);
    });
  });

  group("saveFeeStructure", () {
    test("should successfully save fee structure", () async {
      Globals.user = buildUser();

      final feeStructures = [
        FeeStructure(
          id: "1",
          feeType: "Processing Fee",
          amount: 1000,
          comments: "Test comment",
        ),
        FeeStructure(
          id: "2",
          feeType: "Administrative Fee",
          amount: 500,
          comments: "Admin comment",
        ),
      ];

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Fee structure saved successfully"},
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await requestRepository.saveFeeStructure(feeStructures);

      expect(result, equals("Fee structure saved successfully"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.saveFeeStructureData),
      );
      expect(mockAPIManager.callLog.first["method"], equals("POST"));
    });

    test("should throw exception when save fails", () async {
      Globals.user = buildUser(roleName: "Admin");

      final feeStructures = [
        FeeStructure(id: "1", feeType: "Processing Fee", amount: 1000),
      ];

      final mockResponse = AppResponse(
        message: "Save failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.saveFeeStructure(feeStructures),
        throwsExceptionWithMessage("Save failed"),
      );
    });
  });

  group("deleteFeeStructureData", () {
    test("should successfully delete fee structure data", () async {
      Globals.user = buildUser();

      final feeStructure = FeeStructure(
        id: "1",
        feeType: "Processing Fee",
        amount: 1000,
        comments: "To be deleted",
      );

      final mockResponse = AppResponse(
        message: "Success",
        body: {
          "baseResponse": {
            "status": {
              "statusDescription": "Fee structure deleted successfully",
            },
          },
        },
        code: 200,
        status: ResponseStatus.success,
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result =
          await requestRepository.deleteFeeStructureData(feeStructure);

      expect(result, equals("Fee structure deleted successfully"));
      expect(
        mockAPIManager.callLog.first["endpoint"],
        equals(APIEndpoints.deleteFeeStructureData),
      );
      expect(mockAPIManager.callLog.first["method"], equals("DELETE"));
    });

    test("should throw exception when delete fails", () async {
      Globals.user = buildUser(roleName: "Admin");

      final feeStructure = FeeStructure(id: "1", feeType: "Processing Fee");

      final mockResponse = AppResponse(
        message: "Delete failed",
        body: {},
        code: 500,
        status: ResponseStatus.error,
      );
      mockAPIManager.setMockResponse(mockResponse);

      expect(
        () async => requestRepository.deleteFeeStructureData(feeStructure),
        throwsExceptionWithMessage("Delete failed"),
      );
    });
  });
}
